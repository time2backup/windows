#!/bin/bash

#
#
#

current_directory=$(dirname "$0")


###############
#  FUNCTIONS  #
###############

# print usage
usage() {
	echo "Usage: $(basename "$0") [OPTIONS]"
	echo
	echo "Options:"
	echo "   -v VERSION  tag a version (default to branch name)"
	echo "   -h          print this help"
}


##################
#  MAIN PROGRAM  #
##################

# test if time2backup is there
if ! [ -d "$current_directory/time2backup" ] ; then
	echo "ERROR: you must put time2backup sources in the time2backup directory!"
	exit 1
fi

# get time2backup version
version=$(grep "^version=" "$current_directory/time2backup/time2backup.sh" | head -1 | cut -d= -f2)
if [ -z "$version" ] ; then
	echo "ERROR: Cannot get time2backup version!"
	exit 1
fi

# create build environment
mkdir -p "$current_directory/build"
if [ $? != 0 ] ; then
	echo "ERROR while creating build directory. Please verify your access rights."
	exit 1
fi

package="$current_directory/build/package"

# clear and copy package files
echo "Copy package..."
rm -rf "$package" && cp -rp "$current_directory/package" "$current_directory/build/"
if [ $? != 0 ] ; then
	echo "ERROR while copying package files. Please verify your access rights."
	exit 1
fi

echo "Copy time2backup sources..."
cp -rp "$current_directory/time2backup" "$current_directory/build/package/files/"
if [ $? != 0 ] ; then
	echo "ERROR while copying package files. Please verify your access rights."
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

echo "Modify version number in default.conf..."
sed -i "s/time2backup default configuration file v.*/time2backup default configuration file v$version/" files/default.conf
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
		echo "ERROR: Failed to go move the archive above!"
		exit 1
	fi
done

# going up
cd ../"$version"
if [ $? != 0 ] ; then
	echo "ERROR: Failed to go into the $package directory!"
	exit 4
fi

echo
echo "Generating checksums..."
sha256sum time2backup-${version}_win*.zip > sha256sum.txt
if [ $? != 0 ] ; then
	echo "...Failed!"
	exit 6
fi

echo
echo "Clean files..."
rm -rf ../package

echo
echo "Ready to deploy!"
