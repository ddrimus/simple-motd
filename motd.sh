#!/bin/bash

#   Title: simple-motd
#   Description: Customizable MOTD for Raspberry Pi. Optimized, clean and simple.
#
#   Installation:
#   Disable PrintMOTD, PrintLastLog and UsePAM in the file /etc/ssh/sshd_config (sudo nano /etc/ssh/sshd_config)
#   sudo apt install -y git
#   git clone https://github.com/ddrimus/simple-motd
#   sudo mv simple-motd/motd.sh /etc/motd.sh
#   sudo chmod 775 /etc/motd.sh
#   sudo rm -r simple-motd
#   sudo printf "# MOTD\n/etc/motd.sh\n" | sudo tee -a /etc/profile  > /dev/null 2>&1
#
#   NOTE: Check the GitHub page for more information. [https://github.com/ddrimus/simple-motd]

### SETTINGS ###

ENVIROMENT="PRODUCTION SYSTEM"

### VARIABLES ###

# COLORS
RED="$(tput sgr0 ; tput setaf 1)"
GREEN="$(tput sgr0 ; tput setaf 2)"
BLUE="$(tput sgr0 ; tput setaf 4)"
YELLOW="$(tput sgr0 ; tput setaf 3)"
DARKGREY="$(tput sgr0 ; tput bold ; tput setaf 0)"
WHITE="$(tput sgr0 ; tput setaf 7)"
NC="$(tput sgr0)" # NO COLOR

### FUNCTIONS ###

# OS
FUNCTION_OS () {
   cat /etc/*release | grep "PRETTY_NAME" | cut -d "=" -f 2- | sed 's/"//g'
}

# DATE
FUNCTION_DATE () {
   date +"%e %B %Y - %H:%M"
}

# LAST LOGIN
FUNCTION_LAST_LOGIN () {
   echo -e "$(last | head -1 | cut -c 1-9 | xargs) | $(last | head -1 | cut -c 40-55 | xargs) | $(last | head -1 | cut -c 23-39 | xargs)"
}

# DEVICE MODEL
FUNCTION_MODEL () {
   tr -d '\0' < /proc/device-tree/model
}

# UPTIME
FUNCTION_UPTIME () {
   let upSeconds="$(/usr/bin/cut -d. -f1 /proc/uptime)"
   let secs=$((${upSeconds}%60))
   let mins=$((${upSeconds}/60%60))
   let hours=$((${upSeconds}/3600%24))
   let days=$((${upSeconds}/86400))
   printf "%d Days | %02dH %02dM %02dS" "$days" "$hours" "$mins" "$secs"
}

# LAN IP
FUNCTION_IP () {
   hostname -I | awk '{print $1}'
}

# DISK1
FUNCTION_DISK1 () {
   test -e /dev/sda && df -h ~ | awk 'NR==2 { printf "%sB / %sB (%s)",$3,$2,$5; }' || echo "${RED}NOT CONNECTED${NC}"
}

# DISK2
FUNCTION_DISK2 () {
   test -e /dev/sdb && df -h /dev/sdb1 | awk 'NR==2 { printf "%sB / %sB (%s)",$3,$2,$5; }' || echo "${RED}NOT CONNECTED${NC}"
}

# TEMPERATURE
FUNCTION_TEMPERATURE () {
if [ "$(/opt/vc/bin/vcgencmd measure_temp | cut -c "6-7")" -le 65 ]
then
   echo "$(/opt/vc/bin/vcgencmd measure_temp | cut -c "6-7")°C ${GREEN}[OPTIMAL]${NC}"

elif [ "$(/opt/vc/bin/vcgencmd measure_temp | cut -c "6-7")" -le 80 ]
then
   echo "$(/opt/vc/bin/vcgencmd measure_temp | cut -c "6-7")°C ${YELLOW}[SAFE]${NC}"

else
   echo "$(/opt/vc/bin/vcgencmd measure_temp | cut -c "6-7")°C ${RED}[DANGEROUS]${NC}"
fi
}

### OUTPUT ###

clear
echo -e " ${GREEN}───────────────────────────────────────────────────────────────${NC}"
echo -e " $(FUNCTION_OS) ${GREEN}:${NC} $(FUNCTION_DATE)"
echo -e " ${GREEN}───────────────────────────────────────────────────────────────${NC}"
echo -e " ${GREEN}-${NC} Last login.......${GREEN}:${NC} $(FUNCTION_LAST_LOGIN)"
echo -e " ${GREEN}-${NC} Device model.....${GREEN}:${NC} $(FUNCTION_MODEL)"
echo -e " ${GREEN}-${NC} Uptime...........${GREEN}:${NC} $(FUNCTION_UPTIME)"
echo -e " ${GREEN}-${NC} LAN IP...........${GREEN}:${NC} $(FUNCTION_IP)"
echo -e " ${GREEN}-${NC} Disk 1 (ROOT)....${GREEN}:${NC} $(FUNCTION_DISK1)"
echo -e " ${GREEN}-${NC} Disk 2 (NAS).....${GREEN}:${NC} $(FUNCTION_DISK2)"
echo -e " ${GREEN}-${NC} Temperature......${GREEN}:${NC} $(FUNCTION_TEMPERATURE)"
echo -e " ${GREEN}-${NC} Enviroment.......${GREEN}:${NC} ${YELLOW}$ENVIROMENT${NC}"
echo -e " ${GREEN}───────────────────────────────────────────────────────────────${NC}\n"