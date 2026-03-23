; ModuleID = 'tests/base.ll'
source_filename = "tests/positive_tests.c"
target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-i128:128-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @times8(i32 noundef %x) #0 {
entry:
  %0 = shl i32 %x, 3
  ret i32 %0
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @mod32(i32 noundef %x) #0 {
entry:
  %0 = and i32 %x, 31
  ret i32 %0
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_rotate(i32 noundef %x) #0 {
entry:
  %0 = call i32 @llvm.fshl.i32(i32 %x, i32 %x, i32 8)
  ret i32 %0
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_abs(i32 noundef %x) #0 {
entry:
  %0 = call i32 @llvm.abs.i32(i32 %x, i1 false)
  ret i32 %0
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_max(i32 noundef %a, i32 noundef %b) #0 {
entry:
  %0 = call i32 @llvm.smax.i32(i32 %a, i32 %b)
  ret i32 %0
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_min(i32 noundef %a, i32 noundef %b) #0 {
entry:
  %0 = call i32 @llvm.smin.i32(i32 %a, i32 %b)
  ret i32 %0
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_bswap(i32 noundef %x) #0 {
entry:
  %0 = call i32 @llvm.bswap.i32(i32 %x)
  ret i32 %0
}

; Function Attrs: noinline nounwind uwtable
define dso_local i32 @test_popcount_logic(i32 noundef %i) #0 {
entry:
  %0 = call i32 @llvm.ctpop.i32(i32 %i)
  ret i32 %0
}

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.fshl.i32(i32, i32, i32) #1

; Function Attrs: nocallback nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.abs.i32(i32, i1 immarg) #2

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smax.i32(i32, i32) #1

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.smin.i32(i32, i32) #1

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.bswap.i32(i32) #1

; Function Attrs: nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none)
declare i32 @llvm.ctpop.i32(i32) #1

attributes #0 = { noinline nounwind uwtable "frame-pointer"="all" "min-legal-vector-width"="0" "no-trapping-math"="true" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cmov,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "tune-cpu"="generic" }
attributes #1 = { nocallback nocreateundeforpoison nofree nosync nounwind speculatable willreturn memory(none) }
attributes #2 = { nocallback nofree nosync nounwind speculatable willreturn memory(none) }

!llvm.module.flags = !{!0, !1, !2, !3, !4}
!llvm.ident = !{!5}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{i32 8, !"PIC Level", i32 2}
!2 = !{i32 7, !"PIE Level", i32 2}
!3 = !{i32 7, !"uwtable", i32 2}
!4 = !{i32 7, !"frame-pointer", i32 2}
!5 = !{!"clang version 22.0.0git (https://github.com/llvm/llvm-project.git afc83688cfadfb07c1cd9edc4f3c855d7cf4a261)"}
