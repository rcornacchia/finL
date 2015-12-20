#!/bin/bash

NC='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'

for file in ../test_suite/*.finl
do
	FILENAME=${file##*/}
	printf "${YELLOW}Compiling $FILENAME ...${NC}\n"
	EXECUTABLE="${FILENAME%.*}"
	./finlc $file > "$EXECUTABLE.log" 2>&1
	printf "${YELLOW}Running $EXECUTABLE ...${NC}\n"
	./finl.sh $EXECUTABLE >> "$EXECUTABLE.log" 2>&1
	DIFF=$(diff $EXECUTABLE.log ../test_suite/$EXECUTABLE.out)
	if [ "$DIFF" = "" ]
		then printf "${GREEN}$EXECUTABLE passed.${NC}\n"
	else printf "${RED}$EXECUTABLE failed.${NC}\n"
	fi
done