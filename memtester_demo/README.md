# memtester Demo 插件使用说明


## memtester 插件介绍

官网及源码下载：
https://pyropus.ca./software/memtester/

旧版本源码下载：
wget https://pyropus.ca/software/memtester/old-versions/memtester-4.7.1.tar.gz
tar zxvf memtester-4.7.1.tar.gz
cd memtester-4.7.1
make
./memtester --version

构建方法：
下载、解压，然后输入`make`。就这么简单。如果你愿意，可以运行 `make install` 将生成的二进制文件复制到 `/usr/local/bin/` 目录，并将手册页安装到 `/usr/local/man/man8/` 目录。但这不是必须的。程序可以直接从构建目录运行，你也可以使用 `man ./memtester.8` 命令查看手册页。`/usr/local/` 部分也可以在 Makefile 中进行配置。

### 介绍
memtester 是一个用于测试计算机内存子系统是否存在故障的实用工具。

已验证平台：包括 HP-UX, Debian/RedHat/Ubuntu 等 Linux 发行版, FreeBSD, NetBSD, macOS 等。

### 使用方法
Usage: memtester [-p physaddrbase [-d device]] <mem>[B|K|M|G] [loops]

<mem>：要测的内存容量，默认为兆字节 (MB)。可以使用后缀 B, K, M, G
[loops]：运行次数，可选。如果不填，测试将无限进行直到用户中断。

高级/物理地址测试用法：
-p physaddr：指定从某个物理地址开始测试（通过 mmap mem）。physaddr 是十六进制格式。
-d device：指定映射的设备文件（默认是 /dev/mem）。仅能配合 -p 使用。
危险警告：使用 -p 测试物理地址时，测试会覆盖该区域的数据。如果你覆盖了内核或其他应用正在使用的内存，系统会崩溃。这通常用于测试内存映射的 I/O 设备。

## 例子
memtester 1G 5   # 测试 1GB 内存，共循环 5 次。
memtester -p 0x0c0000 64K  # 测试 64KB 大小的内存，物理地址起始于 0x0C0000：
memtester -p 0 -d /dev/foodev 64k   # 测试 /dev/foodev 设备，偏移量为 0，大小 64KB

### 重要注意事项
Root 权限：必须以 root 身份运行，因为程序需要锁定内存页面（mlock），防止操作系统将测试内存交换（swap）到磁盘上。如果无法锁定内存，测试速度会变慢且由于交换机制测试结果可能不准确。


### 结果解读‌
kylin@kylin-pc:~/memtester$ sudo ./memtester 512K 3
```
memtester version 4.7.1 (64-bit)
Copyright (C) 2001-2024 Charles Cazabon.
Licensed under the GNU General Public License version 2 (only).

pagesize is 4096
pagesizemask is 0xfffffffffffff000
want 0MB (524288 bytes)
got  0MB (524288 bytes), trying mlock ...locked.
Loop 1/3:
  Stuck Address       : ok         
  Random Value        : ok
  Compare XOR         : ok
  Compare SUB         : ok
  Compare MUL         : ok
  Compare DIV         : ok
  Compare OR          : ok
  Compare AND         : ok
  Sequential Increment: ok
  Solid Bits          : ok         
  Block Sequential    : ok         
  Checkerboard        : ok         
  Bit Spread          : ok         
  Bit Flip            : ok         
  Walking Ones        : ok         
  Walking Zeroes      : ok         
  8-bit Writes        : ok
  16-bit Writes       : ok

Loop 2/3:
  ...

Loop 3/3:
  ...

Done.
```
当所有测试项均为 ok，表示测试通过


## memtester Demo 使用方法

### 1. 运行 Shell 脚本示例

`run.sh` 是一个简单的 Bash 脚本，用于快速启动一次配置好的压力测试。

### 2. 运行 Rust 代码示例

`src/lib.rs` 展示了如何在 Rust 程序中使用 `std::process::Command` 来执行 `memtester` 并捕获其输出。
