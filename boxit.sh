#!/bin/bash
#set -n
#./boxit.sh project_id APIkey netwrok(flannel/calico)

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

git_secret(){
kubectl create secret generic gce-secret --from-file=gce.conf=/etc/kubernetes/gce.conf --from-file=config=$HOME/.kube/config -n kube-system
}

git_ccm(){
cd $HOME/adm/ccm
kubectl apply -f ./ccm-rbac.yaml
kubectl apply -f ./ccm.yaml
}


git1=`git init`
echo $?
gitpy=`mkdir pyup;cd pyup;git init;git pull https://github.com/rangapv/pyUpgrade.git;./py.sh`
git_exe Python $?
gitdok=`mkdir doker;cd doker;git init;git pull https://github.com/rangapv/doker.git;./dock.sh`
git_exe Docker $?
gitadm=`mkdir adm;cd adm;git init;git pull https://github.com/rangapv/k8s.git;cd kube_adm;./adm_install.sh`
git_exe Kube_Master $?

git_copy $1 $2

if [ $3 == 'calico' ]
then
gitconf=`git pull https://gist.github.com/88ea8468046bfe19b53a5ff9d0c025f0.git`
sudo kubeadm init --config=./adm-calico-conf.yaml
elif [ $3 == 'flannel' ]
then
gitconf=`git pull https://gist.github.com/fc63aa5af25f2769b87d7db24cae91cd.git`
sudo kubeadm init --config=./adm-conf.yaml
else
echo "No Network Selected, Re-execute"
fi

{

git_kubectl

if [ $3 == 'flannel' ]
then
git_flannel
elif [ $3 == 'calico' ]
then
git_calico
else
echo "No Network selected"
fi

git_dash

git_secret

git_ccm

} 
