#!/bin/bash

declare -r localDir="/root/projetLinux/"
declare -r accountsSource="accountsSource"
declare -r awkScript="checkAccounts.awk"

# string
checkFileValidity() { 
	if [ ! -e $localDir$accountsSource ] ; then
		echo "Accounts source file does not exist."
		return 1
	fi
	if [ -z "$(cat $localDir$accountsSource)" ] ; then
		echo "Accounts source file is empty."
		return 1
	fi

	awkErrors=$(awk -f $localDir$awkScript $localDir$accountsSource 2>&1 > /dev/null)
	if [ -n "$awkErrors" ] ; then
		echo "$awkErrors"
		return 1
	fi

	echo "$(awk -f $localDir$awkScript $localDir$accountsSource)"
	return 0
}

# string ($fileContent, $lineNumber)
getFileLine() {
	echo "$(echo "$1" | cut -d\| -f$2)"
	return 0
}

# string ($firstname, $name)
generateUsername() {
	username=$(echo "$1" | cut -c1)$(echo "$2")
	occurencies=$(grep -c "$username" /etc/passwd)
	if [ $occurencies -ne 0 ] ; then
		username="$username$occurencies"
	fi

	echo "$username"
	return 0
}

# int ($firstName, $name)
userExists(){
	accounts=$(cat /etc/passwd | cut -d: -f5 | grep -c "$1 $2")

	if [ $accounts -gt 0 ] ; then
		return 1
	fi
	return 0
}

# int ($groupName)
createGroupIfNotExist(){
	foundGroups="$(cat /etc/group | cut -d: -f1 | grep "$1")"

	oldSeparator=$IFS
	IFS=$'\n'
	for group in $foundGroups; do
		if [ "$group" = "$1" ]; then
			return 1
		fi
	done
	IFS=$oldSeparator

	groupadd "$1"
	return 0
}

# string ($groupList)
getPrimaryGroup() {
	group="$(echo "$1" | cut -d, -f1)"
	createGroupIfNotExist "$group"

	echo "-g $group"
	return 0
}

# string ($groupList)
getSecondaryGroups() {
	currGroup="$(echo "$1" | cut -d, -f2)"
	if [ $currGroup = $1 ] ; then
		return 0
	fi

	createGroupIfNotExist "$currGroup"
	groups="-G $currGroup"

	i=3
	currGroup="$(echo "$1" | cut -d, -f$i)"
	while [ -n "$currGroup" ] ; do
		createGroupIfNotExist "$currGroup"
		groups="$groups,$currGroup"

		i=$((i+1))
		currGroup="$(echo "$1" | cut -d, -f$i)"
	done

	echo "$groups"
	return 0
}

# void ($infosList)
createUserFromInfos() {
	firstName="$(echo "$1" | cut -d" " -f1)"
	name="$(echo "$1" | cut -d" " -f2)"
	username=$(generateUsername "$firstName" "$name")

	userExists "$firstName" "$name"
	if [ $? -eq 1 ] ; then
		return 0
	fi

	groups="$(echo "$1" | cut -d" " -f3)"
	if [ -n "$groups" ] ; then
		primary="$(getPrimaryGroup $groups)"
		secondary="$(getSecondaryGroups "$groups")"
	fi

	sudo="$(echo "$1" | cut -d" " -f4)"
	if [ $sudo = "oui" ]; then
		if [ -n "$secondary" ]; then
			secondary="$secondary,sudo"
		else
			secondary="-G sudo"
		fi
	fi

	useradd $primary $secondary -c "$firstName $name" "$username"

	password="$(echo "$1" | cut -d" " -f5)"
	echo "$username:$password" | chpasswd
	passwd -e "$username" > /dev/null

	unset primary
	unset secondary
}


# MAIN

declare -r validityReturn=$(checkFileValidity)

if [ $? -ne 0 ] ; then
	echo "$validityReturn"
	exit 1
fi

i=1
currLine=$(getFileLine "$validityReturn" $i)

while [ -n "$currLine" ] ; do
	createUserFromInfos "$currLine"

	i=$((i+1))
	currLine=$(getFileLine "$validityReturn" $i)
done
