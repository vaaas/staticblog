#!/bin/sh

IFS='
'

ensure_sane_arguments () {
	if test -z $1 -o  -z $2
	then
		echo "Invalid arguments"
		exit 1
	fi
}

ensure_sane_environment () {
	if ! test -d $src
	then
		echo "$src is not a directory"
		exit 1
	elif ! test -d $dst
	then
		echo "$dst is not a directory"
		exit 1
	elif ! test -d $src/posts
	then
		echo "$src doesn't have a posts directory"
		exit 1
	elif ! test -d $src/metadata
	then
		echo "$src doesn't have a metadata directory"
		exit 1
	elif ! test -d $src/views
	then
		echo "$src doesn't have a views directory"
		exit 1
	elif ! test -d $src/static
	then
		echo "$src doesn't have a static directory"
		exit 1
	elif ! test -f $src/metadata/blog.sh
	then
		echo "$src doesn't define blog metadata"
		exit 1
	elif ! test -d $src/metadata/posts
	then
		echo "$src doesn't define post metadata"
		exit 1
	elif ! test -f $src/views/post.sh
	then
		echo "$src doesn't have a post view"
		exit 1
	elif ! test -f $src/views/list.sh
	then
		echo "$src doesn't have a list view"
		exit 1
	elif ! test -f $src/views/rss.sh
	then
		echo "$src doesn't have a rss generator"
		exit 1
	fi
}

setup_environment () {
	# list of post files
	files=$(find $src/posts -type f | sort -r)
	# amount of post files
	filenum=$(echo "$files" | wc -l)
	# total amount of pages that need to be generated
	pages=$((filenum/10))
	if test $((pages*10)) -lt $filenum
	then
		pages=$((pages+1))
	fi
}

loop_files () {
	local counter pagenum args f
	# counter till next page
	counter=0
	# current page
	pagenum=1
	# arguments to be passed to list generator
	args=''
	for f in $files
	do
		# create post file
		/bin/sh $src/views/post.sh $src $f \
			> $dst/$(basename $f)
		echo "Created $dst/$(basename $f)"

		# create arguments for list pages
		args="$args
		$f"
	
		counter=$((counter+1))

		# generate pages in 10 post increments
		if test $counter -eq 10
		then
			list_generator
			counter=0
			pagenum=$((pagenum+1))
			args=''
		fi
	done
	
	# generate the last page if necessary
	if test $counter -gt 0
	then
		list_generator
	fi
}

list_generator () {
	# create list file
	/bin/sh $src/views/list.sh $src $pagenum $pages $args \
		> $dst/$pagenum.html
	echo "Created $dst/$pagenum.html"

	# the first page doubles as the RSS/Atom feed
	if test $pagenum -eq 1
	then
		# create RSS feed
		/bin/sh $src/views/rss.sh $src $args \
			> $dst/feed.rss
		echo "Created $dst/feed.rss"
	fi 
}

copy_static () {
	cp -r -- $src/static/* $dst
}

main () {
	ensure_sane_arguments $@
	src=$1
	dst=$2
	ensure_sane_environment
	setup_environment
	loop_files
	copy_static
	echo "Done! :)"
}

main $@
