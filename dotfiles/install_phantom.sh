#!/bin/bash

# ========== Colores (negrita + nombres descriptivos) ==========
# --- Colores normales ---
blackColour='\033[1;38;5;0m'      # #0a0f0a (negro oscuro)
redColour='\033[1;38;5;1m'        # #ff0059 (rojo intenso)
greenColour='\033[1;38;5;2m'       # #00ff41 (verde neón)
yellowColour='\033[1;38;5;3m'      # #b3ff00 (amarillo verdoso)
blueColour='\033[1;38;5;4m'        # #00b3ff (azul eléctrico)
purpleColour='\033[1;38;5;5m'      # #bb00ff (morado vibrante)
turquoiseColour='\033[1;38;5;6m'        # #00ffd2 (cian brillante)
grayColour='\033[1;38;5;7m'       # #d9e0ee (blanco suave)

# --- Colores brillantes ---
strongGray='\033[1;38;5;8m'        # #262a2e (gris oscuro)
lightRedColour='\033[1;38;5;9m'    # #ff477f (rosa fluorescente)
limaColour='\033[1;38;5;10m'  # #77ff00 (verde limón)
lightYellowColour='\033[1;38;5;11m' # #ccff00 (amarillo puro)
lightBlueColour='\033[1;38;5;12m'   # #33ccff (azul cielo)
lightPurpleColour='\033[1;38;5;13m' # #ff77ff (rosa chicle)
lightCyanColour='\033[1;38;5;14m'   # #00ffff (cian encendido)
brightWhiteColour='\033[1;38;5;15m' # #ffffff (blanco puro)

# --- Reset ---
endColour='\033[0m'

#Ctrl+C 
function ctrl_c(){
  echo -e "\n\n${redColour}[+] Leaving...${endColour}\n"
  exit 1
}

trap ctrl_c INT

banner="${limaColour}$(cat << "EOF"                                                                                                                                 


          ____  __                __                     ______                    _             __
         / __ \/ /_  ____ _____  / /_____  ____ ___     /_  __/__  _________ ___  (_)___  ____ _/ /
        / /_/ / __ \/ __ `/ __ \/ __/ __ \/ __ `__ \     / / / _ \/ ___/ __ `__ \/ / __ \/ __ `/ / 
       / ____/ / / / /_/ / / / / /_/ /_/ / / / / / /    / / /  __/ /  / / / / / / / / / / /_/ / /  
      /_/   /_/ /_/\__,_/_/ /_/\__/\____/_/ /_/ /_/    /_/  \___/_/  /_/ /_/ /_/_/_/ /_/\__,_/_/   
                                                                                          
                                         -=[ by r4venn ]=-                                        



EOF
)${endColour}"

# Función de Spinner
function spinner(){
  local SPIN=("◐" "◓" "◑" "◒")
  local i=0
  while true; do 
    echo -ne "\r${limaColour}[${SPIN[i]}]${endColour} $1"
    ((i=(i+1)%4))
    sleep 0.1
  done
}



function installation(){
  echo -e "\n${turquoiseColour}$(for i in $(seq 1 32); do echo -n '='; done)[::] Installing Phantom Terminal [::]$(for i in $(seq 1 31); do echo -n "="; done)${endColour}\n"
  spinner "${grayColour}Installing zsh ${endColour}" &
  SPINNER_PID=$!
  sleep 3 
  kill "$SPINNER_PID" &>/dev/null
  echo -ne "\r[✔] ${grayColour}Zsh Installed.${endColour}\n"

  spinner "${grayColour}Installing kitty ${endColour}" &
  SPINNER_PID=$!
  sleep 3 
  kill "$SPINNER_PID" &>/dev/null
  echo -ne "\r[✔] ${grayColour}Kitty Installed & Configurated.${endColour}              \n"

  spinner "${grayColour}Installing Starship Powerline ${endColour}" &
  SPINNER_PID=$!
  sleep 3 
  kill "$SPINNER_PID" &>/dev/null
  echo -ne "\r[✔] ${grayColour}Starship Installed & Configurated.${endColour}\n"

  spinner "${grayColour}Installing Lsd & bat (ls & cat with steroids) ${endColour}" &
  SPINNER_PID=$!
  sleep 3 
  kill "$SPINNER_PID" &>/dev/null
  echo -ne "\r[✔] ${grayColour}Lsd & Bat Installed.${endColour}\n"

  echo -ne "\n[✔] ${grayColour}Finished. Enjoy!${endColour}\n"


}


function main(){
  echo -e "$banner"
  echo -e "\n${turquoiseColour}$(for in in $(seq 1 100); do echo -n '='; done)"
  echo -e "                                       I N S T A L L A T I O N"
  echo -e "$(for in in $(seq 1 100); do echo -n '='; done)${endColour}"
  #echo -e "\n${limaColour}[+]${endColour}${grayColour} This program requires ${blueColour}sudo${endColour}${grayColour} permissions for a successful installation:${endColour} run sudo $0"
  #echo -e "\n${limaColour}[+]${endColour} ${grayColour}This program requires sudo. Use${endColour}: ${purpleColour}sudo ./install_phantom.sh${endColour}"
  
  echo -ne "\n${purpleColour}[~]${endColour}${grayColour} Install Phantom Terminal?${endColour} ${limaColour}[y/n]:${endColour} "
  read output_show

  if [[ $output_show == "y" ]]; then
    installation
  elif [[ $output_show == "n" ]]; then
    echo -e "${redColour}[-] Hmmmmm alright${endColour}"
    exit 0
  else
    echo -e "${redColour}[!] You have to select y/n${endColour}"
    exit 1
  fi
}

main 
