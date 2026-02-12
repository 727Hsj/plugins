#!/bin/bash

# 检查 stressapptest 是否在预期的编译路径
STRESSAPPTEST_BIN="/home/kylin/code/plugins_source_code/stressapptest/src/stressapptest"

if [ -f "$STRESSAPPTEST_BIN" ]; then
    echo "Found stressapptest at $STRESSAPPTEST_BIN"
    # 运行 10 秒, 256MB 内存, 4 个线程
    $STRESSAPPTEST_BIN -s 10 -M 256 -m 4 -W
else
    # 尝试系统路径
    if command -v stressapptest &> /dev/null; then
        echo "Found stressapptest in system path"
        stressapptest -s 10 -M 256 -m 4 -W
    else
        echo "Error: stressapptest not found. Please compile it first."
        exit 1
    fi
fi
