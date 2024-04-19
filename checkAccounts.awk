BEGIN {
	FS="[:]"
	output=""
	errOutput=""
	error=0
}

( NF != 5 ) {
	err = NR " - Line must have 5 fields"
	errOutput = errOutput err "\n"
	error = 1
}

($1 == "" || $2 == "" || $4 == "" || $5 == "") {
	err = NR "- Fields 1, 2, 4 and 5 cannot be empty."
	errOutput = errOutput err "\n"
	error = 1
}

($4 != "oui" && $4 != "non" && $4 != "Oui" && $4 != "Non" && $4 != "OUI" && $4 != "NON"){
	err = NR "- Fourth field (sudo) must be equal to 'oui' or 'non'."
	errOutput = errOutput err "\n"
	error = 1
}

( $1 !~ /^[a-zA-Z]+$/ || $2 !~ /^[a-zA-Z]+$/){
	err = NR "- First and second fields (name and firstname) must be letters."
	errOutput = errOutput err "\n"
	error = 1
}

( $3 !~ /^[a-zA-Z,]+$/ || $3 ~ /(,,)/ ) {
	err = NR "- Third field (groups) must be letters separated by commas."
	errOutput = errOutput err "\n"
	error = 1
}

( length($5) < 8 ){
	err = NR "- Fifth field (password) must be at least 8 characters long."
	errOutput = errOutput err "\n"
	error = 1
}

( error == 0 ){
	line = ""
	for(i = 1; i <= NF; i++){
	       line = line $i
	       if(i < 5)
		       line = line " "
       }
	output = output line "|"
}

END {
	if(error == 0)
		print output
	else
		print errOutput > "/dev/stderr"
}
