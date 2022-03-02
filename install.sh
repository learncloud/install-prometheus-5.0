#!/bin/bash

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
MANIFEST_HOME=$SCRIPTDIR/yaml/manifests
SETUP_HOME=$SCRIPTDIR/yaml/setup
source $SCRIPTDIR/version.conf

sudo sed -i 's/{ALERTMANAGER_VERSION}/'${ALERTMANAGER_VERSION}'/g' $MANIFEST_HOME/alertmanager-alertmanager.yaml
sudo sed -i 's/{KUBE_RBAC_PROXY_VERSION}/'${KUBE_RBAC_PROXY_VERSION}'/g' $MANIFEST_HOME/kube-state-metrics-deployment.yaml
sudo sed -i 's/{KUBE_STATE_METRICS_VERSION}/'${KUBE_STATE_METRICS_VERSION}'/g' $MANIFEST_HOME/kube-state-metrics-deployment.yaml
sudo sed -i 's/{NODE_EXPORTER_VERSION}/'${NODE_EXPORTER_VERSION}'/g' $MANIFEST_HOME/node-exporter-daemonset.yaml
sudo sed -i 's/{KUBE_RBAC_PROXY_VERSION}/'${KUBE_RBAC_PROXY_VERSION}'/g' $MANIFEST_HOME/node-exporter-daemonset.yaml
sudo sed -i 's/{PROMETHEUS_ADAPTER_VERSION}/'${PROMETHEUS_ADAPTER_VERSION}'/g' $MANIFEST_HOME/prometheus-adapter-deployment.yaml
sudo sed -i 's/{PROMETHEUS_VERSION}/'${PROMETHEUS_VERSION}'/g' $MANIFEST_HOME/prometheus-prometheus.yaml
sudo sed -i 's/{PROMETHEUS_PVC}/'${PROMETHEUS_PVC}'/g' $MANIFEST_HOME/prometheus-prometheus.yaml

if [ $REGISTRY != "{REGISTRY}" ]; then
	sudo sed -i "s/quay.io\/prometheus\/alertmanager/${REGISTRY}\/prometheus\/alertmanager/g" $MANIFEST_HOME/alertmanager-alertmanager.yaml
	sudo sed -i "s/quay.io\/coreos\/kube-rbac-proxy/${REGISTRY}\/coreos\/kube-rbac-proxy/g" $MANIFEST_HOME/kube-state-metrics-deployment.yaml
	sudo sed -i "s/quay.io\/coreos\/kube-state-metrics/${REGISTRY}\/coreos\/kube-state-metrics/g" $MANIFEST_HOME/kube-state-metrics-deployment.yaml
	sudo sed -i "s/quay.io\/prometheus\/node-exporter/${REGISTRY}\/prometheus\/node-exporter/g" $MANIFEST_HOME/node-exporter-daemonset.yaml
	sudo sed -i "s/quay.io\/coreos\/kube-rbac-proxy/${REGISTRY}\/coreos\/kube-rbac-proxy/g" $MANIFEST_HOME/node-exporter-daemonset.yaml
	sudo sed -i "s/quay.io\/coreos\/k8s-prometheus-adapter-amd64/${REGISTRY}\/coreos\/k8s-prometheus-adapter-amd64/g" $MANIFEST_HOME/prometheus-adapter-deployment.yaml
	sudo sed -i "s/quay.io\/prometheus\/prometheus/${REGISTRY}\/prometheus\/prometheus/g" $MANIFEST_HOME/prometheus-prometheus.yaml
fi

if [ $REGISTRY != "{REGISTRY}" ]; then
	sudo sed -i "s/quay.io\/coreos\/configmap-reload/${REGISTRY}\/coreos\/configmap-reload/g" $SETUP_HOME/prometheus-operator-deployment.yaml
	sudo sed -i "s/quay.io\/coreos\/prometheus-config-reloader/${REGISTRY}\/coreos\/prometheus-config-reloader/g" $SETUP_HOME/prometheus-operator-deployment.yaml
	sudo sed -i "s/quay.io\/coreos\/prometheus-operator/${REGISTRY}\/coreos\/prometheus-operator/g" $SETUP_HOME/prometheus-operator-deployment.yaml
		 
fi

sudo sed -i 's/{PROMETHEUS_OPERATOR_VERSION}/'${PROMETHEUS_OPERATOR_VERSION}'/g' $SETUP_HOME/prometheus-operator-deployment.yaml
sudo sed -i 's/{CONFIGMAP_RELOADER_VERSION}/'${CONFIGMAP_RELOADER_VERSION}'/g' $SETUP_HOME/prometheus-operator-deployment.yaml
sudo sed -i 's/{CONFIGMAP_RELOAD_VERSION}/'${CONFIGMAP_RELOAD_VERSION}'/g' $SETUP_HOME/prometheus-operator-deployment.yaml

if ! command -v yq 2>/dev/null ; then
  sudo wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/bin/yq &&\
  sudo chmod +x /usr/bin/yq
fi

if ! command -v sshpass 2>/dev/null ; then
  sudo yum install https://download-ib01.fedoraproject.org/pub/epel/8/Everything/x86_64/Packages/s/sshpass-1.06-9.el8.x86_64.rpm
  sudo chmod +x /usr/bin/sshpass
  # yum install sshpass
fi

i=0

#IFS=' ' read -r -a masters <<< $(kubectl get nodes --selector=node-role.kubernetes.io/master -o jsonpath='{$.items[*].status.addresses[?(@.type=="InternalIP")].address}')
echo "$MAIN_MASTER_IP on work"
sudo cp /etc/kubernetes/manifests/etcd.yaml .
sudo yq e '.metadata.labels.k8s-app = "etcd"' -i etcd.yaml
sudo yq eval '(.spec.containers[0].command[] | select(. == "--listen-metrics-urls*")) = "--listen-metrics-urls=http://{MAIN_MASTER_IP}:2381,http://127.0.0.1:2381"' -i etcd.yaml
sudo sed -i 's/{MAIN_MASTER_IP}/'${MAIN_MASTER_IP}'/g' etcd.yaml
sudo mv -f ./etcd.yaml /etc/kubernetes/manifests/etcd.yaml

sudo cp /etc/kubernetes/manifests/kube-scheduler.yaml .
sudo yq e '.metadata.labels.k8s-app = "kube-scheduler"' -i kube-scheduler.yaml
sudo yq eval 'del(.spec.containers[0].command[] | select(. == "--port*") )' -i kube-scheduler.yaml
sudo mv -f ./kube-scheduler.yaml /etc/kubernetes/manifests/kube-scheduler.yaml

sudo cp /etc/kubernetes/manifests/kube-controller-manager.yaml .
sudo yq e '.metadata.labels.k8s-app = "kube-controller-manager"' -i kube-controller-manager.yaml
sudo yq eval 'del(.spec.containers[0].command[] | select(. == "--port*") )' -i kube-controller-manager.yaml
sudo mv -f ./kube-controller-manager.yaml /etc/kubernetes/manifests/kube-controller-manager.yaml

for master in  "${SUB_MASTER_IP[@]}"
do
  
  if [ $master == $MAIN_MASTER_IP ]; then
    continue
  fi
  echo "$master on work"
  #sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master"  sudo wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/bin/yq
  #sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master"  sudo chmod +x /usr/bin/yq

 

  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" scp /usr/bin/yq ${MASTER_NODE_ROOT_USER[i]}@"$master":/usr/bin/yq
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" scp /usr/bin/sshpass ${MASTER_NODE_ROOT_USER[i]}@"$master":/usr/bin/sshpass
  #sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" yum install yq
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" sudo cp /etc/kubernetes/manifests/etcd.yaml .
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" 'sudo yq e '"'"'.metadata.labels.k8s-app = "etcd"'"'"' -i etcd.yaml'
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" 'sudo yq eval '"'"'(.spec.containers[0].command[] | select(. == "--listen-metrics-urls*")) = "--listen-metrics-urls=http://{master}:2381,http://127.0.0.1:2381"'"'"' -i etcd.yaml'
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" sudo sed -i 's/{master}/'${master}'/g' etcd.yaml

  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" sudo mv -f ./etcd.yaml /etc/kubernetes/manifests/etcd.yaml


  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" sudo cp /etc/kubernetes/manifests/kube-scheduler.yaml .
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" 'sudo yq e '"'"'.metadata.labels.k8s-app = "kube-scheduler"'"'"' -i kube-scheduler.yaml'
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" 'sudo yq eval '"'"'del(.spec.containers[0].command[] | select(. == "--port*") )'"'"' -i kube-scheduler.yaml'
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" sudo mv -f ./kube-scheduler.yaml /etc/kubernetes/manifests/kube-scheduler.yaml

  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" sudo cp /etc/kubernetes/manifests/kube-controller-manager.yaml .
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" 'sudo yq e '"'"'.metadata.labels.k8s-app = "kube-controller-manager"'"'"' -i kube-controller-manager.yaml'
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" 'sudo yq eval '"'"'del(.spec.containers[0].command[] | select(. == "--port*") )'"'"' -i kube-controller-manager.yaml'
  sudo sshpass -p "${MASTER_NODE_ROOT_PASSWORD[i]}" ssh -o StrictHostKeyChecking=no ${MASTER_NODE_ROOT_USER[i]}@"$master" sudo mv -f ./kube-controller-manager.yaml /etc/kubernetes/manifests/kube-controller-manager.yaml
  i=$((i+1))
done



#sudo cp /etc/kubernetes/manifests/kube-scheduler.yaml .
#sudo cp /etc/kubernetes/manifests/kube-controller-manager.yaml .
#sudo yq e '.metadata.labels.k8s-app = "kube-scheduler"' -i kube-scheduler.yaml
#sudo yq e '.metadata.labels.k8s-app = "kube-controller-manager"' -i kube-controller-manager.yaml
#kubectl get pod `kubectl get pod -n kube-system -o jsonpath='{.items[?(@.metadata.labels.component == "kube-scheduler")].metadata.name}'` -n kube-system -o yaml > $SCRIPTDIR/kube-scheduler.yaml
#sudo yq e '.metadata.labels.k8s-app = "kube-scheduler"' -i $SCRIPTDIR/kube-scheduler.yaml
#sudo mv $SCRIPTDIR/kube-scheduler.yaml /etc/kubernetes/manifests/

#kubectl get pod `kubectl get pod -n kube-system -o jsonpath='{.items[?(@.metadata.labels.component == "kube-controller-manager")].metadata.name}'` -n kube-system -o yaml > $SCRIPTDIR/kube-controller-manager.yaml
#sudo yq e '.metadata.labels.k8s-app = "kube-controller-manager"' -i $SCRIPTDIR/kube-controller-manager.yaml
#sudo mv $SCRIPTDIR/kube-controller-manager.yaml /etc/kubernetes/manifests/

kubectl create -f $SETUP_HOME
sleep 5
kubectl create -f $MANIFEST_HOME
