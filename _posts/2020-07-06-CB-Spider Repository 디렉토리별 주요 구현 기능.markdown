---
layout: post
title: Blog
post_title: "CB-Spider Repository 디렉토리별 주요 구현 기능"
date: 2020-07-06 16:30:55
author: 오병택
categories: 
- 기술
- CB-Spider
- 개발
---

## CB-Spider Repository 디렉토리별 주요 구현 기능

멀티 클라우드 서비스 시스템을 개발하기 위해서는 CSP별로 API 및 인증 방법과 자원을 컨트롤하는 방법이 각각 달라 이종 클라우드 연동을 위해 복잡한 개발 및 시험 과정이 필요하다.

Cloud-Barista 멀티 클라우드 인프라 연동 프레임워크(CB-Spider)는 Cloud-Barista 시스템에서 이러한 이종 클라우드 연동의 어려운 문제를 해결하기 위한 클라우드 연동 공통 프레임워크이며, 사용자 및 Cloud-Barista 타 서브시스템에게 서로 다른 클라우드 인프라에 대한 단일 방식의 연동 및 제어 관리 방법 등을 제공한다.

본 게시글은 이러한 CB-Spider를 통해 추가로 CSP 연동이 필요할때 참고할 수 있도록 CB-Spider github repository(https://github.com/cloud-barista/cb-spider) 의 구성 디렉토리 및 주요 기능을 설명하기 위한 것이다.
<!--more-->

## [ 실행 환경 및 필요 go package path 세팅 ]

### */setup.env*

- spider 운영에 필요한 환경변수 세팅

	- CBSPIDER_ROOT, CBSTORE_ROOT, CBLOG_ROOT의 경로 및 PLUGIN_SW ON/OFF 를 환경변수로 설정함.
	- 환경변수중 PLUGIN_SW=ON 으로 설정된 경우, CSP별 driver가 각각 build되고 plugin 방식으로(동적으로) driver를 추가할 수 있음.

		- (OFF 사용 경우 예) OFF mode로 설정하고 build하여 Android 환경에서 사용 가능

- 환경변수 반영 위해 개발/테스트시 먼저 source ./setup.env 실행 필요

### */go.mod*

- Go 패키지 모음
- Build에 필요한 각각의 디펜던시 정의(import 필요한 module들의 path)

### */conf/*

- CB-Spider 운영을 위한 설정 정보

	- Spider 설정, 메타 정보 관리 설정, 로그 설정 등

### */meta_db/*

- 기능

	- 메타 정보 local FS(nutsdb) 활용시 저장소 위치

- 저장 DB 종류 및 위치 설정

	- /cb-store/conf/store_conf.yaml 에서 설정
	- nutsdb or etcd 세팅

### */Dockerfile*

- Docker image build 실행용

  

## [ CB-Spider 주요 디렉토리 및 기능 ]

### # REST API to Go Function 매핑 관계

- 클라우드 연결 정보 관리 기능

  - 다음의 REST API를 call할때 */cloud-info-manager/* 디렉토리에 있는 함수가 실행됨.
  - localhost:1024/spider/cloudos 
    - listCloudOS
  - localhost:1024/spider/driver
    - registerCloudDriver
    - listCloudDriver
    - getCloudDriver
    - unRegisterCloudDriver
  - localhost:1024/spider/credential
    - registerCredential
    - listCredential
    - getCredential
    - unRegisterCredential
  - localhost:1024/spider/region
    - registerRegion
    - listRegion
    - getRegion
    - unRegisterRegion
  - localhost:1024/spider/connectionconfig
    - createConnectionConfig
    - listConnectionConfig
    - getConnectionConfig
    - deleteConnectionConfig
  - 상세 매핑 내용은 */rest-runtime/* 디렉토리에 있는 CBSpiderRuntime.go, CIMRest.go 파일 참고

- 클라우드 자원 제어 기능

  - 다음의 REST API를 call할때 */cloud-control-manager/* 및 */api-runtime/common-runtime/* 디렉토리에 있는 함수가 실행됨.
  - localhost:1024/spider/vmimage
    - createImage
    - listImage
    - getImage
    - deleteImage
  - localhost:1024/spider/vmspec
    - listVMSpec
    - getVMSpec
  - localhost:1024/spider/vmorgspec
    - listOrgVMSpec
    - getOrgVMSpec
  - localhost:1024/spider/vpc
    - createVPC
    - listVPC
    - getVPC
    - deleteVPC
  - localhost:1024/spider/securitygroup
    - createSecurity
    - listSecurity
    - getSecurity
    - deleteSecurity
  - localhost:1024/spider/allsecuritygroup
    - listAllSecurity
  - localhost:1024/spider/cspsecuritygroup
    - deleteCSPSecurity
  - localhost:1024/spider/keypair
    - createKey
    - listKey
    - getKey
    - deleteKey
  - localhost:1024/spider/allkeypair
    - listAllKey
  - localhost:1024/spider/cspkeypair
    - deleteCSPKey
  - localhost:1024/spider/vm
    - startVM
    - listVM
    - getVM
    - terminateVM
  - localhost:1024/spider/allvm
    - listAllVM
  - localhost:1024/spider/cspvm
    - terminateCSPVM
  - localhost:1024/spider/vmstatus
    - listVMStatus
    - getVMStatus
  - localhost:1024/spider/controlvm
    - controlVM
  - localhost:1024/spider/sshrun
    - sshrun
  - 상세 매핑 내용은 */rest-runtime/* 디렉토리에 있는 CBSpiderRuntime.go, CCMRest.go 파일 참고

- Admin 웹 기능

	- 다음의 REST API를 call할때 */api-runtime/rest-runtime/admin-web/* 디렉토리에 있는 함수가 실행됨.
	
	- localhost:1024/spider/adminweb
	  
	  - Frame
	  
	- localhost:1024/spider/adminweb/top
	  
	  - Top
	  
	- localhost:1024/spider/adminweb/driver
	  
	  - Driver
	  
	- localhost:1024/spider/adminweb/credential
	  
	  - Credential
	  
	- localhost:1024/spider/adminweb/region
	  
	  - Region
	  
	- localhost:1024/spider/adminweb/connectionconfig
	  
	  - Connectionconfig
	  
	- localhost:1024/spider/adminweb/spiderinfo
	  
	  - SpiderInfo
	  
	- 상세 매핑 내용은 */rest-runtime/* 디렉토리에 있는 CBSpiderRuntime.go 파일 참고
	
	  

### */api-runtime/*

- */rest-runtime/*

	- */test/*
- */connect-config/*
		- 기능
	
			- CSP별 연결 정보 관리 기능 테스트
	
		- 관련 REST API
	
			- **실행 순서 준수**
		- Cloud 연동 driver 등록
			
				- localhost:1024/spider/driver
	
			- Credential 정보 등록
	
				- localhost:1024/spider/credential
	
			- Region 정보 등록
	
				- localhost:1024/spider/region
	
			- Cloud connection config 생성
	
				- localhost:1024/spider/connectionconfig
	
			- **테스트 script : CPS명~-conn-config.sh**
	
		- */each-test/*
- 기능
			
	
	- Cloud별/각 자원별 생성 기능 시험 후 삭제 시험
	
- 자원 생성 순서
			
	
	- VPC -> SecurityGroup -> KeyPair -> VM
	
- */full-test/*
		- 기능
	
			- CSP별 자원 관리 전체 기능 시험(create -> list -> get -> delete)
	
		- 대상 자원
	
			- VPC, SecurityGroup, KeyPair, VM
	
		- (참고)
	
			- full_test.sh
	
				- CSP별 자원 관리 전체 기능 시험 script
	
		- **Cloud 연결 관리 REST API 사용 예 :** https://documenter.getpostman.com/view/9027676/SztG2R1W?version=latest

	- */admin-web/*
- 기능
		
	- CB-Spider admin web(개발 진행중인 상태임)
			- 위의 REST API 기능 테스트에서와 같은 CSP별 연결 정보 등록을 간단히 UI로 진행할 수 있도록 지원하는 도구
		- - Cloud 연동 driver 등록 기능
			- - Credential 정보 등록 기능
		- - Region 정보 등록 기능
			- - Cloud connection config 등록 기능
		
	- 웹 접속 URL
		
		- http://localhost:1024/spider/adminweb
	
- */grpc-runtime/*

	- gRPC runtime 코드 위치(개발 진행중인 상태임)
	
	  

### */build_all_driver_lib.sh*

- 각각의 CSP 연결 driver를 한번의 실행 명령으로 build 하는 script

  

### */cloud-driver-libs/*

- Build된 각 CSP driver libray 위치(object 파일) 

  

### */cloud-info-manager/*

- **구현된 function**

	- listCloudOS

- */connection-config-info-manager/*

	- Cloud 연결 정보 관리 기능 구현
	- **구현된 function**

		- createConnectionConfig
		- listConnectionConfig
		- getConnectionConfig
		- deleteConnectionConfig

- */credential-info-manager/*

	- Credential 정보 관리 기능 구현
	- **구현된 function**

		- registerCredential
		- listCredential
		- getCredential
		- unRegisterCredential

- */driver-info-manager/*

	- Cloud 연동 driver 정보 관리 기능 구현
	- **구현된 function**

		- registerCloudDriver
		- listCloudDriver
		- getCloudDriver
		- unRegisterCloudDriver

- */region-info-manager/*

	- Region 정보 관리 기능 구현
	- **구현된 function**

		- registerRegion
		
		- listRegion
		
		- getRegion
		
		- unRegisterRegion
		
		  

### */cloud-control-manager/*

- **구현된 function**
- GetCloudConnection
	- createImage
	
- */cloud-driver/*
- **Cloud driver packge 구현 디렉토리**
	- */drivers/*
	- **각 CSP의 연동 driver 실제 기능 구현 코드**
	- */각 CSP명/*
		- */connect/*
		- 각 CSP의 자원(VPC, SecurityGroup, KeyPair, VM) handle을 위한 handler로 이루어짐.
		
		- */main/*
	- 각 CSP의 자원(VPC, SecurityGroup, KeyPair, VM)을 handle 하는 실제 기능
		
	- */각 CSP명-plugin/*
	- Plugin 방식으로(동적으로) 추가할 수 있는 driver 기능
	
	- */interfaces/*
- **멀티 클라우드 연동 driver 공통 interface**
		- */connect/*
	- Cloud driver 'Connection' inferface 정의
		
	- */resources/*
	- Cloud driver 'Resource' inferface 정의

- */iid-manager/*
- **Resource 관련 통합 ID(Integrated ID) 관리**
	- IID C/R/U/D 기능 fuction 구현체
	
- */vm-ssh/*
- **Private key 혹은 private key path를 이용해, VM에 SSH로 파일 copy 및 script 실행 기능을 하는 util**
	- 참고
	
	- 이 util을 편리하게 이용할 수 있는 기능 함수는 ~/cloud-barista/poc-specialized_services/vm-ssh-util/ 에 구현되어 있음.