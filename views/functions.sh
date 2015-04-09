meta_path () {
	local f
	f=$(basename $1 | sed 's/^\(.*\).html$/\1.sh/')
	echo $src/metadata/$f
}

extract_blurb () {
	local endline
	endline=$(sed -n '/\[\[MORE\]\]/=' $1)
	if test -z $endline
	then
		echo
	else
		head -n $endline $1
	fi
}
