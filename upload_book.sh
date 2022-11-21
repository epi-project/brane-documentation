#!/bin/bash
# UPLOAD BOOK.sh
#   by Lut99
#
# Created:
#   23 Feb 2022, 16:36:17
# Last edited:
#   21 Nov 2022, 16:05:04
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
    rsync -ar www/.htaccess "$target" || exit $?
fi
