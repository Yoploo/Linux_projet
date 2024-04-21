#!/bin/bash

# Chemin vers le fichier où la liste précédente est stockée
PREVIOUS_LIST_FILE="/previous.txt"

# Chemin vers le fichier où la nouvelle liste sera stockée
NEW_LIST_FILE="/new_list.txt"

# Chemin vers le fichier de log pour les différences
DIFF_LOG_FILE="/diff_log.txt"

# Trouver les fichiers avec SUID et/ou SGID activés
sudo find / -type f \( -perm -4000 -o -perm -2000 \) -exec ls -l {} \; 2>/dev/null > $NEW_LIST_FILE

# Si le fichier de la liste précédente existe, comparer les listes
if [ -f $PREVIOUS_LIST_FILE ]; then
    diff $PREVIOUS_LIST_FILE $NEW_LIST_FILE > $DIFF_LOG_FILE
    if [ -s $DIFF_LOG_FILE ]; then
        sudo echo "Avertissement : Les listes sont différentes."
        sudo echo "Voici les différences :"
        sudo cat $DIFF_LOG_FILE
        sudo echo "Date de modification des fichiers litigieux :"
        sudo grep -Ff $DIFF_LOG_FILE $NEW_LIST_FILE | awk '{print $6, $7, $8, $9}' | while read -r line;>
                file=$(echo "$line" | awk '{print $NF}')
                mod_date=$(stat -c %y "$file")
                echo "$mod_date"
        done
    else
        sudo echo "Les listes sont identiques."
    fi
else
   sudo echo "Aucune liste précédente trouvée."
fi

# Mettre à jour la liste précédente avec la nouvelle liste
sudo mv $NEW_LIST_FILE $PREVIOUS_LIST_FILE