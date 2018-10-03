# Install Docker and Kubernetes in Master and all Worker nodes of the cluster.

sudo apt-get update && apt-get install -y apt-transport-https  
sudo apt install docker.io  

swapoff -a  

sudo systemctl start docker  
sudo systemctl enable docker  

sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add  

*Next add a repository by creating a file /etc/apt/sources.list.d/kubernetes.list and enter the following content:*  
deb http://apt.kubernetes.io/ kubernetes-xenial main  
*Save and close that file.*   

sudo apt-get update  
sudo apt-get install -y kubelet kubeadm kubectl kubernetes-cni  


# Creating a cluster  

git clone https://github.com/Tejas-Subramanya/kubernetes_cluster_5gempower  

## Perform below operations only in Master node  

sudo kubeadm init --pod-network-cidr=10.244.0.0/16  

**Save the 'kubeadm join' command that is displayed when you run the above command like this one:**  
"kubeadm join $Master_IP$:6443 --token df4gi8.a6q4yp5tut2hp9e0 --discovery-token-ca-cert-hash sha256:$hash$"  
**This will be later used by other worker nodes to join the cluster.**    

*To start using your cluster enter below commands in regular user mode:*  
mkdir -p $HOME/.kube  
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config  
sudo chown $(id -u):$(id -g) $HOME/.kube/config  

*Deploy flannel overlay network:*  
sudo kubectl apply -f https://github.com/coreos/flannel/raw/master/Documentation/kube-flannel.yml  

*To deploy Kubernetes dashboard:*  
sudo kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml  

*To sign-in to dashboard:*  
In a terminal run: sudo kubectl proxy  
Access dashboard from the browser: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/  

sudo kubectl create -f kubernetes_cluster_5gempower/dashboard-admin.yaml  
In the dashboard press skip to sign-in  

## Perform below operations only in Worker nodes as a root user  

*Run the 'kubeadm join' command that was saved before to join the cluster like below:*  
sudo kubeadm join $Master_IP$:6443 --token df4gi8.a6q4yp5tut2hp9e0 --discovery-token-ca-cert-hash sha256:$hash$  
*Replace $Master_IP$ with actual IP and $hash$ with actual hash*
