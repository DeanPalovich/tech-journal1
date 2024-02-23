Get-VM
$basevm = Read-Host -prompt "Enter name of vm to clone.
$vm = Get-VM -Name $basevm
$snapshot = Get-Snapshot -VM $vm -Name "base"
$vmhostname =Read-Host -prompt "enter name of vm host(192.168.7.26)."
$vmhost = Get-VMHost -Name $vmhostname
$dsname = Read-Host -prompt "Enter Name of  Datastore to use(datastore1super16)."
$ds = Get-DataStore -Name $dsname
$linkedClone = "{0}.linked" -f $vm.name
$linkedvm = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
$vmname = Read-Host -prompt "Enter name for your new VM."
$newvm = New-VM -Name $vmname -VM $linkedvm -VMHost $vmhost -Datastore $ds
$newvm | New-Snapshot -Name "base"
$linkedvm | Remove-VM
