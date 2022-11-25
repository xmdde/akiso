#!/bin/bash
for name in *
do
        if [[ -f $name ]]; then
        newname=$(echo $name | tr '[:upper:]' '[:lower:]')
        mv "./$name" "./$newname"
        fi
done