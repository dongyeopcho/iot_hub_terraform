# iot_hub_terraform

## Project Overvie
이 프로젝트는 Azure 리소스를 구성하고 사용자 역할을 할당하기 위한 Terraform 구성을포함합니다.

- Azure 리소스 그룹 생성
- Virtual Network 및 Subnet 설정
- Network Security Group 및 Rules 설정
- Azure Storage Account 및 Data Lake 설정
- Azure IoT Hub 및 Device 설정
- Azure Synapse 설정
- Azure 사용자 Role 설정

## Prerequisites
해당 프로젝트를 사용하기 전에 다름 요구 사항을 충족해야 합니다.

- Terraform 설치
- Azure CLI 설치
- VS Code Terraform Extension

## 초기 환경 세팅 절차
1. VS Code에서 New Terminal을 생성합니다.
2. 아래 명령어를 이용하여 Azure 계정에 로그인합니다. (이 때, 리소스를 생성하려는 구독으로 현재 구독을 변경해야 합니다.)
    ``` sh
    az login
    ```
3. 이후 아래 Terraform 명령어를 실행하여 provider 플러그인을 설치합니다.
    ``` sh
    terraform init
    ```
4. Terraform 문법을 검사합니다.
    ``` sh
    terraform validate
    ```
5. Terraform 실행 계획을 생성하여 구성 변경을 미리 확인하고 실행 계획 파일을 생성합니다.
    ``` sh
    terraform plan -out "main.tfplan"
    ```

6. Terraform을 이용하여 리소스를 생성 및 변경합니다.
    ``` sh
    terraform apply "main.tfplan"
    ```
