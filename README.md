# plugins
Learn how to use various plugins

## how to use
1. in Cargo.toml， add deps what you want to use, such as `stressapptest_demo = { workspace = true }`
2. in src/main.rs, modify some codes to use your plugins.


## 种类
1. 系统压力与稳定性         stressapptest、memtester
2. CPU/内存/中断异常        systemTap、retsnoop、内核中断快照
3. 硬件状态 (温度/电压)     lm-sensors
4. 应用内存泄露/非法访问     Valgrind (Memcheck)
5. 应用依赖与安全	        Hipcheck
6. 系统遥测与报告	        Clear Linux Telemetry
