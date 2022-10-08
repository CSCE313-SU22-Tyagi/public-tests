#!/usr/bin/env bash

# function to clean up files and make executables
remake () {
    #echo -e "\nCleaning old files and making executables"
    make -s clean
    make -s >/dev/null 2>&1
}


echo -e "To remove colour from tests, set COLOUR to 1 in sh file\n"
COLOUR=0
if [[ COLOUR -eq 0 ]]; then
    ORANGE='\033[0;33m'
    GREEN='\033[0;32m'
    RED='\033[0;31m'
    NC='\033[0m'
else
    ORANGE='\033[0m'
    GREEN='\033[0m'
    RED='\033[0m'
    NC='\033[0m'
fi

echo -e "\nTesting :: ./client Gabriel 6 7 (request)\n"
remake
./server | grep "Server received" >test-files/out.txt 2>/dev/null &
./client Gabriel 6 7 >/dev/null 2>&1
wait
if diff test-files/out.txt test-files/test_1.txt; then
    echo -e "  ${GREEN}Passed${NC}"
else
    echo -e "  ${RED}Failed${NC}"
fi

echo -e "\nTesting :: ./client Gabriel 6 7 (reply)\n"
remake
./server >/dev/null 2>&1 &
./client Gabriel 6 7 | grep "Client received" > test-files/out.txt 2>/dev/null
wait
if diff test-files/out.txt test-files/test_2.txt; then
    echo -e "  ${GREEN}Passed${NC}"
else
    echo -e "  ${RED}Failed${NC}"
fi

echo -e "\nTesting :: ./client \"Test Subject\" 4 1 (request)\n"
remake
./server | grep "Server received" >test-files/out.txt 2>/dev/null &
./client "Test Subject" 4 1 >/dev/null 2>&1
wait
if diff test-files/out.txt test-files/test_3.txt; then
    echo -e "  ${GREEN}Passed${NC}"
else
    echo -e "  ${RED}Failed${NC}"
fi

echo -e "\nTesting :: ./client \"Test Subject\" 4 1 (reply)\n"
remake
./server >/dev/null 2>&1 &
./client "Test Subject" 4 1 | grep "Client received" > test-files/out.txt 2>/dev/null
wait
if diff test-files/out.txt test-files/test_4.txt; then
    echo -e "  ${GREEN}Passed${NC}"
else
    echo -e "  ${RED}Failed${NC}"
fi

exit 0
