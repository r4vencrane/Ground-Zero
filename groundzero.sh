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
    # Dependencias divididas para lectura, pero se instalan juntas
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

    echo -e "${grayColour}[*] Updating repositories...${endColour}"
    sudo apt update -y -q > /dev/null 2>&1

    echo -e "${grayColour}[*] Installing packages...${endColour}"
    # Redirigimos stderr a null para que los warnings de apt no rompan el spinner visualmente
    # pero si falla devuelve error
    sudo apt install "${DEPENDENCIES[@]}" -y -q 
    
    # Fix para 'bat' (batcat en Debian/Ubuntu)
    if command -v batcat &> /dev/null; then
        sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
    fi
}

function compile_environment(){
    # 1. Limpieza total del entorno de compilación previo
    if [ -d "build" ]; then
        rm -rf build
    fi
    mkdir -p build 
    cd build || return 1

    # --- BSPWM ---
    git clone -q https://github.com/baskerville/bspwm.git
    make -C bspwm > /dev/null 2>&1
    sudo make -C bspwm install > /dev/null 2>&1
    sudo cp bspwm/contrib/freedesktop/bspwm.desktop /usr/share/xsessions/

    # --- SXHKD ---
    git clone -q https://github.com/baskerville/sxhkd.git
    make -C sxhkd > /dev/null 2>&1
    sudo make -C sxhkd install > /dev/null 2>&1

    # --- PICOM (Jonaburg o Yshui) ---
    # Usamos Yshui que es el standard moderno, o Jonaburg si quieres animaciones especificas
    git clone -q https://github.com/yshui/picom.git  
    cd picom
    # Meson setup suele ser ruidoso, silenciamos
    meson setup --buildtype=release build > /dev/null 2>&1
    ninja -C build > /dev/null 2>&1
    sudo ninja -C build install > /dev/null 2>&1
    cd .. 

    # Salir y limpiar
    cd .. 
    rm -rf build 
}


function install_dotfiles(){
    # Crear estructura de directorios (ignora si existen con -p)
    mkdir -p ~/.config/{bspwm,sxhkd,scripts,picom,bin,polybar,rofi,kitty,wallpapers}

    # Copia forzada (-f) y recursiva (-r)
    # Asume que la carpeta 'dotfiles' existe donde corres el script
    
    cp -rf dotfiles/bspwm/* ~/.config/bspwm/
    cp -rf dotfiles/sxhkd/* ~/.config/sxhkd/
    cp -rf dotfiles/scripts/* ~/.config/scripts/
    cp -rf dotfiles/bin/* ~/.config/bin/
    
    # Picom
    cp -f dotfiles/picom/picom_performance ~/.config/picom/picom.conf

    # Polybar & Rofi & Kitty
    cp -rf dotfiles/polybar/* ~/.config/polybar/
    cp -rf dotfiles/rofi/* ~/.config/rofi/
    cp -rf dotfiles/kitty/* ~/.config/kitty/

    # Wallpapers
    cp -rf assets/wallpapers/* ~/.config/wallpapers/

    # Permisos (Importante: Scripts y binarios propios)
    chmod +x ~/.config/bspwm/bspwmrc
    chmod +x ~/.config/sxhkd/sxhkdrc
    chmod +x ~/.config/scripts/*
    chmod +x ~/.config/bin/* 2>/dev/null || true
}


function install_fonts_themes(){
    # Instalar Fuentes
    if [ -d "assets/fonts" ]; then
        sudo cp -r assets/fonts/* /usr/local/share/fonts/ 2>/dev/null
    fi
    
    if [ -d "dotfiles/polybar/fonts" ]; then
        sudo cp -r dotfiles/polybar/fonts/* /usr/share/fonts/truetype/ 2>/dev/null
    fi
    
    # Actualizar caché silenciosamente
    fc-cache -fv > /dev/null 2>&1

    # Instalar Starship (Prompt)
    if ! command -v starship &> /dev/null; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y > /dev/null 2>&1
    fi
    cp -f dotfiles/starship.toml ~/.config/

    # --- FIX DEL ZSHRC ---
    # Verificamos si ya existe una marca nuestra en el archivo
    # Usamos grep -q (quiet) para buscar un string único
    if ! grep -q "GroundZero Configuration" ~/.zshrc; then
        echo -e "\n# --- GroundZero Configuration ---" >> ~/.zshrc
        cat dotfiles/zshrc >> ~/.zshrc
        echo -e "# ------------------------------" >> ~/.zshrc
    fi
    
    # Cambiar shell a zsh si no lo es
    if [ "$SHELL" != "/usr/bin/zsh" ]; then
        sudo chsh -s /usr/bin/zsh "$USER"
    fi

  sudo cp dotfiles/target.sh /usr/local/bin/target  
  sudo chmod +x /usr/local/bin/target 
}


function full_installation(){ 
    # Header estético
    echo -e "\n${turquoiseColour}$(for i in $(seq 1 45); do echo -n '='; done)[::] /// FULL INSTALLATION [::]$(for i in $(seq 1 44); do echo -n "="; done)${endColour}\n"
    
    # Verificamos internet antes de empezar nada
    echo -e "${lightBlueColour}[::] ACTION :: CHECKING CONNECTIVITY...${endColour}"
    wget -q --spider http://google.com
    if [ $? -ne 0 ]; then
        echo -e "\n${redColour}[!] No internet connection detected. Aborting.${endColour}\n"
        exit 1
    fi

    request_sudo 
    
    # Ejecución modular con execute_process
    execute_process "install_dependencies" "Installing System Dependencies"
    execute_process "compile_environment" "Compiling Environment"
    execute_process "install_dotfiles" "Deploying Configuration Files"
    execute_process "install_fonts_themes" "Setting up Shell & Aesthetics"

    echo -e "\n${turquoiseColour}$(for i in $(seq 1 43); do echo -n '='; done)[::] /// INSTALLATION COMPLETED [::]$(for i in $(seq 1 42); do echo -n "="; done)${endColour}\n"
    echo -e "${purpleColour}[+]${limaColour} Please reboot your system to enter to your new environment.${endColour}" | boxes -d stone 
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
    sudo cp dotfiles/target.sh /usr/local/bin/target  
    sudo chmod +x /usr/local/bin/target

    echo -e "\n${limaColour}[✔]${endColour} ${grayColour}Finished. Enjoy!${endColour}"
    echo -e "${limaColour}[+]${endColour} ${grayColour}Now you can open ${blueColour}kitty${endColour} ${grayColour}terminal${endColour}\n"
}

function phantom_terminal(){
    echo -e "\n${turquoiseColour}$(printf '=%.0s' {1..40}) [::] PHANTOM TERMINAL [::] $(printf '=%.0s' {1..40})${endColour}\n"
    
    # 1. Aseguramos permisos (y validamos internet rápido)
    wget -q --spider http://google.com
    if [ $? -ne 0 ]; then
        echo -e "\n${redColour}[!] No internet connection. Aborting.${endColour}\n"
        return 1
    fi
    request_sudo

    # --- FUNCIÓN 1: ZSH & PLUGINS ---
    function install_zsh_core(){
        # Instalamos Zsh sin output basura
        sudo apt install zsh git -y -q > /dev/null 2>&1
        
        # Creamos carpeta de plugins
        mkdir -p ~/.zsh_plugins

        # Plugin: Autosuggestions (Si existe, borramos y clonamos de nuevo para asegurar limpieza)
        if [ -d "$HOME/.zsh_plugins/zsh-autosuggestions" ]; then
            rm -rf "$HOME/.zsh_plugins/zsh-autosuggestions"
        fi
        git clone -q https://github.com/zsh-users/zsh-autosuggestions ~/.zsh_plugins/zsh-autosuggestions

        # Plugin: Syntax Highlighting
        if [ -d "$HOME/.zsh_plugins/zsh-syntax-highlighting" ]; then
            rm -rf "$HOME/.zsh_plugins/zsh-syntax-highlighting"
        fi
        git clone -q https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh_plugins/zsh-syntax-highlighting

        # Configuramos .zshrc (Solo si no está ya configurado)
        if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
            echo -e "\n# --- Zsh Plugins (Phantom) ---" >> ~/.zshrc
            echo "source $HOME/.zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> ~/.zshrc
            echo "source $HOME/.zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
        fi
    }

    # --- FUNCIÓN 2: KITTY & NERDFONTS ---
    function setup_kitty_visuals(){
        sudo apt install kitty boxes -y -q > /dev/null 2>&1
        
        # Configuración de Kitty
        mkdir -p ~/.config/kitty
        # Usamos cp -f para forzar sobreescritura si actualizas tus dotfiles
        cp -f dotfiles/kitty/kitty.conf ~/.config/kitty/ 2>/dev/null

        # Fuentes (Solo si existen en tu carpeta assets)
        if [ -d "assets/fonts" ]; then
            sudo cp -n assets/fonts/HackNerdFont* /usr/local/share/fonts/ 2>/dev/null
            fc-cache -fv > /dev/null 2>&1
        fi
    }

    # --- FUNCIÓN 3: STARSHIP & TOOLS (LSD/BAT) ---
    function install_cli_tools(){
        # Starship
        if ! command -v starship &> /dev/null; then
            curl -sS https://starship.rs/install.sh | sh -s -- -y > /dev/null 2>&1
        fi
        
        # Inyectar Starship en .zshrc (Idempotente)
        if ! grep -q "starship init zsh" ~/.zshrc; then
            echo 'eval "$(starship init zsh)"' >> ~/.zshrc
        fi
        
        # Copiar config de starship
        cp -f dotfiles/starship.toml ~/.config/ 2>/dev/null

        # LSD y BAT
        sudo apt install lsd bat -y -q > /dev/null 2>&1
        
        # Fix para bat en Debian/Kali (batcat -> bat)
        if command -v batcat &> /dev/null; then
            sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
        fi
    }

    # --- FUNCIÓN 4: ALIASES ---
    function inject_aliases(){
        # Usamos un marcador para saber si ya escribimos los aliases
        if ! grep -q "# --- Phantom Aliases ---" ~/.zshrc; then
            cat <<EOF >> ~/.zshrc

# --- Phantom Aliases ---
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias cat='bat'
EOF
        fi
    }

    # --- FUNCIÓN 5: TARGET SCRIPT ---
    function setup_target_tool(){
        if [ -f "dotfiles/target.sh" ]; then
            sudo cp -f dotfiles/target.sh /usr/local/bin/target
            sudo chmod +x /usr/local/bin/target
        fi
    }

    # --- EJECUCIÓN DEL FLUJO ---
    execute_process "install_zsh_core" "Deploying Zsh Core & Plugins"
    execute_process "setup_kitty_visuals" "Installing Kitty & NerdFonts"
    execute_process "install_cli_tools" "Installing Starship, Lsd & Bat"
    execute_process "inject_aliases" "Configuring Advanced Aliases"
    execute_process "setup_target_tool" "Initializing Target System"

    # --- CAMBIO DE SHELL ---
    if [ "$SHELL" != "/usr/bin/zsh" ]; then
        sudo chsh -s /usr/bin/zsh "$USER" > /dev/null 2>&1
    fi

    echo -e "\n${turquoiseColour}$(printf '=%.0s' {1..40}) [::] PHANTOM TERMINAL DEPLOYED [::] $(printf '=%.0s' {1..40})${endColour}\n"
    echo -e "${purpleColour}[+]${endColour} ${limaColour} Open a new window of ${purpleColour}Kitty Terminal${endColour}${limaColour} to see the new changes.${endColour}" | boxes -d stone 
}



function nvim_installation(){
    echo -e "\n${turquoiseColour}$(for i in $(seq 1 43); do echo -n '='; done)[::] /// SYSTEM INSTALLATION :: NEOVIM [::]$(for i in $(seq 1 34); do echo -n "="; done)${endColour}\n"

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
    echo -e "\n${turquoiseColour}$(for i in $(seq 1 43); do echo -n '='; done)[::] /// NEOVIM SETUP COMPLETED [::]$(for i in $(seq 1 42); do echo -n "="; done)${endColour}\n"
    
    # Pequeño truco: Si 'boxes' no está instalado, usa 'cat' para que no de error el script
    if command -v boxes &> /dev/null; then
        echo -e "${purpleColour}[+]${endColour} ${limaColour}Use '${purpleColour}nvim${endColour}${limaColour}' to start. First launch will install plugins automatically.${endColour}" | boxes -d stone
    else
        echo -e "${purpleColour}[+]${endColour} ${limaColour}Use 'nvim' to start. First launch will install plugins automatically.${endColour}"
    fi
}
function core_stabilization(){

    # --- SUB-FUNCIÓN: PICOM CONFIG ---
    function picom_modes(){
        echo -e "\n${turquoiseColour}/// SYSTEM CONFIGURATION :: COMPOSITOR PICOM :${endColour}\n"
        echo -e "  ${greenColour}❱ 1 ${endColour} ${purpleColour}AESTHETIC MODE${endColour}    ${grayColour}(Blur)${endColour}"
        echo -e "  ${greenColour}❱ 2 ${endColour} ${purpleColour}PERFORMANCE MODE${endColour}  ${grayColour}(No Blur)${endColour}"
        echo -e "  ${greenColour}❱ 0 ${endColour} ${redColour}Return${endColour}"

        echo -ne "\n${limaColour}┌──(select${endColour}${grayColour}::${endColour}${purpleColour}picom${endColour}${limaColour})${endColour}"
        echo -ne "\n${limaColour}└─${endColour}${greenColour}❱${endColour} "
        read picom_choice

        case $picom_choice in
            1)
                # Validamos que el archivo fuente exista
                if [ -f "dotfiles/picom/picom_quality" ]; then
                    cp -f dotfiles/picom/picom_quality ~/.config/picom/picom.conf
                    echo -e "\n${limaColour}[::] ACTION :: APPLYING AESTHETIC MODE ${endColour}"
                    # REINICIO EN CALIENTE (HOT RELOAD)
                    killall picom 2>/dev/null
                    sleep 1
                    picom -b --config ~/.config/picom/picom.conf 2>/dev/null
                    echo -e "${greenColour}[::] STATUS :: SUCCESS${endColour}"
                else
                    echo -e "\n${redColour}[!] Source file 'dotfiles/picom/picom_quality' not found.${endColour}"
                fi
                ;;
            2)
                if [ -f "dotfiles/picom/picom_performance" ]; then
                    cp -f dotfiles/picom/picom_performance ~/.config/picom/picom.conf
                    echo -e "\n${limaColour}[::] ACTION :: APPLYING PERFORMANCE MODE${endColour}"
                    # REINICIO EN CALIENTE
                    killall picom 2>/dev/null
                    sleep 1
                    picom -b --config ~/.config/picom/picom.conf 2>/dev/null
                    echo -e "${greenColour}[::] STATUS :: SUCCESS${endColour}"
                else
                    echo -e "\n${redColour}[!] Source file not found.${endColour}"
                fi
                ;;
            0) return ;;
            *) echo -e "\n${redColour}[!] Invalid option.${endColour}"; sleep 1 ;;
        esac
    }
    function bspwm_config(){
        # Definimos la ruta del archivo de configuración real
        BSPWM_CONFIG="$HOME/.config/bspwm/bspwmrc"

        echo -e "\n${turquoiseColour}/// SYSTEM CONFIGURATION :: BSPWM BORDERS :${endColour}\n"
        echo -e "  ${greenColour}❱ 1 ${endColour} ${purpleColour}ENABLE BORDERS${endColour}      ${grayColour}(Standard Width: 2)${endColour}"
        echo -e "  ${greenColour}❱ 2 ${endColour} ${purpleColour}DISABLE BORDERS${endColour}     ${grayColour}(Clean/Full: 0)${endColour}"
        echo -e "  ${greenColour}❱ 0 ${endColour} ${redColour}Return${endColour}"

        echo -ne "\n${limaColour}┌──(select${endColour}${grayColour}::${endColour}${purpleColour}borders${endColour}${limaColour})${endColour}"
        echo -ne "\n${limaColour}└─${endColour}${greenColour}❱${endColour} "
        read bspwm_choice

        case $bspwm_choice in
            1)
                if [ -f "$BSPWM_CONFIG" ]; then
                  echo -e "\n${limaColour}[::] ACTION :: ACTIVATING BORDERS (Width:2)${endColour}"
                    
                    # 1. SED QUIRÚRGICO:
                    # Busca la línea que configura el ancho y ponle '2'
                    sed -i 's/^bspc config border_width .*/bspc config border_width 2/g' "$BSPWM_CONFIG"
                    
                    # 2. HOT RELOAD (Aplicar cambios sin salir)
                    bspc wm -r 
                    
                    echo -e "${greenColour}[::] STATUS :: SUCCESS${endColour}"
                else
                    echo -e "\n${redColour}[!] Critical: bspwmrc not found at $BSPWM_CONFIG${endColour}"
                fi
                ;;
            2)
                if [ -f "$BSPWM_CONFIG" ]; then
                    echo -e "\n${limaColour}[::] ACTION :: REMOVING BORDERS (Width:0)${endColour}"
                    
                    # 1. SED QUIRÚRGICO:
                    # Busca la línea y ponle '0'
                    sed -i 's/^bspc config border_width .*/bspc config border_width 0/g' "$BSPWM_CONFIG"
                    
                    # 2. HOT RELOAD
                    bspc wm -r
                    
                    echo -e "${gree/nColour}[::] STATUS :: SUCCESS (Clean Mode)${endColour}"
                else
                    echo -e "\n${redColour}[!] Critical: bspwmrc not found at $BSPW/M_CONFIG${endColour}"
                fi
                ;;
            0) return ;;
            *) echo -e "\n${redColour}[!] Invalid option.${endColour}"; sleep 1 ;;
        esac
    }
    # --- SUB-FUNCIÓN: BSPWM CONFIG ---
    
    # --- SUB-FUNCIÓN: WALLPAPERS ---
    function background_rads(){
        # Definimos rutas clave
        WALLPAPER_DIR="$HOME/.config/wallpapers"
        BSPWM_CONFIG="$HOME/.config/bspwm/bspwmrc"

        # Cabecera estética
        echo -e "\n${turquoiseColour}/// SYSTEM CONFIGURATION :: BACKGROUND RADS :${endColour}\n"
        echo -e "${grayColour}Scanning containment zone for available shields...${endColour}\n"

        # 1. Validar que el directorio existe
        if [ ! -d "$WALLPAPER_DIR" ]; then
            echo -e "${redColour}[!] Critical Error: Wallpaper directory missing ($WALLPAPER_DIR)${endColour}"
            return 1
        fi

        # 2. Crear array con las imágenes (ignorando si no hay de algún tipo)
        shopt -s nullglob
        wallpapers=("$WALLPAPER_DIR"/*.png "$WALLPAPER_DIR"/*.jpg "$WALLPAPER_DIR"/*.jpeg)
        shopt -u nullglob

        # Validar si está vacío
        if [ ${#wallpapers[@]} -eq 0 ]; then
            echo -e "${redColour}[!] No visual artifacts found in the sector.${endColour}"
            return 1
        fi

        # 3. Mostrar menú interactivo
        i=1
        for wall in "${wallpapers[@]}"; do
            filename=$(basename "$wall")
            echo -e "  ${limaColour}❱ $i ${endColour} ${blueColour}$filename${endColour}"
            let i++
        done
        
        echo -e "  ${limaColour}❱ 0 ${endColour} ${redColour}Return${endColour}"

        # 4. Input del usuario
        echo -ne "\n${limaColour}┌──(select${endColour}${grayColour}::${endColour}${purpleColour}wallpaper${endColour}${limaColour})${endColour}"
        echo -ne "\n${limaColour}└─${endColour}${greenColour}❱${endColour} "
        read choice

        # 5. Procesar selección
        # Si elige 0 o vacío, salimos
        if [[ "$choice" == "0" || -z "$choice" ]]; then
            return
        fi

        # Ajustar índice (Bash arrays empiezan en 0, nuestro menú en 1)
        index=$((choice - 1))

        # Verificar si el índice es válido
        if [ "$index" -ge 0 ] && [ "$index" -lt "${#wallpapers[@]}" ]; then
            selected_wall="${wallpapers[$index]}"
            selected_name=$(basename "$selected_wall")

            echo -e "\n${limaColour}[::] ACTION :: DEPLOYING VISUAL CONFIG: $selected_name...${endColour}"

            # A) CAMBIO INMEDIATO (Para que lo veas ya)
            feh --bg-fill "$selected_wall"

            # B) PERSISTENCIA (Editar bspwmrc para el reinicio)
            # Usamos '|' como separador en sed porque las rutas tienen '/'
            if grep -q "feh --bg-fill" "$BSPWM_CONFIG"; then
                # Si la línea existe, la reemplazamos
                sed -i "s|feh --bg-fill .*|feh --bg-fill $selected_wall &|g" "$BSPWM_CONFIG"
            else
                # Si no existe, la agregamos al final
                echo "feh --bg-fill $selected_wall &" >> "$BSPWM_CONFIG"
            fi

            echo -e "${greenColour}[::] STATUS :: SUCCESS${endColour}"
            
            # Pequeña pausa para apreciar el éxito
            sleep 1.5
        else
            echo -e "\n${redColour}[!] Invalid coordinates (Wrong number).${endColour}"
            sleep 1
        fi
    }

    # --- LOOP PRINCIPAL DEL MENÚ (CORE) ---
    while true; do
        clear
        echo -e "$banner" 
        echo -e "\n${limaColour}$(printf '=%.0s' {1..120})${endColour}"
        echo -e "\t\t\t\t\t  ${limaColour}C O R E   S T A B I L I Z E R"
        echo -e "${limaColour}$(printf '=%.0s' {1..120})${endColour}\n"

        echo -e "${lightCyanColour}  ▌ 1 ▐${endColour} ${limaColour}Picom Compositor${endColour}   ${grayColour}(Blur & Performance)${endColour}"
        echo -e "${lightCyanColour}  ▌ 2 ▐${endColour} ${limaColour}Bspwm Borders${endColour}      ${grayColour}(Decorations)${endColour}"
        echo -e "${lightCyanColour}  ▌ 3 ▐${endColour} ${limaColour}Wallpapers${endColour}         ${grayColour}(Background Rads)${endColour}"
        echo -e "\n${lightCyanColour}  ▌ 0 ▐${endColour} ${redColour}Exit to Shell${endColour}"

        echo -ne "\n${limaColour}┌──(core${endColour}${grayColour}::${endColour}${purpleColour}menu${endColour}${limaColour})${endColour}"
        echo -ne "\n${limaColour}└─${endColour}${greenColour}❱${endColour} "
        read core_choice

        case $core_choice in
            1) picom_modes; echo -e "\n${lightCyanColour}// PRESS [ENTER] TO CONTINUE_${endColour}"; read ;;
            2) bspwm_config; echo -e "\n${lightCyanColour}// PRESS [ENTER] TO CONTINUE_${endColour}"; read ;;
            3) background_rads; echo -e "\n${lightCyanColour}// PRESS [ENTER] TO CONTINUE_${endColour}"; read ;;
            0) break ;; # Rompe el bucle y sale
            *) echo -e "\n${redColour}[!] Invalid Option.${endColour}"; sleep 1 ;;
        esac
    done
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
    phantom_terminal
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
  echo -e "  ${turquoiseColour}-c${endColour}          ➜ ${redColour}Core Stabilizer${endColour}. ${purpleColour}(Interactive Menu)${endColour}"
  
  echo -e "\n${limaColour}[+]${endColour} ${grayColour}Examples:${endColour}"
  echo -e "\t${greenColour}./groundzero.sh -f${endColour} (Recommended for fresh installs)"
  echo -e "\t${greenColour}./groundzero.sh -t${endColour} (Only shell configuration)"
  echo -e "\t${greenColour}./groundzero.sh -c${endColour} (Post Install: Visuals, Borders, Wallpapers)"

}


declare -i parameter_counter=0 

while getopts "oftpnch" arg; do
  case $arg in
    o) let parameter_counter+=1;;
    f) let parameter_counter+=2;;
    t) let parameter_counter+=3;;
    p) let parameter_counter+=4;;
    n) let parameter_counter+=5;;
    c) let parameter_counter+=6;;
    h) ;;
  esac
done

if [[ $parameter_counter -eq 1 ]]; then
  select_options
elif [[ $parameter_counter -eq 2 ]]; then 
  full_installation
elif [[ $parameter_counter -eq 3 ]]; then 
  phantom_terminal
elif [[ $parameter_counter -eq 4 ]]; then 
  pwnbox_mode
elif [[ $parameter_counter -eq 5 ]]; then 
  nvim_installation 
elif [[ $parameter_counter -eq 6 ]]; then
  core_stabilization
else 
  helpPanel
fi 
