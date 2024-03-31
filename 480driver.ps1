Import-Module '480-utils' -Force

#Call the banner function
480Banner

$conf = Get-480Config -config_path '/home/dean/Documents/GitHub/tech-journal1/480.json'
480Connect -server $conf.vcenter_server


#Select VM Function
Write-Host "Selecting your VM"
Select-VM -folder "BASEVM"



# Call the cloner
Write-Host "Clone a VM"
$shallBeCloned = Read-Host -Prompt "Enter the name of the vm you wish to clone"
$baseVM = Read-Host -Prompt "Enter the name of the base vm of the vm you wish to clone"
$newVMName = Read-Host -Prompt "Enter the name of your new vm"
Cloner -shallBeCloned $shallBeCloned -baseVM $baseVM -newVMName $newVMName
Get-VM

# Milestone6-Blue1
# Create Virtual Machine and Port Group
Write-Host "Create a new virtual switch and port group"
$vSwitchName = Read-Host -Prompt "Enter the name of the virtual switch you wish to create"
$portGroupName = Read-Host -Prompt "Enter the name of the port group you wish to create"
Create_vSwitch -vSwitchName $vSwitchName -portGroupName $portGroupName
Get-VirtualSwitch
# Create vSwitch == New-Network
# Ran, new switch and port BLUE1-LAN, 



# Get IP Info
$vmName = Read-Host -Prompt "Enter the name of the vm you wish to get the IP of"
Get-IP -vCenterServer $conf.vcenter_server -vmName $vmName



# Milestone 6.2 - Deliverable 2
# use set network function after cloner instead of doing it all at once
# Call the cloner

#linkedCloner -shallBeCloned '480-fw-2.base'-baseVM 'Base' -newVMName 'fw-blue3'
#Set-VMNetwork -vmName 'fw-blue3' -networkName '480-WAN-PortGroup' -esxi_host_name $conf.esxi_host_name -vcenter_server $conf.vcenter_server
#Get-VM



# Milestone 6.2 - Deliverable 3
# Create Start and Stop Function
#$vmToCheck = Read-Host -Prompt "Enter the name of the virtual machine you would like to check the status of"
#VMStatus -vmToCheck $vmToCheck

$vmToStart = Read-Host -Prompt "Enter the name of the virtual machine you would like to start"
VMStart -vmToStart $vmToStart
Get-VM

$vmToStop = Read-Host -Prompt "Enter the name of the virtual machine you would like to stop"
VMStop -vmToStop $vmToStop
Get-VM



# Milestone 6.2 - Deliverable 4
#Set network adapter
Get-VM
$vmName = Read-Host -Prompt "Enter the name of the virtual machine you would like to select"
#Get-VirtualNetwork
$networkName = Read-Host -Prompt "Enter the name of the network you would like to select"
Set-VMNetwork -vmName $vmName -networkName $networkName -esxi_host_name $conf.esxi_host_name -vcenter_server $conf.vcenter_server
#network name = BLUE1-LAN

