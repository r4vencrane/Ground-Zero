#!/bin/bash

# --- 1. PREPARACIÓN ---
set -e  # Si algo falla, el script se detiene (seguridad)

# Verificamos que estás en la carpeta correcta
if [ ! -f "setup.sh" ]; then
    echo "[!] ERROR: Ejecuta este script dentro de la carpeta 'Ground-Zero'"
    exit 1
fi

echo "[*] Iniciando instalación de Ground-Zero..."

# Creamos una carpeta temporal "build" para descargar y compilar cosas
# (Es como una mesa de trabajo que luego limpiaremos)
rm -rf build && mkdir build

# --- 2. INSTALAR DEPENDENCIAS (Todo en uno) ---
echo "[*] Instalando paquetes del sistema..."
sudo apt update
sudo apt install -y build-essential git vim xcb libasound2-dev \
    libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev \
    libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev \
    libxcb-xtest0-dev libxcb-shape0-dev libxcb-xkb-dev \
    libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev \
    libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev \
    libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-glx0-dev \
    libxcb-image0-dev libxcb-present-dev libxcb-render0-dev \
    libxcb-render-util0-dev libxcb-util-dev libxcb-xfixes0-dev \
    meson ninja-build uthash-dev \
    polybar kali-community-wallpapers kali-wallpapers-all \
    kitty rofi feh xclip scrot flameshot

# --- 3. COMPILACIÓN (BSPWM, SXHKD, PICOM) ---
# Entramos a la carpeta de trabajo
cd build

echo "[*] Compilando e instalando BSPWM..."
git clone https://github.com/baskerville/bspwm.git
make -C bspwm
sudo make -C bspwm install
sudo cp bspwm/contrib/freedesktop/bspwm.desktop /usr/share/xsessions/

echo "[*] Compilando e instalando SXHKD..."
git clone https://github.com/baskerville/sxhkd.git
make -C sxhkd
sudo make -C sxhkd install

echo "[*] Compilando e instalando PICOM (Animaciones)..."
git clone https://github.com/yshui/picom.git
cd picom
meson setup --buildtype=release build
ninja -C build
sudo ninja -C build install
cd ../.. # Volvemos a la raiz de Ground-Zero

# --- 4. INSTALACIÓN DE DOTFILES (CONFIGURACIONES) ---
echo "[*] Copiando configuraciones..."

# Fuentes (Fonts)
mkdir -p ~/.local/share/fonts
cp -r assets/fonts/* ~/.local/share/fonts/
fc-cache -fv

# Directorios de configuración básicos
mkdir -p ~/.config

# Copiamos carpetas enteras de config
# Nota: Usamos 'cp -r' para copiar recursivamente
cp -r dotfiles/bspwm ~/.config/
cp -r dotfiles/sxhkd ~/.config/
cp -r dotfiles/polybar ~/.config/
cp -r dotfiles/kitty ~/.config/
cp -r dotfiles/rofi ~/.config/

# CONFIGURACIÓN ESPECIAL DE PICOM
# Vi que tienes código fuente dentro de dotfiles/picom, eso NO debe ir a .config
# Solo copiamos el archivo de configuración
mkdir -p ~/.config/picom
cp dotfiles/picom/picom.conf ~/.config/picom/

# Archivos sueltos (zshrc y starship)
cp dotfiles/zshrc ~/.zshrc
cp dotfiles/starship.toml ~/.config/starship.toml

# Scripts y Binarios
cp -r dotfiles/scripts ~/.config/
cp -r dotfiles/bin ~/.config/

# Wallpapers
mkdir -p ~/.config/wallpapers
cp -r assets/wallpapers/* ~/.config/wallpapers/

# Permisos de ejecución
chmod +x ~/.config/bspwm/bspwmrc
chmod +x ~/.config/polybar/launch.sh
chmod +x ~/.config/scripts/*
chmod +x ~/.config/bin/*

# --- 5. LIMPIEZA ---
echo "[*] Limpiando basura..."
rm -rf build

echo "[+] ¡INSTALACIÓN COMPLETADA! Reinicia tu equipo."
