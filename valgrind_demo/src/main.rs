use log::*;
use std::alloc::{Layout, alloc, dealloc};

fn main() {
    println!("Valgrind demo: Triggering a Use-After-Free error...");

    unsafe {
        // 1. 手动分配内存 (类似 C 的 malloc)
        let layout = Layout::new::<u8>();
        let ptr = alloc(layout);

        *ptr = 42; // 正常赋值
        info!("Allocated memory at {:p}, value: {}", ptr, *ptr);

        // 2. 手动释放内存 (类似 C 的 free)
        dealloc(ptr, layout);
        info!("Memory freed.");
        // 3. 释放后再次使用 (Use-After-Free)
        // Rust 运行时通常不会捕捉这个（不像空指针有明确检查），
        // 但 Valgrind 会非常精确地报错。
        info!("Attempting to write to freed memory...");
        *ptr = 100; // <--- 这里是错误点  Invalid write 

        info!(
            "Wrote {} to freed memory. (If you see this, Valgrind should have logged many errors)",
            *ptr
        ); // <--- 这里是错误点  Invalid read 
    }
}
