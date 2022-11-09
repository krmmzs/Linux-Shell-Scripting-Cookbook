#!/bin/bash

data="name, gender, age, country"

oldIFS=$IFS
IFS=","
for item in $data
do
    echo Item: "$item"
done

IFS=$oldIFS
