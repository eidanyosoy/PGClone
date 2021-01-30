#!/bin/bash
function sudocheck () {
  if [[ $EUID -ne 0 ]]; then
    tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔️  You Must Execute as a SUDO USER (with sudo) or as ROOT!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    exit 0
  fi
}

function updatesystem() {
    tee <<-EOF
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⛔️  This can take a while
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
    sleep 5
	apt-get update -yq && apt-get upgrade -yq
	pip uninstall ansible
	pip install ansible-base
	pip install ansible
	python3 -m pip install ansible
	pip install --ignore-installed --upgrade ansible
	clone
}


function clone() {
    sudo rm -rf /opt/pgclone
    curl -fsSL https://raw.githubusercontent.com/MatchbookLab/local-persist/master/scripts/install.sh | sudo bash
    sudo docker volume create -d local-persist -o mountpoint=/mnt --name=unionfs 
    sudo git clone --quiet https://github.com/doob187/PGClone.git /opt/pgclone
    rm -rf /opt/plexguide/menu/pgclone/pgclone.sh 
    mv /opt/pgclone/newpgclone.sh /opt/plexguide/menu/pgcloner/pgclone.sh
    sudo chown -cR 1000:1000 /opt/pgclone/ 1>/dev/null 2>&1
    sudo chmod -cR 755 /opt/pgclone >> /dev/null 1>/dev/null 2>&1	
    sudo bash /opt/plexguide/menu/pgcloner/pgclone.sh
}
sudocheck
updatesystem
