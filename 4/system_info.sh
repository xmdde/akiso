#!bin/bash

cols=$(tput cols)
max_bar_width=$((cols - 20))
bytes_in=()
bytes_out=()
plot="■"
width_in=0
width_out=0

display_uptime () {
	time=$(cat /proc/uptime)
	time=${time% *}
	time=${time%.*}
	day=$((time/86400))
	time=$((time%86400))
	hour=$((time/3600))
	time=$((time%3600))
	min=$((time/60))
	sec=$((time%60))
	printf "UPTIME: $day d $hour h $min m $sec s\n"
}

battery_percent () {
	local percent=$(cat /sys/class/power_supply/BAT0/uevent | grep "POWER_SUPPLY_CAPACITY=")
	local percent=${percent#"POWER_SUPPLY_CAPACITY="}
	echo "BATTERY: $percent%"
}

loadavg () {
	printf "LOAD: "
	cat /proc/loadavg
}

meminfo () {
	cat /proc/meminfo | grep "Mem"
}

cpu_usage () {
	cpu0arr=($(cat /proc/stat | grep "cpu0"))
	cpu1arr=($(cat /proc/stat | grep "cpu1"))
	total0=0
	total1=0
	idle0=${cpu0arr[4]}
	idle1=${cpu1arr[4]}
	for ((i=1; i<11; i++))
	do
	    total0=$((total0+cpu0arr[i]))
	    total1=$((total1+cpu1arr[i]))
	done

	util0=$((100-((idle0-idle0_old)*100)/(total0-total0_old)))
	util1=$((100-((idle1-idle1_old)*100)/(total1-total1_old)))
	freq=($(cat /proc/cpuinfo | grep "cpu MHz"))
	echo "CPU0 UTILIZATION: $util0%  FREQUENCY: ${freq[3]}"
	echo "CPU1 UTILIZATION: $util1%  FREQUENCY: ${freq[7]}"
	total1_old=$total1
	idle1_old=$idle1
	total0_old=$total0
        idle0_old=$idle0

}

set_max () {
	if [[ ${bytes_in[$((num-1))]} -gt $max ]]; then
		max=${bytes_in[$((num-1))]}
	fi
	if [[ ${bytes_out[$((num-1))]} -gt $max ]]; then
		max=${bytes_in[$((num-1))]}
	fi
}

convert () {
	local val=$1
	if [[ $val -gt 1024 ]]; then
	   if [[ $val -gt 1048576 ]]; then
	   	val=$((val/1048576))
		printf "$val""MB/s"
	   else
	   val=$((val/1024))
	   printf "$val""kB/s"
	   fi
	else printf "$val""B/s"
	fi
}

draw () {
printf "UPLOAD ⇧ AND DOWLOAD ⇩ SPEED:\n"
printf "s ago |"
for ((i=$num-1; i>=0; i--))
do
	if [[ $max -gt 0 ]]; then
	width_in=$(((bytes_in[i]*max_bar_width)/max))
	width_out=$(((bytes_out[i]*max_bar_width)/max))
	fi

	printf "\n$i | ⇩ "
	for ((j=0; j<$width_in; j++))
	do
	printf $plot
	done
	convert ${bytes_in[i]}

	printf "\n$i | ⇧ "
	for ((j=0; j<$width_out; j++))
        do
        printf $plot
        done
	convert ${bytes_out[i]}
done
}

init_values () {
	max=0
	num=0
	network_arr=($(cat /proc/net/dev | grep "eth0"))
	old_in=${network_arr[1]}
	old_out=${network_arr[9]}

	cpu0_arr=($(cat /proc/stat | grep "cpu0"))
	cpu1_arr=($(cat /proc/stat | grep "cpu1"))
	idle0_old=${cpu0_arr[4]}
	idle1_old=${cpu1_arr[4]}
	total0_old=0
	total1_old=0
	for ((i=1; i<11; i++))
	do
    	  total0_old=$((total0_old+cpu0arr[i]))
    	  total1_old=$((total1_old+cpu1arr[i]))
	done
}

clear
init_values

while :
do
sleep 1

for ((i=0; i<$cols; i++))
do
    printf "-"
done

network_arr=($(cat /proc/net/dev | grep "eth0"))
now_in=${network_arr[1]}
now_out=${network_arr[9]}
bytes_in[$num]=$((now_in-old_in))
bytes_out[$num]=$((now_out-old_out))
num=$((num+1))

set_max
draw
printf "\n\n"

display_uptime
battery_percent
loadavg
meminfo
cpu_usage

old_in=$now_in
old_out=$now_out
done
