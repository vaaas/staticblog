#!/bin/sh

# setting the IFS to newline for safety
# few files contain newlines
IFS='
'

# base body template
# input: main content
# output: page
render_body () {
	cat <<- _EOF_
	<!DOCTYPE html>
	<html>
	<head>
		<meta charset="utf-8">
		<meta name="description" content="$BLOG_DESCRIPTION">
		<link rel="stylesheet" href="style.css">
		<link rel="alternate" type="application/rss+xml" href="feed.rss">
		<link rel="alternate" type="application/atom+xml" href="feed.atom">
		<title>$BLOG_TITLE - Page $curpage</title>
	</head>
	<body>
	<header>
		<img src="portrait.img" width="124" height="124">
		<h1><a href="/">$BLOG_TITLE</a></h1>
		<h2>$BLOG_DESCRIPTION</h2>
	</header>
	$(cat /dev/stdin)
	</body>
	</html>
	_EOF_
}

# create the atom feed
# $1: path to the source directory
# output: the atom feed
render_atom () {
	local src items
	src=$1
	shift 1
	. $src/metadata/blog.sh


	items () {
		local f POST_TITLE POST_DESCRIPTION POST_PUBLISHED
		for f in $@
		do
			. $(meta_path $src $f)
			cat <<- _EOF_
			<entry>
				<title>$POST_TITLE</title>
				<link href="$BLOG_URL/$(basename $f)"/>
				<updated>$POST_PUBLISHED</updated>
				<content type="xhtml">
					$(extract_blurb $f)
				</content>
			</entry>
			_EOF_
			POST_TITLE=''
			POST_DESCRIPTION=''
			POST_PUBLISHED=''
		done
	}

	cat <<- _EOF_
	<?xml version="1.0" encoding="UTF-8" ?>
	<feed xmlns="http://www.w3.org/2005/Atom">

	<title>$BLOG_TITLE</title>
	<subtitle>$BLOG_DESCRIPTION</subtitle>
	<link href="$BLOG_URL/feed.atom" rel="self"/>
	<link href="$BLOG_URL"/>
	<updated>$(date)</updated>

	$(items)

	</feed>
	_EOF_
}

# creates the rss feed
# $1: the source directory
# output: the rss feed
render_rss () {
	local src items
	src=$1
	shift 1
	. $src/metadata/blog.sh


	items () {
		local f POST_TITLE POST_DESCRIPTION POST_PUBLISHED
		for f in $@
		do
			. $(meta_path $src $f)
			cat <<- _EOF_
			<item>
				<title>$POST_TITLE</title>
				<description>$(extract_blurb $f)</description>
				<link>$BLOG_URL/$(basename $f)</link>
				<pubDate>$POST_PUBLISHED</pubDate>
			</item>
			_EOF_
			POST_TITLE=''
			POST_DESCRIPTION=''
			POST_PUBLISHED=''
		done
	}

	cat <<- _EOF_
	<?xml version="1.0" encoding="UTF-8" ?>
	<rss version="2.0">
	<channel>
		<title>$BLOG_TITLE</title>
		<description>$BLOG_DESCRIPTION</description>
		<link>$BLOG_URL</link>
		<lastBuildDate>$(date)</lastBuildDate>
		<ttl>1440</ttl>
		$(items $@)
	</channel>
	</rss>
	_EOF_
}

# create overview pages
# $1: the source directory
# $2: the current page
# $3: the total number of pages
# [$4...$n]: the posts to be rendered
# output: the overview page
render_list () {
	local src curpage pages prev next articles
	src=$1
	curpage=$2
	pages=$3
	shift 3
	. $src/metadata/blog.sh

	prev () {
		if test $curpage -gt 1
		then
			echo "<a class=\"card\" id=\"prev\" href=\"$((curpage-1)).html\">← Previous</a>"
		fi
	}

	next () {
		if test $curpage -lt $pages
		then
			echo "<a class=\"card\" id=\"next\" href=\"$((curpage+1)).html\">Next →</a>"
		fi
	}

	articles () {
		local f POST_TITLE POST_DESCRIPTION POST_PUBLISHED
		for f in $@
		do
			. $(meta_path $src $f)
			cat <<- _EOF_
			<article class="card">
				<h1><a href="$(basename $f)">
					$POST_TITLE
				</a></h1>
				<div class="published">
					$POST_PUBLISHED
				</div>
				<div class="blurb">
					$(extract_blurb $f)
				</div>
				<a class="card readmore" href="$(basename $f)">Read more</a>
			</article>
			_EOF_
			POST_TITLE=''
			POST_DESCRIPTION=''
			POST_PUBLISHED=''
			POST_CATEGORIES=''
		done
	}

	render_body <<- _EOF_
	<main id="list">
		$(articles $@)
	</main>
	<nav>
		$(prev)
		<a class="card" href="#">Page $curpage of $pages</a>
		$(next)
	</nav>
	_EOF_
}

# create a page of a single post
# $1: the source directory
# $2: the post pathname
# output: the post page
render_post () {
	local src f
	src=$1
	f=$2

	. $src/metadata/blog.sh
	. $(meta_path $src $f)

	render_body <<- _EOF_
	<main id="post">
		<h1><a href="$(basename $f)">
			$POST_TITLE
		</a></h1>
		<div class="published">$POST_PUBLISHED</div>
		$(cat $f)
	</main>
	_EOF_
}

# calcualate the pathname of the post metadata from the post name
# $1: the source directory
# $2: the post filepath
# output: the metadata pathname
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

# truncate posts after [[MORE]] is encountered
# $1: the post pathname
# output: the truncated post source
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
		render_post $src $f \
			> $dst/$(basename $f)
		echo "Created $dst/$(basename $f)"

		# create arguments for list pages
		args=$(echo "$args\n$f")
	
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
	render_list $src $pagenum $pages $args \
		> $dst/$pagenum.html
	echo "Created $dst/$pagenum.html"

	# the first page doubles as the RSS/Atom feed
	if test $pagenum -eq 1
	then
		# create RSS feed
		render_rss $src $args \
			> $dst/feed.rss
		echo "Created $dst/feed.rss"

		# create Atom feed
		render_atom $src $args \
			> $dst/feed.atom
		echo "Created $dst/feed.atom"
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
