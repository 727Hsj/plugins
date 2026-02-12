use std::process::{Command, Stdio};
use std::path::Path;
use log::*;

pub fn run_memtester() {
    // 假设 memtester 可执行文件在 workspace 的 memtester/src/memtester
    let memtester_path = Path::new("/home/kylin/code/plugins_source_code/memtester/memtester");
    let program = if memtester_path.exists() {
        memtester_path.to_str().unwrap()
    } else {
        "memtester" // 尝试系统命令
    };

    info!("Starting memtester using: {}", program);

    // 构造命令: sudo ./memtester 512M 2
    // 运行 2 次, 测试 512MB 内存
    let status = Command::new("sudo")
        .arg(program)
        .arg("512M")
        .arg("2")
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status();

    match status {
        Ok(s) => {
            if s.success() {
                info!("memtester completed successfully.");
            } else {
                info!("memtester failed with exit code: {:?}", s.code());
            }
        },
        Err(e) => {
            info!("Failed to execute memtester: {}", e);
            info!("Make sure it is compiled in ../../memtester/ or installed globally.");
        }
    }
}

fn main() {
    println!("Hello, world!");
    run_memtester();
}
