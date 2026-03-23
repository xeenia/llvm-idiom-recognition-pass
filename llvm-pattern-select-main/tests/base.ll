; ModuleID = 'tests/raw.ll'
source_filename = "tests/positive_tests.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @times8(i32 noundef %x) #0 {
entry:
  %mul = mul nsw i32 %x, 8
  ret i32 %mul
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @mod32(i32 noundef %x) #0 {
entry:
  %rem = urem i32 %x, 32
  ret i32 %rem
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_rotate(i32 noundef %x) #0 {
entry:
  %shl = shl i32 %x, 8
  %shr = lshr i32 %x, 24
  %or = or i32 %shl, %shr
  ret i32 %or
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_abs(i32 noundef %x) #0 {
entry:
  %cmp = icmp slt i32 %x, 0
  %sub = sub nsw i32 0, %x
  %retval.0 = select i1 %cmp, i32 %sub, i32 %x
  ret i32 %retval.0
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_max(i32 noundef %a, i32 noundef %b) #0 {
entry:
  %cmp = icmp sgt i32 %a, %b
  %a.b = select i1 %cmp, i32 %a, i32 %b
  ret i32 %a.b
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_min(i32 noundef %a, i32 noundef %b) #0 {
entry:
  %cmp = icmp slt i32 %a, %b
  %a.b = select i1 %cmp, i32 %a, i32 %b
  ret i32 %a.b
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_bswap(i32 noundef %x) #0 {
entry:
  %and = and i32 %x, -16777216
  %shr = lshr i32 %and, 24
  %and1 = and i32 %x, 16711680
  %shr2 = lshr i32 %and1, 8
  %or = or i32 %shr, %shr2
  %and3 = and i32 %x, 65280
  %shl = shl i32 %and3, 8
  %or4 = or i32 %or, %shl
  %and5 = and i32 %x, 255
  %shl6 = shl i32 %and5, 24
  %or7 = or i32 %or4, %shl6
  ret i32 %or7
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_popcount_logic(i32 noundef %i) #0 {
entry:
  %shr = lshr i32 %i, 1
  %and = and i32 %shr, 1431655765
  %sub = sub i32 %i, %and
  %and1 = and i32 %sub, 858993459
  %shr2 = lshr i32 %sub, 2
  %and3 = and i32 %shr2, 858993459
  %add = add i32 %and1, %and3
  %shr4 = lshr i32 %add, 4
  %add5 = add i32 %add, %shr4
  %and6 = and i32 %add5, 252645135
  %mul = mul i32 %and6, 16843009
  %shr7 = lshr i32 %mul, 24
  ret i32 %shr7
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
