#!/bin/bash
COUNTER=0
for f in `find . -type f -name '*.jpg'|xargs stat -f '%c %N'|sort|awk '{print $2}'| sed '1,$s/.\///g'`; do
#for f in * ; do
    let COUNTER++
#    echo counter: $COUNTER
    echo new file "${COUNTER}_$f"
    mv -- "$f" "${COUNTER}_$f"
done
