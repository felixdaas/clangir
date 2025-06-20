// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -fclangir -Wno-unused-value -emit-cir %s -o %t.cir
// RUN: FileCheck --input-file=%t.cir %s

unsigned up0() {
  unsigned a = 1;
  return +a;
}

// CHECK: cir.func dso_local @_Z3up0v() -> !u32i
// CHECK: %[[#RET:]] = cir.alloca !u32i, !cir.ptr<!u32i>, ["__retval"]
// CHECK: %[[#A:]] = cir.alloca !u32i, !cir.ptr<!u32i>, ["a", init]
// CHECK: %[[#INPUT:]] = cir.load{{.*}} %[[#A]]
// CHECK: %[[#OUTPUT:]] = cir.unary(plus, %[[#INPUT]])
// CHECK: cir.store{{.*}} %[[#OUTPUT]], %[[#RET]]

unsigned um0() {
  unsigned a = 1;
  return -a;
}

// CHECK: cir.func dso_local @_Z3um0v() -> !u32i
// CHECK: %[[#RET:]] = cir.alloca !u32i, !cir.ptr<!u32i>, ["__retval"]
// CHECK: %[[#A:]] = cir.alloca !u32i, !cir.ptr<!u32i>, ["a", init]
// CHECK: %[[#INPUT:]] = cir.load{{.*}} %[[#A]]
// CHECK: %[[#OUTPUT:]] = cir.unary(minus, %[[#INPUT]])
// CHECK: cir.store{{.*}} %[[#OUTPUT]], %[[#RET]]

unsigned un0() {
  unsigned a = 1;
  return ~a; // a ^ -1 , not
}

// CHECK: cir.func dso_local @_Z3un0v() -> !u32i
// CHECK: %[[#RET:]] = cir.alloca !u32i, !cir.ptr<!u32i>, ["__retval"]
// CHECK: %[[#A:]] = cir.alloca !u32i, !cir.ptr<!u32i>, ["a", init]
// CHECK: %[[#INPUT:]] = cir.load{{.*}} %[[#A]]
// CHECK: %[[#OUTPUT:]] = cir.unary(not, %[[#INPUT]])
// CHECK: cir.store{{.*}} %[[#OUTPUT]], %[[#RET]]

int inc0() {
  int a = 1;
  ++a;
  return a;
}

// CHECK: cir.func dso_local @_Z4inc0v() -> !s32i
// CHECK: %[[#RET:]] = cir.alloca !s32i, !cir.ptr<!s32i>, ["__retval"]
// CHECK: %[[#A:]] = cir.alloca !s32i, !cir.ptr<!s32i>, ["a", init]
// CHECK: %[[#ATMP:]] = cir.const #cir.int<1> : !s32i
// CHECK: cir.store{{.*}} %[[#ATMP]], %[[#A]] : !s32i
// CHECK: %[[#INPUT:]] = cir.load{{.*}} %[[#A]]
// CHECK: %[[#INCREMENTED:]] = cir.unary(inc, %[[#INPUT]]) nsw
// CHECK: cir.store{{.*}} %[[#INCREMENTED]], %[[#A]]
// CHECK: %[[#A_TO_OUTPUT:]] = cir.load{{.*}} %[[#A]]
// CHECK: cir.store{{.*}} %[[#A_TO_OUTPUT]], %[[#RET]]
// CHECK: %[[#OUTPUT:]] = cir.load{{.*}} %[[#RET]]
// CHECK: cir.return %[[#OUTPUT]] : !s32i

int dec0() {
  int a = 1;
  --a;
  return a;
}

// CHECK: cir.func dso_local @_Z4dec0v() -> !s32i
// CHECK: %[[#RET:]] = cir.alloca !s32i, !cir.ptr<!s32i>, ["__retval"]
// CHECK: %[[#A:]] = cir.alloca !s32i, !cir.ptr<!s32i>, ["a", init]
// CHECK: %[[#ATMP:]] = cir.const #cir.int<1> : !s32i
// CHECK: cir.store{{.*}} %[[#ATMP]], %[[#A]] : !s32i
// CHECK: %[[#INPUT:]] = cir.load{{.*}} %[[#A]]
// CHECK: %[[#INCREMENTED:]] = cir.unary(dec, %[[#INPUT]]) nsw
// CHECK: cir.store{{.*}} %[[#INCREMENTED]], %[[#A]]
// CHECK: %[[#A_TO_OUTPUT:]] = cir.load{{.*}} %[[#A]]
// CHECK: cir.store{{.*}} %[[#A_TO_OUTPUT]], %[[#RET]]
// CHECK: %[[#OUTPUT:]] = cir.load{{.*}} %[[#RET]]
// CHECK: cir.return %[[#OUTPUT]] : !s32i


int inc1() {
  int a = 1;
  a++;
  return a;
}

// CHECK: cir.func dso_local @_Z4inc1v() -> !s32i
// CHECK: %[[#RET:]] = cir.alloca !s32i, !cir.ptr<!s32i>, ["__retval"]
// CHECK: %[[#A:]] = cir.alloca !s32i, !cir.ptr<!s32i>, ["a", init]
// CHECK: %[[#ATMP:]] = cir.const #cir.int<1> : !s32i
// CHECK: cir.store{{.*}} %[[#ATMP]], %[[#A]] : !s32i
// CHECK: %[[#INPUT:]] = cir.load{{.*}} %[[#A]]
// CHECK: %[[#INCREMENTED:]] = cir.unary(inc, %[[#INPUT]]) nsw
// CHECK: cir.store{{.*}} %[[#INCREMENTED]], %[[#A]]
// CHECK: %[[#A_TO_OUTPUT:]] = cir.load{{.*}} %[[#A]]
// CHECK: cir.store{{.*}} %[[#A_TO_OUTPUT]], %[[#RET]]
// CHECK: %[[#OUTPUT:]] = cir.load{{.*}} %[[#RET]]
// CHECK: cir.return %[[#OUTPUT]] : !s32i

int dec1() {
  int a = 1;
  a--;
  return a;
}

// CHECK: cir.func dso_local @_Z4dec1v() -> !s32i
// CHECK: %[[#RET:]] = cir.alloca !s32i, !cir.ptr<!s32i>, ["__retval"]
// CHECK: %[[#A:]] = cir.alloca !s32i, !cir.ptr<!s32i>, ["a", init]
// CHECK: %[[#ATMP:]] = cir.const #cir.int<1> : !s32i
// CHECK: cir.store{{.*}} %[[#ATMP]], %[[#A]] : !s32i
// CHECK: %[[#INPUT:]] = cir.load{{.*}} %[[#A]]
// CHECK: %[[#INCREMENTED:]] = cir.unary(dec, %[[#INPUT]]) nsw
// CHECK: cir.store{{.*}} %[[#INCREMENTED]], %[[#A]]
// CHECK: %[[#A_TO_OUTPUT:]] = cir.load{{.*}} %[[#A]]
// CHECK: cir.store{{.*}} %[[#A_TO_OUTPUT]], %[[#RET]]
// CHECK: %[[#OUTPUT:]] = cir.load{{.*}} %[[#RET]]
// CHECK: cir.return %[[#OUTPUT]] : !s32i

// Ensure the increment is performed after the assignment to b.
int inc2() {
  int a = 1;
  int b = a++;
  return b;
}

// CHECK: cir.func dso_local @_Z4inc2v() -> !s32i
// CHECK: %[[#RET:]] = cir.alloca !s32i, !cir.ptr<!s32i>, ["__retval"]
// CHECK: %[[#A:]] = cir.alloca !s32i, !cir.ptr<!s32i>, ["a", init]
// CHECK: %[[#B:]] = cir.alloca !s32i, !cir.ptr<!s32i>, ["b", init]
// CHECK: %[[#ATMP:]] = cir.const #cir.int<1> : !s32i
// CHECK: cir.store{{.*}} %[[#ATMP]], %[[#A]] : !s32i
// CHECK: %[[#ATOB:]] = cir.load{{.*}} %[[#A]]
// CHECK: %[[#INCREMENTED:]] = cir.unary(inc, %[[#ATOB]]) nsw
// CHECK: cir.store{{.*}} %[[#INCREMENTED]], %[[#A]]
// CHECK: cir.store{{.*}} %[[#ATOB]], %[[#B]]
// CHECK: %[[#B_TO_OUTPUT:]] = cir.load{{.*}} %[[#B]]
// CHECK: cir.store{{.*}} %[[#B_TO_OUTPUT]], %[[#RET]]
// CHECK: %[[#OUTPUT:]] = cir.load{{.*}} %[[#RET]]
// CHECK: cir.return %[[#OUTPUT]] : !s32i

int *inc_p(int *i) {
  --i;
  ++i;
  return i;
}

// CHECK: cir.func dso_local @_Z5inc_pPi(%arg0: !cir.ptr<!s32i>

// CHECK:   %[[#i_addr:]] = cir.alloca !cir.ptr<!s32i>, !cir.ptr<!cir.ptr<!s32i>>, ["i", init] {alignment = 8 : i64}
// CHECK:   %[[#i_dec:]] = cir.load{{.*}} %[[#i_addr]] : !cir.ptr<!cir.ptr<!s32i>>, !cir.ptr<!s32i>
// CHECK:   %[[#dec_const:]] = cir.const #cir.int<-1> : !s32i
// CHECK:   = cir.ptr_stride(%[[#i_dec]] : !cir.ptr<!s32i>, %[[#dec_const]] : !s32i), !cir.ptr<!s32i>

// CHECK:   %[[#i_inc:]] = cir.load{{.*}} %0 : !cir.ptr<!cir.ptr<!s32i>>, !cir.ptr<!s32i>
// CHECK:   %[[#inc_const:]] = cir.const #cir.int<1> : !s32i
// CHECK:   = cir.ptr_stride(%[[#i_inc]] : !cir.ptr<!s32i>, %[[#inc_const]] : !s32i), !cir.ptr<!s32i>

void floats(float f) {
// CHECK: cir.func dso_local @{{.+}}floats{{.+}}
  f = +f; // CHECK: %{{[0-9]+}} = cir.unary(plus, %{{[0-9]+}}) : !cir.float, !cir.float
  f = -f; // CHECK: %{{[0-9]+}} = cir.unary(minus, %{{[0-9]+}}) : !cir.float, !cir.float
  ++f; // CHECK: = cir.unary(inc, %{{[0-9]+}}) : !cir.float, !cir.float
  --f; // CHECK: = cir.unary(dec, %{{[0-9]+}}) : !cir.float, !cir.float
  f++; // CHECK: = cir.unary(inc, %{{[0-9]+}}) : !cir.float, !cir.float
  f--; // CHECK: = cir.unary(dec, %{{[0-9]+}}) : !cir.float, !cir.float

  f = !f;
  // CHECK: %[[#F_BOOL:]] = cir.cast(float_to_bool, %{{[0-9]+}} : !cir.float), !cir.bool
  // CHECK: = cir.unary(not, %[[#F_BOOL]]) : !cir.bool, !cir.bool
}

void doubles(double d) {
// CHECK: cir.func dso_local @{{.+}}doubles{{.+}}
  d = +d; // CHECK: %{{[0-9]+}} = cir.unary(plus, %{{[0-9]+}}) : !cir.double, !cir.double
  d = -d; // CHECK: %{{[0-9]+}} = cir.unary(minus, %{{[0-9]+}}) : !cir.double, !cir.double
  ++d; // CHECK: = cir.unary(inc, %{{[0-9]+}}) : !cir.double, !cir.double
  --d; // CHECK: = cir.unary(dec, %{{[0-9]+}}) : !cir.double, !cir.double
  d++; // CHECK: = cir.unary(inc, %{{[0-9]+}}) : !cir.double, !cir.double
  d--; // CHECK: = cir.unary(dec, %{{[0-9]+}}) : !cir.double, !cir.double

  d = !d;
  // CHECK: %[[#D_BOOL:]] = cir.cast(float_to_bool, %{{[0-9]+}} : !cir.double), !cir.bool
  // CHECK: = cir.unary(not, %[[#D_BOOL]]) : !cir.bool, !cir.bool
}

void pointers(int *p) {
// CHECK: cir.func dso_local @{{[^ ]+}}pointers
  // CHECK: %[[#P:]] = cir.alloca !cir.ptr<!s32i>, !cir.ptr<!cir.ptr<!s32i>>

  p = +p;
  // CHECK: cir.unary(plus, %{{.+}}) : !cir.ptr<!s32i>, !cir.ptr<!s32i>

  ++p;
  // CHECK:  %[[#INC:]] = cir.const #cir.int<1> : !s32i
  // CHECK:  %[[#RES:]] = cir.ptr_stride(%{{.+}} : !cir.ptr<!s32i>, %[[#INC]] : !s32i), !cir.ptr<!s32i>
  // CHECK:  cir.store{{.*}} %[[#RES]], %[[#P]] : !cir.ptr<!s32i>, !cir.ptr<!cir.ptr<!s32i>>
  --p;
  // CHECK:  %[[#DEC:]] = cir.const #cir.int<-1> : !s32i
  // CHECK:  %[[#RES:]] = cir.ptr_stride(%{{.+}} : !cir.ptr<!s32i>, %[[#DEC]] : !s32i), !cir.ptr<!s32i>
  // CHECK:  cir.store{{.*}} %[[#RES]], %[[#P]] : !cir.ptr<!s32i>, !cir.ptr<!cir.ptr<!s32i>>
  p++;
  // CHECK:  %[[#INC:]] = cir.const #cir.int<1> : !s32i
  // CHECK:  %[[#RES:]] = cir.ptr_stride(%{{.+}} : !cir.ptr<!s32i>, %[[#INC]] : !s32i), !cir.ptr<!s32i>
  // CHECK:  cir.store{{.*}} %[[#RES]], %[[#P]] : !cir.ptr<!s32i>, !cir.ptr<!cir.ptr<!s32i>>
  p--;
  // CHECK:  %[[#DEC:]] = cir.const #cir.int<-1> : !s32i
  // CHECK:  %[[#RES:]] = cir.ptr_stride(%{{.+}} : !cir.ptr<!s32i>, %[[#DEC]] : !s32i), !cir.ptr<!s32i>
  // CHECK:  cir.store{{.*}} %[[#RES]], %[[#P]] : !cir.ptr<!s32i>, !cir.ptr<!cir.ptr<!s32i>>

  bool p1 = !p;
  // %[[BOOLPTR:]] = cir.cast(ptr_to_bool, %15 : !cir.ptr<!s32i>), !cir.bool
  // cir.unary(not, %[[BOOLPTR]]) : !cir.bool, !cir.bool
}

void chars(char c) {
// CHECK: cir.func dso_local @{{.+}}chars{{.+}}

  int c1 = +c;
  // CHECK: %[[#PROMO:]] = cir.cast(integral, %{{.+}} : !s8i), !s32i
  // CHECK: cir.unary(plus, %[[#PROMO]]) : !s32i, !s32i
  int c2 = -c;
  // CHECK: %[[#PROMO:]] = cir.cast(integral, %{{.+}} : !s8i), !s32i
  // CHECK: cir.unary(minus, %[[#PROMO]]) nsw : !s32i, !s32i

  // Chars can go through some integer promotion codegen paths even when not promoted.
  ++c; // CHECK: cir.unary(inc, %10) : !s8i, !s8i
  --c; // CHECK: cir.unary(dec, %12) : !s8i, !s8i
  c++; // CHECK: cir.unary(inc, %14) : !s8i, !s8i
  c--; // CHECK: cir.unary(dec, %16) : !s8i, !s8i

  bool c3 = !c;
  // CHECK: %[[#C_BOOL:]] = cir.cast(int_to_bool, %{{[0-9]+}} : !s8i), !cir.bool
  // CHECK: cir.unary(not, %[[#C_BOOL]]) : !cir.bool, !cir.bool
}
