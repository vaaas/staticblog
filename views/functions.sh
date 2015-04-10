meta_path () {
	local src path name reladir
	src=$1
	path=$2
	name=$(basename $path | sed 's/^\(.*\).html$/\1.sh/')
	reladir=$(realpath --relative-to $src $(dirname $path))
	if test -z $reladir
	then
		echo $src/$name
	else
		echo $src/metadata/$reladir/$name
	fi
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
