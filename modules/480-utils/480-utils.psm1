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
      $linkedvm | Remove-VM
    }
    catch {
      Write-Host "ERROR"
      exit
    }
  }

