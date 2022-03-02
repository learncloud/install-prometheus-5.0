cd img/

sudo docker load < prometheus-prometheus_${PROMETHEUS_VERSION}.tar
sudo docker load < prometheus-operator_${PROMETHEUS_OPERATOR_VERSION}.tar
sudo docker load < node-exporter_${NODE_EXPORTER_VERSION}.tar
sudo docker load < kube-state-metrics_${KUBE_STATE_METRICS_VERSION}.tar
sudo docker load < config-reloader_${CONFIGMAP_RELOADER_VERSION}.tar
sudo docker load < config-reload_${CONFIGMAP_RELOAD_VERSION}.tar
sudo docker load < kube-rbac-proxy_${KUBE_RBAC_PROXY_VERSION}.tar
sudo docker load < prometheus-adapter_${PROMETHEUS_ADAPTER_VERSION}.tar
sudo docker load < alertmanager_${ALERTMANAGER_VERSION}.tar
 
sudo docker tag quay.io/prometheus/prometheus:${PROMETHEUS_VERSION} ${REGISTRY}/prometheus/prometheus:${PROMETHEUS_VERSION}
sudo docker tag quay.io/coreos/prometheus-operator:${PROMETHEUS_OPERATOR_VERSION} ${REGISTRY}/coreos/prometheus-operator:${PROMETHEUS_OPERATOR_VERSION}
sudo docker tag quay.io/prometheus/node-exporter:${NODE_EXPORTER_VERSION} ${REGISTRY}/prometheus/node-exporter:${NODE_EXPORTER_VERSION}
sudo docker tag quay.io/coreos/kube-state-metrics:${KUBE_STATE_METRICS_VERSION} ${REGISTRY}/coreos/kube-state-metrics:${KUBE_STATE_METRICS_VERSION}
sudo docker tag quay.io/coreos/prometheus-config-reloader:${CONFIGMAP_RELOADER_VERSION} ${REGISTRY}/coreos/prometheus-config-reloader:${CONFIGMAP_RELOADER_VERSION}
sudo docker tag quay.io/coreos/configmap-reload:${CONFIGMAP_RELOAD_VERSION} ${REGISTRY}/coreos/configmap-reload:${CONFIGMAP_RELOAD_VERSION}
sudo docker tag quay.io/coreos/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION} ${REGISTRY}/coreos/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION}
sudo docker tag quay.io/coreos/k8s-prometheus-adapter-amd64:${PROMETHEUS_ADAPTER_VERSION} ${REGISTRY}/coreos/k8s-prometheus-adapter-amd64:${PROMETHEUS_ADAPTER_VERSION}
sudo docker tag quay.io/prometheus/alertmanager:${ALERTMANAGER_VERSION} ${REGISTRY}/prometheus/alertmanager:${ALERTMANAGER_VERSION}
 
sudo docker push ${REGISTRY}/prometheus/prometheus:${PROMETHEUS_VERSION}
sudo docker push ${REGISTRY}/coreos/prometheus-operator:${PROMETHEUS_OPERATOR_VERSION}
sudo docker push ${REGISTRY}/prometheus/node-exporter:${NODE_EXPORTER_VERSION}
sudo docker push ${REGISTRY}/coreos/kube-state-metrics:${KUBE_STATE_METRICS_VERSION}
sudo docker push ${REGISTRY}/coreos/prometheus-config-reloader:${CONFIGMAP_RELOADER_VERSION}
sudo docker push ${REGISTRY}/coreos/configmap-reload:${CONFIGMAP_RELOAD_VERSION}
sudo docker push ${REGISTRY}/coreos/kube-rbac-proxy:${KUBE_RBAC_PROXY_VERSION}
sudo docker push ${REGISTRY}/coreos/k8s-prometheus-adapter-amd64:${PROMETHEUS_ADAPTER_VERSION}
sudo docker push ${REGISTRY}/prometheus/alertmanager:${ALERTMANAGER_VERSION}


