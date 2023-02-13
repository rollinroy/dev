#!/bin/bash

grep "^[0-9]" test_Q052452505.txt | awk '{print $2,$3,$4,$5}' | grep "\S" | grep -v "Seattle\|Incoming\|Toll\|Voice\|Carson" | awk '{print $3,$4}' |sort -k 2 | uniq -c
# April-May
# clean up to list just the txn's
grep -v "104570860\|^[0-9][0-9]\/" message_Q052452505.txt |grep "^[0-9]" | grep "\S" |  more

# cleanup and get count
grep -v "104570860\|^[0-9][0-9]\/" message_AprMay.txt |grep "^[0-9]" | grep "\S" | awk '{print $4,$5}' |sort -k 2 | uniq -c
echo April-May Messages > Summary_AprilMay_Msgs.txt;grep -v "104570860\|^[0-9][0-9]\/" message_AprMay.txt |grep "^[0-9]" | grep "\S" | awk '{print $4,$5}' |sort -k 2 | uniq -c >> Summary_AprilMay_Msgs.txt

echo April-May Messages > Summary_MayJune_Msgs.txt;grep -v "104570860\|^[0-9][0-9]\/" message_MayJune.txt |grep "^[0-9]" | grep "\S" | awk '{print $4,$5}' |sort -k 2 | uniq -c >> Summary_MayJune_Msgs.txt

echo April-May Messages > Summary_JuneJuly_Msgs.txt;grep -v "104570860\|^[0-9][0-9]\/" message_JuneJuly.txt |grep "^[0-9]" | grep "\S" | awk '{print $4,$5}' |sort -k 2 | uniq -c >> Summary_JuneJuly_Msgs.txt

echo April-May Messages > Summary_All_Msgs.txt;awk '{print $4,$5}' messages_all.txt |sort -k 2 | uniq -c >> Summary_All_Msgs.txt
