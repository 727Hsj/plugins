# Stressapptest Demo 插件使用说明

本目录包含了一个演示插件，展示了如何通过 Shell 脚本和 Rust 代码来调用 `stressapptest` 工具进行系统压力测试。

## stressapptest插件介绍

https://github.com/stressapptest/stressapptest.git

### 介绍
内存和CPU压力: stressapptest 主要用于在内存和处理器上施加压力，检查它们在高负荷情况下的可靠性园。它可以通过执行读写操作、内存复制只和反转等来达到这个目的。

磁盘I0 测试:除了内存和CPU测试之外，stressapptest还能进行磁盘!O测试，这通过向指定的设备或文件进行读写操作来完成

网络测试:stressapptest 可以进行网络测试，这是通过添加指定向特定IP地址或响应网络请求的线程来实现的。。

### 基本用法

内存测试：
./stressapptest -s 20 -M 256 -m 8 -W     # 测试 256MB 内存，运行 8 个“热拷贝”线程，20 秒后退出。
./stressapptest -s 20 -M 256 -m 8 -C 8 -W # 分配 256MB 内存，运行 8 个“热拷贝”线程和 8 个 CPU 负载线程，20秒后退出。

IO 测试
./stressapptest -f /tmp/file1 -f /tmp/file2 # 运行 2 个文件 I/O 线程，自动检测内存大小和核心数量以选择分配的内存和内存复制线程。
./stressapptest --help                   # 列出可用参数

stressapptest -s 3600 -M 4096 -m 8 -C 8 -f /tmp/stress_test -l /var/log/stress_test.log # 测试 4GB 内存，运行 1 小时，使用 8 个内存和 8 个 CPU 线程，同时进行磁盘 I/O 测试，并记录日志

网络测试
机器 A‌（IP: 192.168.1.100）stressapptest --listen -s 3600  # 这台机器启动监听模式，等待其他机器连接。
机器 B‌（IP: 192.168.1.101）stressapptest -n 192.168.1.100 -s 3600  # 这台机器连接到机器 A，进行网络通信压力测试

### 常见参数：

-M mbytes ：要测试的内存兆字节数（默认检测所有可用内存）
-s seconds ：运行时间（默认 20 秒）
-m threads ：要运行的内存复制线程数（默认根据 CPU 核心数自动检测）
-C ： CPU 压力线程数	例如 8，用于增加 CPU 负载
-W ：使用更消耗 CPU 的内存复制（默认关闭）
-f filename ：添加一个处理文件 filename 的磁盘线程（无）
-F ：不检查每笔交易的结果，而是使用 libc memcpy（默认关闭）

下面俩参数用于在 stressapptest 中进行网络压力测试，允许你将多台机器连接起来进行分布式压力测试。
-n ipaddr ：添加连接到指定 IP 地址系统的网络线程（无）
--listen ：运行一个监听并响应网络线程的线程（默认 0）

### 错误处理：

-l logfile ：将日志输出到文件 logfile（无）
-v level ：详细程度（0-20，默认 8）

### 结果解读‌
测试结束时，关注 Status: PASS 或 FAIL，以及 Hardware Errors 和 Data Errors 的计数。
通常，错误数小于内存大小（GB）的 0.1 倍视为通过


## Stressapptest Demo 前置条件
已在 stressapptest_demo 目录下为您准备了两个示例，分别展示了 Shell 脚本用法和 Rust 代码调用用法。

请确保您已经编译了 `stressapptest` 或者系统中已安装该工具。
本示例默认会在 `stressapptest/src/stressapptest` 路径寻找编译好的二进制文件，如果未找到，将尝试使用系统的 `stressapptest` 命令。

## Stressapptest Demo 使用方法

### 1. 运行 Shell 脚本示例

`run.sh` 是一个简单的 Bash 脚本，用于快速启动一次配置好的压力测试。

```bash
cd plugins/stressapptest_demo
chmod +x run.sh
./run.sh
```

该脚本默认配置为：运行 10 秒，测试 256MB 内存，使用 4 个线程。

### 2. 运行 Rust 代码示例

`src/main.rs` 展示了如何在 Rust 程序中使用 `std::process::Command` 来执行 `stressapptest` 并捕获其输出。

您可以直接在当前目录下运行：

```bash
cargo run
```

或者在 workspace 根目录下运行：

```bash
cargo run -p stressapptest_demo
```
