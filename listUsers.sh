#!/bin/bash

#string ($groupList)
getSecondaryGroups() {
	next=$(echo "$1" | cut -d" " -f4)

	if [ -z "$next" ]; then
		echo "Pas de groupe"
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

#int/bool ($username, $groupName, $secondaryGroups = "")
isInSecondaryGroup() {
	if [ -z "$3" ]; then
		userGroups=$(groups $1)
		secondaryGroups=$(getSecondaryGroups "$userGroups")
	else
		secondaryGroups=$3
	fi

	if [ "$secondaryGroups" = "Pas de groupe" ]; then
		return 0
	fi

	j=1
	currGroup=$(echo "$secondaryGroups" | cut -d, -f$j)
	until [ -z "$currGroup" ]; do
		if [ "$currGroup" = "$2" ]; then
			return 1
		fi
		j=$((j+1))
		currGroup=$(echo "$secondaryGroups" | cut -d, -f$j)
	done

	return 0
}

#string ($username, $secondary = "")
toStringSudoer() {
	isInSecondaryGroup "$username" "sudo" "$secondary" 
	sudoer=$?
	if [ $sudoer -eq 1 ]; then
		echo "OUI"
	else
		echo "NON"
	fi
	return 0
}





#MAIN

declare -r humans=$(awk -F: '($3 >= 1000 && $1 != "nobody"){print()}' /etc/passwd)
declare -r oldSeparator=$IFS
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

	echo "Sudoer : $(toStringSudoer "$username" "$secondary")"
	echo
done
