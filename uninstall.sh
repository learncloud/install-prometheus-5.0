#!/bin/bash


  
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MANIFEST_HOME=$SCRIPTDIR/yaml/manifests
SETUP_HOME=$SCRIPTDIR/yaml/setup
source $SCRIPTDIR/version.conf

if ! command -v yq 2>/dev/null ; then
  sudo wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/bin/yq &&\
  sudo chmod +x /usr/bin/yq
fi

if ! command -v sshpass 2>/dev/null ; then
  sudo yum install https://download-ib01.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/s/sshpass-1.06-9.el8.x86_64.rpm
  sudo chmod +x /usr/bin/sshpass
  # yum install sshpass
fi

sudo cp /etc/kubernetes/manifests/kube-scheduler.yaml .
sudo yq eval 'del(.metadata.labels.k8s-app)' -i kube-scheduler.yaml
sudo yq e '.spec.containers[0].command += "--port=0"' -i ./kube-scheduler.yaml
sudo mv -f ./kube-scheduler.yaml /etc/kubernetes/manifests/kube-scheduler.yaml

sudo cp /etc/kubernetes/manifests/kube-controller-manager.yaml .
sudo yq eval 'del(.metadata.labels.k8s-app)' -i kube-controller-manager.yaml
sudo yq e '.spec.containers[0].command += "--port=0"' -i ./kube-controller-manager.yaml
sudo mv -f ./kube-controller-manager.yaml /etc/kubernetes/manifests/kube-controller-manager.yaml


sudo cp /etc/kubernetes/manifests/etcd.yaml .
sudo yq eval 'del(.metadata.labels.k8s-app)' -i etcd.yaml
sudo yq eval '(.spec.containers[0].command[] | select(. == "--listen-metrics-urls*")) = "--listen-metrics-urls=http://127.0.0.1:2381"' -i etcd.yaml
sudo mv -f ./etcd.yaml /etc/kubernetes/manifests/etcd.yaml

for master in  "${SUB_MASTER_IP[@]}"
do
  
  if [ $master == $MAIN_MASTER_IP ]; then
    continue
  fi

  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" scp /usr/bin/yq ${MASTER_NODE_ROOT_USER[i]}@"$master":/usr/bin/yq
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" sudo cp /etc/kubernetes/manifests/etcd.yaml .
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" 'sudo yq e '"'"'del(.metadata.labels.k8s-app)'"'"' -i etcd.yaml'
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" 'sudo yq eval '"'"'(.spec.containers[0].command[] | select(. == "--listen-metrics-urls*")) = "--listen-metrics-urls=http://127.0.0.1:2381"'"'"' -i etcd.yaml'
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" sudo mv -f ./etcd.yaml /etc/kubernetes/manifests/etcd.yaml
  
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" sudo cp /etc/kubernetes/manifests/kube-scheduler.yaml .
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" 'sudo yq e '"'"'del(.metadata.labels.k8s-app)'"'"' -i kube-scheduler.yaml'
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" 'sudo yq eval '"'"'.spec.containers[0].command += "--port=0"'"'"' -i kube-scheduler.yaml'
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" sudo mv -f ./kube-scheduler.yaml /etc/kubernetes/manifests/kube-scheduler.yaml


  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" sudo cp /etc/kubernetes/manifests/kube-controller-manager.yaml .
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" 'sudo yq e '"'"'del(.metadata.labels.k8s-app)'"'"' -i kube-controller-manager.yaml'
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" 'sudo yq eval '"'"'.spec.containers[0].command += "--port=0"'"'"' -i kube-controller-manager.yaml'
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" sudo mv -f ./kube-controller-manager.yaml /etc/kubernetes/manifests/kube-controller-manager.yaml

  i=$((i+1))
done

kubectl delete -f $MANIFEST_HOME
sleep 5
kubectl delete -f $SETUP_HOME
