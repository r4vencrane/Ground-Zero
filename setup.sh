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

banner="${turquoiseColour}$(cat << "EOF"

          __________________ ________   ____ __________  ________       _______________________________ ________   
         /  _____/\______   \\_____  \ |    |   \      \ \______ \      \____    /\_   _____/\______   \\_____  \  
        /   \  ___ |       _/ /   |   \|    |   /   |   \ |    |  \       /     /  |    __)_  |       _/ /   |   \ 
        \    \_\  \|    |   \/    |    \    |  /    |    \|    `   \     /     /_  |        \ |    |   \/    |    \
         \______  /|____|_  /\_______  /______/\____|__  /_______  /    /_______ \/_______  / |____|_  /\_______  / v1.0
                \/        \/         \/                \/        \/             \/        \/         \/         \/


  // AUTHOR : r4vencrane
  // GITHUB : github.com/r4vencrane

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

function install_dependencies(){
  sudo apt update && sudo 

  DEPENDENCIES=(
        build-essential git vim xcb libxcb-util0-dev libxcb-ewmh-dev 
        libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev 
        libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev libxcb-xkb-dev
        libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev libepoxy-dev 
        libpcre2-dev libpixman-1-dev libx11-xcb-dev libxcb1-dev libxcb-composite0-dev 
        libxcb-damage0-dev libxcb-glx0-dev libxcb-image0-dev libxcb-present-dev 
        libxcb-render0-dev libxcb-render-util0-dev libxcb-util-dev libxcb-xfixes0-dev 
        meson ninja-build uthash-dev
        polybar rofi feh kitty lsd bat boxes zsh curl wget
    )

    sudo apt update
    sudo apt install "${DEPENDENCIES[@]}"

    sudo ln -s /usr/bin/batcat /usr/local/bin/bat
}

function compile_environment(){
  mkdir -p build 
  cd build || exit 

  if [ ! -d "bspwm" ]; then
        git clone https://github.com/baskerville/bspwm.git
  fi
    
  make -C bspwm
  sudo make -C bspwm install
  sudo cp bspwm/contrib/freedesktop/bspwm.desktop /usr/share/xsessions/

  if [ ! -d "sxhkd" ]; then
        git clone https://github.com/baskerville/sxhkd.git
    fi
    make -C sxhkd
    sudo make -C sxhkd install

  if [ ! -d "picom" ]; then
        git clone https://github.com/yshui/picom.git  
  fi
  cd picom
  meson setup --buildtype=release build
  ninja -C build
  sudo ninja -C build install
  cd .. # Salir de picom

  cd .. # Salir de carpeta build
  rm -rf build # Limpieza
}

function install_dotfiles(){
  mkdir -p ~/.config/bspwm
  mkdir -p ~/.config/sxhkd
  mkdir -p ~/.config/scripts
  mkdir -p ~/.config/bin
  mkdir -p ~/.config/picom
  mkdir -p ~/.config/polybar
  mkdir -p ~/.config/rofi
  mkdir -p ~/.config/kitty
  mkdir -p ~/.config/wallpapers

  # Copiar configs (Asume que estás en la raíz del repo clonado)
  cp dotfiles/bspwm/* ~/.config/bspwm/
  cp dotfiles/sxhkd/* ~/.config/sxhkd/
  cp dotfiles/scripts/* ~/.config/scripts/
  cp dotfiles/bin/* ~/.config/bin/ # Asegúrate que 'target' es el nombre correcto del binario/script
  
  # Picom Config
  /bin/cat dotfiles/picom/picom_home > ~/.config/picom/picom.conf

  # Polybar Config
  cp -r dotfiles/polybar/* ~/.config/polybar/

  # Rofi Config
  cp -r dotfiles/rofi/* ~/.config/rofi/

  # Kitty Config
  cp dotfiles/kitty/* ~/.config/kitty/

  # Wallpapers
  cp assets/wallpapers/* ~/.config/wallpapers/

  # Permisos de ejecución necesarios
  chmod +x ~/.config/bspwm/bspwmrc
  chmod +x ~/.config/scripts/*
}

function install_fonts_themes(){
  sudo cp assets/fonts/HackNerdFont* /usr/local/share/fonts/ 2>/dev/null 
  sudo cp dotfiles/polybar/fonts/* /usr/share/fonts/truetype/ 2>/dev/null
  
  # Actualizar caché de fuentes
  fc-cache -v > /dev/null 2>&1

  curl -sS https://starship.rs/install.sh | sh -s -- -y
  cp dotfiles/starship.toml ~/.config/
  /bin/cat dotfiles/zshrc >> ~/.zshrc
}


function full_installation(){ 
  echo -e "\n${turquoiseColour}$(for i in $(seq 1 32); do echo -n '='; done)[::] Full Installation [::]$(for i in $(seq 1 31); do echo -n "="; done)${endColour}\n"
  install_dependencies
  compile_environment
  install_dotfiles
  install_fonts_themes

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


function options(){
  echo -e "${lightCyanColour}▌ 1 ▐${endColour} ${limaColour}Full Setup"
  echo -e "${lightCyanColour}▌ 2 ▐${endColour} ${limaColour}Phantom Terminal"
  echo -e "${lightCyanColour}▌ 3 ▐${endColour} ${limaColour}Pwnbox Mode"
  echo -e "${lightCyanColour}▌ 4 ▐${endColour} ${limaColour}Nvim & NvChad"

}

function select_options(){
  echo -e "$banner"
  echo -e "\n${limaColour}$(for in in $(seq 1 120); do echo -n '='; done)"
  echo -e "                                                I N S T A L L A T I O N"
  echo -e "$(for in in $(seq 1 120); do echo -n '='; done)${endColour}"
  echo -e "\n${limaColour}[+]${endColour}${blueColour} This program requires ${limaColour}sudo${endColour}${blueColour} permissions for a successful installation"

  echo -e "\n${limaColour}[+]${endColour} ${grayColour}Select an option:${endColour}\n"
  options 
  echo -ne "\n${purpleColour}[~]${endColour} ${grayColour}Install: ${endColour}"
  read output_show

  if [[ $output_show -eq 1 ]]; then
    full_installation
  elif [[ $output_show -eq 2 ]]; then 
    terminal_strike
  elif [[ $output_show -eq 3 ]]; then 
     pwnbox_mode
  elif [[ $output_show -eq 4 ]]; then 
    nvim_installation
  else 
    echo -e "\n${redColour}[!] You have to select a number! [1-4]${endColour}"
  fi
  
}

function helpPanel(){
  echo -e "$banner" 
  echo -e "\n${limaColour}$(for in in $(seq 1 120); do echo -n '='; done)"
  echo -e "                                                  H E L P   P A N E L"
  echo -e "$(for in in $(seq 1 120); do echo -n '='; done)${endColour}"
  echo -e "\n${limaColour}[+]${endColour} ${grayColour}Usage:${endColour} \n\t${turquoiseColour}./groundzero.sh [options]${endColour}"
  echo -e "\n${limaColour}[+]${endColour} ${grayColour}Options:${endColour}"
  echo -e "  ${turquoiseColour}-o${endColour}          ➜ ${grayColour}Show Installation Options ${purpleColour}(Interactive Menu)${endColour}"
  echo -e "  ${turquoiseColour}-f${endColour}          ➜ ${grayColour}Full Setup. Includes: ${greenColour}Bspwm, Polybar, Picom, Rofi, Zsh ${endColour}"
  echo -e "  ${turquoiseColour}-t${endColour}          ➜ ${grayColour}Phantom Terminal. Only CLI tools: ${greenColour}Zsh, Starship Powerline, Bat, Lsd, Kitty. ${endColour}"
  echo -e "  ${turquoiseColour}-p${endColour}          ➜ ${grayColour}Pwnbox Mode. ${greenColour}Install Terminal Strike in Pwnbox${endColour}"
  echo -e "  ${turquoiseColour}-n${endColour}          ➜ ${grayColour}Install Nvim with Nvchad${endColour}"
  
  echo -e "\n${limaColour}[+]${endColour} ${grayColour}Examples:${endColour}"
  echo -e "\t${greenColour}./groundzero.sh -f${endColour} (Recommended for fresh installs)"
  echo -e "\t${greenColour}./groundzero.sh -t${endColour} (Only shell configuration)"

}


declare -i parameter_counter=0 

while getopts "oftpnh" arg; do
  case $arg in
    o) let parameter_counter+=1;;
    f) let parameter_counter+=2;;
    t) let parameter_counter+=3;;
    p) let parameter_counter+=4;;
    n) let parameter_counter+=5;;
    h) ;;
  esac
done

if [[ $parameter_counter -eq 1 ]]; then
  select_options
elif [[ $parameter_counter -eq 2 ]]; then 
  full_installation
elif [[ $parameter_counter -eq 3 ]]; then 
  terminal_strike
elif [[ $parameter_counter -eq 4 ]]; then 
  pwnbox_mode
elif [[ $parameter_counter -eq 5 ]]; then 
  nvim_installation 
else 
  helpPanel
fi 
