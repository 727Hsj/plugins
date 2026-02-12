#!/bin/bash

# 系统监控脚本 - 适用于飞腾/麒麟 (ARM64)
# CPU、内存、温度、进程TOP 全屏实时显示

# 清屏并隐藏光标
clear
tput civis

# 退出时恢复光标
trap 'tput cnorm; clear; exit' INT TERM EXIT

while true; do
    # 获取系统时间
    time_now=$(date "+%Y-%m-%d %H:%M:%S")
    
    # 获取CPU利用率（1秒采样）
    cpu_stat1=$(cat /proc/stat | grep '^cpu ' | head -1)
    sleep 0.5
    cpu_stat2=$(cat /proc/stat | grep '^cpu ' | head -1)
    
    cpu_idle1=$(echo $cpu_stat1 | awk '{print $5}')
    cpu_total1=$(echo $cpu_stat1 | awk '{print $2+$3+$4+$5+$6+$7+$8}')
    cpu_idle2=$(echo $cpu_stat2 | awk '{print $5}')
    cpu_total2=$(echo $cpu_stat2 | awk '{print $2+$3+$4+$5+$6+$7+$8}')
    
    cpu_delta=$((cpu_total2 - cpu_total1))
    idle_delta=$((cpu_idle2 - cpu_idle1))
    
    if [ $cpu_delta -ne 0 ]; then
        cpu_usage=$((100 * (cpu_delta - idle_delta) / cpu_delta))
    else
        cpu_usage=0
    fi
    
    # 获取内存信息
    mem_info=$(cat /proc/meminfo)
    mem_total=$(echo "$mem_info" | grep 'MemTotal:' | awk '{print $2}')
    mem_free=$(echo "$mem_info" | grep 'MemFree:' | awk '{print $2}')
    mem_available=$(echo "$mem_info" | grep 'MemAvailable:' | awk '{print $2}')
    
    mem_total_gb=$(echo "scale=2; $mem_total/1024/1024" | bc)
    mem_used_gb=$(echo "scale=2; ($mem_total - $mem_available)/1024/1024" | bc)
    mem_usage=$((100 * (mem_total - mem_available) / mem_total))
    
    # 获取CPU温度
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        temp_raw=$(cat /sys/class/thermal/thermal_zone0/temp)
        temp_c=$(echo "scale=1; $temp_raw/1000" | bc)
    else
        temp_c="N/A"
    fi
    
    # 获取负载平均值
    load_avg=$(cat /proc/loadavg | awk '{print $1", "$2", "$3}')
    
    # 获取进程TOP 5 (按CPU)
    top_cpu=$(ps -eo pid,comm,%cpu,%mem,user --sort=-%cpu | head -6 | tail -5)
    
    # 获取进程TOP 5 (按内存)
    top_mem=$(ps -eo pid,comm,%cpu,%mem,user --sort=-%mem | head -6 | tail -5)
    
    # 开始绘制界面
    echo -e "\033[1;36m╔════════════════════════════════════════════════════════════════╗\033[0m"
    echo -e "\033[1;36m║\033[1;37m             麒麟系统实时监控 - 飞腾平台                      \033[1;36m║\033[0m"
    echo -e "\033[1;36m╠════════════════════════════════════════════════════════════════╣\033[0m"
    echo -e "\033[1;36m║\033[0m 系统时间: $time_now                                          \033[1;36m║\033[0m"
    echo -e "\033[1;36m║\033[0m 负载平均: $load_avg                                          \033[1;36m║\033[0m"
    echo -e "\033[1;36m╠════════════════════════════════════════════════════════════════╣\033[0m"
    
    # CPU信息
    echo -e "\033[1;36m║\033[1;33m CPU利用率\033[0m"
    echo -e "\033[1;36m║\033[0m ┌────────────────────────────────────────────────────────┐"
    echo -e "\033[1;36m║\033[0m │ 使用率: ${cpu_usage}%                                      │"
    
    # CPU进度条
    bar_length=50
    filled=$((cpu_usage * bar_length / 100))
    bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=filled; i<bar_length; i++)); do bar="${bar}░"; done
    
    if [ $cpu_usage -lt 30 ]; then
        echo -e "\033[1;36m║\033[0m │ [\033[32m$bar\033[0m] $cpu_usage%  \033[32m✓ 轻载\033[0m    │"
    elif [ $cpu_usage -lt 60 ]; then
        echo -e "\033[1;36m║\033[0m │ [\033[33m$bar\033[0m] $cpu_usage%  \033[33m⚠ 正常\033[0m    │"
    else
        echo -e "\033[1;36m║\033[0m │ [\033[31m$bar\033[0m] $cpu_usage%  \033[31m✗ 高负载\033[0m   │"
    fi
    echo -e "\033[1;36m║\033[0m └────────────────────────────────────────────────────────┘"
    
    # 内存信息
    echo -e "\033[1;36m║\033[1;33m 内存使用\033[0m"
    echo -e "\033[1;36m║\033[0m ┌────────────────────────────────────────────────────────┐"
    echo -e "\033[1;36m║\033[0m │ 已用: ${mem_used_gb}GB / 总计: ${mem_total_gb}GB (${mem_usage}%)               │"
    
    # 内存进度条
    filled=$((mem_usage * bar_length / 100))
    bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=filled; i<bar_length; i++)); do bar="${bar}░"; done
    
    if [ $mem_usage -lt 50 ]; then
        echo -e "\033[1;36m║\033[0m │ [\033[32m$bar\033[0m] $mem_usage%  \033[32m✓ 充足\033[0m    │"
    elif [ $mem_usage -lt 80 ]; then
        echo -e "\033[1;36m║\033[0m │ [\033[33m$bar\033[0m] $mem_usage%  \033[33m⚠ 正常\033[0m    │"
    else
        echo -e "\033[1;36m║\033[0m │ [\033[31m$bar\033[0m] $mem_usage%  \033[31m✗ 不足\033[0m    │"
    fi
    echo -e "\033[1;36m║\033[0m └────────────────────────────────────────────────────────┘"
    
    # CPU温度
    echo -e "\033[1;36m║\033[1;33m CPU温度\033[0m"
    echo -e "\033[1;36m║\033[0m ┌────────────────────────────────────────────────────────┐"
    if [ "$temp_c" != "N/A" ]; then
        echo -e "\033[1;36m║\033[0m │ 当前温度: ${temp_c}°C                                          │"
        
        # 温度进度条
        temp_int=$(echo $temp_c | cut -d. -f1)
        if [ $temp_int -gt 80 ]; then temp_int=80; fi
        filled=$((temp_int * bar_length / 80))
        bar=""
        for ((i=0; i<filled; i++)); do bar="${bar}█"; done
        for ((i=filled; i<bar_length; i++)); do bar="${bar}░"; done
        
        if [ $temp_int -lt 50 ]; then
            echo -e "\033[1;36m║\033[0m │ [\033[32m$bar\033[0m] ${temp_c}°C  \033[32m✓ 正常\033[0m    │"
        elif [ $temp_int -lt 70 ]; then
            echo -e "\033[1;36m║\033[0m │ [\033[33m$bar\033[0m] ${temp_c}°C  \033[33m⚠ 偏高\033[0m    │"
        else
            echo -e "\033[1;36m║\033[0m │ [\033[31m$bar\033[0m] ${temp_c}°C  \033[31m✗ 过热\033[0m    │"
        fi
    else
        echo -e "\033[1;36m║\033[0m │ 无法读取温度传感器                        │"
    fi
    echo -e "\033[1;36m║\033[0m └────────────────────────────────────────────────────────┘"
    
    # CPU TOP 5
    echo -e "\033[1;36m║\033[1;33m CPU TOP 5进程\033[0m"
    echo -e "\033[1;36m║\033[0m ┌────────────────────────────────────────────────────────┐"
    echo -e "\033[1;36m║\033[0m │ PID  名称                CPU%  内存%  用户              │"
    echo -e "\033[1;36m║\033[0m ├────────────────────────────────────────────────────────┤"
    IFS=$'\n'
    count=0
    for proc in $top_cpu; do
        if [ $count -lt 5 ]; then
            pid=$(echo $proc | awk '{printf "%-6s", $1}')
            name=$(echo $proc | awk '{print $2}' | cut -c1-15)
            cpu=$(echo $proc | awk '{printf "%-6s", $3}')
            mem=$(echo $proc | awk '{printf "%-6s", $4}')
            user=$(echo $proc | awk '{print $5}' | cut -c1-8)
            printf "\033[1;36m║\033[0m │ %-6s %-18s %-6s %-6s %-8s │\n" "$pid" "$name" "$cpu" "$mem" "$user"
        fi
        ((count++))
    done
    echo -e "\033[1;36m║\033[0m └────────────────────────────────────────────────────────┘"
    
    # 内存 TOP 5
    echo -e "\033[1;36m║\033[1;33m 内存 TOP 5进程\033[0m"
    echo -e "\033[1;36m║\033[0m ┌────────────────────────────────────────────────────────┐"
    echo -e "\033[1;36m║\033[0m │ PID  名称                CPU%  内存%  用户              │"
    echo -e "\033[1;36m║\033[0m ├────────────────────────────────────────────────────────┤"
    count=0
    for proc in $top_mem; do
        if [ $count -lt 5 ]; then
            pid=$(echo $proc | awk '{printf "%-6s", $1}')
            name=$(echo $proc | awk '{print $2}' | cut -c1-15)
            cpu=$(echo $proc | awk '{printf "%-6s", $3}')
            mem=$(echo $proc | awk '{printf "%-6s", $4}')
            user=$(echo $proc | awk '{print $5}' | cut -c1-8)
            printf "\033[1;36m║\033[0m │ %-6s %-18s %-6s %-6s %-8s │\n" "$pid" "$name" "$cpu" "$mem" "$user"
        fi
        ((count++))
    done
    echo -e "\033[1;36m║\033[0m └────────────────────────────────────────────────────────┘"
    
    # 底部提示
    echo -e "\033[1;36m╠════════════════════════════════════════════════════════════════╣\033[0m"
    echo -e "\033[1;36m║\033[0m 按 \033[1;33mCtrl+C\033[0m 退出 | 风扇转速: \033[1;31m硬件未暴露接口，无法读取\033[0m       \033[1;36m║\033[0m"
    echo -e "\033[1;36m╚════════════════════════════════════════════════════════════════╝\033[0m"
    
    sleep 2
done