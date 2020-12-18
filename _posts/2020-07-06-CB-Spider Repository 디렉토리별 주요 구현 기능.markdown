---
layout: post
title: Blog
post_title: "CB-Spider Repository 디렉토리 및 파일별 주요 기능(12/16 updated)"
date: 2020-07-06 16:30:55
author: 오병택
categories: 
- 기술
- CB-Spider
- 개발
---
멀티 클라우드 서비스 시스템을 개발하기 위해서는 CSP별로 API 및 인증 방법과 자원을 컨트롤하는 방법이 각각 달라 이종 클라우드 연동을 위해 복잡한 개발 및 시험 과정이 필요하다.

Cloud-Barista 멀티 클라우드 인프라 연동 프레임워크(CB-Spider)는 Cloud-Barista 플랫폼의 하위 프레임워크 중의 하나로서, 이러한 이종 클라우드 연동의 어려운 문제를 해결하기 위한 클라우드 인프라 연동 ‘공통 프레임워크’ 이며, 사용자 및 Cloud-Barista 타 프레임워크에게 서로 다른 클라우드 인프라에 대한 단일 방식의 연동 및 제어 관리가 가능한 API를 제공한다.

본 글은 이러한 CB-Spider를 통해 추가로 다른 CSP 클라우드 연동이 필요할때 cloud 연동 driver 개발시 참고할 수 있도록 [CB-Spider github repository](https://github.com/cloud-barista/cb-spider "github.com/cloud-barista/cb-spider"){:target="_blank"} 의 구성 디렉토리 및 주요 파일의 기능을 설명하기 위한 것이다.<BR>
(2020/12/16 updated)
<!--more-->

<BR>

### [ 실행 환경 세팅 ]
#### */setup.env*

- spider 운영에 필요한 환경변수 세팅
	- *(중요)* CBSPIDER_ROOT, CBSTORE_ROOT, CBLOG_ROOT의 실제 경로 를 환경변수로 설정함.
	 - 특히, CBSTORE_ROOT 위치 설정 주의
	   - 예) export CBSTORE_ROOT=$CBSPIDER_ROOT

	- 환경변수 중, PLUGIN_SW
	  - ON 으로 설정할 경우 : CSP별 driver가 각각 build 되고 plugin 방식으로(동적으로) driver를 추가할 수 있음.
	  - OFF 사용 경우 예 : OFF mode로 설정하고 build하여 Android 환경에서 사용 가능

  - LOCALHOST=OFF 
	  - ON 으로 설정할 경우 : 공유기 환경 또는 사설 IP에서 spider 실행시 AdminWeb 동작이 일부 불가능할 때
  - MEERKAT=OFF
    - 분산 Spider 메카니즘(PoC) OFF 

- 환경변수 반영 위해 개발/테스트시 먼저 `source ./setup.env` 실행 필요

<BR>

#### */go.mod*

- Go 패키지 모음
- Build에 필요한 각각의 dependency 정의(import 필요한 module들의 path)

<BR>

#### */conf/*

- CB-Spider 운영을 위한 설정 정보
	- Spider 설정, 메타정보 관리 설정, 로그 설정 등
	- ./conf/log_conf.yaml 
      - loglevel을 debug / info / warn / error 중에 선택할 수 있는데, debug로 설정할 경우 debug가 가능하도록 코드에서 생산하는 상세한 log가 출력되며, error로 설정할 경우에는 error 발생 log만 출력됨.
	- ./conf/store_conf.yaml 
      - 저장 DB 종류 및 위치 설정
        - nutsdb or etcd
        - CB-Spider 운영에 관련된 데이터를 저장하는 DB를 nutsdb, etcd 중 어느 것으로 사용할지, 그리고 저장 DB 위치를 설정함.
        - (주의) 위의 /setup.env에서 설정한 CBSTORE_ROOT 환경변수 참고 필요


<BR>

#### */meta_db/*

- 기능
	- 메타 정보 local F/S(nutsdb) 활용시 실제 저장소 파일 위치

- 저장 DB 종류 및 위치 설정
	- /cb-store/ or /cb-spider/의 /conf/store_conf.yaml 에서 설정
  (위의 /setup.env에서 설정한 CBSTORE_ROOT 환경변수에 따라)

<BR>

#### */Dockerfile*
- Docker image build 실행용

<BR>

### [ REST API to Go Function 매핑 관계 ]

- **클라우드 연결 정보 관리 기능 REST API**

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

- **클라우드 자원 제어 기능 REST API**

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
  - localhost:1024/spider/allvpc
    - listAllVPC
  - localhost:1024/spider/cspvpc
    - deleteCSPVPC
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

- **Admin 웹 기능**

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
	- localhost:1024/spider/adminweb/vpc/
	  - VPC
	- localhost:1024/spider/adminweb/vpcmgmt/
	  -	VPCMgmt
	- localhost:1024/spider/adminweb/securitygroup
	  -	SecurityGroup
	- localhost:1024/spider/adminweb/securitygroupmgmt/
	  -	SecurityGroupMgmt
	- localhost:1024/spider/adminweb/keypair/
	  -	KeyPair
	- localhost:1024/spider/adminweb/keypairmgmt/
	  -	KeyPairMgmt
	- localhost:1024/spider/adminweb/vm/
	  -	VM
	- localhost:1024/spider/adminweb/vmmgmt/
	  -	VMMgmt
	- localhost:1024/spider/adminweb/vmimage/
	  -	VMImage
	- localhost:1024/spider/adminweb/vmspec/
	  -	VMSpec
	  
	- 상세 매핑 내용은 */rest-runtime/* 디렉토리에 있는 CBSpiderRuntime.go 파일 참고
	
<BR>

-	(참고) **CB-Spider REST API 규격 및 API별 사용 예**
	- 클라우드 인프라 연동 정보 관리 REST API
	  -	[cloud-barista.github.io/rest-api/v0.3.0/spider/ccim/](https://cloud-barista.github.io/rest-api/v0.3.0/spider/ccim/ "https://cloud-barista.github.io/rest-api/v0.3.0/spider/ccim/"){:target="_blank"}
	  -	관리대상: Cloud Driver/ Credential/ Region:Zone
	- 클라우드 인프라 공통 제어 관리 REST API 
	  -	[cloud-barista.github.io/rest-api/v0.3.0/spider/cctm/](https://cloud-barista.github.io/rest-api/v0.3.0/spider/cctm/ "https://cloud-barista.github.io/rest-api/v0.3.0/spider/cctm/"){:target="_blank"}
	  -	제어대상: Image/Spec/VPC/Subnet/SecurityGroup/ KeyPair/ VM

<BR>

### [ CB-Spider 주요 디렉토리 및 파일 기능 ]

<BR>

#### */api-runtime/*
- 코드 build 및 서버 구동 후 아래의 테스트를 진행할 수 있음.
  - `cd cb-spider/api-runtime/`
  - 아래의 두가지 방법으로 실행할 수 있음.  # 1024 포트로 REST API Server 구동됨
    - 방법 1)
      - `go run *.go` 로 build 및 API Server 실행
    - 방법 2)
      -	`make` 로 build 후 `./cb-spider` 로 API Server 실행

- */rest-runtime/*

  - */test/* : REST API 기능 테스트 script들이 존재함.
    - */connect-config/*
      - 기능
        - Driver 및 Credential 정보 등록 등 CSP별 연결 정보 관리 기능 테스트
        - 여기서 생성된 connection config 정보를 이용해 자원 관리 REST API 실행 

      - 관련 REST API
        - **등록 순서 준수**
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
    	
    	- full_test.sh
    	  - CSP별 자원 관리 전체 기능 시험 script
<BR>
  - */admin-web/* 디렉토리 기능
    - CB-Spider admin web
    - 위의 REST API 기능 테스트에서와 같은 CSP별 연결 정보 등록을 간단히 UI로 진행할 수 있도록 지원하는 도구
      - Cloud 연동 driver 등록 기능
      - Credential 정보 등록 기능
      - Region 정보 등록 기능
      - Cloud connection config 등록 기능
    - 웹 접속 URL
      - http://localhost:1024/spider/adminweb
<BR>
- */grpc-runtime/*
	- gRPC runtime 코드 위치
	- gRPC API 서버가 구동됨
	  -	기본 Port : 2048
<BR>
- */meerkat-runtime/*
  - meerkat runtime 엔진(PoC) 코드 위치
    -	기본 Port : 4096
  -	분산 Spider 메카니즘

<BR>  

#### */cloud-info-manager/*
- **현 디렉토리에 구현된 function**
	- listCloudOS<BR>
- */connection-config-info-manager/*
	- Cloud 연결 정보 관리 기능 구현 코드
	- **구현된 function**
		- createConnectionConfig
		- listConnectionConfig
		- getConnectionConfig
		- deleteConnectionConfig

- */credential-info-manager/*
	- Credential 정보 관리 기능 구현 코드
	- **구현된 function**
		- registerCredential
		- listCredential
		- getCredential
		- unRegisterCredential

- */driver-info-manager/*
	- Cloud 연동 driver 정보 관리 기능 구현 코드
	- **구현된 function**
		- registerCloudDriver
		- listCloudDriver
		- getCloudDriver
		- unRegisterCloudDriver

- */region-info-manager/*
	- Region 정보 관리 기능 구현 코드
	- **구현된 function**
		- registerRegion
		- listRegion
		- getRegion
		- unRegisterRegion
<BR>		  

#### */cloud-control-manager/*

- **구현된 function**
   - GetCloudConnection
   - createImage<BR>
- */cloud-driver/*
   - **Cloud driver package 구현 디렉토리**
   - */call-log/*
      -	Hiscall log 관련 format, 대상 cloud driver 등 설정 기능


   - */drivers/*
      - **각 CSP의 연동 driver 실제 기능 구현 코드**
      - */CSP명/* 디렉토리 (각각의 driver 구현 디렉토리로서, CSP 이름으로 alibaba, aws, azure, cloudit, docker, gcp, openstack, ncp 등이 될 수 있음.)
        - */connect/*
          - 각 CSP의 자원(VPC, SecurityGroup, KeyPair, VM) handle을 위한 handler로 이루어짐.

        - */main/*
          - 각 CSP의 자원(VPC, SecurityGroup, KeyPair, VM)을 handle 하는 실제 기능

        - */resources/*
          - 각 CSP의 자원(VPC, SecurityGroup, KeyPair, VM, VMspc, Image 등)을 handle 하는 **driver handler 실제 기능 구현**
          - Ex) VMHandler.go : VM 생성 및 life cycle 제어 기능 구현

        - [CSP명]Driver.go
          - CSP 인프라 API에 credential 정보를 이용해 인증 후 연결 client 생성
          - 이 client 정보를 이용해 각 handler에서 해당 CSP API를 호출하여 제어 기능 수행

      - */CSP명-plugin/*
         - 개별 driver를 build하여 plugin 방식으로(동적으로) 추가시 활용
         - build_driver_lib.sh
           - 해당 CSP driver를 build 하는 script
         - [CSP명]Driver-lib.go
           - 해당 CSP 인프라 API에 credential 정보를 이용해 인증 후 연결 client 생성
           - 이 client 정보를 이용해 각 handler에서 해당 CSP API를 호출하여 제어 기능 수행

   - */interfaces/*
      - **멀티 클라우드 연동 driver 공통 interface**
      - */connect/*
        - Cloud driver 'Connection' inferface 정의
      - */resources/*
        - Cloud driver 'Resource' inferface 정의

<BR>           
- */iid-manager/*
   - **Resource 관련 통합 ID(Integrated ID) 관리**
   - IID C/R/U/D 기능 fuction 구현체

<BR>      
- */vm-ssh/*
   - **Private key 혹은 private key path를 이용해, VM에 SSH로 파일 copy 및 script 실행 기능을 하는 utility**
   - 참고 : 이 utility을 편리하게 이용할 수 있는 기능 함수는 poc-specialized_services repository의 /vm-ssh-util/ 디렉토리에 구현되어 있음.
   - [~/cloud-barista/poc-specialized_services/vm-ssh-util/SshUtil.go](https://github.com/cloud-barista/poc-specialized_services/blob/master/vm-ssh-util/SshUtil.go "github.com/cloud-barista/poc-specialized_services/blob/master/vm-ssh-util/SshUtil.go"){:target="_blank"} 에 구현되어 있음.

<BR>  

#### */build_all_driver_lib.sh*
- 각각의 CSP 연결 driver를 한번의 실행 명령으로 build 하는 script
  - cb-spider 서버를 구동하기 전에 실행 필요
<BR>

#### */cloud-driver-libs/*
- Build된 각 CSP driver libray 위치(object 파일) 

<BR>

### [ REST API 통한 VM 생성 실행 예(REST API로부터 driver까지) ]

<BR>

- REST API인 localhost:1024/spider/vm 을 call하면,

  => /api-runtime/rest-runtime/CCIMRest.go 의 startVM(c echo.Context) 함수를 실행하여<BR>
result로서 cmrt.StartVM(req.ConnectionName, rsVM, reqInfo)가 실행됨.
<P>
  => 이에 따라, /api-runtime/common-runtime/CCMCommon.go 내의 <BR>
StartVM(connectionName string, rsType string, reqInfo cres.VMReqInfo) (*cres.VMInfo, error)가 실행되어, <BR>
create resource를 위해 (cres.VMHandler).StartVM(vmReqInfo cres.VMReqInfo) (cres.VMInfo, error)를 call함.
<P>
  => 연동된 cloud driver의 해당 기능을 실행하기 위해 해당 interface를 call함.<BR>
: /cloud-control-manager/cloud-driver/interfaces/resources/ 디렉토리의 VMHandler.go 내의 interface로서 StartVM(vmReqInfo VMReqInfo) (VMInfo, error)이 호출됨.
<P>
  => 해당 CSP의 driver 내의 실제 기능 함수가 호출되어, <BR>
/cloud-control-manager/cloud-driver/drivers/[CSP명]/resources/ 디렉토리 내에 위치한 VMHandler.go의 실제 VM 생성 함수가 실행됨.<BR>
: func (vmHandler *AwsVMHandler) StartVM(vmReqInfo irs.VMReqInfo) (irs.VMInfo, error)
