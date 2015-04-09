#!/bin/sh
EOF='
'

src=$1
file=$2

. $src/views/functions.sh
. $src/metadata/blog.sh
. $(meta_path $file)

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
<header>
	<img src="shit_logo.svg" width="125" height="125">
	<h1><a href="/">$BLOG_TITLE</a></h1>
	<h2>$BLOG_DESCRIPTION</h2>
</header>
<main id="post">
	<h1><a href="$(basename $file)">
		$POST_TITLE
	</a></h1>
	<div class="published">$POST_PUBLISHED</div>
	$(cat $file)
</main>
</body>
</html>
_EOF_
