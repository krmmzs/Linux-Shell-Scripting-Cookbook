#!/bin/bash

rename 's/ /_/g' *.mkv
count=1;
for img in $(find . -iname '*.png' -o -iname '*.jpg' -o -type f -maxdepth 1)
do
    new=image-$count.${img##*.}

    echo "Renaming $img to $new"
    mv "$img" "$new"
    let count++
done
