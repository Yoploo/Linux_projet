#!/bin/bash

localDir="/root/projetLinux/"
accountsSource="accountsSourceTest"
awkScript="checkAccounts.awk"

# string
function checkFileValidity() { 
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

validityReturn=$(checkFileValidity)
if [ $? -ne 0 ] ; then
	echo "$validityReturn"
	exit 1
fi

echo "Pas d'erreurs"
