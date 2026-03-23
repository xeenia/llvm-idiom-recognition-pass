; CHECK-LABEL: define dso_local i32 @negative_mul_not_pow2(i32 noundef %a)
; CHECK: %mul = mul nsw i32 %a, 7
; CHECK-NOT: shl
; CHECK: ret i32 %mul

; CHECK-LABEL: define dso_local i32 @negative_mul_zero(i32 noundef %a)
; CHECK: %mul = mul nsw i32 %a, 0
; CHECK-NOT: shl
; CHECK: ret i32 %mul

; CHECK-LABEL: define dso_local i32 @negative_urem_not_pow2(i32 noundef %a)
; CHECK: %rem = urem i32 %a, 6
; CHECK-NOT: and
; CHECK: ret i32 %rem

; CHECK-LABEL: define dso_local i32 @negative_srem_pow2(i32 noundef %a)
; CHECK: %rem = srem i32 %a, 8
; CHECK-NOT: and
; CHECK: ret i32 %rem

; CHECK-LABEL: define dso_local i32 @negative_rotate_bad_sum(i32 noundef %x, i32 noundef %s)
; CHECK: %or = or i32 %shl, %shr
; CHECK-NOT: call i32 @llvm.fshl.i32
; CHECK: ret i32 %or

; CHECK-LABEL: define dso_local i32 @negative_rotate_diff_vars(i32 noundef %x, i32 noundef %y, i32 noundef %s)
; CHECK: %or = or i32 %shl, %shr
; CHECK-NOT: call i32 @llvm.fshl.i32
; CHECK: ret i32 %or

; CHECK-LABEL: define dso_local i32 @negative_abs_wrong_pred(i32 noundef %x)
; CHECK: %cond = select i1 %cmp, i32 %sub, i32 %x
; CHECK-NOT: call i32 @llvm.abs.i32
; CHECK: ret i32 %cond

; CHECK-LABEL: define dso_local i32 @negative_minmax_mismatch(i32 noundef %a, i32 noundef %b, i32 noundef %c)
; CHECK: %a.c = select i1 %cmp, i32 %a, i32 %c
; CHECK-NOT: call i32 @llvm.smax.i32
; CHECK-NOT: call i32 @llvm.smin.i32
; CHECK: ret i32 %a.c

; CHECK-LABEL: define dso_local i32 @negative_bswap_partial(i32 noundef %a)
; CHECK: %shl = shl i32 %and, 24
; CHECK-NOT: call i32 @llvm.bswap.i32
; CHECK: ret i32 %shl

; ModuleID = 'tests/negative_tests.c'
source_filename = "tests/negative_tests.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @negative_mul_not_pow2(i32 noundef %a) #0 {
entry:
  %a.addr = alloca i32, align 4
  store i32 %a, ptr %a.addr, align 4
  %0 = load i32, ptr %a.addr, align 4
  %mul = mul nsw i32 %0, 7
  ret i32 %mul
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @negative_mul_zero(i32 noundef %a) #0 {
entry:
  %a.addr = alloca i32, align 4
  store i32 %a, ptr %a.addr, align 4
  %0 = load i32, ptr %a.addr, align 4
  %mul = mul nsw i32 %0, 0
  ret i32 %mul
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @negative_urem_not_pow2(i32 noundef %a) #0 {
entry:
  %a.addr = alloca i32, align 4
  store i32 %a, ptr %a.addr, align 4
  %0 = load i32, ptr %a.addr, align 4
  %rem = urem i32 %0, 6
  ret i32 %rem
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @negative_srem_pow2(i32 noundef %a) #0 {
entry:
  %a.addr = alloca i32, align 4
  store i32 %a, ptr %a.addr, align 4
  %0 = load i32, ptr %a.addr, align 4
  %rem = srem i32 %0, 8
  ret i32 %rem
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @negative_rotate_bad_sum(i32 noundef %x, i32 noundef %s) #0 {
entry:
  %x.addr = alloca i32, align 4
  %s.addr = alloca i32, align 4
  store i32 %x, ptr %x.addr, align 4
  store i32 %s, ptr %s.addr, align 4
  %0 = load i32, ptr %x.addr, align 4
  %1 = load i32, ptr %s.addr, align 4
  %shl = shl i32 %0, %1
  %2 = load i32, ptr %x.addr, align 4
  %3 = load i32, ptr %s.addr, align 4
  %sub = sub i32 31, %3
  %shr = lshr i32 %2, %sub
  %or = or i32 %shl, %shr
  ret i32 %or
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @negative_rotate_diff_vars(i32 noundef %x, i32 noundef %y, i32 noundef %s) #0 {
entry:
  %x.addr = alloca i32, align 4
  %y.addr = alloca i32, align 4
  %s.addr = alloca i32, align 4
  store i32 %x, ptr %x.addr, align 4
  store i32 %y, ptr %y.addr, align 4
  store i32 %s, ptr %s.addr, align 4
  %0 = load i32, ptr %x.addr, align 4
  %1 = load i32, ptr %s.addr, align 4
  %shl = shl i32 %0, %1
  %2 = load i32, ptr %y.addr, align 4
  %3 = load i32, ptr %s.addr, align 4
  %sub = sub i32 32, %3
  %shr = lshr i32 %2, %sub
  %or = or i32 %shl, %shr
  ret i32 %or
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @negative_abs_wrong_pred(i32 noundef %x) #0 {
entry:
  %x.addr = alloca i32, align 4
  store i32 %x, ptr %x.addr, align 4
  %0 = load i32, ptr %x.addr, align 4
  %cmp = icmp sgt i32 %0, 0
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load i32, ptr %x.addr, align 4
  %sub = sub nsw i32 0, %1
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load i32, ptr %x.addr, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %sub, %cond.true ], [ %2, %cond.false ]
  ret i32 %cond
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @negative_abs_wrong_const(i32 noundef %x) #0 {
entry:
  %x.addr = alloca i32, align 4
  store i32 %x, ptr %x.addr, align 4
  %0 = load i32, ptr %x.addr, align 4
  %cmp = icmp slt i32 %0, 1
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %1 = load i32, ptr %x.addr, align 4
  %sub = sub nsw i32 0, %1
  br label %cond.end

cond.false:                                       ; preds = %entry
  %2 = load i32, ptr %x.addr, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %sub, %cond.true ], [ %2, %cond.false ]
  ret i32 %cond
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @negative_minmax_mismatch(i32 noundef %a, i32 noundef %b, i32 noundef %c) #0 {
entry:
  %a.addr = alloca i32, align 4
  %b.addr = alloca i32, align 4
  %c.addr = alloca i32, align 4
  store i32 %a, ptr %a.addr, align 4
  store i32 %b, ptr %b.addr, align 4
  store i32 %c, ptr %c.addr, align 4
  %0 = load i32, ptr %a.addr, align 4
  %1 = load i32, ptr %b.addr, align 4
  %cmp = icmp sgt i32 %0, %1
  br i1 %cmp, label %cond.true, label %cond.false

cond.true:                                        ; preds = %entry
  %2 = load i32, ptr %a.addr, align 4
  br label %cond.end

cond.false:                                       ; preds = %entry
  %3 = load i32, ptr %c.addr, align 4
  br label %cond.end

cond.end:                                         ; preds = %cond.false, %cond.true
  %cond = phi i32 [ %2, %cond.true ], [ %3, %cond.false ]
  ret i32 %cond
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @negative_bswap_partial(i32 noundef %a) #0 {
entry:
  %a.addr = alloca i32, align 4
  store i32 %a, ptr %a.addr, align 4
  %0 = load i32, ptr %a.addr, align 4
  %and = and i32 %0, 255
  %shl = shl i32 %and, 24
  ret i32 %shl
}

attributes #0 = { noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 22.0.0git (https://github.com/llvm/llvm-project.git afc83688cfadfb07c1cd9edc4f3c855d7cf4a261)"}
