#!/bin/sh

IFS='
'

# ensure sane arguments
if ! test -d $1
then
	echo "$1 is not a directory"
	exit 1
elif ! test -d $2
then
	echo "$2 is not a directory"
	exit 1
fi

src="$1"
dst="$2"

# ensure sane working environment
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
elif ! test -f $src/views/post.sh
then
	echo "$src doesn't have a post view"
	exit 1
elif ! test -f $src/views/list.sh
then
	echo "$src doesn't have a list view"
fi

# create temporary directory
mkdir /var/tmp/staticblog/

# create list pages
counter=0
pagenum=1
args=''
for file in `find $src/metadata -type f | sort -r`
do
	args="$args
	$file"
	counter=$((counter+1))
	
	if test $counter -eq 10
	then
		$src/views/list.sh $args \
			> /var/tmp/staticblog/$pagenum.html
		counter=0
		$pagenum=$((pagenum+1))
	fi
done

# create post pages
for file in `find $src/posts -type f`
do
	meta=`echo $file | sed s/.html/.json`
	$src/views/post.sh $file $meta \
		> /var/tmp/staticblog/$file.html
done

# move results
find /var/tmp/staticblog -type f -exec mv -v -t $src ;
