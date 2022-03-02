if [ ! -d img ]; then
   mkdir img
fi

cd img/

sudo docker pull quay.io/prometheus/prometheus:${PROMETHEUS_VERSION}
sudo docker save quay.io/prometheus/prometheus:${PROMETHEUS_VERSION} > prometheus-prometheus_${PROMETHEUS_VERSION}.tar
sudo docker pull quay.io/coreos/prometheus-operator:${PROMETHEUS_OPERATOR_VERSION}
sudo docker save quay.io/coreos/prometheus-operator:${PROMETHEUS_OPERATOR_VERSION} > prometheus-operator_${PROMETHEUS_OPERATOR_VERSION}.tar
sudo docker pull quay.io/prometheus/node-exporter:${NODE_EXPORTER_VERSION}
sudo docker save quay.io/prometheus/node-exporter:${NODE_EXPORTER_VERSION} > node-exporter_${NODE_EXPORTER_VERSION}.tar
sudo docker pull quay.io/coreos/kube-state-metrics:${KUBE_STATE_METRICS_VERSION}
sudo docker save quay.io/coreos/kube-state-metrics:${KUBE_STATE_METRICS_VERSION} > kube-state-metrics_${KUBE_STATE_METRICS_VERSION}.tar
sudo docker pull quay.io/coreos/prometheus-config-reloader:${CONFIGMAP_RELOADER_VERSION}
sudo docker save quay.io/coreos/prometheus-config-reloader:${CONFIGMAP_RELOADER_VERSION} > config-reloader_${CONFIGMAP_RELOADER_VERSION}.tar
sudo docker pull quay.io/coreos/configmap-reload:${CONFIGMAP_RELOAD_VERSION}
sudo docker save quay.io/coreos/configmap-reload:${CONFIGMAP_RELOAD_VERSION} > config-reload_${CONFIGMAP_RELOAD_VERSION}.tar
sudo docker pull quay.io/coreos/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION}
sudo docker save quay.io/coreos/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION} > kube-rbac-proxy_${KUBE_RBAC_PROXY_VERSION}.tar
sudo docker pull quay.io/coreos/k8s-prometheus-adapter-amd64:${PROMETHEUS_ADAPTER_VERSION}
sudo docker save quay.io/coreos/k8s-prometheus-adapter-amd64:${PROMETHEUS_ADAPTER_VERSION} > prometheus-adapter_${PROMETHEUS_ADAPTER_VERSION}.tar
sudo docker pull quay.io/prometheus/alertmanager:${ALERTMANAGER_VERSION}
sudo docker save quay.io/prometheus/alertmanager:${ALERTMANAGER_VERSION} > alertmanager_${ALERTMANAGER_VERSION}.tar

sudo yum install yq
sudo yum install sshpass
