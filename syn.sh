#!/bin/sh
Synchronization()
{
local dir1=$1
local dir2=$2
for i in "$dir1"/*
do
i=${i##/}
echo "Viewed file: " $dir1/$i
if [ -f "$dir2/$i" ] && [ -f "$dir1/$i" ]; then
    echo "CONFLICT"
    echo "\t" 1 Date of last mod: "$dir1/$i:" $(date -r "$dir1/$i")
    echo "\t" 2 Date of last mod: "$dir2/$i:" $(date -r "$dir2/$i")
    exec 3>&1
    result=$(gdialog --title "CONFLICT" --menu "Which file?" 15 80 2 1 "$dir1/$i: $(date -r "$dir1/$i")"  2 "$dir2/$i: $(date -r "$dir2/$i")"  2>&1 1>&3)
    echo "result=" $result
    case "$result" in
           '1')
           cp "$dir1/$i" "$dir2/$i"
           ;;
           '2')
           cp "$dir2/$i" "$dir1/$i"
           ;;
    esac
    exec 3>&-
    echo "\n"
    continue
elif [ -d "$dir2/$i" ] && [ -d "$dir1/$i" ]; then
    echo "DIVE TO $i"
    Synchronization "$dir1/$i" "$dir2/$i"
    continue
fi
cp -r "$dir1/$i" "$dir2/$i"
done
for j in "$dir2"/
do
j=${j##*/}
echo "Viewed file: " $dir2/$j
if [ ! -e "$dir1/$j" ]; then
    echo NOT EXISTS IN DIR1 $dir2/$j
    cp -r "$dir2/$j" "$dir1/$j"
fi
done
echo "\n"
}

directory1="/home/username/LAB"
directory2="/media/username/KINGSTON/LAB"
echo dir1 is $directory1
echo dir2 is $directory2
if [ ! -d "$directory1" ]; then
    echo "directory $directory1 does not exist"
fi

if [ ! -d "$directory2" ]; then
    echo "directory $directory2 does not exist"
fi
[ -d "$directory1" ] && [ -d "$directory2" ] && Synchronization $directory1 $directory2
