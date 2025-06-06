//==-- CIRGenFunctionInfo.h - Representation of fn argument/return types ---==//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// Defines CIRGenFunctionInfo and associated types used in representing the
// CIR source types and ABI-coerced types for function arguments and
// return values.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_CLANG_CIR_CIRGENFUNCTIONINFO_H
#define LLVM_CLANG_CIR_CIRGENFUNCTIONINFO_H

#include "clang/AST/CanonicalType.h"
#include "clang/CIR/Dialect/IR/CIRTypes.h"

#include "llvm/ADT/FoldingSet.h"
#include "llvm/Support/TrailingObjects.h"

namespace clang::CIRGen {

/// A class for recording the number of arguments that a function signature
/// requires.
class RequiredArgs {
  /// The number of required arguments, or ~0 if the signature does not permit
  /// optional arguments.
  unsigned NumRequired;

public:
  enum All_t { All };

  RequiredArgs(All_t _) : NumRequired(~0U) {}
  explicit RequiredArgs(unsigned n) : NumRequired(n) { assert(n != ~0U); }

  unsigned getOpaqueData() const { return NumRequired; }

  bool allowsOptionalArgs() const { return NumRequired != ~0U; }

  /// Compute the arguments required by the given formal prototype, given that
  /// there may be some additional, non-formal arguments in play.
  ///
  /// If FD is not null, this will consider pass_object_size params in FD.
  static RequiredArgs
  forPrototypePlus(const clang::FunctionProtoType *prototype,
                   unsigned additional) {
    if (!prototype->isVariadic())
      return All;

    if (prototype->hasExtParameterInfos())
      additional += llvm::count_if(
          prototype->getExtParameterInfos(),
          [](const clang::FunctionProtoType::ExtParameterInfo &ExtInfo) {
            return ExtInfo.hasPassObjectSize();
          });

    return RequiredArgs(prototype->getNumParams() + additional);
  }

  static RequiredArgs
  forPrototypePlus(clang::CanQual<clang::FunctionProtoType> prototype,
                   unsigned additional) {
    return forPrototypePlus(prototype.getTypePtr(), additional);
  }

  unsigned getNumRequiredArgs() const {
    assert(allowsOptionalArgs());
    return NumRequired;
  }
};

class CIRGenFunctionInfo final
    : public llvm::FoldingSetNode,
      private llvm::TrailingObjects<
          CIRGenFunctionInfo, clang::CanQualType,
          clang::FunctionProtoType::ExtParameterInfo> {

  typedef clang::FunctionProtoType::ExtParameterInfo ExtParameterInfo;

  /// The cir::CallingConv to use for this function (as specified by the user).
  cir::CallingConv CallingConvention : 8;

  /// The cir::CallingConv to actually use for this function, which may depend
  /// on the ABI.
  cir::CallingConv EffectiveCallingConvention : 8;

  /// The clang::CallingConv that this was originally created with.
  unsigned ASTCallingConvention : 6;

  /// Whether this is an instance method.
  unsigned InstanceMethod : 1;

  /// Whether this is a chain call.
  unsigned ChainCall : 1;

  /// Whether this function is a CMSE nonsecure call
  unsigned CmseNSCall : 1;

  /// Whether this function is noreturn.
  unsigned NoReturn : 1;

  /// Whether this function is returns-retained.
  unsigned ReturnsRetained : 1;

  /// Whether this function saved caller registers.
  unsigned NoCallerSavedRegs : 1;

  /// How many arguments to pass inreg.
  unsigned HasRegParm : 1;
  unsigned RegParm : 3;

  /// Whether this function has nocf_check attribute.
  unsigned NoCfCheck : 1;

  RequiredArgs Required;

  /// The struct representing all arguments passed in memory. Only used when
  /// passing non-trivial types with inalloca. Not part of the profile.
  /// TODO: think about modeling this properly, this is just a dumb subsitution
  /// for now since we arent supporting anything other than arguments in
  /// registers atm
  cir::RecordType *ArgRecord;
  unsigned ArgRecordAlign : 31;
  unsigned HasExtParameterInfos : 1;

  unsigned NumArgs;

  clang::CanQualType *getArgTypes() {
    return getTrailingObjects<clang::CanQualType>();
  }

  const clang::CanQualType *getArgTypes() const {
    return getTrailingObjects<clang::CanQualType>();
  }

  ExtParameterInfo *getExtParameterInfosBuffer() {
    return getTrailingObjects<ExtParameterInfo>();
  }

  const ExtParameterInfo *getExtParameterInfosBuffer() const {
    return getTrailingObjects<ExtParameterInfo>();
  }

  CIRGenFunctionInfo() : Required(RequiredArgs::All) {}

public:
  static CIRGenFunctionInfo *create(cir::CallingConv cirCC, bool instanceMethod,
                                    bool chainCall,
                                    const clang::FunctionType::ExtInfo &extInfo,
                                    llvm::ArrayRef<ExtParameterInfo> paramInfos,
                                    clang::CanQualType resultType,
                                    llvm::ArrayRef<clang::CanQualType> argTypes,
                                    RequiredArgs required);
  void operator delete(void *p) { ::operator delete(p); }

  // Friending class TrailingObjects is apparantly not good enough for MSVC, so
  // these have to be public.
  friend class TrailingObjects;
  size_t numTrailingObjects(OverloadToken<clang::CanQualType>) const {
    return NumArgs + 1;
  }
  size_t numTrailingObjects(OverloadToken<ExtParameterInfo>) const {
    return (HasExtParameterInfos ? NumArgs : 0);
  }

  using const_arg_iterator = const clang::CanQualType *;
  using arg_iterator = clang::CanQualType *;

  static void Profile(llvm::FoldingSetNodeID &ID, bool InstanceMethod,
                      bool ChainCall, const clang::FunctionType::ExtInfo &info,
                      llvm::ArrayRef<ExtParameterInfo> paramInfos,
                      RequiredArgs required, clang::CanQualType resultType,
                      llvm::ArrayRef<clang::CanQualType> argTypes) {
    ID.AddInteger(info.getCC());
    ID.AddBoolean(InstanceMethod);
    ID.AddBoolean(info.getNoReturn());
    ID.AddBoolean(info.getProducesResult());
    ID.AddBoolean(info.getNoCallerSavedRegs());
    ID.AddBoolean(info.getHasRegParm());
    ID.AddBoolean(info.getRegParm());
    ID.AddBoolean(info.getNoCfCheck());
    ID.AddBoolean(info.getCmseNSCall());
    ID.AddBoolean(required.getOpaqueData());
    ID.AddBoolean(!paramInfos.empty());
    if (!paramInfos.empty()) {
      for (auto paramInfo : paramInfos)
        ID.AddInteger(paramInfo.getOpaqueValue());
    }
    resultType.Profile(ID);
    for (auto i : argTypes)
      i.Profile(ID);
  }

  /// getASTCallingConvention() - Return the AST-specified calling convention
  clang::CallingConv getASTCallingConvention() const {
    return clang::CallingConv(ASTCallingConvention);
  }

  void Profile(llvm::FoldingSetNodeID &ID) {
    ID.AddInteger(getASTCallingConvention());
    ID.AddBoolean(InstanceMethod);
    ID.AddBoolean(ChainCall);
    ID.AddBoolean(NoReturn);
    ID.AddBoolean(ReturnsRetained);
    ID.AddBoolean(NoCallerSavedRegs);
    ID.AddBoolean(HasRegParm);
    ID.AddBoolean(RegParm);
    ID.AddBoolean(NoCfCheck);
    ID.AddBoolean(CmseNSCall);
    ID.AddInteger(Required.getOpaqueData());
    ID.AddBoolean(HasExtParameterInfos);
    if (HasExtParameterInfos) {
      for (auto paramInfo : getExtParameterInfos())
        ID.AddInteger(paramInfo.getOpaqueValue());
    }
    getReturnType().Profile(ID);
    for (const auto &I : arguments())
      I.Profile(ID);
  }

  llvm::MutableArrayRef<clang::CanQualType> arguments() {
    return llvm::MutableArrayRef<clang::CanQualType>(arg_begin(), NumArgs);
  }
  llvm::ArrayRef<clang::CanQualType> arguments() const {
    return llvm::ArrayRef<clang::CanQualType>(arg_begin(), NumArgs);
  }

  llvm::MutableArrayRef<clang::CanQualType> requiredArguments() {
    return llvm::MutableArrayRef<clang::CanQualType>(arg_begin(),
                                                     getNumRequiredArgs());
  }
  llvm::ArrayRef<clang::CanQualType> requiredArguments() const {
    return llvm::ArrayRef<clang::CanQualType>(arg_begin(),
                                              getNumRequiredArgs());
  }

  const_arg_iterator arg_begin() const { return getArgTypes() + 1; }
  const_arg_iterator arg_end() const { return getArgTypes() + 1 + NumArgs; }
  arg_iterator arg_begin() { return getArgTypes() + 1; }
  arg_iterator arg_end() { return getArgTypes() + 1 + NumArgs; }

  unsigned arg_size() const { return NumArgs; }

  llvm::ArrayRef<ExtParameterInfo> getExtParameterInfos() const {
    if (!HasExtParameterInfos)
      return {};
    return llvm::ArrayRef(getExtParameterInfosBuffer(), NumArgs);
  }
  ExtParameterInfo getExtParameterInfo(unsigned argIndex) const {
    assert(argIndex <= NumArgs);
    if (!HasExtParameterInfos)
      return ExtParameterInfo();
    return getExtParameterInfos()[argIndex];
  }

  /// getCallingConvention - Return the user specified calling convention, which
  /// has been translated into a CIR CC.
  cir::CallingConv getCallingConvention() const { return CallingConvention; }

  /// getEffectiveCallingConvention - Return the actual calling convention to
  /// use, which may depend on the ABI.
  cir::CallingConv getEffectiveCallingConvention() const {
    return EffectiveCallingConvention;
  }

  clang::CanQualType getReturnType() const { return getArgTypes()[0]; }

  bool isChainCall() const { return ChainCall; }

  bool isVariadic() const { return Required.allowsOptionalArgs(); }
  RequiredArgs getRequiredArgs() const { return Required; }
  unsigned getNumRequiredArgs() const {
    return isVariadic() ? getRequiredArgs().getNumRequiredArgs() : arg_size();
  }

  cir::RecordType *getArgRecord() const { return ArgRecord; }

  /// Return true if this function uses inalloca arguments.
  bool usesInAlloca() const { return ArgRecord; }
};

} // namespace clang::CIRGen

#endif
