#!/usr/bin/env bash

FILENAME=""
PATTERN=""
MAX=16384

RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
RESET='\033[0m'

clear
echo -e "${CYAN}__________ ________  _____________________${RESET}"
echo -e "${CYAN}\\______   \\\\_____  \\ \\_   _____/\\____    /${RESET}"
echo -e "${CYAN} |    |  _/ /   |   \\ |    __)    /     / ${RESET}"
echo -e "${CYAN} |    |   \\/    |    \\|     \\    /     /_ ${RESET}"
echo -e "${CYAN} |______  /\\_______  /\\___  /   /_______ \\ ${RESET}"
echo -e "${CYAN}        \\/         \\/     \\/            \\/ ${RESET}"
echo -e "${YELLOW}             BOFZ Buffer Overflow Scanner${RESET}"
echo -e "${GREEN}Maptnh@S-H4CK13 https://github.com/MartinxMax ${RESET}"
echo -e '--------------------------------------------------------'

if [ $# -lt 1 ]; then
  echo -e "${RED}[×${RED}[\xd7] Usage: $0 <executable path> [-stack <string>]${RESET}"
  exit 1
fi
 
while [[ "$#" -gt 0 ]]; do
  case $1 in
    -stack)
      shift
      PATTERN="$1"
      ;;
    *)
      FILENAME="$1"
      ;;
  esac
  shift

done

if [ ! -x "$FILENAME" ]; then
  echo -e "${RED}[×${RED}[\xd7] File not executable or not found: $FILENAME${RESET}"
  exit 1
fi

for size in $(seq 1 $MAX); do
  printf "\r${YELLOW}[*] Trying buffer size: %4d ${RESET}" "$size"
  input=$(head -c "$size" </dev/zero | tr '\0' 'A')
  result=$(setsid bash -c "(echo -n \"$input\"; printf '\n') | \"$FILENAME\" 2>&1")
  status=$?

  if [[ -n "$PATTERN" ]]; then
    if echo "$result" | grep -q "$PATTERN"; then
      printf "\n${RED}[!] Pattern '$PATTERN' found at buffer size: %d bytes${RESET}\n" "$size"
      exit 0
    fi
  else
    if echo "$result" | grep -q 'stack smashing detected'; then
      printf "\n${RED}[!] Stack smashing detected at: %d bytes${RESET}\n" "$size"
      exit 0
    elif [ $status -eq 139 ]; then
      printf "\n${RED}[!] Buffer overflow (SIGSEGV) detected at: %d bytes${RESET}\n" "$size"
      exit 0
    fi
  fi

done

printf "\n${GREEN}[✓] No buffer overflow or pattern found in 1–%d bytes range${RESET}\n" "$MAX"
exit 0
