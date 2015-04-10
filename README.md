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

	/bin/sh staticblog.sh $source $destination

Will generate files in `$destination` based on the input from `$source`.

## How it works

The main script scans the `posts` directory and passes the posts and their
corresponding metadata to the generator scripts, which then use this information
to generate files.

Metadata files are shell scripts setting certain variables, which are then
sourced by the generator scripts.

Generator scripts are shell scripts using "here-document" redirection to create
pages from a "template". To change the template, simply change the script.

Every 10 posts are passed to the list generator, which generates an overview
(headlines) of these posts. A feeds are also generated out of the first page.

## Directory structure

### `posts`

Body text content of blog posts.

### `metadata`

Information about pages.

#### `metadata/blog.sh`

Information about the blog itself.

#### `metadata/posts`

Information about blog posts.

### `views`

Generator scripts.

### `static`

Static files copied verbatim, like images, scripts, or stylesheets.

## Notes

Blog posts are sorted in reverse using coreutils sort. This means the user is
responsible for naming files sanely.

## Todo

- Add support for custom, non-blog pages (e.g. contact pages).
- Add support for categories and/or tags.
