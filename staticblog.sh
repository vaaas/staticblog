#!/bin/sh

IFS='
'

ensure_sane_arguments () {
	if ! test -d $1
	then
		echo "$1 is not a directory"
		exit 1
	elif ! test -d $2
	then
		echo "$2 is not a directory"
		exit 1
	fi
}

ensure_sane_environment () {
	if ! test -d $src/posts
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
	elif ! test -f $src/metadata/blog.sh
	then
		echo "$src doesn't define blog metadata"
	elif ! test -f $src/views/post.sh
	then
		echo "$src doesn't have a post view"
		exit 1
	elif ! test -f $src/views/list.sh
	then
		echo "$src doesn't have a list view"
	elif ! test -f $src/views/rss.sh
	then
		echo "$src doesn't have a rss generator"
	fi
}

setup_environment () {
	mkdir /var/tmp/staticblog/
	# list of post files
	files=`find $src/posts -type f -printf %f | sort -r`
	# amount of post files
	filenum=`echo $files | wc -l`
	# total amount of pages that need to be generated
	pages=$((filenum/10))
	if test $((pages*10)) -lt $filenum
	then
		pages=$((pages+1))
	fi
}

loop_files () {
	# counter till next page
	counter=0
	# current page
	pagenum=1
	# arguments to be passed to list generator
	args=''
	for file in $files
	do
		# rewrite post file into metadata file
		meta=`echo $file | sed 's/^\(.*\).html$/\1.sh/'`

		# create post file
		/bin/sh $src/views/post.sh \
			$src/metadata/blog.sh \
			$src/metadata/$meta \
			$src/posts/$file \
			> /var/tmp/staticblog/$file
		echo "Created /var/tmp/staticblog/$file"

		# create arguments for list pages
		args="$args
		$src/metadata/$meta"
	
		counter=$((counter+1))

		# generate pages in 10 post increments
		if test $counter -eq 10
		then
			list_generator
			counter=0
			pagenum=$((pagenum+1))
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
	/bin/sh $src/views/list.sh \
		$src/metadata/blog.sh \
		$pagenum \
		$pages \
		$args \
		> /var/tmp/staticblog/$pagenum.html
	echo "Created /var/tmp/staticblog/$pagenum.html"

	# the first page doubles as the RSS/Atom feed
	if test $pagenum -eq 1
	then
		# create RSS feed
		/bin/sh $src/views/rss.sh \
			$src/metadata/blog.sh \
			$args \
			> /var/tmp/staticblog/feed.rss
		echo "Created /var/tmp/staticblog/feed.rss"
	fi 
}

finalise () {
	find /var/tmp/staticblog -type f -exec mv -v -t $dst -- {} +
	rmdir /var/tmp/staticblog/
}

main () {
	ensure_sane_arguments
	src=$1
	dst=$2
	ensure_sane_environment
	setup_environment
	loop_files
	finalise
}

main $@
