# valgrind Demo 插件使用说明

valgrind是一个构建动态分析程序的工具集框架，它有一套功能强大的工具集合，包括debug、profiling等，其中最重要和常用的是内存泄漏检测工具memcheck。

本 demo 就是聚焦 memcheck

本目录包含了一个演示插件，展示了如何通过 Shell 脚本和 Rust 代码来调用 `valgrind` 工具进行系统压力测试。

## valgrind 插件介绍

wget https://sourceware.org/pub/valgrind/valgrind-3.22.0.tar.bz2
tar xf valgrind-3.22.0.tar.bz2
cd valgrind-3.22.0
./configure --prefix=`pwd`/build
make -j8
make install

valgrind 将会被安装在valgrind-3.22.0/build/bin/里面

测试：./valgrind --version

### 介绍
Valgrind 是一个强大的内存调试和性能分析工具，广泛用于 Linux 系统上的程序开发和测试。它可以帮助开发者检测内存泄漏、数组越界、未初始化变量等问题，并提供详细的报告。Valgrind 支持多种编程语言，尤其是 C 和 C++。

### 基本用法
valgrind [valgrind-options] ./your-program [program-options]

valgrind-options参数：
--tool指定哪一个valgrind工具去使用，如Memcheck、Callgrind等
--leak-check指定输出具体的内存泄露位置
--trace-children指定是否追踪子进程
--log-file指定记录日志文件的名称

### 例子：
valgrind --tool=memcheck --leak-check=full --trace-children=yes --log-file=valgrind.log ./a.out

### 结果解读‌
使用run 脚本的测试命令
` 开始 `
==83606== Memcheck, a memory error detector
==83606== Copyright (C) 2002-2022, and GNU GPL'd, by Julian Seward et al.
==83606== Using Valgrind-3.22.0 and LibVEX; rerun with -h for copyright info
==83606== Command: target/debug/valgrind_demo
==83606==
` 代码的 println ` 
Valgrind demo: Triggering a Use-After-Free error...
Allocated memory at 0x4a66f90, value: 42
Memory freed.
Attempting to write to freed memory...
` 非法写入，代码中有指向 `
==83606== Invalid write of size 1
==83606==    at 0x112020: valgrind_demo::main (main.rs:22)
==83606==    by 0x11193F: core::ops::function::FnOnce::call_once (function.rs:253)
==83606==    by 0x11178B: std::sys::backtrace::__rust_begin_short_backtrace (backtrace.rs:158)
==83606==    by 0x11189F: std::rt::lang_start::{{closure}} (rt.rs:206)
==83606==    by 0x126553: call_once<(), (dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe)> (function.rs:290)
==83606==    by 0x126553: do_call<&(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe), i32> (panicking.rs:589)
==83606==    by 0x126553: catch_unwind<i32, &(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe)> (panicking.rs:552)
==83606==    by 0x126553: catch_unwind<&(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe), i32> (panic.rs:359)
==83606==    by 0x126553: {closure#0} (rt.rs:175)
==83606==    by 0x126553: do_call<std::rt::lang_start_internal::{closure_env#0}, isize> (panicking.rs:589)
==83606==    by 0x126553: catch_unwind<isize, std::rt::lang_start_internal::{closure_env#0}> (panicking.rs:552)
==83606==    by 0x126553: catch_unwind<std::rt::lang_start_internal::{closure_env#0}, isize> (panic.rs:359)
==83606==    by 0x126553: std::rt::lang_start_internal (rt.rs:171)
==83606==    by 0x111877: std::rt::lang_start (rt.rs:205)
==83606==    by 0x1120C7: main (in /home/kylin/code/plugins/target/debug/valgrind_demo)
==83606==  Address 0x4a66f90 is 0 bytes inside a block of size 1 free'd
` Valgrind 甚至帮你追溯了这块内存的“前世今生” , 时间倒序` 

` 被释放 ` 
==83606==    at 0x484E24C: free (vg_replace_malloc.c:985)
==83606==    by 0x111817: alloc::alloc::dealloc (alloc.rs:114)
==83606==    by 0x111FBF: valgrind_demo::main (main.rs:15)
==83606==    by 0x11193F: core::ops::function::FnOnce::call_once (function.rs:253)
==83606==    by 0x11178B: std::sys::backtrace::__rust_begin_short_backtrace (backtrace.rs:158)
==83606==    by 0x11189F: std::rt::lang_start::{{closure}} (rt.rs:206)
==83606==    by 0x126553: call_once<(), (dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe)> (function.rs:290)
==83606==    by 0x126553: do_call<&(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe), i32> (panicking.rs:589)
==83606==    by 0x126553: catch_unwind<i32, &(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe)> (panicking.rs:552)
==83606==    by 0x126553: catch_unwind<&(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe), i32> (panic.rs:359)
==83606==    by 0x126553: {closure#0} (rt.rs:175)
==83606==    by 0x126553: do_call<std::rt::lang_start_internal::{closure_env#0}, isize> (panicking.rs:589)
==83606==    by 0x126553: catch_unwind<isize, std::rt::lang_start_internal::{closure_env#0}> (panicking.rs:552)
==83606==    by 0x126553: catch_unwind<std::rt::lang_start_internal::{closure_env#0}, isize> (panic.rs:359)
==83606==    by 0x126553: std::rt::lang_start_internal (rt.rs:171)
==83606==    by 0x111877: std::rt::lang_start (rt.rs:205)
==83606==    by 0x1120C7: main (in /home/kylin/code/plugins/target/debug/valgrind_demo)

` 被申请 `
==83606==  Block was alloc'd at
==83606==    at 0x484B158: malloc (vg_replace_malloc.c:442)
==83606==    by 0x1117D3: alloc::alloc::alloc (alloc.rs:94)
==83606==    by 0x111F0B: valgrind_demo::main (main.rs:9)
==83606==    by 0x11193F: core::ops::function::FnOnce::call_once (function.rs:253)
==83606==    by 0x11178B: std::sys::backtrace::__rust_begin_short_backtrace (backtrace.rs:158)
==83606==    by 0x11189F: std::rt::lang_start::{{closure}} (rt.rs:206)
==83606==    by 0x126553: call_once<(), (dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe)> (function.rs:290)
==83606==    by 0x126553: do_call<&(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe), i32> (panicking.rs:589)
==83606==    by 0x126553: catch_unwind<i32, &(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe)> (panicking.rs:552)
==83606==    by 0x126553: catch_unwind<&(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe), i32> (panic.rs:359)
==83606==    by 0x126553: {closure#0} (rt.rs:175)
==83606==    by 0x126553: do_call<std::rt::lang_start_internal::{closure_env#0}, isize> (panicking.rs:589)
==83606==    by 0x126553: catch_unwind<isize, std::rt::lang_start_internal::{closure_env#0}> (panicking.rs:552)
==83606==    by 0x126553: catch_unwind<std::rt::lang_start_internal::{closure_env#0}, isize> (panic.rs:359)
==83606==    by 0x126553: std::rt::lang_start_internal (rt.rs:171)
==83606==    by 0x111877: std::rt::lang_start (rt.rs:205)
==83606==    by 0x1120C7: main (in /home/kylin/code/plugins/target/debug/valgrind_demo)
==83606== 

` 非法读取 ` 
==83606== Invalid read of size 1
==83606==    at 0x1456B8: core::fmt::num::imp::<impl core::fmt::Display for u8>::fmt (num.rs:221)
==83606==    by 0x142247: fmt (rt.rs:173)
==83606==    by 0x142247: core::fmt::write (mod.rs:1468)
==83606==    by 0x127B4B: default_write_fmt<std::io::stdio::StdoutLock> (mod.rs:639)
==83606==    by 0x127B4B: write_fmt<std::io::stdio::StdoutLock> (mod.rs:1954)
==83606==    by 0x127B4B: <&std::io::stdio::Stdout as std::io::Write>::write_fmt (stdio.rs:834)
==83606==    by 0x12831B: write_fmt (stdio.rs:808)
==83606==    by 0x12831B: print_to<std::io::stdio::Stdout> (stdio.rs:1164)
==83606==    by 0x12831B: std::io::stdio::_print (stdio.rs:1275)
==83606==    by 0x11207B: valgrind_demo::main (main.rs:24)
==83606==    by 0x11193F: core::ops::function::FnOnce::call_once (function.rs:253)
==83606==    by 0x11178B: std::sys::backtrace::__rust_begin_short_backtrace (backtrace.rs:158)
==83606==    by 0x11189F: std::rt::lang_start::{{closure}} (rt.rs:206)
==83606==    by 0x126553: call_once<(), (dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe)> (function.rs:290)
==83606==    by 0x126553: do_call<&(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe), i32> (panicking.rs:589)
==83606==    by 0x126553: catch_unwind<i32, &(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe)> (panicking.rs:552)
==83606==    by 0x126553: catch_unwind<&(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe), i32> (panic.rs:359)
==83606==    by 0x126553: {closure#0} (rt.rs:175)
==83606==    by 0x126553: do_call<std::rt::lang_start_internal::{closure_env#0}, isize> (panicking.rs:589)
==83606==    by 0x126553: catch_unwind<isize, std::rt::lang_start_internal::{closure_env#0}> (panicking.rs:552)
==83606==    by 0x126553: catch_unwind<std::rt::lang_start_internal::{closure_env#0}, isize> (panic.rs:359)
==83606==    by 0x126553: std::rt::lang_start_internal (rt.rs:171)
==83606==    by 0x111877: std::rt::lang_start (rt.rs:205)
==83606==    by 0x1120C7: main (in /home/kylin/code/plugins/target/debug/valgrind_demo)
==83606==  Address 0x4a66f90 is 0 bytes inside a block of size 1 free'd
==83606==    at 0x484E24C: free (vg_replace_malloc.c:985)
==83606==    by 0x111817: alloc::alloc::dealloc (alloc.rs:114)
==83606==    by 0x111FBF: valgrind_demo::main (main.rs:15)
==83606==    by 0x11193F: core::ops::function::FnOnce::call_once (function.rs:253)
==83606==    by 0x11178B: std::sys::backtrace::__rust_begin_short_backtrace (backtrace.rs:158)
==83606==    by 0x11189F: std::rt::lang_start::{{closure}} (rt.rs:206)
==83606==    by 0x126553: call_once<(), (dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe)> (function.rs:290)
==83606==    by 0x126553: do_call<&(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe), i32> (panicking.rs:589)
==83606==    by 0x126553: catch_unwind<i32, &(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe)> (panicking.rs:552)
==83606==    by 0x126553: catch_unwind<&(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe), i32> (panic.rs:359)
==83606==    by 0x126553: {closure#0} (rt.rs:175)
==83606==    by 0x126553: do_call<std::rt::lang_start_internal::{closure_env#0}, isize> (panicking.rs:589)
==83606==    by 0x126553: catch_unwind<isize, std::rt::lang_start_internal::{closure_env#0}> (panicking.rs:552)
==83606==    by 0x126553: catch_unwind<std::rt::lang_start_internal::{closure_env#0}, isize> (panic.rs:359)
==83606==    by 0x126553: std::rt::lang_start_internal (rt.rs:171)
==83606==    by 0x111877: std::rt::lang_start (rt.rs:205)
==83606==    by 0x1120C7: main (in /home/kylin/code/plugins/target/debug/valgrind_demo)
==83606==  Block was alloc'd at
==83606==    at 0x484B158: malloc (vg_replace_malloc.c:442)
==83606==    by 0x1117D3: alloc::alloc::alloc (alloc.rs:94)
==83606==    by 0x111F0B: valgrind_demo::main (main.rs:9)
==83606==    by 0x11193F: core::ops::function::FnOnce::call_once (function.rs:253)
==83606==    by 0x11178B: std::sys::backtrace::__rust_begin_short_backtrace (backtrace.rs:158)
==83606==    by 0x11189F: std::rt::lang_start::{{closure}} (rt.rs:206)
==83606==    by 0x126553: call_once<(), (dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe)> (function.rs:290)
==83606==    by 0x126553: do_call<&(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe), i32> (panicking.rs:589)
==83606==    by 0x126553: catch_unwind<i32, &(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe)> (panicking.rs:552)
==83606==    by 0x126553: catch_unwind<&(dyn core::ops::function::Fn<(), Output=i32> + core::marker::Sync + core::panic::unwind_safe::RefUnwindSafe), i32> (panic.rs:359)
==83606==    by 0x126553: {closure#0} (rt.rs:175)
==83606==    by 0x126553: do_call<std::rt::lang_start_internal::{closure_env#0}, isize> (panicking.rs:589)
==83606==    by 0x126553: catch_unwind<isize, std::rt::lang_start_internal::{closure_env#0}> (panicking.rs:552)
==83606==    by 0x126553: catch_unwind<std::rt::lang_start_internal::{closure_env#0}, isize> (panic.rs:359)
==83606==    by 0x126553: std::rt::lang_start_internal (rt.rs:171)
==83606==    by 0x111877: std::rt::lang_start (rt.rs:205)
==83606==    by 0x1120C7: main (in /home/kylin/code/plugins/target/debug/valgrind_demo)
==83606== 

` 代码 println ，为什么没崩溃？`
Wrote 100 to freed memory. (If you see this, Valgrind should have logged many errors)

`操作系统层面：这块内存虽然在逻辑上被释放了（归还给了分配器），但它可能仍然属于当前进程的地址空间页（Page）即使是“非法”的，物理上仍然可写，所以没有触发 OS 的 Segmentation Fault (段错误)。Rust 层面：因为使用了 unsafe，Rust 放弃了安全检查。危险性：这正是最危险的情况——数据损坏 (Data Corruption)。程序仍然在跑，但它正在默默地破坏堆上的数据结构或其他对象的内存，这种 bug 极其隐蔽。`

` SUMMARY `
==83606== 
==83606== HEAP SUMMARY:
==83606==     in use at exit: 456 bytes in 1 blocks
==83606==   total heap usage: 9 allocs, 8 frees, 3,373 bytes allocated
==83606== 
==83606== LEAK SUMMARY:
==83606==    definitely lost: 0 bytes in 0 blocks
==83606==    indirectly lost: 0 bytes in 0 blocks
==83606==      possibly lost: 0 bytes in 0 blocks
==83606==    still reachable: 456 bytes in 1 blocks
==83606==         suppressed: 0 bytes in 0 blocks
==83606== Reachable blocks (those to which a pointer was found) are not shown.
==83606== To see them, rerun with: --leak-check=full --show-leak-kinds=all
==83606== 
==83606== For lists of detected and suppressed errors, rerun with: -s
==83606== ERROR SUMMARY: 2 errors from 2 contexts (suppressed: 0 from 0)


## valgrind Demo 使用方法

`src/main.rs` 展示了如何在 Rust 程序中有一个模拟内存释放后重用的例子。
cargo build -p valgrind_demo，在 target/debug/ 有他的可执行文件

然后运行 src/run.sh 脚本。
