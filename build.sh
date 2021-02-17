#!/bin/bash
#
#  Build script for time2backup Windows package
#
#  Website: https://time2backup.org
#  MIT License
#  Copyright (c) 2017-2021 Jean Prunneaux
#


# go into current directory
cd "$(dirname "$0")" || exit 1

# test if sources are there
if ! [ -d src ] ; then
	echo "ERROR: you must put your sources in the src directory!"
	exit 1
fi


#
#  Functions
#

# Print usage
print_help() {
	echo "Usage: $0 [OPTIONS]"
	echo "Options:"
	echo "   -v, --version VERSION  Specify a version"
	echo "   -h, --help             Print this help"
}


##################
#  MAIN PROGRAM  #
##################

# get options
while [ $# -gt 0 ] ; do
	case $1 in
		-v|--version)
			if [ -z "$2" ] ; then
				print_help
				exit 1
			fi
			version=$2
			shift
			;;
		-h|--help)
			print_help
			exit
			;;
		*)
			break
			;;
	esac
	shift
done

# prompt to choose version
if [ -z "$version" ] ; then
	version=$(grep 'version=' src/time2backup.sh | head -1 | cut -d= -f2)

	echo -n "Choose version: [$version] "
	read version_user
	if [ -n "$version_user" ] ; then
		version=$version_user
	fi

	echo
fi

# create build environment
mkdir -p archives
if [ $? != 0 ] ; then
	echo "ERROR while creating archives directory. Please verify your access rights."
	exit 3
fi

build_directory=archives/build

# clean and copy package files
echo "Clean and copy package..."
rm -rf "$build_directory" && cp -rp package "$build_directory"
if [ $? != 0 ] ; then
	echo "ERROR while copying package files. Please verify your access rights."
	exit 1
fi

echo "Copy time2backup sources..."
cp -rp src "$build_directory"/files/time2backup
if [ $? != 0 ] ; then
	echo "ERROR while copying sources files. Please verify your access rights."
	exit 1
fi

# go into the copied package directory
cd "$build_directory" || exit 4

echo "Set version number in install.bat..."
sed -i "s/set version=/set version=$version/" install.bat
if [ $? != 0 ] ; then
	echo "...Failed!"
	exit 3
fi

echo
echo "Building package..."

# set archive name
archive=time2backup-${version}_win64.zip

echo "ZIP package..."

zip -r "$archive" * > /dev/null
if [ $? != 0 ] ; then
	echo "...Failed!"
	exit 5
fi

# create version directory
mkdir -p ../"$version"
if [ $? != 0 ] ; then
	echo "ERROR: Cannot create version directory!"
	exit 1
fi

# move zip above
mv "$archive" ../"$version"
if [ $? != 0 ] ; then
	echo "ERROR: Failed to move the archive!"
	exit 1
fi

# going up
cd .. || exit 4

echo "Clean files..."
rm -rf build

echo
echo "Package is ready!"
