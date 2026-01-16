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
  echo -e "\n\n${redColour}[!] Leaving...${endColour}\n"
  tput cnorm # Recuperar cursor
  # Matamos procesos hijos forzosamente
  pkill -P $$ 2>/dev/null
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

LOG_FILE="setup.log"

# Función de Spinner

function spinner(){
    local pid_proc=$1
    local msg="$2"
    local SPIN=("◐" "◓" "◑" "◒")
    local i=0

    tput civis # Ocultar cursor

    # Mientras el proceso con PID $pid_proc exista...
    while kill -0 "$pid_proc" 2>/dev/null; do
        echo -ne "\r${limaColour}[${SPIN[i]}]${endColour} ${grayColour}${msg}...${endColour}"
        ((i=(i+1)%4))
        sleep 0.1
    done

    tput cnorm # Recuperar cursor al terminar
}

function execute_process() {
    local command="$1"
    local message="$2"

    # 1. Ejecutamos el comando en SEGUNDO PLANO (&)
    # Redirigimos stderr a stdout y todo al log
    eval "$command" >> "$LOG_FILE" 2>&1 &
    
    # 2. Capturamos el PID del comando que acabamos de lanzar
    local pid_proc=$!

    # 3. Llamamos al spinner (Bloquea la ejecución hasta que pid_proc termine)
    spinner "$pid_proc" "$message"

    # 4. Esperamos el código de salida del proceso ya terminado
    wait "$pid_proc"
    local exit_code=$?

    # 5. Limpiamos la línea del spinner
    echo -ne "\r\033[K"

    # 6. Mostramos resultado final alineado
    if [ $exit_code -eq 0 ]; then
        printf "${limaColour}[✔]${endColour}${grayColour} %-50s${endColour} ${limaColour}[OK]${endColour}\n" "$message"
    else
        printf "${redColour}[✖]${endColour}${grayColour} %-50s${endColour} ${redColour}[ERROR]${endColour}\n" "$message"
    fi
}


function request_sudo(){
    echo -e "${greenColour}[*]${purpleColour} Requesting sudo permissions...${endColour}"
    
    # Intentamos refrescar las credenciales de sudo.
    # Si el usuario ya tiene permisos recientes, no pedirá nada.
    # Si no, pedirá la contraseña aquí mismo, de forma interactiva y limpia.
    if sudo -v; then
        # Si la contraseña es correcta, entramos aquí.
        
        # Mantenemos el token de sudo vivo en segundo plano
        # Esto se ejecuta infinitamente mientras el script principal ($$) siga vivo.
        while true; do 
            sudo -n true 
            sleep 60 
            kill -0 "$$" || exit 
        done 2>/dev/null &
        
        echo -e "${limaColour}[✔]${endColour} ${turquoiseColour}Sudo Configurated.${endColour}\n"
    else
        echo -e "${redColour}[✖] Authentication Failed. This program needs sudo permissions to perform system installation.${endColour}"
        exit 1
    fi
}


function install_dependencies(){ 

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
    sudo apt install "${DEPENDENCIES[@]}" -y 

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
  mkdir -p ~/.config/picom 
  mkdir -p ~/.config/bin
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
  /bin/cat dotfiles/picom/picom_performance > ~/.config/picom/picom.conf

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
  picom_modes
  sleep 10
  request_sudo 
  execute_process "install_dependencies" "System Dependencies"
  execute_process "compile_environment" "Compiling Environment"
  execute_process "install_dotfiles" "Files Configurations"
  execute_process "install_fonts_themes" "Aesthetic and Shell"

}

function pwnbox_mode(){
    echo -e "\n${turquoiseColour}$(for i in $(seq 1 32); do echo -n '='; done)[::] Installing Phantom Terminal [::]$(for i in $(seq 1 31); do echo -n "="; done)${endColour}\n"
    
    # 1. Aseguramos permisos antes de empezar para evitar bloqueos
    request_sudo

    # --- ZSH & Plugins ---
    # Agrupamos la instalación y la descarga de plugins
    CMD_ZSH="sudo apt install zsh -y && \
    mkdir -p ~/.zsh_plugins && \
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh_plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh_plugins/zsh-syntax-highlighting"
    
    execute_process "$CMD_ZSH" "Installing Zsh & Plugins"

    # Configuración de .zshrc (Sed y Echos)
    CMD_ZSH_CONF="sed -i '/oh-my-zsh.sh/s/^/#/' ~/.zshrc; \
    echo '' >> ~/.zshrc; \
    echo '# Zsh Plugins' >> ~/.zshrc; \
    echo 'source \$HOME/.zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh' >> ~/.zshrc; \
    echo 'source \$HOME/.zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc"
    
    execute_process "$CMD_ZSH_CONF" "Configuring .zshrc plugins"

    # --- Kitty Terminal ---
    # Asumiendo que tu config está en 'dotfiles/kitty' y fuentes en 'assets/fonts'
    CMD_KITTY="sudo apt install kitty boxes -y && \
    mkdir -p ~/.config/kitty && \
    cp dotfiles/kitty/kitty.conf ~/.config/kitty/ && \
    sudo cp assets/fonts/HackNerdFont* /usr/local/share/fonts/ && \
    fc-cache -fv"
    
    execute_process "$CMD_KITTY" "Installing Kitty & NerdFonts"

    # --- Starship ---
    CMD_STARSHIP="curl -sS https://starship.rs/install.sh | sh -s -- -y && \
    echo 'eval \"\$(starship init zsh)\"' >> ~/.zshrc && \
    cp dotfiles/starship.toml ~/.config/"
    
    execute_process "$CMD_STARSHIP" "Installing Starship Powerline"

    # --- LSD & BAT ---
    execute_process "sudo apt install lsd bat -y" "Installing Lsd & Bat"

    # Aliases
    CMD_ALIASES="echo '' >> ~/.zshrc && \
    echo '# Manual aliases' >> ~/.zshrc && \
    echo \"alias ll='lsd -lh --group-dirs=first'\" >> ~/.zshrc && \
    echo \"alias la='lsd -a --group-dirs=first'\" >> ~/.zshrc && \
    echo \"alias l='lsd --group-dirs=first'\" >> ~/.zshrc && \
    echo \"alias lla='lsd -lha --group-dirs=first'\" >> ~/.zshrc && \
    echo \"alias ls='lsd --group-dirs=first'\" >> ~/.zshrc && \
    echo \"alias cat='batcat'\" >> ~/.zshrc"
    
    execute_process "$CMD_ALIASES" "Configuring Shell Aliases"

    # --- Hacking Arsenal ---
    echo -e "\n${limaColour}[+]${endColour} ${turquoiseColour}Hacking Arsenal${endColour}"

    # Target
    # Asumo que target.sh está en 'dotfiles/bin/' o en la raíz, ajusta la ruta origen si es necesario
    execute_process "sudo cp dotfiles/bin/target.sh /usr/local/bin/target && sudo chmod +x /usr/local/bin/target" "Setting up target.sh"

    # Network Recon & Root Shadow
    # Creamos carpeta temporal o Tools para clonar, instalar y limpiar
    CMD_TOOLS="mkdir -p ~/Tools && \
    git clone https://github.com/r4vencrane/Network-Recon.git ~/Tools/Network-Recon && \
    sudo cp ~/Tools/Network-Recon/netrecon.sh /usr/local/bin/netrecon && \
    sudo chmod +x /usr/local/bin/netrecon && \
    git clone https://github.com/r4vencrane/Root-Shadow.git ~/Tools/Root-Shadow"
    
    execute_process "$CMD_TOOLS" "Installing Recon Tools"

    # --- Finalización ---
    execute_process "gsettings set org.mate.background picture-filename /usr/share/backgrounds/hackthebox-alt.jpg" "Setting Wallpaper"

    echo -e "\n${limaColour}[✔]${endColour} ${grayColour}Finished. Enjoy!${endColour}"
    echo -e "${limaColour}[+]${endColour} ${grayColour}Now you can open ${blueColour}kitty${endColour} ${grayColour}terminal${endColour}\n"
}

function picom_modes_test(){
  echo -e "\n${turquoiseColour}// COMPOSITOR SETUP (Picom) :${endColour}\n"

  echo -e "\n  ${purpleColour}❱ 1 ❰${endColour} ${turquoiseColour}AESTHETIC MODE${endColour}"
 
  # Opción 2: Performance
  echo -e "\n  ${purpleColour}❱ 2 ❰${endColour} ${turquoiseColour}PERFORMANCE MODE${endColour}"
  
  # Prompt estilo terminal
  echo -ne "\n${limaColour}┌──(select${endColour}${grayColour}::${endColour}${purpleColour}picom${endColour}${limaColour})${endColour}"
  echo -ne "\n${limaColour}└─${endColour}${grayColour}>>${endColour} "
  read output_blur

  #mkdir -p ~/.config/picom 

  if [[ $output_blur -eq 1 ]]; then
    #/bin/cat dotfiles/picom/picom_quality > ~/.config/picom/picom.conf
    echo -e "\n${limaColour}[ Quality Mode Selected ]"
  elif [[ $output_blur -eq 2 ]]; then 
    #/bin/cat dotfiles/picom/picom_performance > ~/.config/picom/picom.conf
    echo -e "\n${limaColour}[ Performance Mode Selected ]"
  else 
    echo -e "\n${redColour}[!] You have to select a number! [1-2]${endColour}"
  fi

  sleep 10

}

function picom_modes(){
  # Cabecera Cyberpunk
  echo -e "\n${turquoiseColour}/// SYSTEM CONFIGURATION :: COMPOSITOR PICOM :${endColour}\n"

  # --- Opción 1: QUALITY ---
  echo -e "\n  ${greenColour}❱ 1 ❰${endColour} ${purpleColour}AESTHETIC MODE${endColour}"
  
  # --- Opción 2: PERFORMANCE ---
  echo -e "\n  ${greenColour}❱ 2 ❰${endColour} ${purpleColour}PERFORMANCE MODE${endColour}"
  
  # Prompt estilo terminal
  echo -ne "\n${limaColour}┌──(select${endColour}${grayColour}::${endColour}${purpleColour}picom${endColour}${limaColour})${endColour}"
  echo -ne "\n${limaColour}└─${endColour}${greenColour}>>${endColour} "
  read output_blur
  
  # Creamos el directorio (usando -p para evitar errores)
  mkdir -p ~/.config/picom 
  
  if [[ $output_blur -eq 1 ]]; then
    #/bin/cat dotfiles/picom/picom_quality > ~/.config/picom/picom.conf
    echo -e "\n${limaColour}[ Quality Mode Selected ]"
  elif [[ $output_blur -eq 2 ]]; then 
    #/bin/cat dotfiles/picom/picom_performance > ~/.config/picom/picom.conf
    echo -e "\n${limaColour}[ Performance Mode Selected ]"
  else 
    echo -e "\n${redColour}[!] Invalid option. You have to select a number! [1-2]${endColour}"
    exit 1
  fi

  sleep 10

}

function nvim_installation(){
    echo -e "\n${turquoiseColour}// INITIATING NEOVIM INSTALLATION...${endColour}\n"

    # --- Lógica 1: Instalación del Binario (Root) ---
    function install_nvim_binary(){
        # 1. Limpieza preventiva (Borrar residuos de intentos fallidos anteriores)
        sudo rm -f /opt/nvim-linux-x86_64.tar.gz
        
        # 2. Si ya existe la carpeta descomprimida, la borramos para re-instalar limpio
        if [ -d "/opt/nvim-linux-x86_64" ]; then
            sudo rm -rf /opt/nvim-linux-x86_64
        fi
        
        cd /opt
        
        # 3. Descarga silenciosa
        sudo wget -q https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz
        
        # Verificación: Si wget falló (sin internet), no seguimos
        if [ ! -f "nvim-linux-x86_64.tar.gz" ]; then return 1; fi

        # 4. Instalación
        sudo tar -xf nvim-linux-x86_64.tar.gz
        sudo rm nvim-linux-x86_64.tar.gz
        
        # 5. Link (La 'f' sobreescribe si ya existe, perfecto para re-runs)
        sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    }

    # --- Lógica 2: Configuración de NvChad (Usuario) ---
    function deploy_nvchad_config(){
        # 1. GESTIÓN DE BACKUPS (La corrección importante)
        # Si existe un backup previo, lo borramos para dejar espacio al nuevo
        if [ -d "$HOME/.config/nvim.bak" ]; then
            rm -rf "$HOME/.config/nvim.bak"
        fi

        # Ahora sí, si existe config actual, la movemos a .bak (seguro)
        if [ -d "$HOME/.config/nvim" ]; then
            mv "$HOME/.config/nvim" "$HOME/.config/nvim.bak"
        fi
        
        # 2. Limpieza de Cache (Vital para NvChad al reinstalar)
        rm -rf "$HOME/.local/share/nvim"
        rm -rf "$HOME/.cache/nvim"
        
        # 3. Clonar NvChad
        git clone -q https://github.com/NvChad/starter "$HOME/.config/nvim"
    }

    # --- EJECUCIÓN ---
    execute_process "install_nvim_binary" "Downloading & Installing Neovim Binary"
    execute_process "deploy_nvchad_config" "Deploying NvChad Config (Auto-Backup)"

    # Mensaje Final (Validando si boxes está instalado)
    echo -e "\n${greenColour}[✔]${endColour}${grayColour} Neovim Setup Complete.${endColour}"
    
    # Pequeño truco: Si 'boxes' no está instalado, usa 'cat' para que no de error el script
    if command -v boxes &> /dev/null; then
        echo -e "${limaColour} [+] Use 'nvim' to start. First launch will install plugins automatically.${endColour}" | boxes -d stone
    else
        echo -e "${limaColour} [+] Use 'nvim' to start. First launch will install plugins automatically.${endColour}"
    fi
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
  echo -e "  ${turquoiseColour}-p${endColour}          ➜ ${grayColour}Pwnbox Mode. ${greenColour}Target: HTB/Pwnbox Environment${endColour}"
  echo -e "  ${turquoiseColour}-n${endColour}          ➜ ${grayColour}Install Nvim with Nvchad${endColour}"
  echo -e "  ${turquoiseColour}-c${endColour}          ➜ ${redColour}Core Stabilization${endColour}. ${purpleColour}(Interactive Menu)${endColour}"
  
  echo -e "\n${limaColour}[+]${endColour} ${grayColour}Examples:${endColour}"
  echo -e "\t${greenColour}./groundzero.sh -f${endColour} (Recommended for fresh installs)"
  echo -e "\t${greenColour}./groundzero.sh -t${endColour} (Only shell configuration)"
  echo -e "\t${greenColour}./groundzero.sh -c${endColour} (Post Install: Visuals, Borders, Wallpapers)"

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
