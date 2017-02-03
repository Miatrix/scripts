#!/bin/bash
# Mount ACD using rclone
# Import common functions
source /opt/plexacd/plexacd.func
# Import config
source /opt/plexacd/plexacd.conf

check_mount() {
# Check acd rclone mount, remount if offline, check decrypt path
if mountpoint -q $ACDCRYPT; then
  log "Mount $ACDCRYPT is already mounted, exiting."
  exit 0
  else
		log "Mount $ACDCRYPT is offline, remounting"
		mount_acdcrypt
fi
}

mount_acdcrypt() {
# Mount rclone acd mount
$rclone mount \
    --read-only \
    --allow-non-empty \
    --allow-other
    --quiet \
    $REMOTENAME: $ACDCRYPT &
  if [ $? -eq 0 ]; then
    log "Mounted $ACDCRYPT successfully."
  else
    log "Mount of $ACDCRYPT failed"
    exit 1
  fi
}

main() {
    lock $PROGNAME \
        || eexit "Only one instance of $PROGNAME can run at one time."
		
		logsetup
		check_mount
		rm $lock_file
}

# Execute main function, will provide logging
main
