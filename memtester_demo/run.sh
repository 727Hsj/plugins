#!/bin/bash

# 确保当前用户有 sudo 权限
if [ "$EUID" -ne 0 ]; then
  echo "请用 sudo 执行此脚本"
  exit 1
fi

# 检查 memtester 是否在预期的编译路径
MEMTESTER_BIN="/home/kylin/code/plugins_source_code/memtester/memtester"

if [ -f "$MEMTESTER_BIN" ]; then
    echo "Found memtester at $MEMTESTER_BIN"
    # 运行 10 秒, 256MB 内存, 4 个线程
    $MEMTESTER_BIN 512M 3
else
    echo "Error: memtester not found. Please compile it first." 
fi
