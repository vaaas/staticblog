# Static blog generator written in sh

These are a bunch of scripts that create static blog websites from a series of
posts and their metadata. Features:

1. "Templates"
2. 100% pure sh
3. /bin/dash compatible
4. Extensible
5. Under 500 SLOC!

## Usage

Running:

	/bin/sh staticblog.sh $source_dir $destination_dir

Will generate files in $destination_dir based on the input from $source_dir.

## How it works

The main script scans the `posts` directory and passes the posts and their
corresponding metadata to the generator scripts, which then use this information
to generate files.

Metadata files are shell scripts setting certain variables, which are then
sourced by the generator scripts.

Generator scripts are shell scripts using "here-document" redirection to create
pages from a "template". To change the template, simply change the script.

Every 10 posts are passed to the list generator, which generates an overview
(headlines) of these posts. A RSS feed is also generated out of the first page.

## Directory structure

### `posts`

The content of blog posts.

### `metadata`

Information about these blog posts. The special blog.sh file describes the blog
itself.

### `views`

Generator scripts.

## Notes

These scripts are *only* concerned with generating HTML pages and the RSS feed,
so they do not manage other static files (e.g. images, stylesheets), or a
website's entire hierarchy.

Blog posts are sorted in reverse using coreutils sort. This means the user is
responsible for naming files sanely.

## Todo

- Add support for custom, non-blog pages (e.g. contact pages).
- Add support for categories and/or tags.
- Add support for Atom feeds.
