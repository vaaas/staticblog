#!/bin/sh
EOF='
'
src=$1
shift 1
. $src/views/functions.sh
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
