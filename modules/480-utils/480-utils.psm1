function 480Banner(){
    Write-host "⠀⠀⠀⠀
         ⠀⢀⣏⣉⣿⣿⣿⣿⣿⣦⡠⠔⠒⣒⡶⠶⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⢸⡟⣿⣿⣿⣿⣿⣿⣿⣷⣤⠎⠁⠀⠀⢸⠈⢢⠀⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠈⣟⠻⣛⠿⠯⢍⡙⠛⠛⠿⣦⡀⠠⠀⣸⠀⠀⡇⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⢨⠋⠀⠀⠀⠀⠈⠳⣀⠞⠁⠀⠀⠀⠀⠑⢄⡹⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⢀⣀⠀⡏⠀⣀⠀⠀⠀⠀⠀⠈⡅⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⢇⠀⠀⠀⠀⢿⣿⢃⢇⢸⣿⡷⠀⠀⠀⠀⢠⠃⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⢀⠎⠒⠄⣀⡀⣀⠠⠊⠈⠢⣀⠀⠀⠀⠀⡠⠚⡄⠀⠀⠀⠀⠀⠀
    ⠀⠀⠀⡠⠒⡌⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠁⠀⠀⢱⢀⡀⠀⠀⠀⠀
    ⠀⠀⠀⠁⠀⠇⠀⠀⠀⠀⢸⣑⠶⠶⠲⠶⢶⣲⠆⠀⠀⠀⠀⢸⠀⠸⠐⠂⠀⠀
    ⠀⠀⠀⠀⠀⠘⡀⠀⠀⠀⠘⡅⠀⠀⠀⠀⠀⡝⠀⠀⠀⠀⠀⡜⠀⠀⠀⠀⠀⠀
    ⠈⢆⠀⠀⠀⠀⠘⠤⡀⠀⠀⠘⠤⣀⣀⡠⠞⠀⠀⠀⠀⡠⠊⠀⠀⠀⠀⠀⠀⠂
    ⠀⠀⠣⡀⠀⠀⠀⠀⣼⣷⣦⣤⣤⣄⣀⣀⣀⣤⣤⣶⣿⣦⠀⠀⠀⠀⠀⡠⠂⠀
    ⠀⠀⠀⠈⠂⢄⡀⡸⣿⡿⠟⢿⣿⣿⣿⡿⠟⢿⣿⣿⣿⡿⢃⠀⢀⠠⠊⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⢨⠁⠉⢀⣤⡀⠙⠟⠉⢀⣄⠀⠉⠛⠉⣀⣼⡒⠁⠀⠀⠀⠀⠀
    ⠀⠀⠀⠀⠀⠀⢸⣷⣾⣿⣿⣿⣦⣤⣶⣿⣿⣷⣦⣤⣾⣿⣿⡇------Hello SYS480-Devops From Dean"
}

function 480Connect([string] $server){
    $conn = $global:DefaultVIServer
    #are we already connected
    if ($conn){
        $msg = 'Already Connected to: {0}' -f $conn

        Write-Host -ForegroundColor Green $msg
    }
    else{
        $conn = Connect-VIServer -Server $server
        #if this fails, let Connect-VIServer handle the encryption
    }
}

function Get-480Config([string] $config_path){
    Write-Host "Reading " $config_path
    $conf = $null
    if (Test-Path $config_path){
        $conf = (Get-Content -Raw -Path $config_path | ConvertFrom-Json)
        $msg = "Using configuration at {0}" -f $config_path
        Write-Host -ForegroundColor Green $msg
    }
    else{
        Write-Host -ForegroundColor "Yellow" "No Configurtion"
    }
    return $conf
}

function Select-VM([string] $folder){
    $selected_vm=$null
    try{
        $vms = Get-VM -Location $folder
        $index = 1
        foreach($vm in $vms){
            Write-Host [$index] $vm.name
            $index+=1
        }
        $pick_index = Read-Host "Which index number [x] do you wish to pick?"
        if($pick_index -ge $index){
            return "Error, you selected a VM that does not exist" 
        }        
        $selected_vm = $vms[$pick_index -1]
        Write-Host "You picked " $selected_vm.name
        #note this is a full on vm object that we can interact with
        return $selected_vm
    }

    catch{
        Write-Host "Invalid Folder: $folder" -ForegroundColor "Red"
    }
}

function Cloner([string] $shallBeCloned, [string] $baseVM, [string] $newVMName){
    try{
      Write-Host $shallBeCloned
      Write-Host $baseVM
      Write-Host $newVMName
    
      $vm = Get-VM -Name $shallBeCloned
      $snapshot = Get-Snapshot -VM $vm -Name $baseVM
      $vmhost = Get-VMHost -Name "192.168.7.26"
      $ds = Get-DataStore -Name "datastore1-super16"
      $linkedClone = "{0}.linked" -f $vm.name
      $linkedVM = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
      $newvm = New-VM -Name "$newVMName.base" -VM $linkedVM -VMHost $vmhost -Datastore $ds
      $newvm | New-Snapshot -Name "Base"
      #$linkedvm | Remove-VM
    }
    catch {
      Write-Host "ERROR"
      
    }
  }

#Milestone 6
function Create_vSwitch([string] $vSwitchName, [string] $portGroupName){
    try{
        Write-Host $vSwitchName
        Write-Host $portGroupName

        New-VirtualSwitch -VMHost '192.168.7.26' -Name $vSwitchName
        Get-VMHost '192.168.7.26' | Get-VirtualSwitch -name $vSwitchName | New-VirtualPortGroup -Name $portGroupName
    }
    catch{
        Write-Host "Error with virtual switch and port group creation."
        
    }
}

function Get-IP([string] $vCenterServer, [string] $vmName){
    $vm = Get-VM -Name $vmName
    Get-VM -Name $vm | Select-Object Name, @{N="IP Address";E={@($_.Guest.IPAddress[0])}}
    Get-NetworkAdapter -Server $vCenterServer -VM $vm.Name | Format-Table -AutoSize
}

function linkedCloner([string] $shallBeCloned, [string] $baseVM, [string] $newVMName){
    Write-Host $shallBeCloned # = Select-VM -folder "BASEVM"
    Write-Host $baseVM
    Write-Host $newVMName # = Read-Host "Enter new vm name"
    
    
    $vm = Get-VM -Name $shallBeCloned
    $snapshot = Get-Snapshot -VM $vm -Name $baseVM
    $vmhost = Get-VMHost -Name "192.168.7.26"
    $ds = Get-DataStore -Name "datastore1-super16"
    $linkedClone = $newVMName
    $linkedVM = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
}
<#
function VMStatus([string] $vmToCheck){
    Get-VM -Name $vmToCheck
}
#>
function VMStart([string] $vmToStart){
    try{
        Get-VM -Name $vmToStart
        Start-VM -VM $vmToStart -Confirm
    }
    catch {
        Write-Host "Your VM is already on"
    }
}
function VMStop([string] $vmToStop){
    try{
        Get-VM -Name $vmToStop
        Stop-VM -VM $vmToStop -Confirm
    }
    catch {
        Write-Host "Your VM is already off"
    }
}
function Set-VMNetwork([string] $vmName, [string] $networkName, [string] $esxi_host_name, [string] $vcenter_server){
    $vm = Get-VM -Name $vmName
    Get-NetworkAdapter -vm $vm | Set-NetworkAdapter -NetworkName $networkName
}

function New-linkedCloner([string] $shallBeCloned, [string] $newVMName){
    Write-Host $shallBeCloned
    Write-Host $newVMName
    
    $vm = Get-VM -Name $shallBeCloned
    $snapshot = Get-Snapshot -VM $vm -Name "Base"
    $vmhost = Get-VMHost -Name "192.168.7.26"
    $ds = Get-DataStore -Name "datastore1-super16"
    $linkedClone = $newVMName
    $linkedVM = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
  }



# Milestone 9
function New-linkedCloner2([string] $shallBeCloned, [string] $newVMName, [string] $datastoreNum){
    Write-Host $shallBeCloned
    Write-Host $newVMName
    Write-Host $datastoreNum
    
    $vm = Get-VM -Name $shallBeCloned
    $snapshot = Get-Snapshot -VM $vm -Name "Base"
    $vmhost = Get-VMHost -Name "192.168.7.26"
    $ds = Get-DataStore -Name $datastoreNum
    $linkedClone = $newVMName
    $linkedVM = New-VM -LinkedClone -Name $linkedClone -VM $vm -ReferenceSnapshot $snapshot -VMHost $vmhost -Datastore $ds
  }

function SetIP([string] $VMName, [string] $interfaceIndex, [string] $IPAddr, [string] $netmask, [string] $gateway, [string] $nameserver, [string] $guestUser, [string] $guestPass){ 
    Get-NetworkAdapter -VM $VMName | Set-NetworkAdapter -NetworkName "BLUE1-LAN"

    $guestPass = Read-Host -Prompt "Enter password"
    Write-Host $VMName
    Write-Host $interfaceIndex
    Write-Host $IPAddr
    Write-Host $netmask
    Write-Host $gateway
    Write-Host $nameserver
    Write-Host $guestUser
    Write-Host $guestPass
    
    $scriptIP = "netsh interface ip set address name='$interfaceIndex' static $IPAddr $netmask $gateway"
    Invoke-VMScript -VM $VMName -ScriptText $scriptIP -GuestUser $guestUser -GuestPassword $guestPass -ScriptType bat -WarningAction 0

    $scriptIP = "netsh interface ip set address name='Ethernet0' static 10.0.5.7 255.255.255.0 10.0.5.2"
    Invoke-VMScript -VM "dc-blue2" -ScriptText $scriptIP -GuestUser "deployer" -GuestPassword "passworddean$" -ScriptType bat -WarningAction 0


    $scriptDNS1 = 'netsh interface ip set dns name=`"Ethernet0" static 10.0.5.2'
    Invoke-VMScript -VM $VMName -ScriptText $scriptDNS1 -GuestUser $guestUser -GuestPassword $guestPass -ScriptType bat -WarningAction 0

    $scriptDNS2 = 'netsh interface ipv4 set dns name=`"Ethernet1" static 8.8.8.8'
    Invoke-VMScript -VM $VMName -ScriptText $scriptDNS2 -GuestUser $guestUser -GuestPassword $guestPass -ScriptType bat -WarningAction 0
}