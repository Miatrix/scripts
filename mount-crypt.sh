#!/bin/bash
# Mount ACD using rclone
# Import common functions
source /opt/plexacd/plexacd.func
# Import functions
source /opt/plexacd/plexacd.conf

# Mount Functions

unmount_mediadir() {
# Unmount the plex acd mounts
if mountpoint -q $MEDIADIR; then 
	log "Unmounting $MEDIADIR"
	$fusermount -u $MEDIADIR
	if [ $? -eq 0 ]; then
 		log "Failed to unmount $MEDIADIR... Retrying with force"
 	else
		$fusermount -uz $MEDIADIR
 		log "$MEDIADIR removed with force"
 	fi
else
	log "$MEDIADIR already unmountpoint"
fi
}
unmount_acdcrypt() {
if mountpoint -q $ACDCRYPT; then
  log "Unmounting $ACDCRYPT"
  $fusermount -u $ACDCRYPT
  if [ $? -eq 0 ]; then
    log "Failed to unmount $ACDCRYPT... Retrying with force"
  else
    $fusermount -uz $ACDCRYPT
    log "$ACDCRYPT removed with force"
  fi
else
  log "$ACDCRYPT already unmountpoint"
fi
}

mount_acdcrypt() {
# Mount the acd via rclone to encrypted path, then run encfs to decrypt
log "Mounting $ACDCRYPT"
$rclone mount \
    --read-only \
    --allow-non-empty \
    --allow-other \
    --quiet \
    $REMOTENAME: $ACDCRYPT &
	if [ $? -eq 0 ]; then
		log "Mounted $ACDCRYPT successfully."
	else
		log "Mount of $ACDCRYPT failed"
		exit 1
	fi
	
}

mount_mediadir() {
# Mount the unionfs
$unionfs -o cow,auto_cache,allow_other,max_readahead=2000000000 -o uid=1001 -o gid=1001 $LOCALDIR=RW:$ACDCRYPT=RO $MEDIADIR
if [ $? -eq 0 ]; then
  log "Mounted $MEDIADIR successfully"
  else
  log "Failed to mount unionfs of $LOCALDIR and $ACDCRYPT. please retry"
fi

}

main() {
    lock $PROGNAME \
        || eexit "Only one instance of $PROGNAME can run at one time."
		
		logsetup
		#Unmounts
		unmount_mediadir
		unmount_acdcrypt
		#Mounts
		mount_acdcrypt
		mount_mediadir

		rm $lock_file
}

# Execute main function, will provide logging
main
