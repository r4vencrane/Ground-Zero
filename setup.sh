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

     _________
    / ======= \
   / __________\
  | ___________ | ---------------------------------------------------------------------------------------------------------
  | |         | |       ________                               .___ __________                   
  | |         | |      /  _____/______  ____  __ __  ____    __| _/ \____    /___________  ____  
  | |         | |     /   \  __\_  __ \/  _ \|  |  \/    \  / __ |    /     // __ \_  __ \/  _ \ 
                      \    \_\  \  | \(  <_> )  |  /   |  \/ /_/ |   /     /\  ___/|  | \(  <_> )
                       \______  /__|   \____/|____/|___|  /\____ |  /_______ \___  >__|   \____/ 
                              \/                        \/      \/          \/   \/
  | | -       | |
  | |         | |
  | |_________| |________________________
  \=____________/       
  / """"""""""" \                       
 / ::::::::::::: \                  
(_________________)

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

function pwnbox_mode(){
  echo -e "\n${turquoiseColour}$(for i in $(seq 1 32); do echo -n '='; done)[::] Installing Phantom Terminal [::]$(for i in $(seq 1 31); do echo -n "="; done)${endColour}\n"
  spinner "${grayColour}Installing zsh ${endColour}" &
  SPINNER_PID=$!
  sudo apt install zsh -y &>/dev/null 
  sed -i '/oh-my-zsh.sh/s/^/#/' ~/.zshrc

  # ========== [✔] Instalar plugins: autosuggestions & syntax highlighting ==========
  mkdir -p ~/.zsh_plugins
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh_plugins/zsh-autosuggestions &>/dev/null
  git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh_plugins/zsh-syntax-highlighting &>/dev/null

  # ========== [✔] Activar plugins manualmente ==========
  {
    echo ""
    echo "# Zsh Plugins (manual install, no oh-my-zsh)"
    echo "source \$HOME/.zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
    echo "source \$HOME/.zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  } >> ~/.zshrc
  kill "$SPINNER_PID" &>/dev/null
  echo -ne "\r${limaColour}[✔]${endColour} ${blueColour}Zsh${endColour} ${grayColour}Installed.${endColour}\n"

  spinner "${grayColour}Installing kitty ${endColour}" &
  SPINNER_PID=$!
  sudo apt install kitty -y &>/dev/null
  sudo apt install boxes -y &>/dev/null 
  mkdir ~/.config/kitty  &>/dev/null
  cp kitty/kitty.conf ~/.config/kitty/ &>/dev/null
  sudo cp fonts/HackNerdFont* /usr/share/fonts/
  kill "$SPINNER_PID" &>/dev/null
  echo -ne "\r${limaColour}[✔]${endColour} ${blueColour}Kitty${endColour} ${grayColour}Installed & Configurated.${endColour}              \n"

  spinner "${grayColour}Installing Starship Powerline ${endColour}" &
  SPINNER_PID=$!
  curl -sS https://starship.rs/install.sh | sh -s -- -y > /dev/null 2>&1 #aqui le tenemos que dar que si 
  echo 'eval "$(starship init zsh)"' >> ~/.zshrc 
  cp starship.toml ~/.config/
  kill "$SPINNER_PID" &>/dev/null
  echo -ne "\r${limaColour}[✔]${endColour} ${blueColour}Starship${endColour} ${grayColour}Installed & Configurated.${endColour}\n"

  spinner "${grayColour}Installing Lsd & bat (ls & cat with steroids) ${endColour}" &
  SPINNER_PID=$!
  sudo apt install lsd -y &>/dev/null
  sudo apt install bat -y &>/dev/null
  echo "# Manual aliases
  alias ll='lsd -lh --group-dirs=first'
  alias la='lsd -a --group-dirs=first'
  alias l='lsd --group-dirs=first'
  alias lla='lsd -lha --group-dirs=first'
  alias ls='lsd --group-dirs=first'
  alias cat='batcat'" >> ~/.zshrc 
  kill "$SPINNER_PID" &>/dev/null
  echo -ne "\r${limaColour}[✔]${endColour} ${blueColour}Lsd & Bat${endColour} ${grayColour}Installed.${endColour}\n"
  #Target
  spinner "${grayColour}Setting up ${endColour}${limaColour}target.sh${endColour}" &
  SPINNER_PID=$!
  sudo cp target.sh /usr/local/bin/target  
  sudo chmod +x /usr/local/bin/target  
  kill "$SPINNER_PID" &>/dev/null
  echo -ne "\r${limaColour}[✔]${endColour} ${limaColour}target.sh${endColour} ${grayColour}is ready to use.${endColour}\n"

  echo -e "\n${limaColour}[+]${endColour} ${turquoiseColour}Hacking Arsenal${endColour}"
  #Arsenal
  spinner "${grayColour}Setting up ${endColour}${limaColour}Network Recon${endColour}" &
  SPINNER_PID=$!
  git clone https://github.com/r4vencrane/Network-Recon.git &>/dev/null
  mv Network-Recon ../ &>/dev/null
  sudo cp ../Network-Recon/netrecon.sh /usr/local/bin/netrecon
  sudo chmod +x /usr/local/bin/netrecon
  kill "$SPINNER_PID" &>/dev/null
  echo -ne "\r${limaColour}[✔]${endColour} ${limaColour}Network Recon${endColour} ${grayColour}is ready to use.${endColour}\n"

  #Arsenal
  spinner "${grayColour}Setting up ${endColour}${limaColour}Root Shadow${endColour}" &
  SPINNER_PID=$!
  git clone https://github.com/r4vencrane/Root-Shadow.git &>/dev/null
  mv Root-Shadow ../ &>/dev/null
  kill "$SPINNER_PID" &>/dev/null
  echo -ne "\r${limaColour}[✔]${endColour} ${limaColour}Root Shadow${endColour} ${grayColour}is ready to use.${endColour}\n"
  sleep 1
  
  gsettings set org.mate.background picture-filename /usr/share/backgrounds/hackthebox-alt.jpg &>/dev/null
  echo -ne "\n${limaColour}[✔]${endColour} ${grayColour}Finished. Enjoy!${endColour}\n"
  echo -e "${limaColour}[+]${endColour} ${grayColour}Now you can open ${blueColour}kitty${endColour} ${grayColour}terminal${endColour}\n"
  source ~/.zshrc &>/dev/null

}


function main(){
  echo -e "$banner"
  echo -e "\n${turquoiseColour}$(for in in $(seq 1 100); do echo -n '='; done)"
  echo -e "                                       I N S T A L L A T I O N"
  echo -e "$(for in in $(seq 1 100); do echo -n '='; done)${endColour}"
  echo -e "\n${limaColour}[+]${endColour}${grayColour} This program requires ${blueColour}sudo${endColour}${grayColour} permissions for a successful installation"
  
  echo -ne "\n${purpleColour}[~]${endColour}${grayColour} Install Phantom Terminal?${endColour} ${limaColour}[y/n]:${endColour} "
  read output_show

  if [[ $output_show == "y" ]]; then
    echo '"y" was selected'
  elif [[ $output_show == "n" ]]; then
    echo -e "${redColour}[-] Hmmmmm alright${endColour}"
    exit 0
  else
    echo -e "${redColour}[!] You have to select y/n${endColour}"
    exit 1
  fi
}

main 
