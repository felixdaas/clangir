// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -fclangir -emit-cir %s -o %t.cir
// RUN: FileCheck --input-file=%t.cir %s

#include <stdbool.h>

typedef struct {
  bool x;
} S;

// CHECK:  cir.func dso_local @init_bool
// CHECK:    [[ALLOC:%.*]] = cir.alloca !rec_S, !cir.ptr<!rec_S>
// CHECK:    [[ZERO:%.*]] = cir.const #cir.zero : !rec_S
// CHECK:    cir.store{{.*}} [[ZERO]], [[ALLOC]] : !rec_S, !cir.ptr<!rec_S>
void init_bool(void) {
  S s = {0};
}

// CHECK:  cir.func dso_local @store_bool
// CHECK:    [[TMP0:%.*]] = cir.alloca !cir.ptr<!rec_S>, !cir.ptr<!cir.ptr<!rec_S>>
// CHECK:    cir.store{{.*}} %arg0, [[TMP0]] : !cir.ptr<!rec_S>, !cir.ptr<!cir.ptr<!rec_S>>
// CHECK:    [[TMP1:%.*]] = cir.const #cir.int<0> : !s32i
// CHECK:    [[TMP2:%.*]] = cir.cast(int_to_bool, [[TMP1]] : !s32i), !cir.bool
// CHECK:    [[TMP3:%.*]] = cir.load{{.*}} [[TMP0]] : !cir.ptr<!cir.ptr<!rec_S>>, !cir.ptr<!rec_S>
// CHECK:    [[TMP4:%.*]] = cir.get_member [[TMP3]][0] {name = "x"} : !cir.ptr<!rec_S> -> !cir.ptr<!cir.bool>
// CHECK:    cir.store{{.*}} [[TMP2]], [[TMP4]] : !cir.bool, !cir.ptr<!cir.bool>
void store_bool(S *s) {
  s->x = false;
}

// CHECK:  cir.func dso_local @load_bool
// CHECK:    [[TMP0:%.*]] = cir.alloca !cir.ptr<!rec_S>, !cir.ptr<!cir.ptr<!rec_S>>, ["s", init] {alignment = 8 : i64}
// CHECK:    [[TMP1:%.*]] = cir.alloca !cir.bool, !cir.ptr<!cir.bool>, ["x", init] {alignment = 1 : i64}
// CHECK:    cir.store{{.*}} %arg0, [[TMP0]] : !cir.ptr<!rec_S>, !cir.ptr<!cir.ptr<!rec_S>>
// CHECK:    [[TMP2:%.*]] = cir.load{{.*}} [[TMP0]] : !cir.ptr<!cir.ptr<!rec_S>>, !cir.ptr<!rec_S>
// CHECK:    [[TMP3:%.*]] = cir.get_member [[TMP2]][0] {name = "x"} : !cir.ptr<!rec_S> -> !cir.ptr<!cir.bool>
// CHECK:    [[TMP4:%.*]] = cir.load{{.*}} [[TMP3]] : !cir.ptr<!cir.bool>, !cir.bool
void load_bool(S *s) {
  bool x = s->x;
}
