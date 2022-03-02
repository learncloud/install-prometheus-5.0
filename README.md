
# Prometheus 설치 가이드

## 구성 요소
* prometheus ([quay.io/prometheus/prometheus:v2.11.0](https://quay.io/repository/prometheus/prometheus?tag=latest&tab=tags))
* prometheus-operator ([quay.io/coreos/prometheus-operator:v0.34.0](https://quay.io/repository/coreos/prometheus-operator?tag=latest&tab=tags))
* node-exporter ([quay.io/prometheus/node-exporter:v0.18.1](https://quay.io/repository/prometheus/node-exporter?tag=latest&tab=tags))
* kube-state-metric ([quay.io/coreos/kube-state-metrics:v1.8.0](https://quay.io/repository/coreos/kube-state-metrics?tag=latest&tab=tags))
* configmap-reloader ([quay.io/coreos/prometheus-config-reloader:v0.34.0](https://quay.io/repository/coreos/prometheus-config-reloader?tag=latest&tab=tags))
* configmap-reload ([quay.io/coreos/configmap-reload:v0.0.1](https://quay.io/repository/coreos/configmap-reload?tag=latest&tab=tags))
* kube-rbac-proxy ([quay.io/coreos/kube-rbac-proxy:v0.4.1](https://quay.io/repository/coreos/kube-rbac-proxy?tag=latest&tab=tags))
* prometheus-adapter ([quay.io/coreos/k8s-prometheus-adapter-amd64:v0.5.0](https://quay.io/repository/coreos/k8s-prometheus-adapter-amd64?tag=latest&tab=tags))
* alertmanager ([quay.io/prometheus/alertmanager:v0.20.0](https://quay.io/repository/prometheus/alertmanager?tag=latest&tab=tags))



## Step 0. Prometheus Config 설정
* 목적 : `version.conf 파일에 설치를 위한 정보 기입`
* 순서: 
	* 환경에 맞는 config 내용 작성
		* version.conf 에 알맞는 버전과 registry 정보를 입력한다.

## 폐쇄망 구축 가이드
* 외부 네트워크 통신이 가능한 환경에서 setImg.sh를 이용 하여 이미지 및 패키지를 다운로드 받고 local Repository에 푸쉬한다.	
* 외부 네트워크 환경 스크립트 실행 순서
	```bash
	chmod +x version.conf
	source version.conf
	chmod +x setImg.sh
	./setImg.sh
	```
* 폐쇄망 설치 스크립트 실행순서
	```bash
	source version.conf
	chmod +x version.conf
	chmod +x setLocalReg.sh
	./setLocalReg.sh
	```
* 외부 통신이 가능한 환경에서 yq 패키지를 다운받는다.
	```bash
	sudo wget https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 -O /usr/bin/yq
	```
* yq bin 파일을 각 마스터의 /usr/bin/으로 복사한다.
## Step 1. installer 실행
* 목적 : `설치를 위한 shell script 실행`
* 순서: 
	* 권한 부여 및 실행
	``` bash
	chmod +x install.sh
	./install.sh
	```


## Step 2. kube-scheduler, kube-controller-manager,  etcd 설정 ( Sub master의 user와 password를 모를 시)

* 목적 : Kubernetes의 scheduler 정보와 controller 정보, etcd 정보를 수집하기 위함

* kube-system namespace에 있는 모든 kube-schduler pod의 metadata.labels에k8s-app: kube-scheduler추가
* kube-system namespace에 있는 모든 kube-contoroller-manager pod의 metadata.labels에k8s-app: kube-controller-manager 추가
* kube-system namespace에 있는 모든 etcd pod의 metadata.labels에k8s-app: etcd 추가
* kube-system namespace에 있는 모든 kube-schduler pod의 spec.container.command에서 --port=0 삭제
* kube-system namespace에 있는 모든 kube-contoroller-manager pod의 spec.container.command에서 --port=0 삭제

