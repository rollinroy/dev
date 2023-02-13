#!/bin/bash
R=/Users/royboy/tmp
FILES="$R/x $R/y.z $R/t.w"
for i in $( echo $FILES ); do
   echo $i
done
