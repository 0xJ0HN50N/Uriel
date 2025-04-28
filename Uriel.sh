#!/bin/bash

# Get the terminal width
terminal_width=$(tput cols)

# Define ASCII art logo with bold red
logo="
\033[1;31m  _    _        _        _ 
 | |  | |      (_)      | |
 | |  | | _ __  _   ___ | |
 | |  | || '__|| | / _ \| |
 | |__| || |   | ||  __/| |
  \____/ |_|   |_| \___||_|\033[0m
"

# System information fetching
hostname=$(hostname)
os_name=$(lsb_release -d | cut -f2)
kernel=$(uname -r)
uptime=$(uptime -p)
cpu_model=$(lscpu | grep 'Model name' | cut -d: -f2 | sed 's/^ *//g')  # Trim leading spaces
cpu_cores=$(lscpu | grep '^CPU(s):' | cut -d: -f2 | sed 's/^ *//g')
cpu_threads=$(lscpu | grep '^Thread(s) per core:' | cut -d: -f2 | sed 's/^ *//g')
ram=$(free -h | grep Mem | awk '{print $2}')
disk=$(df -h | grep '^/dev' | awk '{print $1 ": " $3 " used, " $2 " total"}' | head -n 1)

# Get the host device name more explicitly
host_device=$(sudo dmidecode -s system-manufacturer)
host_model=$(sudo dmidecode -s system-product-name)

# Combine manufacturer and model for a clearer host device description
full_device_name="$host_device $host_model"

# Check for coreboot and GRUB using the grub.cfg file
coreboot_check=$(dmesg | grep -i "coreboot")
grub_check=$(ls /boot/grub/grub.cfg 2>/dev/null)

# Function to check battery status (if applicable)
function check_battery_status {
    if [[ -d /sys/class/power_supply/BAT0 ]]; then
        battery_status=$(cat /sys/class/power_supply/BAT0/status)
        battery_percentage=$(cat /sys/class/power_supply/BAT0/capacity)
        echo -e "\033[1;33mBattery:\033[0m \033[1;37m$battery_percentage%\033[0m \033[1;32m($battery_status)\033[0m"
    else
        echo -e "\033[1;33mBattery:\033[0m \033[1;31mNot Available\033[0m"
    fi
}

# Function to display system load averages
function display_load_averages {
    load_averages=$(uptime | awk -F'load average:' '{ print $2 }')
    echo -e "\033[1;33mLoad Averages:\033[0m \033[1;37m$load_averages\033[0m"
}

# Function to display fan speeds (if available)
function display_fan_speeds {
    fan_speeds=$(sensors | grep -i "fan" | awk '{print $1 ": " $2}')
    if [[ -n "$fan_speeds" ]]; then
        echo -e "\033[1;33mFan Speeds:\033[0m"
        echo -e "\033[1;37m$fan_speeds\033[0m"
    else
        echo -e "\033[1;33mFan Speeds:\033[0m \033[1;31mNot Available\033[0m"
    fi
}

# Function to check if Libreboot is likely running
function check_libreboot {
    # Check if Coreboot is detected and GRUB is found
    if [[ -n "$coreboot_check" ]] && [[ -n "$grub_check" ]]; then
        echo -e "\033[1;32mLibreboot:\033[0m \033[1;32mLikely Running\033[0m"
    else
        echo -e "\033[1;32mLibreboot:\033[0m \033[1;31mNot Detected\033[0m"
    fi
}

# Start the UI display
clear
echo -e "$logo"  # Bold red logo
echo -e "\033[1;36mSystem Information:\033[0m"
echo "----------------------------------"

# Display Host Device Information
echo -e "\033[1;33mHost Device:\033[0m \033[1;37m$full_device_name\033[0m"

# Display System Information with better formatting and brighter colors
echo -e "\033[1;33mHostname:\033[0m \033[1;37m$hostname\033[0m"
echo -e "\033[1;33mOS:\033[0m \033[1;37m$os_name\033[0m"
echo -e "\033[1;33mKernel:\033[0m \033[1;37m$kernel\033[0m"
echo -e "\033[1;33mUptime:\033[0m \033[1;37m$uptime\033[0m"

# Display CPU information on separate lines
echo -e "\033[1;33mCPU Model:\033[0m \033[1;37m$cpu_model\033[0m"
echo -e "\033[1;33mCPU Cores:\033[0m \033[1;37m$cpu_cores\033[0m"
echo -e "\033[1;33mCPU Threads:\033[0m \033[1;37m$cpu_threads\033[0m"

echo -e "\033[1;33mRAM:\033[0m \033[1;37m$ram\033[0m"
echo -e "\033[1;33mDisk:\033[0m \033[1;37m$disk\033[0m"
echo "----------------------------------"

# Display Coreboot and GRUB information with colored status
if [[ -n "$coreboot_check" ]]; then
    echo -e "\033[1;32mCoreboot:\033[0m \033[1;32mDetected\033[0m"
else
    echo -e "\033[1;32mCoreboot:\033[0m \033[1;31mNot Detected\033[0m"
fi

if [[ -n "$grub_check" ]]; then
    echo -e "\033[1;32mGRUB:\033[0m \033[1;32mDetected\033[0m"
else
    echo -e "\033[1;32mGRUB:\033[0m \033[1;31mNot Detected\033[0m"
fi

# Check if Libreboot is likely running
echo "----------------------------------"
check_libreboot

# Display Battery Status
echo "----------------------------------"
check_battery_status

# Display Fan Speeds
echo "----------------------------------"
display_fan_speeds

# Display Load Averages
echo "----------------------------------"
display_load_averages
echo "----------------------------------"

# Add Footer with author and some styling
echo -e "\033[1;34mMade by 0xJohn5on\033[0m"
echo -e "\033[1;33m----------------------------------\033[0m"