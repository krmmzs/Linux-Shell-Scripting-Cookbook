# Tangled Web? Not At All!

## Overview

## Image crawler and downloader

图片爬取器（image crawler）可以下载Web页面上所有的图片。不用翻遍页面手动保存图片，我们可以用脚本识别图片并自动下载

```bash
#!/bin/bash
#Filename: img_downloader.sh

if [ $# -ne 3 ];
then
    echo "Usage: $0 URL -d DIRECTORY"
    exit 1
fi

while [ $# -gt 0 ]
do
    case $1 in
        -d) shift; directory=$1; shift;;
        *) url=$1; shift;;
    esac
done

echo "URL: $url"
echo "DIR: $directory"

mkdir -p "$directory";
baseurl=$(echo "$url" | grep -E -o "https?://[a-z.\-]+")
echo Downloading "$url"
curl -s "$url" | grep -E -o "<img src=[^>]*>" | 
    sed 's/<img src=\"\([^"]*\).*/\1/g' |
    sed "s,^/,$baseurl/," > /tmp/$$.list
    cd "$directory";
    while read filename;
    do
        echo Downloading "$filename"
        curl -s -O "$filename" --silent
    done < /tmp/$$.list
```
