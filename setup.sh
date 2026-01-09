#!/bin/bash

# --- PREPARACIÓN DEL ENTORNO ---
set -e  # Salir si hay error

# Obtenemos la ruta absoluta de donde está este script
# Esto permite correr el script desde cualquier lado sin romper las rutas
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$REPO_DIR/build"

echo "[+] Iniciando instalación desde: $REPO_DIR"

# Crear carpeta temporal para descargas y compilación (se ignora en git)
mkdir -p "$BUILD_DIR"

# --- ACTUALIZACIÓN ---
echo "[*] Actualizando sistema..."
sudo apt update 

# --- DEPENDENCIAS ---
echo "[*] Instalando dependencias..."
sudo apt install -y build-essential git vim xcb libasound2-dev \
libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev \
libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev \
libxcb-xtest0-dev libxcb-shape0-dev libxcb-xkb-dev polybar \
kali-community-wallpapers kali-wallpapers-all


# --- COMPILACIÓN (Usando la carpeta build) ---

# 1. BSPWM
if ! command -v bspwm &> /dev/null; then
    echo "[*] Compilando BSPWM..."
    cd "$BUILD_DIR"
    git clone https://github.com/baskerville/bspwm.git
    cd bspwm
    make
    sudo make install
    sudo cp contrib/freedesktop/bspwm.desktop /usr/share/xsessions/
else
    echo "[!] BSPWM ya está instalado."
fi

# 2. SXHKD
if ! command -v sxhkd &> /dev/null; then
    echo "[*] Compilando SXHKD..."
    cd "$BUILD_DIR"
    git clone https://github.com/baskerville/sxhkd.git
    cd sxhkd
    make
    sudo make install
else
    echo "[!] SXHKD ya está instalado."
fi

# 3. PICOM
if ! command -v picom &> /dev/null; then
    echo "[*] Instalando deps y compilando PICOM..."
    # (Aquí pones todas las deps de picom que tenías antes)
    sudo apt install -y libconfig-dev libdbus-1-dev libegl-dev libev-dev \
    libgl-dev libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev \
    libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev libxcb-glx0-dev \
    libxcb-image0-dev libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev \
    libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev libxcb-xfixes0-dev \
    meson ninja-build uthash-dev

    cd "$BUILD_DIR"
    git clone https://github.com/yshui/picom.git
    cd picom
    meson setup --buildtype=release build
    ninja -C build
    sudo ninja -C build install
else
    echo "[!] Picom ya está instalado."
fi

# --- INSTALACIÓN DE DOTFILES (La parte clave) ---
echo "[*] Copiando tus configuraciones..."

# Volvemos a la raíz del repo por seguridad
cd "$REPO_DIR"

# Copiamos Fuentes
if [ -d "$REPO_DIR/assets/fonts" ]; then
    echo "  -> Instalando fuentes..."
    mkdir -p ~/.local/share/fonts
    cp -r "$REPO_DIR/assets/fonts/"* ~/.local/share/fonts/
    fc-cache -fv
fi

# Copiamos Configs (BSPWM, Polybar, etc.)
# Esto toma lo que está en tu carpeta 'dotfiles' y lo pone en ~/.config
# Usamos un bucle para hacerlo limpio
for config in bspwm sxhkd polybar picom kitty rofi; do
    if [ -d "$REPO_DIR/dotfiles/$config" ]; then
        echo "  -> Copiando config de $config..."
        # Borra la config vieja si existe para evitar conflictos (opcional pero recomendado)
        rm -rf ~/.config/$config
        cp -r "$REPO_DIR/dotfiles/$config" ~/.config/
    fi
done

# Permisos de ejecución para scripts internos de bspwm
chmod +x ~/.config/bspwm/bspwmrc
mkdir ~/.config/wallpapers
cd 
cp Ground-Zero/assets/wallpapers/* ~/.config/wallpapers


# --- LIMPIEZA ---
echo "[*] Limpiando archivos temporales..."
rm -rf "$BUILD_DIR"

echo "[+] ¡INSTALACIÓN COMPLETADA!"
echo "    Por favor reinicia el sistema."
