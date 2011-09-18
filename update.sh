#!/usr/bin/env bash

# This script just updates any files/folders that are present in the repo

# which files/directories to ignore
ignored_files=(.git .gitignore README.md update.sh . ..)

in_array() {
	local hay needle=$1
	shift
	for hay; do
		[[ $hay == $needle ]] && return 0
	done
	return 1
}

update_directory() 
{
	for f in `ls -a "$1"`
	do
		in_array "$f" "${ignored_files[@]}"
		if [ $? -eq 0 ]; then
			echo -n ""
		elif [ -h "$1/$f" ]; then
			echo ">> skipping symbolic link, $1/$f"
		elif [ -d "$1/$f" ]; then
			update_directory "$1/$f"
		else
			if [ "$1" == "." ]; then
				cp -v "$HOME/.$f" "$1/$f"
			else
				cp -v "$HOME/$1/$f" "$1/$f"
			fi
		fi
	done
}

update_directory "."
