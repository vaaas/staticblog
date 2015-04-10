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
