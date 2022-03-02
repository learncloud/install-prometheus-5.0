
# postgre prometheus 연동 가이드

## 구성 요소
* postgre ([timescaledev/promscale-extension:latest-pg12](https://hub.docker.com/layers/timescaledev/promscale-extension/latest-pg12/images/sha256-77fa2ea35276a0c28fa460b45a98fbfd7250c24e70628d0a6b18737d357793a8?context=explore))
* promscale-connector ([timescale/promscale:0.1.2](https://hub.docker.com/layers/timescale/promscale/0.1.4/images/sha256-de1c4e0d0c5e6c91be2ba18faea7a663793db3535d18a57cbe5608e4e63cd41b?context=explore))

## Prerequisite


## 구축 가이드
* 외부 네트워크 통신이 가능한 환경에서 필요한 이미지를 다운받는다
```
$ sudo docker pull timescaledev/promscale-extension:latest-pg12
$ sudo docker pull timescale/promscale:0.1.4
```
* 생성한 이미지 tar 파일을 폐쇄망 환경으로 이동시킨 뒤 사용하려는 registry에 push한다.
```
$ sudo docker load < promscale-extension:latest-pg12.tar
$ sudo docker load < timescale/promscale:0.1.4.tar
    
$ sudo docker tag timescaledev/promscale-extension:latest-pg12 ${REGISTRY}/timescaledev/promscale-extension:latest-pg12
$ sudo docker tag timescale/promscale:0.1.4 ${REGISTRY}/timescale/promscale:0.1.4
  
$ sudo docker push ${REGISTRY}/timescaledev/promscale-extension:latest-pg12
$ sudo docker push ${REGISTRY}/timescale/promscale:0.1.4
	
```
	
	
	

## 설치 가이드
1. [pvc 및 postgre pod 생성](#step-1-pvc-%EB%B0%8F-postgre-pod-%EC%83%9D%EC%84%B1)
2. [pro	mscale-connector 설치](#step-2-promscale-connector-%EC%84%A4%EC%B9%98)
3. [prometheus 설정 변경](#step-3-prometheus-%EC%84%A4%EC%A0%95-%EB%B3%80%EA%B2%BD)
4. [확인](#step-4-%ED%99%95%EC%9D%B8)
	
***

## Step 1. PVC 및 postgre pod 생성
* 목적 : postgre가 사용할 pvc와 postgre pod 생성
* kubectl create -f postgre-pvc.yaml 명령어를 통해 pvc와 pv 생성 [postgre-pvc.yaml](https://github.com/tmax-cloud/install-prometheus/blob/main/postgre-connection-guide/manifest/postgre-pvc.yaml)
* postgre-password-secret.yaml 에서 $PASSWORD를 원하는 비밀번호를 BASE64로 인코딩하여 대체 [postgre-password-secret.yaml](https://github.com/tmax-cloud/install-prometheus/blob/main/postgre-connection-guide/manifest/postgre-password-secret.yaml)
* kubectl create -f postgre-password-secret.yaml 명령어를 통해 postgre DB에서 사용할 비밀번호를 위한 secret 생성 
* postgre-deployment.yaml 에서 원하는 db user id를 $USER_ID에 대체 [postgre-deployment.yaml](https://github.com/tmax-cloud/install-prometheus/blob/main/postgre-connection-guide/manifest/postgre-deployment.yaml)
* kubectl create -f postgre-deployment.yaml 명령어를 통해 postgre deployment와 service 생성


***

## Step 2. promscale-connector 설치
* 목적 : promscale-connector pod 및 service 생성, postgre와 연결
* promscale-connector-deployment.yaml 에서 $USER_ID를 postgre에 설정한 db user id로 대체 [promscale-connector-deployment.yaml](https://github.com/tmax-cloud/install-prometheus/blob/main/postgre-connection-guide/manifest/promscale-connector-deployment.yaml)
* kubectl create -f postgre-deployment.yaml 명령어를 통해 promscale-connector pod 와 service 생성

***

## Step 3. prometheus 설정 변경

* 목적 : prometheus가 promscale-connector를 인지하고 metric 정보를 postgre db 에 read/write 할 수 있도록 함

* prometheus-prometheus.yaml 에서 spec 아래 레벨에 다음을 추가한다.
	```
  remoteWrite:
    - url: "http://promscale.monitoring.svc.cluster.local:9201/write"
  remoteRead:
    - url: "http://promscale.monitoring.svc.cluster.local:9201/read"
	```


***

## Step 4. 확인
* 목적: postgre, promscale-connector, prometheus의 정상 연동 확인
* postgre pod에 접속한다.
* psql -U $USER_ID 명령어로 postgresql 접속
* \c postgres로 DB 접속
* \dv  → prometheus에서 등록한 metric 확인


