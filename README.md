# Scripts for use with Plex / rclone

### Prerequisites

What things you need to install the software and how to install them

```
* Fully setup plex / rclone install
* Mount points for your local data / acd-crypt 
```

### Installing / Deployment

To install you need to pull this git repo

```
git pull https://github.com/jaketame/scripts.git
Amend plexconf.conf with your relevant paths
```

Once you have the scripts locally update crontab.

Required

```
@reboot /opt/plexacd/mount-crypt.sh
```

You have two options for uploading to acd

Option 1 - Upload files to cloud based on local filesystem free space

```
*/5 * * * * /opt/plexacd/disk-check.sh
```

Option 2 - Upload files every 6 hours

```
0 */6 * * * /opt/plexacd/upload-cloud.sh
```

Optional - Run mount-check every 5 minutes to verify mount is still online Not needed as rclone mount is fairly stable

```
*/5 * * * * /opt/plexacd/check-mount.sh
```


