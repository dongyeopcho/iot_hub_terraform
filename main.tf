# Resource Group 생성 
resource "azurerm_resource_group" "pnp_hub_rg" {
  location = var.resource_group_location # 리소스 그룹 위치 변수 사용
  name     = "PNP-HUB-RG" # 리소스 그룹 이름
}

resource "azurerm_resource_group" "pnp_spoke_rg" {
  location = var.resource_group_location # 리소스 그룹 위치 변수 사용
  name     = "PNP-SPOKE-RG" # 리소스 그룹 이름
}

# Hub Vnet 및 Subnet 생성
resource "azurerm_virtual_network" "pnp_hub_vnet" {
  name                = "pnp_hub_vnet" # 가상 네트워크 이름
  address_space       = ["10.0.0.0/16"] # 가상 네트워크 주소 공간
  location            = azurerm_resource_group.pnp_hub_rg.location # 가상 네트워크 위치
  resource_group_name = azurerm_resource_group.pnp_hub_rg.name # 가상 네트워크가 속한 리소스 그룹 이름
}

resource "azurerm_subnet" "pnp_hub_bastion_pep_subnet" {
  name                 = "PNP-HUB-BASTION-PEP-SUBNET" # 서브넷 이름
  resource_group_name  = azurerm_resource_group.pnp_hub_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.pnp_hub_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.1.0/24"] # 서브넷 주소 공간
}

resource "azurerm_subnet" "pnp_hub_iot_pep_subnet" {
  name                 = "PNP-HUB-IOT-PEP-SUBNET" # 서브넷 이름
  resource_group_name  = azurerm_resource_group.pnp_hub_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.pnp_hub_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.2.0/24"] # 서브넷 주소 공간
}

resource "azurerm_subnet" "pnp_hub_plh_pep_subnet" {
  name                 = "PNP-HUB-PLH-PEP-SUBNET" # 서브넷 이름
  resource_group_name  = azurerm_resource_group.pnp_hub_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.pnp_hub_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.0.3.0/24"] # 서브넷 주소 공간
}

# Spoke Vnet 및 Subnet 생성
resource "azurerm_virtual_network" "pnp_spoke_vnet" {
  name                = "pnp_spoke_vnet" # 가상 네트워크 이름
  address_space       = ["10.1.0.0/16"] # 가상 네트워크 주소 공간
  location            = azurerm_resource_group.pnp_spoke_rg.location # 가상 네트워크 위치
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name # 가상 네트워크가 속한 리소스 그룹 이름
}

resource "azurerm_subnet" "pnp_spoke_syn_pep_subnet" {
  name                 = "PNP-SPOKE-SYN-PEP-SUBNET" # 서브넷 이름
  resource_group_name  = azurerm_resource_group.pnp_spoke_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.pnp_spoke_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.1.1.0/24"] # 서브넷 주소 공간
}

resource "azurerm_subnet" "pnp_spoke_data_st_pep_subnet" {
  name                 = "PNP-SPOKE-DATA-ST-PEP-SUBNET" # 서브넷 이름
  resource_group_name  = azurerm_resource_group.pnp_spoke_rg.name # 서브넷이 속한 리소스 그룹 이름
  virtual_network_name = azurerm_virtual_network.pnp_spoke_vnet.name # 서브넷이 속한 가상 네트워크 이름
  address_prefixes     = ["10.1.2.0/24"] # 서브넷 주소 공간
}

# 가상 네트워크 피어링 설정 (Hub Vnet에서 Spoke Vnet으로)
resource "azurerm_virtual_network_peering" "peer_hub_to_spoke" {
  name                         = "peer_hub_to_spoke"
  resource_group_name          = azurerm_resource_group.pnp_hub_rg.name
  virtual_network_name         = azurerm_virtual_network.pnp_hub_vnet.name
  remote_virtual_network_id     = azurerm_virtual_network.pnp_spoke_vnet.id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
  allow_virtual_network_access = true
}

# 가상 네트워크 피어링 설정 (Spoke Vnet에서 Hub Vnet으로)
resource "azurerm_virtual_network_peering" "peer_spoke_to_hub" {
  name                         = "peer_spoke_to_hub"
  resource_group_name          = azurerm_resource_group.pnp_spoke_rg.name
  virtual_network_name         = azurerm_virtual_network.pnp_spoke_vnet.name
  remote_virtual_network_id     = azurerm_virtual_network.pnp_hub_vnet.id
  allow_forwarded_traffic      = false
  allow_gateway_transit        = true
  use_remote_gateways          = false
  allow_virtual_network_access = true
}

# HUB Bastion VM NIC용도 Azure 공용 IP 정의
resource "azurerm_public_ip" "pnp_hub_bastion_vm_ip" {
  name                = "PNP-HUB-BASTION-VM-IP"                       # 공용 IP 이름
  resource_group_name = azurerm_resource_group.pnp_hub_rg.name # 리소스 그룹 이름
  location            = var.resource_group_location # 공용 IP 위치
  allocation_method   = "Dynamic"                             # 공용 IP 할당 방법 (Dynamic 또는 Static)
}

# HUB Bastion VM NIC 생성
resource "azurerm_network_interface" "pnp_hub_bastion_vm_nic" {
  name                = "PNP-HUB-BASTION-VM-NIC" # 네트워크 인터페이스 이름
  resource_group_name = azurerm_resource_group.pnp_hub_rg.name # 네트워크 인터페이스가 속한 리소스 그룹 이름 
  location            = var.resource_group_location # 네트워크 인터페이스 위치

  ip_configuration {
    name = "PNP-HUB-NIC-CONFIG" # IP 구성 이름
    subnet_id = azurerm_subnet.pnp_hub_bastion_pep_subnet.id # IP 구성이 속한 서브넷의 ID
    private_ip_address_allocation = "Dynamic" # 사설 IP 주소 동적 할당
    public_ip_address_id = azurerm_public_ip.pnp_hub_bastion_vm_ip.id
  }
}

# 가상 네트워크에 대한 NSG 생성
resource "azurerm_network_security_group" "pnp_hub_bastion_vm_nsg" {
  name                = "PNP-HUB-BASTION-VM-NSG"                 # NSG 이름
  resource_group_name = azurerm_resource_group.pnp_hub_rg.name   # NSG가 속한 리소스 그룹 이름
  location            = var.resource_group_location              # NSG 위치
}

# 3389 포트 인바운드 규칙 생성
resource "azurerm_network_security_rule" "pnp_hub_bastion_vm_nsg_3389_inbound" {
  name                        = "RDPAllow"                                  # 규칙 이름
  priority                    = 1001                                        # 규칙 우선순위
  direction                   = "Inbound"                                   # 인바운드 규칙
  access                      = "Allow"                                     # 허용 규칙
  protocol                    = "Tcp"                                       # TCP 프로토콜
  source_port_range           = "*"                                         # 모든 소스 포트
  destination_port_range      = "3389"                                      # 대상 포트 3389 (RDP)
  source_address_prefix       = "*"                                         # 모든 소스 주소
  destination_address_prefix  = "*"                                         # 모든 대상 주소
  resource_group_name         = azurerm_resource_group.pnp_hub_rg.name      # NSG가 속한 리소스 그룹 이름
  network_security_group_name = azurerm_network_security_group.pnp_hub_bastion_vm_nsg.name # 규칙이 속한 NSG 이름
}

# 네트워크 인터페이스에 NSG 연결
resource "azurerm_network_interface_security_group_association" "connect_bastion_nic_nsg" {
  network_interface_id      = azurerm_network_interface.pnp_hub_bastion_vm_nic.id    # 네트워크 인터페이스 ID
  network_security_group_id = azurerm_network_security_group.pnp_hub_bastion_vm_nsg.id  # NSG ID
}

# Hub Bastion 용도의 VM 생성
resource "azurerm_windows_virtual_machine" "PNP-HUB-BASTION-VM" {
  name                = "PNP-HUB-BS-VM" # 가상 머신 이름
  resource_group_name = azurerm_resource_group.pnp_hub_rg.name # 가상 머신이 속한 리소스 그룹 이름
  location            = var.resource_group_location # 가상 머신 위치
  size                = "Standard_D2s_v3" # 가상 머신 크기
  admin_username      = "iotvmadmin" # 관리자 사용자 이름
  admin_password      = "aprkwhs123!@#" # 관리자 비밀번호
  network_interface_ids = [azurerm_network_interface.pnp_hub_bastion_vm_nic.id] # 가상 머신이 사용할 네트워크 인터페이스 ID
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

# Azure IoT Hub 리소스 생성
resource "azurerm_iothub" "pnp_data_iot_c01" {
  name                = "PNP-DATA-IOT-C01" # IoT Hub 이름
  resource_group_name = azurerm_resource_group.pnp_hub_rg.name # IoT Hub가 속한 리소스 그룹 이름
  location            = var.resource_group_location # IoT Hub 위치

  sku {
    capacity = 1 # 용량 설정
    name     = "S1" # SKU 이름 (S1은 Standard SKU)
  }
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "iothub_private_dns_zone" {
  name                = "privatelink.azure-devices.net"  # Private DNS Zone 이름
  resource_group_name = azurerm_resource_group.pnp_hub_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "iothub_private_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_hub_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.iothub_private_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_hub_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "iothub_servicebus_private_dns_zone" {
  name                = "privatelink.servicebus.windows.net"  # Private DNS Zone 이름
  resource_group_name = azurerm_resource_group.pnp_hub_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "iothub_servicebus_private_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_hub_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.iothub_servicebus_private_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_hub_vnet.id # 가상 네트워크 ID
}

# IoT Hub Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_data_iot_c01_pep" {
  name                = "PNP-HUB-IOT-IOTHUB-PEP"                   # Private Endpoint 이름
  resource_group_name = azurerm_resource_group.pnp_hub_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.resource_group_location  # Private Endpoint 위치
  subnet_id           = azurerm_subnet.pnp_hub_iot_pep_subnet.id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-iothub-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_iothub.pnp_data_iot_c01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["iotHub"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.iothub_private_dns_zone.id, azurerm_private_dns_zone.iothub_servicebus_private_dns_zone.id]  # Private DNS Zone ID
  }
}

# Azure Synapse 용도의 Storage Account 생성
resource "azurerm_storage_account" "pnp_spoke_syn_adls_d01" {
  name                     = "pnpspokesynadlsd01"  # Storage Account 이름
  resource_group_name      = azurerm_resource_group.pnp_spoke_rg.name  # 리소스 그룹 이름
  location                 = var.resource_group_location  # 리소스 그룹 위치
  account_tier             = "Premium"  # 프리미엄 계층
  account_replication_type = "LRS"  # 로컬 복제  
  account_kind             = "BlockBlobStorage"
  is_hns_enabled = true # account_tier 가 Standard 또는 Premium이며, account_kind가 BlockBlobStorage일 때만 사용 가능

  network_rules { # Blob 서비스에 대한 CORS (Cross-Origin Resource Sharing) 규칙을 구성합니다.
    default_action = "Allow"  # 기본 동작 (Deny)
  }
}

# Azure AD 사용자의 Object ID 또는 서비스 주체의 Object ID를 지정
# variable "user_object_id" {
#   description = "권한 부여할 계정 Object Id"
#   type = string
#   default = "derik@megazone.com"
# }

# Azure 리소스 그룹에 리소스 관리자 역할 부여
# resource "azurerm_role_assignment" "example" {
#   principal_id   = var.user_object_id
#   role_definition_name = "Blob Contributor"  # 역할 정의 (Owner, Contributor, Reader 등)
#   scope          = azurerm_storage_account.pnp_spoke_syn_adls_d01.primary_blob_connection_string
# }

# Azure Storage에 대한 Container(filesystem) 생성
resource "azurerm_storage_data_lake_gen2_filesystem" "synapse_filesystem" {
  name               = "synapse"
  storage_account_id = azurerm_storage_account.pnp_spoke_syn_adls_d01.id
}

resource "azurerm_storage_account_network_rules" "pnp_spoke_syn_adls_d01_network_deny" {
  storage_account_id  = azurerm_storage_account.pnp_spoke_syn_adls_d01.id
  default_action      = "Deny"
  depends_on          = [azurerm_storage_data_lake_gen2_filesystem.synapse_filesystem]
}

# Synapse Workspace 정의
resource "azurerm_synapse_workspace" "pnp-spoke-syn-d01" {
  name                = "pnp-spoke-syn-d01"  # Synapse Workspace 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name  # 리소스 그룹 이름
  location            = var.resource_group_location  # 리소스 그룹 위치
  storage_data_lake_gen2_filesystem_id = azurerm_storage_data_lake_gen2_filesystem.synapse_filesystem.id # 연결할 ADLS 스토리지 계정
  sql_administrator_login                                   = "iotsynadmin"
  sql_administrator_login_password                          = "aprkwhs123!@#"
  managed_virtual_network_enabled = true
  
  # Managed Identity 설정 (시스템 할당)
  # Synapse Workspace을 생성할 때 시스템 할당된 관리 ID를 사용하려면
  # 아래의 identity 블록을 주석 해제하고, type을 "SystemAssigned"로 지정합니다.
  identity {
    type = "SystemAssigned"
  }
}

# Synapse SQL Pool 정의
# resource "azurerm_synapse_sql_pool" "dedicated01" {
#   name                = "dedicated01"  # SQL Pool 이름
#   workspace_name      = azurerm_synapse_workspace.pnp-spoke-syn-d01.name  # Synapse Workspace 이름
#   resource_group_name = azurerm_resource_group.pnp_spoke_rg.name  # 리소스 그룹 이름
#   performance_level   = "DW100c"  # 성능 레벨
#   collation           = "SQL_Latin1_General_CP1_CI_AS"  # Collation 설정
# }


# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "pnp_spoke_syn_dev_dns_zone" {
  name                = "privatelink.dev.azuresynapse.net"  # Private DNS Zone 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_syn_dev_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_syn_dev_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_hub_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_syn_dev_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_syn_dev_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_spoke_vnet.id # 가상 네트워크 ID
}

# Blob Storage Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_spoke_syn_dev_pep" {
  name                = "PNP-SPOKE-SYN-DEV-PEP"                   # Private Endpoint 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.resource_group_location  # Private Endpoint 위치
  subnet_id           = azurerm_subnet.pnp_spoke_syn_pep_subnet.id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-syn-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_synapse_workspace.pnp-spoke-syn-d01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["dev"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.pnp_spoke_syn_dev_dns_zone.id]  # Private DNS Zone ID
  }
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "pnp_spoke_syn_sql_dns_zone" {
  name                = "privatelink.sql.azuresynapse.net"  # Private DNS Zone 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_syn_sql_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_syn_sql_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_hub_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_syn_sql_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_syn_sql_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_spoke_vnet.id # 가상 네트워크 ID
}

# Synapse SQL Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_spoke_syn_sql_pep" {
  name                = "PNP-SPOKE-SYN-SQL-PEP"                   # Private Endpoint 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.resource_group_location  # Private Endpoint 위치
  subnet_id           = azurerm_subnet.pnp_spoke_syn_pep_subnet.id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-syn-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_synapse_workspace.pnp-spoke-syn-d01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["sql"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.pnp_spoke_syn_sql_dns_zone.id]  # Private DNS Zone ID
  }
}

# Synapse SQL On Demand Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_spoke_syn_ondemand_pep" {
  name                = "PNP-SPOKE-SYN-ONDEMAND-PEP"                   # Private Endpoint 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.resource_group_location  # Private Endpoint 위치
  subnet_id           = azurerm_subnet.pnp_spoke_syn_pep_subnet.id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-syn-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_synapse_workspace.pnp-spoke-syn-d01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["sqlondemand"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.pnp_spoke_syn_sql_dns_zone.id]  # Private DNS Zone ID
  }
}

# Private Link Hub 정의
resource "azurerm_synapse_private_link_hub" "pnp_hub_plh_c01" {
  name                = "pnphubplhc01"  # Private Link Hub 이름
  resource_group_name = azurerm_resource_group.pnp_hub_rg.name  # 리소스 그룹 이름
  location            = var.resource_group_location  # 리소스 그룹 위치
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "pnp_hub_plh_private_dns_zone" {
  name                = "privatelink.azuresynapse.net"  # Private DNS Zone 이름
  resource_group_name = azurerm_resource_group.pnp_hub_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_hub_plh_c01_private_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_hub_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_hub_plh_private_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_hub_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_hub_plh_c01_private_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_hub_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_hub_plh_private_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_spoke_vnet.id # 가상 네트워크 ID
}

# Synapse Private Link Web Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_hub_plh_web_pep" {
  name                = "PNP-HUB-PLH-WEB-PEP"                   # Private Endpoint 이름
  resource_group_name = azurerm_resource_group.pnp_hub_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.resource_group_location  # Private Endpoint 위치
  subnet_id           = azurerm_subnet.pnp_hub_plh_pep_subnet.id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-iothub-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_synapse_private_link_hub.pnp_hub_plh_c01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["web"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.pnp_hub_plh_private_dns_zone.id]  # Private DNS Zone ID
  }
  
}

# Data Lake 용도의 Storage Account 생성
resource "azurerm_storage_account" "pnp_spoke_data_adls_d01" {
  name                     = "pnpspokedataadlsd01"  # Storage Account 이름
  resource_group_name      = azurerm_resource_group.pnp_spoke_rg.name  # 리소스 그룹 이름
  location                 = var.resource_group_location  # 리소스 그룹 위치
  account_tier             = "Premium"  # 프리미엄 계층
  account_replication_type = "LRS"  # 로컬 복제  
  account_kind             = "BlockBlobStorage"
  is_hns_enabled = true # account_tier 가 Standard 또는 Premium이며, account_kind가 BlockBlobStorage일 때만 사용 가능

  network_rules { # Blob 서비스에 대한 CORS (Cross-Origin Resource Sharing) 규칙을 구성합니다.
    default_action = "Deny"  # 기본 동작 (Deny)
  }
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "pnp_spoke_adls_blob_dns_zone" {
  name                = "privatelink.blob.core.windows.net"  # Private DNS Zone 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_adls_blob_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_adls_blob_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_hub_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_adls_blob_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_adls_blob_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_spoke_vnet.id # 가상 네트워크 ID
}

# Blob Storage Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_spoke_data_st_blob_pep" {
  name                = "PNP-SPOKE-DATA-ST-BLOB-PEP"                   # Private Endpoint 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.resource_group_location  # Private Endpoint 위치
  subnet_id           = azurerm_subnet.pnp_spoke_data_st_pep_subnet.id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-storage-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_storage_account.pnp_spoke_data_adls_d01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["blob"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.pnp_spoke_adls_blob_dns_zone.id]  # Private DNS Zone ID
  }
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "pnp_spoke_adls_web_dns_zone" {
  name                = "privatelink.web.core.windows.net"  # Private DNS Zone 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_adls_web_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_adls_web_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_hub_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_adls_web_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_adls_web_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_spoke_vnet.id # 가상 네트워크 ID
}

# Blob Storage Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_spoke_data_st_web_pep" {
  name                = "PNP-SPOKE-DATA-ST-WEB-PEP"                   # Private Endpoint 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.resource_group_location  # Private Endpoint 위치
  subnet_id           = azurerm_subnet.pnp_spoke_data_st_pep_subnet.id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-storage-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_storage_account.pnp_spoke_data_adls_d01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["web"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.pnp_spoke_adls_web_dns_zone.id]  # Private DNS Zone ID
  }
}

# Private DNS Zone 정의
resource "azurerm_private_dns_zone" "pnp_spoke_adls_dfs_dns_zone" {
  name                = "privatelink.dfs.core.windows.net"  # Private DNS Zone 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name  # 리소스 그룹 이름
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_adls_dfs_dns_zone_link_hub" {
  name                  = "link_hub"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_adls_dfs_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_hub_vnet.id # 가상 네트워크 ID
}

# Private DNS Zone과 가상 네트워크 링크 설정
resource "azurerm_private_dns_zone_virtual_network_link" "pnp_spoke_adls_dfs_dns_zone_link_spoke" {
  name                  = "link_spoke"                        # 링크 이름
  resource_group_name   = azurerm_resource_group.pnp_spoke_rg.name   # 리소스 그룹 이름
  private_dns_zone_name = azurerm_private_dns_zone.pnp_spoke_adls_dfs_dns_zone.name  # Private DNS Zone 이름
  virtual_network_id    = azurerm_virtual_network.pnp_spoke_vnet.id # 가상 네트워크 ID
}

# Blob Storage Private Endpoint 생성
resource "azurerm_private_endpoint" "pnp_spoke_data_st_dfs_pep" {
  name                = "PNP-SPOKE-DATA-ST-DFS-PEP"                   # Private Endpoint 이름
  resource_group_name = azurerm_resource_group.pnp_spoke_rg.name   # Private Endpoint가 속한 리소스 그룹 이름
  location            = var.resource_group_location  # Private Endpoint 위치
  subnet_id           = azurerm_subnet.pnp_spoke_data_st_pep_subnet.id             # Private Endpoint를 할당할 서브넷 ID

  # 연결된 서비스 구성
  private_service_connection {
    name                           = "example-iothub-pe-connection"  # Private Endpoint 연결 이름
    private_connection_resource_id = azurerm_storage_account.pnp_spoke_data_adls_d01.id # Private Endpoint 연결 리소스 ID
    is_manual_connection           = false                          # 수동 연결 여부
    subresource_names = ["dfs"] # Private Endpoint 하위 리소스 
  }

  private_dns_zone_group {
    name                           = "default"  # Private DNS Zone 연결 이름
    private_dns_zone_ids            = [azurerm_private_dns_zone.pnp_spoke_adls_dfs_dns_zone.id]  # Private DNS Zone ID
  }
}