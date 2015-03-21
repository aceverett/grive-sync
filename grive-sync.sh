#!/bin/sh
###############################################################################
# grive-sync
# This script is based on Josh Beard's original grive-sync shell script
# (https://github.com/joshbeard/grive-sync).
# 
# The original shell script grep'ed the log file, sending a list of changes
# to notify-osd. Since this is intended for a headless machine, the notify-osd
# feature isn't needed.
#
# Grive is created by Nestal Wan at https://github.com/Grive/grive/
# This script is hacked up by Josh Beard at http://signalboxes.net
# Josh Beard's original script mangled by Adam Everett
#
# I don't know how robust this script is and haven't done much testing
# Feel free to do whatever you want with it.
# 
###############################################################################

# Change this to 1 once you've changed the variables
I_HAVE_EDITED=0

# This needs to best set for notify-send if calling from cron
# DISPLAY=:0.0
# Path to an icon for notify-osd
#NOTIFY_ICON="/home/josh/.icons/google-drive.png"
#NOTIFY_BIN=$(which notify-send)
#NOTIFY_ICON="/home/myself/.icons/grive.png"

# Global variables
GRIVE_DIR="/media/xxxxxx/google drive"
GRIVE_BIN=$(command -v grive)

###############################################################################
# You don't need to edit below here unless you really want to
###############################################################################
[ "$I_HAVE_EDITED" -eq "0" ] && printf "You need to configure $0\n" && exit 1

ps_bin=$(which ps)
rm_bin=$(which rm)
grep_bin=$(which grep)
sed_bin=$(which sed)
mktemp_bin=$(which mktemp)

# Create a temporary log file
TMPLOG=$($mktemp_bin /tmp/grive-XXXX)

# These are the strings we'll look for in the grive log to figure out what
# files were changed.
REMOVEL_MSG="deleted in local. deleting remote"
REMOVER_MSG="deleted in remote. deleting local"
UPLOAD_MSG="doesn't exist in server, uploading"
DOWNLOAD_MSG="created in remote. creating local"

# Test if we can locate grive
if ! type grive >/dev/null 2>&1; then
	printf "Can't locate grive\n"
	exit 1
fi

# GRIVE_DIR doesn't exist
[ ! -d "${GRIVE_DIR}" ] && printf "${GRIVE_DIR} does not exist.\n" && exit 1

# Function to extract filename from log file
get_filename() {
	filename=$($grep_bin "$1" "${TMPLOG}"|$sed_bin 's/.*"\(.*\)"[^"]*$/\1/')
	printf "$(basename "$filename")"
}

# Check if it's already running
if ! $ps_bin aux|$grep_bin -q -e '[g]rive '; then

	# Run grive and output to a temporary log
	cd "${GRIVE_DIR}"
	${GRIVE_BIN} -l "${TMPLOG}"

	# Get the count of operations
	#_ldeletions=$($grep_bin -c "${REMOVEL_MSG}" "${TMPLOG}")
	#_rdeletions=$($grep_bin -c "${REMOVER_MSG}" "${TMPLOG}")
	#_uploads=$($grep_bin -c "${UPLOAD_MSG}" "${TMPLOG}")
	#_downloads=$($grep_bin -c "${DOWNLOAD_MSG}" "${TMPLOG}")

	# Setup the notify-osd message
	#notify=""
	#if [ $_ldeletions -gt 0 ]; then
	#	# If it's only one file, show the filename
	#	if [ $_ldeletions -eq 1 ]; then
	#		_filename=$(get_filename "${REMOVEL_MSG}")
	#		notify="$_filename removed from local"
	#	else
	#		notify="${_ldeletions} removed from local"
	#	fi
	#fi

	#if [ $_rdeletions -gt 0 ]; then
	#	[ ! -z "$notify" ] && notify="${notify}\n"
	#	if [ $_rdeletions -eq 1 ]; then
	#		_filename=$(get_filename "${REMOVER_MSG}")
	#		notify="$_filename removed from remote"
	#	else
	#		notify="${_rdeletions} removed from remote"
	#	fi
	#fi

	#if [ $_uploads -gt 0 ]; then
	#	[ ! -z "$notify" ] && notify="${notify}\n"
	#	if [ $_uploads -eq 1 ]; then
	#		_filename=$(get_filename "${UPLOAD_MSG}")
	#		notify="${notify}$_filename uploaded"
	#	else
	#		notify="${notify}${_uploads} uploaded"
	#	fi
	#fi

	#if [ $_downloads -gt 0 ]; then
	#	[ ! -z "$notify" ] && notify="${notify}\n"
	#	if [ $_downloads -eq 1 ]; then
	#		_filename=$(get_filename "${DOWNLOAD_MSG}")
	#		notify="${notify}$_filename downloaded"
	#	else
	#		notify="${notify}${_downloads} downloaded"
	#	fi
	#fi

	# Display the notify-osd message
	#if [ ! -z "$notify" ]; then
	#	${NOTIFY_BIN} -i "${NOTIFY_ICON}" "Grive" "$notify"
	#fi

	# Remove the grive ouput log	
	$rm_bin -f "${TMPLOG}"
fi
