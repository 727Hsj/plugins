use log::*;
use std::path::Path;
use std::process::{Command, Stdio};

pub fn run_stressapptest() {
    // 假设 stressapptest 可执行文件在 workspace 的 stressapptest/src/stressapptest
    // 或者用户已经安装在系统路径中。这里我们尝试使用相对路径寻找。

    let stressapptest_path =
        Path::new("/home/kylin/code/plugins_source_code/stressapptest/src/stressapptest");

    let program = if stressapptest_path.exists() {
        stressapptest_path.to_str().unwrap()
    } else {
        "stressapptest" // 尝试系统命令
    };

    info!("Starting stressapptest using: {}", program);

    // 构造命令: ./stressapptest -s 10 -M 64 -m 2
    // 运行 10 秒, 测试 64MB 内存, 2 个线程
    let status = Command::new(program)
        .arg("-s")
        .arg("10")
        .arg("-M")
        .arg("64")
        .arg("-m")
        .arg("2")
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status();

    match status {
        Ok(s) => {
            if s.success() {
                info!("stressapptest completed successfully.");
            } else {
                info!("stressapptest failed with exit code: {:?}", s.code());
            }
        }
        Err(e) => {
            info!("Failed to execute stressapptest: {}", e);
            info!("Make sure it is compiled in ../../stressapptest/ or installed globally.");
        }
    }
}

fn main() {
    println!("Hello, world!");
    run_stressapptest();
}
