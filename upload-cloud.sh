#!/bin/bash
# Script to uplaod latest tv shows
# Import common functions
source /opt/plexacd/plexacd.func
# Import functions
source /opt/plexacd/plexacd.conf

uploadtv() {
  rclone move --exclude partial~ --log-file=$PLEXACD/logs/rclone-tv.log --transfers 10 --acd-upload-wait-per-gb=10s $LOCALTV $REMOTETV
}

uploadmv() {
  rclone move --exclude partial~ --log-file=$PLEXACD/logs/rclone-movie.log --transfers 10 --acd-upload-wait-per-gb=10s $LOCALMV $REMOTEMV
}

main() {
    lock $PROGNAME \
        || eexit "Only one instance of $PROGNAME can run at one time."

    logsetup
    # Pause nzbget for fastest upload
    pause_nzbget
    # Upload TV Shows
    uploadtv
		# Upload Movies
    uploadmv
    # Resume nzbget
    resume_nzbget

    rm $lock_file
}

# Execute functions inside main, will providing locking to avoid multiple scripts running at same time
main
