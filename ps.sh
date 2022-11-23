#!/bin/bash
echo "PPID|PID|Comm|State|TTY|RSS|PGID|SID|Files" >> /home/user/tmp.txt
cd /proc

for FILE in $(ls | grep '[0-9]')
do

if [ -e $FILE ]
then
	cd $FILE
	read test <<< $(cat stat)
	arr=( $test )
	read files <<< $(sudo ls -l fd | wc -l)
	echo ${arr[3]} "|" ${arr[0]} "|" ${arr[1]} "|" ${arr[2]} "|" ${arr[6]} "|" ${arr[23]} "|" 
${arr[4]} "|" ${arr[5]} "|" $files >> /home/user/tmp.txt
	cd ..
fi
done
column /home/user/tmp.txt -t -s "|"
rm /home/user/tmp.txt
