variable "com_var" {}
variable "resource_group" {}
variable "network" {}

# HUB Bastion VM NIC용도 Azure 공용 IP 정의
resource "azurerm_public_ip" "hub_bastion_vm_ip" {
  name                = "${var.com_var.conf.project_name}-hub-bastion-vm-ip"                       # 공용 IP 이름
  resource_group_name = var.resource_group.hub_rg.name # 리소스 그룹 이름
  location            = var.com_var.location # 공용 IP 위치
  allocation_method   = "Dynamic"                             # 공용 IP 할당 방법 (Dynamic 또는 Static)
}

# HUB Bastion VM NIC 생성
resource "azurerm_network_interface" "hub_bastion_vm_nic" {
  name                = "${var.com_var.conf.project_name}-hub-bastion-vm-nic" # 네트워크 인터페이스 이름
  resource_group_name = var.resource_group.hub_rg.name # 네트워크 인터페이스가 속한 리소스 그룹 이름 
  location            = var.com_var.location # 네트워크 인터페이스 위치

  ip_configuration {
    name = "${var.com_var.conf.project_name}-hub-nic-config" # IP 구성 이름
    subnet_id = var.network.hub_subnet.bastion_id # IP 구성이 속한 서브넷의 ID
    private_ip_address_allocation = "Dynamic" # 사설 IP 주소 동적 할당
    public_ip_address_id = azurerm_public_ip.hub_bastion_vm_ip.id
  }
}

# 가상 네트워크에 대한 NSG 생성
resource "azurerm_network_security_group" "hub_bastion_vm_nsg" {
  name                = "${var.com_var.conf.project_name}-hub-bastion-vm-nsg" # NSG 이름
  resource_group_name = var.resource_group.hub_rg.name   # NSG가 속한 리소스 그룹 이름
  location            = var.com_var.location              # NSG 위치
}

# 3389 포트 인바운드 규칙 생성
resource "azurerm_network_security_rule" "hub_bastion_vm_nsg_3389_inbound" {
  name                        = "RDPAllow"                                  # 규칙 이름
  priority                    = 1001                                        # 규칙 우선순위
  direction                   = "Inbound"                                   # 인바운드 규칙
  access                      = "Allow"                                     # 허용 규칙
  protocol                    = "Tcp"                                       # TCP 프로토콜
  source_port_range           = "*"                                         # 모든 소스 포트
  destination_port_range      = "3389"                                      # 대상 포트 3389 (RDP)
  source_address_prefix       = "*"                                         # 모든 소스 주소
  destination_address_prefix  = "*"                                         # 모든 대상 주소
  resource_group_name         = var.resource_group.hub_rg.name      # NSG가 속한 리소스 그룹 이름
  network_security_group_name = azurerm_network_security_group.hub_bastion_vm_nsg.name # 규칙이 속한 NSG 이름
}

# 네트워크 인터페이스에 NSG 연결
resource "azurerm_network_interface_security_group_association" "connect_bastion_nic_nsg" {
  network_interface_id      = azurerm_network_interface.hub_bastion_vm_nic.id    # 네트워크 인터페이스 ID
  network_security_group_id = azurerm_network_security_group.hub_bastion_vm_nsg.id  # NSG ID
}

# Hub Bastion 용도의 VM 생성
resource "azurerm_windows_virtual_machine" "PNP-HUB-BASTION-VM" {
  name                = "${var.com_var.conf.project_name}-hub-bs-vm" # 가상 머신 이름
  resource_group_name = var.resource_group.hub_rg.name # 가상 머신이 속한 리소스 그룹 이름
  location            = var.com_var.location # 가상 머신 위치
  size                = "Standard_D2s_v3" # 가상 머신 크기
  admin_username      = "iotvmadmin" # 관리자 사용자 이름
  admin_password      = "aprkwhs123!@#" # 관리자 비밀번호
  network_interface_ids = [azurerm_network_interface.hub_bastion_vm_nic.id] # 가상 머신이 사용할 네트워크 인터페이스 ID
  # patch_mode = "AutomaticByPlatform" # Windows Virtual Machine에 대한 업데이트 모드를 설정

  os_disk {
    caching              = "ReadWrite" # OS 디스크 캐싱 설정
    storage_account_type = "Standard_LRS" # OS 디스크 저장소 유형
  }

  source_image_reference {
    publisher = "microsoftwindowsdesktop" # 이미지 게시자
    offer     = "windows-11" # 이미지 제안
    sku       = "win11-22h2-pro" # Windows 11 버전
    version   = "latest" # 최신 버전
  }
}