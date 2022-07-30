#!/usr/bin/env bash

# function to clean up files and make executables
remake () {
    #echo -e "\nCleaning old files and making executables"
    make -s >/dev/null 2>&1
    make -C test-files/ -s >/dev/null 2>&1
}

# function to check for FIFO channel files
checkclean () {
    if [ "$1" = "f" ]; then
        if [ "$(find . -type p)" ]; then
            #echo "Failed to close FIFORequestChannel - removing for next test"
            find . -type p -exec rm {} +
        fi
    else
        echo "something broke"
        exit 1
    fi
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

SCORE=0
#echo -e "\nTest cases for LE6"

remake
echo -e "\nTesting :: Compilation\n"
echo -e "  ${GREEN}Passed${NC}" # if you've made it this far, it's compiling
SCORE=$(($SCORE+5))

echo -e "\nTesting :: Use of Signals\n"
strace -o trace.tst ./client -f 3.csv >out1.tst 2>/dev/null
if [ $(grep 'CLONE_SIGHAND' trace.tst | wc -l) -gt 2 ]; then
    echo -e "  ${GREEN}Passed${NC}"
    SCORE=$(($SCORE+20))
else
    echo -e "  ${RED}Incorrect use of signals${NC}"
fi

remake
#echo -e "\nTest cases for signal output"

echo -e "\nTesting :: ./client -f 5.csv \n"
N=1000
P=5
./client -f 5.csv >out.tst
if [ $(comm -12 <(sort out.tst) <(sort test-files/file_good.txt) | wc -l) -eq $(cat test-files/file_good.txt | wc -l) ]; then
    echo -e "  ${GREEN}Passed${NC}"
    SCORE=$(($SCORE+15))
else
    echo -e "  ${RED}Failed${NC}"
fi
checkclean "f"

remake
echo -e "\nTesting :: ./client -f 17.csv \n"
N=1000
P=5
./client -f 17.csv >out.tst
if [ $(comm -12 <(sort out.tst) <(sort test-files/file_bad.txt) | wc -l) -eq $(cat test-files/file_bad.txt | wc -l) ]; then
    echo -e "  ${GREEN}Passed${NC}"
    SCORE=$(($SCORE+15))
else
    echo -e "  ${RED}Failed${NC}"
fi
checkclean "f"

remake
echo -e "\nTesting :: ./client -p 17 -n 1000 -h 10 -b 10 -w 100 \n"
N=1000
P=5
./client ./client -p 17 -n 1000 -h 10 -b 10 -w 100 >out.tst
if [ $(comm -12 <(sort out.tst) <(sort test-files/patient_bad.txt) | wc -l) -eq $(cat test-files/patient_bad.txt | wc -l) ]; then
    echo -e "  ${GREEN}Passed${NC}"
    SCORE=$(($SCORE+15))
else
    echo -e "  ${RED}Failed${NC}"
fi
checkclean "f"

# if code has to kill thread itself, then fail
remake
echo -e "\nTesting :: Threads Close Correctly\n"
strace >/dev/null -o out.trace ./client -p 5 -w 100 -b 10 -h 100 2>&1 >/dev/null
if cat out.trace | egrep -q "tgkill|tkill"; then
    echo -e "  ${RED}Failed${NC}"
else
    echo -e "  ${GREEN}Passed${NC}"
    SCORE=$(($SCORE+20))
fi

# if returns a fail then memory leak
remake
echo -e "\nTesting :: Memory Leakage\n"
if ./client -p 5 -w 100 -b 10 -h 100 2>&1 >/dev/null; then
    echo -e "  ${GREEN}Passed${NC}"
    SCORE=$(($SCORE+10))
else
    echo -e "  ${RED}Failed${NC}"
fi

echo -e "\nSCORE: ${SCORE}/100\n"
echo -e "\n"
make -s clean
exit 0
