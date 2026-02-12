#!/bin/bash

# 获取脚本所在目录的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# 项目根目录 (假设 run.sh 在 plugins/valgrind_demo/ 下)
# 向上两级: valgrind_demo -> plugins
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 1. 寻找 Valgrind
# 优先查找 ../../plugins_source_code 下的 valgrind (相对于 PROJECT_ROOT 的上级)
# 注意：这里假设 plugins_source_code 和 plugins 是兄弟目录
VALGRIND_PATH="$PROJECT_ROOT/../plugins_source_code/valgrind-3.22.0/build/bin/valgrind"

if [ ! -f "$VALGRIND_PATH" ]; then
    echo "Error: valgrind executable not found at custom path or in PATH."
    exit 1
fi

echo "Using valgrind: $VALGRIND_PATH"

# 2. 寻找目标二进制文件
TARGET_BIN="$PROJECT_ROOT/target/debug/valgrind_demo"

if [ ! -f "$TARGET_BIN" ]; then
    echo "Binary not found at $TARGET_BIN. Attempting to build..."
    # 切换到 workspace 根目录进行构建
    pushd "$PROJECT_ROOT" > /dev/null
    cargo build -p valgrind_demo
    popd > /dev/null
    
    if [ ! -f "$TARGET_BIN" ]; then
        echo "Error: Build failed or binary not found at $TARGET_BIN"
        exit 1
    fi
fi

# 3. 运行测试
echo "Running valgrind memcheck on $TARGET_BIN..."
"$VALGRIND_PATH" --tool=memcheck --leak-check=full --log-file=valgrind.log "$TARGET_BIN"

