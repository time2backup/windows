#!/bin/bash

#
#  Build script for time2backup Windows package
#
#  Website: https://time2backup.github.io
#  MIT License
#  Copyright (c) 2017 Jean Prunneaux
#


# get current_directory
current_directory=$(dirname "$0")

# test if time2backup is there
if ! [ -d "$current_directory/time2backup" ] ; then
	echo "ERROR: you must put time2backup sources in the time2backup directory!"
	exit 1
fi


###############
#  FUNCTIONS  #
###############

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
			;;
		*)
			break
			;;
	esac
	shift
done

# prompt to choose version
if [ -z "$version" ] ; then
	version=$(grep "^version=" "$current_directory/time2backup/time2backup.sh" | head -1 | cut -d= -f2)

	echo -n "Choose version: [$version] "
	read version_user
	if [ -n "$version_user" ] ; then
		version=$version_user
	fi

	echo
fi

# create build environment
mkdir -p "$current_directory/build"
if [ $? != 0 ] ; then
	echo "ERROR while creating build directory. Please verify your access rights."
	exit 3
fi

package="$current_directory/build/package"

# clean and copy package files
echo "Clean and copy package..."
rm -rf "$package" && cp -rp "$current_directory/package" "$current_directory/build/"
if [ $? != 0 ] ; then
	echo "ERROR while copying package files. Please verify your access rights."
	exit 1
fi

echo "Copy time2backup sources..."
cp -rp "$current_directory/time2backup" "$package/files/"
if [ $? != 0 ] ; then
	echo "ERROR while copying sources files. Please verify your access rights."
	exit 1
fi

# go into the copied package directory
cd "$package"
if [ $? != 0 ] ; then
	echo "ERROR: Failed to go into the $package directory!"
	exit 4
fi

echo "Modify version number in install.bat..."
sed -i "s/set version=/set version=$version/" install.bat
if [ $? != 0 ] ; then
	echo "...Failed!"
	exit 3
fi

# build archive for each arch
for arch in 32 64 ; do

	echo
	echo "Building $arch bits package..."

	# set cygwin installer
	cygwin="setup-x86"
	if [ $arch == 64 ] ; then
		cygwin+="_64"
	fi
	cygwin+=".exe"

	echo
	echo "Copy cygwin installer..."
	cp -p ../../cygwin/$cygwin files/cygwin-setup.exe
	if [ $? != 0 ] ; then
		echo "...Failed!"
		exit 1
	fi

	# set archive name
	archive="time2backup-${version}_win$arch.zip"

	echo "Archive package..."

	zip -r "$archive" * > /dev/null
	if [ $? != 0 ] ; then
		echo "...Failed!"
		exit 5
	fi

	# create archive directory
	mkdir -p ../"$version"
	if [ $? != 0 ] ; then
		echo "ERROR: Cannot create archive directory!"
		exit 1
	fi

	# move archive above
	mv "$archive" ../"$version"
	if [ $? != 0 ] ; then
		echo "ERROR: Failed to move the archive!"
		exit 1
	fi
done

# going up
cd ..
if [ $? != 0 ] ; then
	echo "ERROR: Failed to go into the archive directory!"
	exit 4
fi

echo "Clean files..."
rm -rf package

echo
echo "Package is ready!"
