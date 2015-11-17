#!/bin/bash

for file in ../test_suite/*.finl
do
	FILENAME=${file##*/}
	echo "Compiling $FILENAME ..."
	EXECUTABLE="${FILENAME%.*}"
	./finlc $file
	echo "Running $EXECUTABLE ..."
	./finl.sh $EXECUTABLE > "$EXECUTABLE.log"
	DIFF=$(diff $EXECUTABLE.log ../test_suite/$EXECUTABLE.out)
	if [ "$DIFF" = "" ]
		then echo "$EXECUTABLE passed."
	else echo "$EXECUTABLE failed."
	fi
done