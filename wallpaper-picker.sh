#!/bin/bash
DIR="$HOME/Pictures/Wallpapers"
ORDER_FILE="$HOME/.cache/wallpaper_order.txt"

if [ ! -f "$ORDER_FILE" ]; then
    ls "$DIR" | grep -E "\.(jpg|jpeg|png|gif|webp)$" > "$ORDER_FILE"
fi

TEMP_ORDER=$(grep -xFf <(ls "$DIR") "$ORDER_FILE" 2>/dev/null)
NEW_FILES=$(ls "$DIR" | grep -E "\.(jpg|jpeg|png|gif|webp)$" | grep -vxFf "$ORDER_FILE" 2>/dev/null)
echo -e "${TEMP_ORDER}\n${NEW_FILES}" | sed '/^$/d' > "$ORDER_FILE"

LIST=""
while read -r file; do
    [ -z "$file" ] && continue
    LIST+="$file\0icon\x1f$DIR/$file\n"
done < "$ORDER_FILE"

EFFECTS=("fade" "wipe" "wave" "grow" "center" "outer")
RANDOM_EFFECT=${EFFECTS[$RANDOM % ${#EFFECTS[@]}]}

SELECTION=$(echo -en "$LIST" | rofi -dmenu -i -show-icons -sep '\n' \
    -theme "$HOME/.config/rofi/themes/rofi-wall-picker.rasi" \
    -p "Эффект: $RANDOM_EFFECT")

if [ -n "$SELECTION" ]; then

    grep -vxF "$SELECTION" "$ORDER_FILE" > "${ORDER_FILE}.tmp"
    echo "$SELECTION" >> "${ORDER_FILE}.tmp"
    sed -i '/^$/d' "${ORDER_FILE}.tmp"
    mv "${ORDER_FILE}.tmp" "$ORDER_FILE"

    awww img "$DIR/$SELECTION" \
        --transition-type "$RANDOM_EFFECT" \
        --transition-duration 0.9 \
        --transition-fps 120
fi
