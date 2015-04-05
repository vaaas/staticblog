#!/bin/sh

blogmeta=$1
curpage=$2
pages=$3
. $blogmeta
shift 3

gen_link () {
	basename $1 | sed 's/^\(.*\).sh$/\1.html/'
}

reset_variables () {
	POST_TITLE=''
	POST_DESCRIPTION=''
	POST_PUBLISHED=''
}

prev () {
	if test $curpage -gt 1
	then
		echo "<a id=\"prev\" href=\"$((curpage-1)).html\">Previous page</a>"
	fi
}

next () {
	if test $curpage -lt $pages
	then
		echo "<a id=\"next\" href=\"$((curpage+1)).html\">Next page</a>"
	fi
}

articles () {
	for i in $@
	do
		. $i
		cat <<- _EOF_
		<article>
			<h1><a href="$(gen_link $i)">$POST_TITLE</a></h1>
			<h2>$POST_DESCRIPTION</h2>
			<div class="published">$POST_PUBLISHED</div>
		</article>
		_EOF_
		reset_variables
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
	<title>$BLOG_TITLE - Page $#</title>
</head>
<body>
<main id="list">
	$(articles $@)
</main>
<nav>
	$(prev)
	<div id="curpage">Page $curpage of $pages</div>
	$(next)
</nav>
</body>
</html>
_EOF_
