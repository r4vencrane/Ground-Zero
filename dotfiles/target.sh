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

FILE="$HOME/.target_ip"

if [[ "$1" == "copy" ]]; then
    if [ -f "$FILE" ]; then
      tr -d '\n' < "$FILE" | xclip -selection clipboard
      echo -e "${limaColour}[+]${endColour} ${grayColour}IP copied${endColour}: ${turquoiseColour}$(tr -d '\n' < "$FILE")${endColour}"
    else
      echo -e "${redColour}[-] Error: El archivo $FILE no existe${endColour}"
    fi
else
    echo -n "$1" > "$FILE"
    echo -e "${limaColour}[+]${endColour} ${grayColour}Saved:${endColour} ${turquoiseColour}$1${endColour}"
fi


