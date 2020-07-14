#!/bin/bash
#set -n

git_exe(){
if [  $2 == 0 ]
then
  echo "$1 Installed ; Verify version "
fi
}

git_copy(){
if [ -f "/etc/kubernetes/gce.conf" ]
then
 `sudo truncate -s 0 /etc/kubernetes/gce.conf`
else
 cmd1=`sudo touch  /etc/kubernetes/gce.conf`
fi
 sudo chmod 777 /etc/kubernetes/gce.conf
 sudo echo "[Global]" >> /etc/kubernetes/gce.conf
 sudo echo "project-id = $1" >> /etc/kubernetes/gce.conf
 sudo echo "node-tags = kubernetes" >> /etc/kubernetes/gce.conf
 sudo echo "key = $2" >> /etc/kubernetes/gce.conf  
}

git_kubectl(){
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

git_flannel(){
cd $HOME/adm/kube_flannel
kubectl apply -f ./kube-flannel.yml
}

git_calico(){
cd $HOME/adm/kube_calico
kubectl apply -f ./kube-calico.yaml
}

git_dash(){
cd $HOME/adm/kube_dash
kubectl apply -f ./recommended.yaml
kubectl apply -f ./dashboard-adminuser.yaml
}

git1=`git init`
echo $?
gitpy=`mkdir pyup;cd pyup;git init;git pull https://github.com/rangapv/pyUpgrade.git;./py.sh`
git_exe Python $?
gitdok=`mkdir doker;cd doker;git init;git pull https://github.com/rangapv/doker.git;./dock.sh`
git_exe Docker $?
gitadm=`mkdir adm;cd adm;git init;git pull https://github.com/rangapv/k8s.git;cd kube_node;./node_install.sh`
git_exe Kube_Node $?

git_copy $1 $2


{

echo "Copy the master config to node/.kube"
echo "make changes to kubelet file in /etc/systemd/system/kubelet.service.d/10-kubeadm.conf "
echo "execute the kubeadm join that you got from the Master node"

} 
