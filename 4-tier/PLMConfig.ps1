#Import-Module 'C:\Program Files (x86)\Microsoft SDKs\Windows Azure\PowerShell\ServiceManagement\Azure\Azure.psd1'

# Prior to running this script you need to (1) run Add-AzureAccount, (2) create a storage account and (3) create
#  a VirtualNetwork all in the same Region

# Retrieve with Get-AzureSubscription 
$subscriptionName = '[Subscription Name]'
$storageAccountName = '[Storage Account Name]'
$storagetorageKey = '[Enter Key]'

$user = 'plmuser'
$pwd = 'P@ssw0rd!'
$Location = 'East US'

#Vnet - Needs to be created prior to calling this script
$RegionalVNet = '[VNET NAME]'
$subnetName = '[SUBNET NAME]'

$availSet1 = 'PLM1'
$availSet2 = 'PLM2'
$serviceRoot = 'plmeastPROD'
# Retreive with Get-AzureStorageAccount 

 
# Specify the storage account location

Set-AzureSubscription -SubscriptionName $subscriptionName -CurrentStorageAccount $storageAccountName 
 
# Select the correct subscription (allows multiple subscription support) 
Select-AzureSubscription -SubscriptionName $subscriptionName 

# If you need a new storage account
#New-AzureStorageAccount -StorageAccountName $serviceRoot -Location $Location
#Set-AzureSubscription -SubscriptionName $subscriptionName  -CurrentStorageAccount $serviceRoot



# Image Name is hardcoded but use this command to re-validate the vhd file
# - OR - 
# Set image name to a pre-existing vhd file in your storage account
# - OR - 
# Use an image that you have syspreped and added to your image gallery

#$ImageName = (Get-AzureVMImage | 
#                Where { $_.ImageFamily -eq "Windows Server 2012 R2 Datacenter" } | 
#                sort PublishedDate -Descending | Select-Object -First 1).ImageName
$ImageName = 'a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-R2-201405.01-en.us-127GB.vhd'

#$DBImageName = (Get-AzureVMImage |
#              Where { $_.ImageFamily -eq "SQL Server 2012 SP1 Enterprise on Windows Server 2012" } | 
#                sort PublishedDate -Descending | Select-Object -First 1).ImageName
$DBImageName = 'fb83b3509582419d99629ce476bcb5c8__SQL-Server-2012-SP1-11.0.3430.0-Enterprise-ENU-Win2012-cy14su05'                
### Create Cloud Services ###
#New-AzureService -AffinityGroup 'mjzAG' -ServiceName $serviceRoot

### Create VMs ###

## Web ##
$webService = $serviceRoot + "WEB"
$webVM1Name = 'web1';
$webVM2Name = 'web2';

New-AzureService -ServiceName $webService -Location $Location 

# Configure VM: Add UserID & Password, Size, Image, Name, IP address, Subnet, VNet Assignment, 
# and Public loadbalanced Endpoint
$webVM1config = New-AzureVMConfig -Name $webVM1Name -InstanceSize "Small" -ImageName $ImageName `
    -AvailabilitySetName $availSet1 |
Add-AzureProvisioningConfig -Windows -AdminUsername $user -Password $pwd |
# Set-AzureStaticVNetIP -IPAddress "10.0.0.15" |
Set-AzureSubnet 'Subnet-1' |
Add-AzureEndpoint -Name "HttpIn" `
-Protocol "tcp" -PublicPort 80 -LocalPort 8080 -LBSetName "WebFarm" -ProbePort 80 `
-ProbeProtocol "http" -ProbePath '/'

$webVM2config = New-AzureVMConfig -Name $webVM2Name -InstanceSize "Small" -ImageName $ImageName `
    -AvailabilitySetName $availSet2 |
Add-AzureProvisioningConfig -Windows -AdminUsername $user -Password $pwd |
# Set-AzureStaticVNetIP -IPAddress "10.0.0.16" |
Set-AzureSubnet 'Subnet-1' |
Add-AzureEndpoint -Name "HttpIn" `
-Protocol "tcp" -PublicPort 80 -LocalPort 8080 -LBSetName "WebFarm" -ProbePort 80 `
-ProbeProtocol "http" -ProbePath '/'


## PLM Servers ##

$plmService = $serviceRoot + "PLM"
$plmVM1Name = 'plmserver1';
$plmVM2Name = 'plmserver2';
$plmVM3Name = 'plmserver3';

New-AzureService -ServiceName $plmService -Location $Location  

$plmVM1config = New-AzureVMConfig -Name $plmVM1Name -InstanceSize "Small" -ImageName $ImageName `
    -AvailabilitySetName $availSet1 |
Add-AzureProvisioningConfig -Windows -AdminUsername $user -Password $pwd |
# Set-AzureStaticVNetIP -IPAddress "10.0.0.17" |
Set-AzureSubnet 'Subnet-1' 

$plmVM2config = New-AzureVMConfig -Name $plmVM2Name -InstanceSize "Small" -ImageName $ImageName `
    -AvailabilitySetName $availSet1 |
Add-AzureProvisioningConfig -Windows -AdminUsername $user -Password $pwd |
#Set-AzureStaticVNetIP -IPAddress "10.0.0.18" |
Set-AzureSubnet 'Subnet-1' 

$plmVM3config = New-AzureVMConfig -Name $plmVM3Name -InstanceSize "Small" -ImageName $ImageName `
    -AvailabilitySetName $availSet2 |
Add-AzureProvisioningConfig -Windows -AdminUsername $user -Password $pwd |
#Set-AzureStaticVNetIP -IPAddress "10.0.0.19" |
Set-AzureSubnet 'Subnet-1'



## Publishing ##

$pubService = $serviceRoot + "PUB"
$pubVM1Name = 'pubserver1';
$pubVM2Name = 'pubserver2';

New-AzureService -ServiceName $pubService -Location $Location  


$pubVM1config = New-AzureVMConfig -Name $pubVM1Name -InstanceSize "Small" -ImageName $ImageName `
    -AvailabilitySetName $availSet2 |
Add-AzureProvisioningConfig -Windows -AdminUsername $user -Password $pwd |
#Set-AzureStaticVNetIP -IPAddress "10.0.0.20" |
Set-AzureSubnet 'Subnet-1' 

$pubVM2config = New-AzureVMConfig -Name $pubVM2Name -InstanceSize "Small" -ImageName $ImageName `
    -AvailabilitySetName $availSet2 |
Add-AzureProvisioningConfig -Windows -AdminUsername $user -Password $pwd |
#Set-AzureStaticVNetIP -IPAddress "10.0.0.21" |
Set-AzureSubnet 'Subnet-1' 


## DB ##

$dbService = $serviceRoot + "DB"
$dbVM1Name = 'dbServer1';
$dbVM2Name = 'dbServer2';

New-AzureService -ServiceName $dbService -Location $Location  

$dbVM1config = New-AzureVMConfig -Name $dbVM1Name -InstanceSize "Small" -ImageName $ImageName `
    -AvailabilitySetName $availSet1 |
Add-AzureProvisioningConfig -Windows -AdminUsername $user -Password $pwd |
#Set-AzureStaticVNetIP -IPAddress "10.0.0.22" |
Set-AzureSubnet 'Subnet-1' 


$dbVM2config = New-AzureVMConfig -Name $dbVM2Name -InstanceSize "Small" -ImageName $ImageName `
    -AvailabilitySetName $availSet2 |
Add-AzureProvisioningConfig -Windows -AdminUsername $user -Password $pwd |
#Set-AzureStaticVNetIP -IPAddress "10.0.0.23" |
Set-AzureSubnet 'Subnet-1' 

#Create VMs
New-AzureVM -ServiceName $webService -VMs $webVM1config, $webVM2config -VNetName $RegionalVNet -WaitForBoot

New-AzureVM -ServiceName $plmService -VMs $plmVM1config, $plmVM2config, $plmVM3config -VNetName $RegionalVNet -WaitForBoot

New-AzureVM -ServiceName $pubService -VMs $pubVM1config, $pubVM2config -VNetName $RegionalVNet -WaitForBoot

New-AzureVM -ServiceName $dbService -VMs $dbVM1config, $dbVM2config -VNetName $RegionalVNet -WaitForBoot

