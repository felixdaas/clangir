//===--- ABIInfoImpl.cpp - Encapsulate calling convention details ---------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file partially mimics clang/lib/CodeGen/ABIInfoImpl.cpp. The queries are
// adapted to operate on the CIR dialect, however.
//
//===----------------------------------------------------------------------===//

#include "ABIInfo.h"
#include "CIRCXXABI.h"
#include "LowerFunction.h"
#include "LowerFunctionInfo.h"
#include "clang/CIR/MissingFeatures.h"
#include "llvm/Support/ErrorHandling.h"

namespace cir {

bool classifyReturnType(const CIRCXXABI &CXXABI, LowerFunctionInfo &FI,
                        const ABIInfo &Info) {
  mlir::Type Ty = FI.getReturnType();

  if (const auto RT = mlir::dyn_cast<RecordType>(Ty)) {
    cir_cconv_assert(!cir::MissingFeatures::isCXXRecordDecl());
  }

  return CXXABI.classifyReturnType(FI);
}

bool isAggregateTypeForABI(mlir::Type T) {
  cir_cconv_assert(!cir::MissingFeatures::functionMemberPointerType());
  return !LowerFunction::hasScalarEvaluationKind(T);
}

mlir::Value emitRoundPointerUpToAlignment(cir::CIRBaseBuilderTy &builder,
                                          mlir::Value ptr, unsigned alignment) {
  // OverflowArgArea = (OverflowArgArea + Align - 1) & -Align;
  mlir::Location loc = ptr.getLoc();
  mlir::Value roundUp = builder.createPtrStride(
      loc, builder.createPtrBitcast(ptr, builder.getUIntNTy(8)),
      builder.getUnsignedInt(loc, alignment - 1, /*width=*/32));
  auto dataLayout = mlir::DataLayout::closest(roundUp.getDefiningOp());
  return builder.create<cir::PtrMaskOp>(
      loc, roundUp.getType(), roundUp,
      builder.getSignedInt(loc, -(signed)alignment,
                           dataLayout.getTypeSizeInBits(roundUp.getType())));
}

mlir::Type useFirstFieldIfTransparentUnion(mlir::Type Ty) {
  if (auto RT = mlir::dyn_cast<RecordType>(Ty)) {
    if (RT.isUnion())
      cir_cconv_assert_or_abort(
          !cir::MissingFeatures::ABITransparentUnionHandling(), "NYI");
  }
  return Ty;
}

CIRCXXABI::RecordArgABI getRecordArgABI(const RecordType RT,
                                        CIRCXXABI &CXXABI) {
  if (cir::MissingFeatures::typeIsCXXRecordDecl()) {
    cir_cconv_unreachable("NYI");
  }
  return CXXABI.getRecordArgABI(RT);
}

CIRCXXABI::RecordArgABI getRecordArgABI(mlir::Type ty, CIRCXXABI &CXXABI) {
  auto st = mlir::dyn_cast<RecordType>(ty);
  if (!st)
    return CIRCXXABI::RAA_Default;
  return getRecordArgABI(st, CXXABI);
}

} // namespace cir
