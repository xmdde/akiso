#!/bin/bash
cd $1
hash=()
path=()
size=()
num=0
list=()
duplicates=()

add_data () {
for file in *
do
if [[ -f $file ]]; then
        read tmp <<< $(sha256sum $file)
        read hash[num] <<< ${tmp% *}
        read path[num] <<< $(realpath $file)
        read size[num] <<< $(stat -c%s $file)
        read list[num] <<< "${hash[num]}"" ""${path[num]}"" ""${size[num]}"
        num=$((num + 1))
fi

if [[ -d $file ]]; then
        cd $file
        add_data
        cd ..
fi
done
}
 
bubble_sort () {
for ((i = 0; i<$num; i++))
do
    
    for((j = 0; j<$num-i-1; j++))
    do
        if [ "${list[j]}" \> "${list[$((j+1))]}" ]
        then
            temp=${list[j]}
            list[$j]=${list[$((j+1))]}  
            list[$((j+1))]=$temp
        fi
    done
done
}

dp1 () {
num_of_d=0
for((i = 0; i<$num-1; i++))
do
        tmpa=(${list[i]})
        a=${tmpa[0]}
        tmpb=(${list[$((i+1))]})
        b=${tmpb[0]}

        if [ $a == $b ]
        then
            read duplicates[num_of_d] <<< "${tmpa[2]}"" ""${tmpa[1]}"" ""${tmpb[1]}"
            num_of_d=$((num_of_d + 1))
        fi
done
}

bubble_sort_duplicates () {
for ((i = 0; i<$num_of_d; i++))
do

    for((j = 0; j<$num_of_d-i-1; j++))
    do
        tmpa=(${duplicates[j]})
        a=${tmpa[0]}
        tmpb=(${duplicates[$((j+1))]})
        b=${tmpb[0]}

        if [ $a -lt $b ]
        then
            temp=${duplicates[j]}
            duplicates[$j]=${duplicates[$((j+1))]}
            duplicates[$((j+1))]=$temp
        fi
    done
done
}

add_data
bubble_sort
echo "duplikaty:"
dp1
bubble_sort_duplicates
for ((i = 0; i<$num_of_d; i++))
do
    echo ${duplicates[$i]}
done