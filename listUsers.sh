#!/bin/bash

#string ($groupList)
getSecondaryGroups() {
	next=$(echo "$1" | cut -d" " -f4)

	if [ -z "$next" ]; then
		echo "Pas de groupes"
		return 0
	fi
	secondary="$next"

	i=5
	until [ -z "$next" ]; do
		if [ $secondary != $next ]; then
			secondary="$secondary,$next"
		fi
		next=$(echo "$1" | cut -d" " -f$i)
		i=$((i+1))
	done
	echo "$secondary"
	return 0
}

#string ($size)
sizeToString() {
	size=$1
	res=""
	units="o Ko Mo Go To"
	for unit in $units; do
		res="$((size%1024))$unit $res"
		size=$((size/1024))
	done
	echo "$res"
	return 0
}



#MAIN

humans=$(awk -F: '($3 >= 1000 && $1 != "nobody"){print()}' /etc/passwd)
oldSeparator=$IFS
IFS=$'\n'

for line in $humans; do
	username=$(echo "$line" | cut -d: -f1)
	fullName=$(echo "$line" | cut -d: -f5)
	groups=$(groups $username)
	primary=$(echo "$groups" | cut -d" " -f3)
	secondary=$(getSecondaryGroups "$groups")
	homeDir=$(echo "$line" | cut -d: -f6)
	homeDirSize=$(du -sb "$homeDir" | cut -f1)

	echo "Utilisateur : $username"
	echo "Prénom : $(echo "$fullName" | cut -d" " -f1)"
	echo "Nom : $(echo "$fullName" | cut -d" " -f2)"
	echo "Groupe primaire : $primary"
	echo "Groupe secondaires : $secondary"

	IFS=$oldSeparator
	echo "Répertoire personnel : $(sizeToString $homeDirSize)"
	IFS=$'\n'

	echo
done
