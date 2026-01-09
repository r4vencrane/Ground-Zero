#!/bin/bash

# --- 1. PREPARACIÓN ---
set -e  # Abortar si hay errores

if [ ! -f "setup.sh" ]; then
    echo "[!] ERROR: Ejecuta este script desde la carpeta 'Ground-Zero'"
    exit 1
fi

echo "[*] Iniciando instalación de Ground-Zero (BSPWM + Terminal Aesthetics)..."

# Limpieza y creación de entorno de trabajo
rm -rf build && mkdir build

# --- 2. INSTALAR PAQUETES Y DEPENDENCIAS ---
echo "[*] Instalando paquetes del sistema..."
sudo apt update
sudo apt install -y \
    build-essential git vim curl wget unzip \
    xcb libasound2-dev libxcb-util0-dev libxcb-ewmh-dev \
    libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev \
    libxcb-xinerama0-dev libxcb-xtest0-dev libxcb-shape0-dev libxcb-xkb-dev \
    libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev \
    libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev \
    libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-glx0-dev \
    libxcb-image0-dev libxcb-present-dev libxcb-render0-dev \
    libxcb-render-util0-dev libxcb-util-dev libxcb-xfixes0-dev \
    meson ninja-build uthash-dev \
    polybar kali-community-wallpapers kali-wallpapers-all \
    kitty rofi feh xclip scrot flameshot \
    zsh bat lsd   # Agregados para la terminal

# --- 3. COMPILACIÓN DE ENTORNO GRÁFICO ---
cd build

echo "[*] Compilando BSPWM..."
git clone https://github.com/baskerville/bspwm.git
make -C bspwm
sudo make -C bspwm install
sudo cp bspwm/contrib/freedesktop/bspwm.desktop /usr/share/xsessions/

echo "[*] Compilando SXHKD..."
git clone https://github.com/baskerville/sxhkd.git
make -C sxhkd
sudo make -C sxhkd install

echo "[*] Compilando PICOM..."
git clone https://github.com/yshui/picom.git
cd picom
meson setup --buildtype=release build
ninja -C build
sudo ninja -C build install
cd ../.. # Volver a la raíz

# --- 4. ESTÉTICA DE TERMINAL (ZSH & STARSHIP) ---
echo "[*] Configurando Shell y Starship..."

curl -sS https://starship.rs/install.sh | sh -s -- -y

sudo cp assets/fonts/HackNerdFont*  /usr/share/fonts

# NOTA: Tu archivo .zshrc debe apuntar a estas rutas. Si usa /usr/share, avísame.


# --- 5. COPIADO DE DOTFILES ---
echo "[*] Instalando Dotfiles..."

# Preparar directorios
mkdir -p ~/.config
mkdir -p ~/.local/share/fonts

# Fuentes
cp -r assets/fonts/* ~/.local/share/fonts/
fc-cache -fv

# Configs Gráficas
cp -r dotfiles/bspwm ~/.config/
cp -r dotfiles/sxhkd ~/.config/
cp -r dotfiles/polybar ~/.config/
cp -r dotfiles/rofi ~/.config/

# Configs de Terminal
cp -r dotfiles/kitty ~/.config/
/bin/cat dotfiles/zshrc >> ~/.zshrc
cp dotfiles/starship.toml ~/.config/starship.toml

# Configs de Picom (Solo el .conf)
mkdir -p ~/.config/picom
cp dotfiles/picom/picom.conf ~/.config/picom/

# Scripts y Wallpapers
cp -r dotfiles/scripts ~/.config/
cp -r dotfiles/bin ~/.config/
mkdir -p ~/.config/wallpapers
cp -r assets/wallpapers/* ~/.config/wallpapers/

# --- 6. AJUSTES FINALES Y PERMISOS ---
echo "[*] Aplicando permisos y correcciones..."

chmod +x ~/.config/bspwm/bspwmrc
chmod +x ~/.config/polybar/launch.sh
chmod +x ~/.config/scripts/*
chmod +x ~/.config/bin/*
sudo ln -s /usr/bin/batcat /usr/local/bin/bat

# FIX AUTOMÁTICO DE RENDIMIENTO (PICOM)
# Esto cambia el backend a xrender si estaba en glx para evitar lentitud
#if grep -q 'backend = "glx"' ~/.config/picom/picom.conf; then
#    echo " -> Aplicando parche de rendimiento a Picom..."
#    sed -i 's/backend = "glx"/backend = "xrender"/g' ~/.config/picom/picom.conf
#    sed -i 's/vsync = true/vsync = false/g' ~/.config/picom/picom.conf
#fi

# Limpieza
rm -rf build

echo "[+] ¡INSTALACIÓN COMPLETADA!"
echo "    Reinicia el sistema para ver los cambios en la terminal y entorno."
