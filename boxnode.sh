#!/bin/bash
#./boxnode.sh project_id APIkey

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

git_kubelet(){
FILENAME="/etc/systemd/system/kubelet.service.d/10-kubeadm.conf"
sudo chmod 644 /etc/systemd/system/kubelet.service.d/10-kubeadm.conf 
while IFS= read -r line
do
if [[ "$line" == *"Environment=\"KUBELET_KUBECONFIG_ARGS=--boot"* ]]
then
declare -i nu=${#line}
declare -i su1=$(( nu - 1 ))
new1=$(echo "$line" | cut -c 1-$su1)
new2="--cloud-provider=external --cloud-config=/etc/kubernetes/gce.conf\""
str1="${new1} ${new2}"
str3=${str1//\//\\\/}
str4=${str3//\"/\\\"}
sudo sed -i "/Environment=\"KUBELET_KUBECONFIG_ARGS=--boots/s/.*/$str4/" /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
fi
done < "$FILENAME"
sudo chmod 640 /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
}


git_dash(){
cd $HOME/adm/kube_dash
kubectl apply -f ./recommended.yaml
kubectl apply -f ./dashboard-adminuser.yaml
}

git_clean(){
if [ -f $1 ]
then
 `sudo truncate -s 0 $1`
else
 echo "Not Much"
fi
}

git_clean /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
git_clean /etc/kubernetes/gce.conf

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
git_kubelet

echo "execute the kubeadm join that you got from the Master node"
}
