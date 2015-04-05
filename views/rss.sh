#!/bin/sh
EOF='
'
blogmeta=$1
. $blogmeta
shift 1

reset_variables () {
	POST_TITLE=''
	POST_DESCRIPTION=''
	POST_PUBLISHED=''
}

gen_link () {
	dir=$1
	base=`basename $2 | sed 's/^\(.*\).sh$/\1.html/'`
	echo $dir/$base
}

items () {
	for i in $@
	do
		. $i
		cat <<- _EOF_
		<item>
			<title>$POST_TITLE</title>
			<description>$POST_DESCRIPTION</description>
			<link>$(gen_link $BLOG_URL $i)</link>
			<pubDate>$POST_PUBLISHED</pubDate>
		</item>
		_EOF_
		reset_variables
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
