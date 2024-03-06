Import-Module '480-utils' -Force
480Banner
$conf = Get-480Config - config_path = "/home/dean/Documents/GitHub/tech-journal1/480.json"
480Connect -server $conf.vcenter_server
Write-Host "Selecting your VM"
Select-VM -folder "BASEVM"
$db = Select-DB
$snapshot = Get-Snapshot -VM $vm.Name | Select-Object -First 1
$network = Select-Network -vm $vm.Name
FullClone -vm $vm.Name -snap $snapshot -vmhost $config.esxi_host -ds $db -network $network