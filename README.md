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

## Perform below operations only in Master node  

git clone https://github.com/Tejas-Subramanya/kubernetes_cluster_5gempower

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
sudo kubectl create -f kubernetes_cluster_5gempower/dashboard-admin.yaml

*To sign-in to dashboard:*
In a terminal run: sudo kubectl proxy
Access dashboard from the browser: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
In the dashboard press skip to sign-in

*Assigning labels to nodes of the cluster:*
Run 'kubectl get nodes' to get the names of your cluster’s nodes. Pick out the one that you want to add a label to, and then run 'kubectl label nodes <node-name> <label-key>=<label-value>', to add a label to the node you’ve chosen. 
For example, if my node name is ‘clusternode1’ and my desired label is ‘node1=enodeb’, then I can run 'kubectl label nodes clusternode1 node1=enodeb'. Depending on this label, 'nodeSelector' parameter in your pod configuration file(YAML/JSON) needs to be updated accordingly.

*Deploying Pods:*
Pods can be deployed directly from the dashboard by selecting the required pod configuration file. In this repository you can find pod configuration files for deploying srsenb, srsepc and empower-runtime controller.


## Perform below operations only in Worker nodes as a root user  

*Run 'sudo kubeadm join $Master_IP$:6443 --token df4gi8.a6q4yp5tut2hp9e0 --discovery-token-ca-cert-hash sha256:$hash$' command that was saved before to join the cluster* 
*Replace $Master_IP$ with actual IP and $hash$ with actual hash.*
