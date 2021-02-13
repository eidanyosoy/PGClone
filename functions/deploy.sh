#!/bin/bash
#
# Title:      basic parts 
# Author:     MrDoob
# GNU:        General Public License v3.0
################################################################################
deploypgblitz() {
  deployblitzstartcheck 
  # At Bottom - Ensure Keys Are Made
  # RCLONE BUILD
  echo "#------------------------------------------" >/opt/appdata/plexguide/rclone.conf
  echo "# rClone.config created over rclone " >>/opt/appdata/plexguide/rclone.conf
  echo "#------------------------------------------" >>/opt/appdata/plexguide/rclone.conf
  cat /opt/appdata/plexguide/.gdrive >>/opt/appdata/plexguide/rclone.conf
  if [[ $(cat "/opt/appdata/plexguide/.gcrypt") != "NOT-SET" ]]; then
    echo ""
    cat /opt/appdata/plexguide/.gcrypt >>/opt/appdata/plexguide/rclone.conf
  fi
  cat /opt/appdata/plexguide/.tdrive >>/opt/appdata/plexguide/rclone.conf
  if [[ $(cat "/opt/appdata/plexguide/.tcrypt") != "NOT-SET" ]]; then
    echo ""
    cat /opt/appdata/plexguide/.tcrypt >>/opt/appdata/plexguide/rclone.conf
  fi
  cat /opt/appdata/plexguide/.keys >>/opt/appdata/plexguide/rclone.conf
  deploydrives
}
deploypgmove() {
  # RCLONE BUILD
  echo "#------------------------------------------" >/opt/appdata/plexguide/rclone.conf
  echo "# rClone.config created over rclone " >>/opt/appdata/plexguide/rclone.conf
  echo "#------------------------------------------" >>/opt/appdata/plexguide/rclone.conf

  cat /opt/appdata/plexguide/.gdrive >/opt/appdata/plexguide/rclone.conf

  if [[ $(cat "/opt/appdata/plexguide/.gcrypt") != "NOT-SET" ]]; then
    echo ""
    cat /opt/appdata/plexguide/.gcrypt >>/opt/appdata/plexguide/rclone.conf
  fi
  deploydrives
}

dockervolumen() {
dovolcheck=$(docker volume ls | grep unionfs)
if [[ "$dovolcheck" == "unionfs" ]]; then
tee <<-EOF
     🚀      Docker Volume exist | skipping
EOF
else
tee <<-EOF
     🚀      Creating Docker Volume 
     🚀      this can take a long time  
EOF
curl -fsSL https://raw.githubusercontent.com/MatchbookLab/local-persist/master/scripts/install.sh | sudo bash
docker volume create -d local-persist -o mountpoint=/mnt --name=unionfs 
tee <<-EOF
     🚀      Creating Docker created
EOF
fi
}
updatesystem() {
tee <<-EOF
     🚀      System will be updated now 
	         this can take a long time  
EOF
  # update system to new packages
  ansible-playbook /opt/pgclone/ymls/update.yml 2>&1 >>/dev/null
tee <<-EOF
     🚀      System is up2date now
EOF
}
stopmunts() {
mount=$(docker ps --format '{{.Names}}' | grep "mount**")
if [[ "$mount" == "mount**" ]]; then 
   docker stop mount** >> /dev/null
   fusermount -uzq /mnt/unionfs >> /dev/null
fi
}
removeoldui() {
UI=$(docker ps --format '{{.Names}}' | grep "pgui")
if [[ "$UI" == "pgui" ]]; then 
   docker stop pgui >> /dev/null
   docker rm pgui >> /dev/null
   rm -rf /opt/appdata/pgui/ >> /dev/null
fi
}
update_pip() {
pip3 list --outdated --format=freeze | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U
}
vnstat() {
apt-get install ethtool vnstat vnstati -yqq 2>&1 >>/dev/null
export DEBIAN_FRONTEND=noninteractive
network=$(ifconfig | grep -E 'eno1|enp|ens5' | awk '{print $1}' | sed -e 's/://g')
sed -i 's/eth0/'$network'/g' /etc/vnstat.conf
sed -i '/UseLogging/s/2/0/' /etc/vnstat.conf
sed -i '/RateUnit/s/1/0/' /etc/vnstat.conf
sed -i '/UnitMode/s/0/1/' /etc/vnstat.conf
sed -i 's/Locale "-"/Locale "LC_ALL=en_US.UTF-8"/g' /etc/vnstat.conf
/etc/init.d/vnstat restart 2>&1 >>/dev/null
}

deploydockermount() {
tee <<-EOF
     🚀      Deploy of Docker Mounts
EOF
   ansible-playbook /opt/pgclone/ymls/remove-2.yml
   ansible-playbook /opt/pgclone/ymls/mounts.yml
   clonestart
}
norcloneconf() {
rcc=/opt/appdata/plexguide/rclone.conf
if [[ ! -f "$rcc" ]]; then
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ⛔ Fail Notice for deploy of Docker 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     Sorry we cant Deploy the Docker.
     We cant find any rclone.conf file 
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ⛔ Fail Notice for deploy of Docker
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -rp '↘️  Acknowledge Info | Press [ENTER] ' typed </dev/tty
clonestart
else
  echo ""
fi
}
deploydockeruploader() {
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     🚀  Deploy of Docker Uploader
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
   cleanlogs
   ansible-playbook /opt/pgclone/ymls/uploader.yml
  read -rp '↘️  Acknowledge Info | Press [ENTER] ' typed </dev/tty
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
     💪     DEPLOYED sucessfully !
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    read -p '↘️  Acknowledge Info | Press [ENTER] ' typed2 </dev/tty
    clonestart
}
### Docker Uploader Deploy end ##
deploydrives() {
  fail=0
tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      🚀 Conducting RClone Mount Checks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    vnstat
    #norcloneconf
    removeoldui
    cleanlogs
    stopmunts
    testdrive
    multihdreadonly
    updatesystem
    stopmunts
    dockervolumen
    deploydockeruploader	
    deploydockermount
    deploySuccessUploader
}

########################################################################################
doneokay() {
 echo
  read -p 'Confirm Info | PRESS [ENTER] ' typed </dev/tty
}
testdrive() {
IFS=$'\n'
filter="$1"
config=/opt/appdata/plexguide/rclone.conf
mapfile -t mounttest < <(eval rclone listremotes --config=${config} | grep "$filter" | sed '/pgunion/d')
for i in ${mounttest[@]}; do
    rclone lsd --config=${config} $i | head -n1
    echo "$i = Passed"
done
}
################################################################################
deployblitzstartcheck() {
  pgclonevars
  if [[ "$displaykey" == "0" ]]; then
    tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   ⛔ Fail Notice
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  💬  There are [0] keys generated for Blitz! Create those first!
  NOTE: 

  Without any keys, Blitz cannot upload any data without the use
  of service accounts

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    read -p '↘️  Acknowledge Info | Press [ENTER] ' typed </dev/tty
    clonestart
  fi
}
################################################################################
cleanlogs() {
  echo "Prune service logs..."
  journalctl --flush
  journalctl --rotate
  journalctl --vacuum-time=1s
  truncate -s 0 /var/plexguide/logs/*.log
  rm -rf /var/plexguide/logs/ >>/dev/null 2>&1
  find /var/logs -name "*.gz" -delete >>/dev/null 2>&1
}
prunedocker() {
  echo "Prune docker images and volumes..."
  docker system prune --volumes -f
}
################################################################################
deploySuccessUploader() {
  tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💪 DEPLOYED: $finaldeployoutput
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  rClone has been deployed sucessfully!
  All services are active and running normally.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -rp '↘️  Acknowledge Info | Press [ENTER] ' typed </dev/tty
}
deploymountSuccess() {
  tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
💪 DEPLOYED: $finaldeployoutput
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  rClone has been deployed sucessfully!
  All services are active and running normally.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
  read -rp '↘️  Acknowledge Info | Press [ENTER] ' typed </dev/tty
}
