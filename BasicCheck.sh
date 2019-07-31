#!/bin/bash
errorArray=(1 1 1)
statusArray=("FAIL" "FAIL" "FAIL")
lastStatus=0;
returnCode=7;
path=$1;
program=$2;
shift 2
echo Searching for a makefile at: $path;
cd $path;
make > /dev/null 2>&1
lastStatus=$?

if [ $lastStatus -ne 0 ]; then
    echo "File not found!";
else
     echo "File found!";
     errorArray[0]=0;
     statusArray[0]="PASS"
     echo "Success! $lastStatus";
     valgrind --tool=memcheck --leak-check=full --error-exitcode=1 ./$program "$@"> /dev/null 2>&1
     lastStatus=$?
     echo "\n $path$program"
     if [ $lastStatus -ne 0 ]; then
          echo "valgrind failed $lastStatus"
     else
          echo "valgrind success $lastStatus"
          errorArray[1]=0;
          statusArray[1]="PASS"
     fi
     valgrind  --tool=helgrind --error-exitcode=1 ./$program "$@" > /dev/null 2>&1	
     lastStatus=$?
     if [ $lastStatus -ne 0 ]; then
          echo "helgrind failed $lastStatus"
     else
          echo "helgrind success $lastStatus"
          errorArray[2]=0;
          statusArray[2]="PASS"
     fi
fi
returnCode=$((${errorArray[0]}*4+${errorArray[1]}*2+${errorArray[2]}));
echo "    Compilation    Memory leaks   thread race";
echo "        ${statusArray[0]}           ${statusArray[1]}           ${statusArray[2]}"
echo $returnCode;
exit $returnCode;
