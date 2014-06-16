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

#Vnet
$RegionalVNet = 'mjzVN'

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

$webService = $serviceRoot + "WEB"
$webVM1Name = 'web1'
$webVM2Name = 'web2'

$plmService = $serviceRoot + "PLM"
$plmVM1Name = 'plmserver1'
$plmVM2Name = 'plmserver2'
$plmVM3Name = 'plmserver3'

$pubService = $serviceRoot + "PUB"
$pubVM1Name = 'pubserver1'
$pubVM2Name = 'pubserver2'


$dbService = $serviceRoot + "DB"
$dbVM1Name = 'dbServer1'
$dbVM2Name = 'dbServer2'

Start-AzureVM -ServiceName $webService -Name $webVM1Name
Start-AzureVM -ServiceName $webService -Name $webVM2Name

Start-AzureVM -ServiceName $plmService -Name $plmVM1Name
Start-AzureVM -ServiceName $plmService -Name $plmVM2Name
Start-AzureVM -ServiceName $plmService -Name $plmVM3Name

Start-AzureVM -ServiceName $pubService -Name $pubVM1Name
Start-AzureVM -ServiceName $pubService -Name $pubVM2Name

Start-AzureVM -ServiceName $dbService -Name $dbVM1Name
Start-AzureVM -ServiceName $dbService -Name $dbVM2Name
