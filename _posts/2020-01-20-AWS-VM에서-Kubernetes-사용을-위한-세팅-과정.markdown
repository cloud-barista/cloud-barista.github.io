---
layout: post
title: "AWS VM에서 Kubernetes 사용을 위한 세팅 과정"
date: 2020-01-20 16:54:46
author: 박진휘
categories: 
- blog 
- Kubernetes
- AWS
img: kubernetes.jpeg
thumb: kubernetes.png
---

1. EC2 접속

2. 인스턴스 이미지 종류 검색 
	>■ 18.04 검색
	>■ 우분투 18.04 LTS버전 선택

3. 인스턴스 생성 시작
	>■ flavor , volume, 보안 그룹, 키페어 선택
<!--more-->
4. 기본 설정 방법
	>■ 계정 비밀번호 설정

	>	$ sudo passwd root / sudo passwd ubuntu
	
	>■ hostName 변경(여러 창을 띄워놓고 작업 중 구분 쉽게하기 위해)

	>	$ sudo vim /etc/hostname	기존의 것 삭제 후 hostname 입력
	>	$ sudo vim /etc hosts		127.0.0.1 hostname 추가 입력
	
	>■ 패키지 Install 속도 증가를 위해

	>	$ sudo vim /etc/apt/source.list
	>	$ %s/바꿀내용/mirror.kakao.com/g

	>■ 패키지 Installer update (2개 다하는 것은 옵션)
	
	>	$ sudo apt-get update –y && sudo apt-get upgrade –y
	>	$ sudo apt update –y && sudo apt upgrade –y

	>■ ssh 설정

	>	$ sudo vim /etc/ssh/sshd.config
	>	$ #port 22 -> #제거 (옵션)
	>	$ #PermitRootLogin no –> yes (옵션)
	>	$ #PasswordAuthentication no  -> yes (키페어 사용안할 시)

	>■ ssh 재시작 / 설정적용

	>	$ sudo service ssh restart

5. K8s 설치과정 
	>■ 도커 설치

	>	$ sudo apt-get install –y docker.io
	
	>■ K8s 설치 (k8s document 참고) 
	> 	: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

	>	$ sudo apt-get update && sudo apt-get install -y apt-transport-https curl
	>	$ curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
	>	$ cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
	>	  deb https://apt.kubernetes.io/ kubernetes-xenial main
	>     EOF
	>	$ sudo apt-get update
	>	$ sudo apt-get install -y kubelet kubeadm kubectl 
		※worker에는 kubectl 제외
	(선택적)sudo apt-mark hold kubelet kubeadm kubectl
		※버전 홀드 풀려면 sudo apt-mark unhold~
	
6. K8s 클러스터 구축 과정
	>■ 클러스터 초기화

		$ sudo systemctl restart kubelet (모든 노드에서 실행)
		$ sudo systemctl enable kubelet (모든 노드에서 실행)
		$ sudo swapoff –a (모든 노드에서 실행)
		$ sudo kubeadm init —pod-network-cidr=172.16.0.0/16
			(Pod Network 옵션 선택적)

	>■ 일반 User 계정에서 Kubectl 명령어 수행 권한 부여

		$ mkdir –p $HOME/.kube
		$ cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
		$ chown $(id -u):$(id -g) $HOME/.kube/config

	>■ Pod Network CNI 설치 (Calico 선택시)

		$ sudo kubectl apply –f  https://docs.projectcalico.org/
		v3.3/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml	- Pod Network Cidr 설정 필요
		$ wget https://docs.projectcalico.org/v3.3/getting-started/
		kubernetes/installation/hosted/kubernetes-datastore/
		calico-networking/1.7/calico.yaml
		$ sed s/192.168.0.0\\/16/172.16.0.0\\/16/g –i calico.yaml
		$ sudo kubectl apply –f calico.yaml
		$ vim calico.yaml -> /Daemonset -> extionsions/v1beta1=> apps/v1				
                /Deployment-> extensions/v1 => apps/v1
				/Deployment-> spec 아래에 selector field 추가
			selector:
			  matchLabels:
			     k8s-app: calico-typha	
	
	>■ Node Join 인자 확인

		$ sudo kubeadm token list // 토큰 값 확인
		$ sudo token create // 토큰 값 expired일 경우
		$ sudo openssl x509 –pubkey –in /etc/kubernetes/pki/ca.crt | openssl rsa –pubin –outform der 2>/dev/null | openssl dgst –sha256 –hex | sed ‘s/^.*//’	// Hash 확인
	
	>■ Node Join
	
		$ sudo kubeadm join <MasterIp:6443> --token <token 값> 
		--disocvery-token-ca-cert-hash sha256:<Hash 값>
	
	>■ Cluster 확인(Master에서)

	>	$ sudo kubectl cluster-info
	>	$ sudo kubectl get nodes 

7. Web Tool 설치
	>■ 대시보드 배포

		$ sudo kubectl apply –f https://raw.githubusercontent.com/kubernetes/dashboard/
		v2.0.0-rc1/aio/deploy/recommended.yaml
	
	>■ 접속을 위한 환경 과정 (https://crystalcube.co.kr/199 참고)

		$ grep 'client-certificate-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kube.crt
		$ grep 'client-key-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kube.key
		$ openssl pkcs12 -export -clcerts -inkey kube.key -in kube.crt –out kube.p12 -name "one-node"
			/etc/kubernetes/pki/ca.crt , kube.p12 파일 접속할 환경으로 이동
	
	>■ 인증서 추가 후 Dashboard 접속 :
https://master_ip:api_server_port/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/

	>	※master_ip: api_server_port 확인

	>	$ sudo kubectl cluster-info