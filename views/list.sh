#!/bin/sh
EOF='
'

src=$1
curpage=$2
pages=$3
shift 3
. $src/views/functions.sh
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

cat <<- _EOF_
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="description" content="$BLOG_DESCRIPTION">
	<link rel="stylesheet" href="style.css">
	<link rel="alternate" type="application/rss+xml" href="feed.rss">
	<title>$BLOG_TITLE - Page $curpage</title>
</head>
<body>
<header>
	<img src="shit_logo.svg" width="125" height="125">
	<h1><a href="/">$BLOG_TITLE</a></h1>
	<h2>$BLOG_DESCRIPTION</h2>
</header>
<main id="list">
	$(articles $@)
</main>
<nav>
	$(prev)
	<a class="card" href="#">Page $curpage of $pages</a>
	$(next)
</nav>
</body>
</html>
_EOF_
