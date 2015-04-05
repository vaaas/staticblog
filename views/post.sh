#!/bin/sh

blogmeta=$1
postmeta=$2
post=$3

. $blogmeta
. $postmeta

gen_link () {
	basename $1
}

cat <<- _EOF_
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<meta name="description" content="$BLOG_DESCRIPTION">
	<link rel="stylesheet" href="style.css">
	<link rel="alternate" type="application/rss+xml" href="feed.rss">
	<title>$BLOG_TITLE - $POST_TITLE</title>
</head>
<body>
<main id="post">
	<h1><a href="$(gen_link $post)">$POST_TITLE</a></h1>
	<h2>$POST_DESCRIPTION</h2>
	<div class="published">$POST_PUBLISHED</div>
	$(cat $post)
</main>
</body>
</html>
_EOF_
