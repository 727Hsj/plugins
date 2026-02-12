# lmsensors Demo 插件使用说明


## lmsensors 插件介绍

参考连接
https://blog.csdn.net/gitblog_00988/article/details/155155444
https://gitcode.com/gh_mirrors/lm/lm-sensors

### 介绍
lm_sensors是一款linux的硬件监控的软件，可以帮助我们来监控主板，CPU的工作电压，风扇转速、温度等数据。
这些数据我们通常在主板的 BIOS也可以看到。当我们可以在机器运行的时候通过lm_sensors随时来监测着CPU的温度变化，可以预防和保护因为CPU过热而会烧掉。

### 使用方法
在飞腾平台上，执行 sudo sensors-detect，结果是

``` c
Sorry, no sensors were detected.
This is relatively common on laptops, where thermal management is
handled by ACPI rather than the OS.

```

很多笔记本电脑（尤其是 ARM/飞腾平台）的温度、风扇控制完全由 ACPI 和 EC 管理

操作系统不需要、也无法通过 lm-sensors 直接读取

这不是失败，而是设计如此


直接 sudo apt install psensor，这个 gui 有显示 cpu 温度，cpu usage, free mem, fan speed.

也可以写一个脚本，但是 风扇转速（极大概率无解）飞腾笔记本，读不到风扇转速 (ai分析了 lmsensors psensor 等很多上下文)。
