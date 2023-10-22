#!/usr/bin/env bash

dnf -y install jq

# list current support php version
readarray -t php_list < <(plesk bin php_handler --list -json true | jq -r '. | to_entries | .[].value.id')

selected_php="plesk-php80-fastcgi"

# prompt the user to select a value from the array
echo "Select php version: "
select value in "${php_list[@]}"; do
    selected_php=${value}
    break
done

# Display the selected value
echo "You selected ${value}"

# Prompt the user for confirmation
read -p "Are you sure you want to all to all domains? [y/N] " answer

# Check if the input is valid
if [[ "$answer" =~ ^[Yy]$ ]]; then
    echo "Continuing..."
else
    echo "Aborting..."
    exit 1
fi

# all domain
plesk db -Ne "select name from domains where htype='vrt_hst'" > domains.txt

# domain with php 5.6
#plesk db -sNe "select name from hosting hos,domains dom where dom.id = hos.dom_id and php = 'true' AND php_handler_id LIKE 'fastcgi-5.6'" > domains.txt

# change domain in list to selected_php
while read -r d; do
    plesk bin domain -u "$d" -php_handler_id ${selected_php}
done < domains.txt

exit 0