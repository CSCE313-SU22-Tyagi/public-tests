#!/bin/bash

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

echo -e "\nTesting :: client opens pipes\n"
remake

timeout 2 ./server >/dev/null 2>&1 &
timeout 1 strace -e trace=openat -f -o test-files/trace ./client -n Ali -i 8361 >/dev/null 2>&1
wait
cat test-files/trace | grep pipe_ | sed 's/[0-9]* //1' | sed 's/ = [0-9]*//1' > test-files/out_client.txt
if diff -qwB test-files/out_client.txt test-files/test_0.txt; then
    echo -e "   ${GREEN}Passed${NC}"
else
    echo -e "   ${RED}Failed${NC}"
fi

echo -e "\nTesting :: ./server & ./client -n Ali -i 8361\n"
remake
timeout 2 ./server > test-files/out_server.txt 2>/dev/null &
timeout 2 ./client -n Ali -i 8361 > test-files/out_client.txt 2>/dev/null
wait
if diff -q test-files/out_server.txt test-files/test_1_server.txt; then
    echo -e "   ${ORANGE}Server  -  ${GREEN}Passed${NC}"
else
    echo -e "   ${ORANGE}Server  -  ${RED}Failed${NC}"
fi

echo -e "\n"

if diff -q test-files/out_client.txt test-files/test_1_client.txt; then
    echo -e "   ${ORANGE}Client  -  ${GREEN}Passed${NC}"
else
    echo -e "   ${ORANGE}Client  -  ${RED}Failed${NC}"
fi

echo -e "\nTesting :: ./server & ./client -n Kyle -i 9851\n"
remake
timeout 2 ./server > test-files/out_server.txt 2>/dev/null &
timeout 2 ./client -n Kyle -i 9851 > test-files/out_client.txt 2>/dev/null
wait
if diff -q test-files/out_server.txt test-files/test_2_server.txt; then
    echo -e "   ${ORANGE}Server  -  ${GREEN}Passed${NC}"
else
    echo -e "   ${ORANGE}Server  -  ${RED}Failed${NC}"
fi

echo -e "\n"

if diff -q test-files/out_client.txt test-files/test_2_client.txt; then
    echo -e "   ${ORANGE}Client  -  ${GREEN}Passed${NC}"
else
    echo -e "   ${ORANGE}Client  -  ${RED}Failed${NC}"
fi

echo -e "\nTesting :: ./server & ./client -n Kyle -i 0000\n"
remake
timeout 2 ./server >test-files/out_server.txt 2>/dev/null &
timeout 2 ./client -n Kyle -i 0000 > test-files/out_client.txt 2>/dev/null
if diff -q test-files/out_server.txt test-files/test_3_server.txt; then
wait
    echo -e "   ${ORANGE}Server  -  ${GREEN}Passed${NC}"
else
    echo -e "   ${ORANGE}Server  -  ${RED}Failed${NC}"
fi

echo -e "\n"

if diff -q test-files/out_client.txt test-files/test_3_client.txt; then
    echo -e "   ${ORANGE}Client  -  ${GREEN}Passed${NC}"
else
    echo -e "   ${ORANGE}Client  -  ${RED}Failed${NC}"
fi

echo -e "\nTesting :: ./server & ./client -n Someone -i 9851\n"
remake
timeout 2 ./server >test-files/out_server.txt 2>/dev/null &
timeout 2 ./client -n Someone -i 9851 > test-files/out_client.txt 2>/dev/null
wait
if diff -q test-files/out_server.txt test-files/test_4_server.txt; then
    echo -e "   ${ORANGE}Server  -  ${ORANGE}${GREEN}Passed${NC}"
else
    echo -e "   ${ORANGE}Server  -  ${ORANGE}${RED}Failed${NC}"
fi

echo -e "\n"

if diff -q test-files/out_client.txt test-files/test_4_client.txt; then
    echo -e "   ${ORANGE}Client  -  ${ORANGE}${GREEN}Passed${NC}"
else
    echo -e "   ${ORANGE}Client  -  ${ORANGE}${RED}Failed${NC}"
fi

echo -e "\n"

exit 0