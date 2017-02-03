#!/bin/bash
# It will send an email to $mailto, if the (free available) percentage of space is >= 85%
# Import common functions
source /opt/plexacd/plexacd.func
# Import global variables
source /opt/plexacd/plexacd.conf

# Change these values to your relevant paths
THRESHOLD=85
UCLOUD=<path-to-upload-cloud.sh>
MAILTO=<email here>
# This takes the path from conf file
PATHS=$LOCALDIR

# Shouldn't need to change these values
AWK=/bin/awk
DU=`/usr/bin/du -ks`
GREP=/bin/grep
SED=/bin/sed
CAT=/bin/cat
MAILFILE=/tmp/mailviews$$
MAILER=/bin/mail

diskCheck() {
for path in $PATHS
do
## Validate the Percentage of Disk space ##
DISK_AVAIL=`/bin/df -k / | grep -v Filesystem |awk '{print $5}' |sed 's/%//g'`
if [ $DISK_AVAIL -ge $THRESHOLD ]
then
  log "Disk space is low $DISK_AVAIL % on $PATHS \n\n" > $MAILFILE
  log "Running upload-cloud to reduce disk space \n\n" >> $MAILFILE
  $CAT $MAILFILE | $MAILER -s "WARNING: Disk space on on $PATHS" $MAILTO
	# Run upload cloud script
  $UCLOUD
else
   log "Disk is currently $DISK_AVAIL % on $PATHS"
fi
done

}

main() {
    lock $PROGNAME \
        || eexit "Only one instance of $PROGNAME can run at one time."

    logsetup
		# Execute disk check
		diskCheck

    rm $lock_file
}

# Execute functions inside main, will providing locking to avoid multiple scripts running at same time
main
