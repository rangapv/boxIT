#!/bin/bash
#set -v
t1=`curl -O -L  https://github.com/projectcalico/calicoctl/releases/download/v3.14.0/calicoctl`
t2=`chmod +x calicoctl`
t3=`sudo mv calicoctl /usr/local/bin`
t4="/etc/calico/calicoctl.cfg"
t5="$HOME"
t6="kubeconfig: \"${t5}/.kube/config\""
sudo mkdir -p /etc/calico
t7=`git pull https://gist.github.com/rangapv/50a364d81baf27b2ad8f3f75322fdc6a.git`

if [ -f "$t4" ]
then
 `sudo truncate -s 0 "$t4"`
else
 cmd1=`sudo touch "$t4"`
fi
sudo chmod 777 "$t4"
sudo echo "apiVersion: projectcalico.org/v3" >> "$t4"
sudo echo "kind: CalicoAPIConfig" >> "$t4"
sudo echo "metadata:" >> "$t4"
sudo echo "spec:" >> "$t4"
sudo echo "  datastoreType: \"kubernetes\"" >> "$t4"
sudo echo "  ${t6}" >> "$t4"
sudo chmod 644 "$t4"
