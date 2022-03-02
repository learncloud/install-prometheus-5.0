
# ClusterTemplate 가이드


## Step 1. clustertemplate 생성
* kubectl create -f prometheus-clustertemplate.yaml 명령어를 통해 cluster template 생성


***

## Step 2. template instace 생성

```
APP_NAME = prometheus 앱 네임 (prometheus로 설정 하는 것을 추천)
APP_NAME_GRAFANA = grafana 앱 네임 (grafana로 설정 하는 것을 추천)
GATEWAY_ADDRESS = ingress에 들어갈 host DNS 주소
INGRESS_IP = ingress IP
NAMESPACEC = namespace이름
```
설정 후 template instance 생성

