#!/bin/bash
#
#  Build script for time2backup Windows package
#
#  Website: https://time2backup.org
#  MIT License
#  Copyright (c) 2017-2019 Jean Prunneaux
#


# go into current directory
cd "$(dirname "$0")"
if [ $? != 0 ] ; then
	echo "ERROR: cannot go into current directory"
	exit 1
fi

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
	echo "   -f, --force            Force mode"
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
		-f|--force)
			# TODO: force mode
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
if ! cd "$build_directory" ; then
	echo "ERROR: Failed to go into the build directory!"
	exit 4
fi

echo "Set version number in install.bat..."
sed -i "s/set version=/set version=$version/" install.bat
if [ $? != 0 ] ; then
	echo "...Failed!"
	exit 3
fi

# build archive for each arch
for arch in 32 64 ; do

	echo
	echo "Building ${arch}bits package..."

	# set cygwin installer
	cygwin='setup-x86'
	[ $arch == 64 ] && cygwin+='_64'
	cygwin+='.exe'

	echo
	echo "Copy cygwin installer..."
	cp -p ../../cygwin/$cygwin files/cygwin-setup.exe
	if [ $? != 0 ] ; then
		echo "...Failed!"
		exit 1
	fi

	# set archive name
	archive=time2backup-${version}_win${arch}.zip

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
done

# going up
if ! cd .. ; then
	echo "ERROR: Failed to go into the archive directory!"
	exit 4
fi

echo "Clean files..."
rm -rf build

echo
echo "Package is ready!"
