#!/bin/bash
# UPLOAD BOOK.sh
#   by Lut99
#
# Created:
#   23 Feb 2022, 16:36:17
# Last edited:
#   06 Sep 2023, 15:23:31
# Auto updated?
#   Yes
#
# Description:
#   Simple script to upload the (rendered) mdbook to the remote server
#

# Read the CLI
if [ $# != 2 ]; then
    echo "Usage: $0 <book_path> <target>"
    exit 1
fi
book=$1
target=$2

# Render the book
cd "$book"
mdbook build || exit $?

# Send it to the DigitalOcean server to be served
echo "Uploading to '$target'..."
rsync -ar --delete book/* "$target" || exit $?
# Also upload the .htaccess, if it has one
if [[ -f "www/.htaccess" ]]; then
    echo "Uploading .htaccess to '$target'..."
    rsync -ar www/.htaccess "$target/.htaccess" || exit $?
fi
# Also upload the custom highlight.js, if it has one
if [[ -d "www/highlight.js" ]]; then
    # Copy highlight.js itself

    # Append all files to the end of the highlight.js file
    echo "Constructing custom highlight.js..."
    cp www/highlight.js/highlight.js www/highlight.js.custom
    for f in www/highlight.js/*.js; do
        # Skip the file itself
        if [[ "$f" == "www/highlight.js/highlight.js" ]]; then continue; fi

        # Append it
        cat "$f" >> www/highlight.js.custom
    done

    echo "Uploading highlight.js to '$target'..."
    rsync -ar www/highlight.js.custom "$target/highlight.js" || exit $?
fi
