function 480Banner()
{
    Write-host "Hello SYS480 DevOps"
}

function 480Connect([string] $server)
{
    $conn = $global:DefaultVIServer
    if ($conn){
        $msg = "Already Connected to: {0}" -f $conn

        Write-Host -ForegroundColor Green $msg
    }else
    {
        $conn = Connect-VIServer -Server $server
    }

}

Function Get-480Config([string] $config_path)
{
    
    $conf=$null
    if(Test-Path $config_path)
    {
        $conf = (Get-Content -Raw -Path $config_path | ConvertFrom-Json)
        $msg = "Using Configuration at {0}" -f $config_path
        Write-Host -ForegroundColor "Green" $msg 
    } else 
    {
        Write-Host -ForegroundColor "Yellow" "No Configuration"
    }
    return $conf
}
Function ErrorHandling($index, $maxIndex)
{
    if ($index -ge 1 -and $index -le $maxIndex)
    {
        return $true
    }
    else {
        Write-Host "Invlaid index. Please enter an index between 1 and $maxIndex" -ForegroundColor "yellow"
        return $false
    }
}
Function Select-VM([string] $folder)
{
    Write-Host "Select VM"
    $Selected_vm=$null
    try 
    {
        $vms = Get-VM -Location $folder
        $index = 1
        if ($vms.Count -eq 0){
            Write-Host "No VMS found " -ForegroundColor "Red"
            return $null
        }
        foreach($vm in $vms)
        {
            Write-Host [$index] $vm.Name
            $index+=1
        }    
        
        do
        {
            $pick_index =Read-Host "which index number [x] do you wish to pick?"
            if ($pick_index -eq "") {
                Write-Host "Please enter a valid index." -ForegroundColor "yellow"
                Continue
            }
            if (ErrorHandling -index $pick_index -maxIndex $vms.Count)
            {
                $Selected_vm = $vms[$pick_index - 1]
                Write-Host "you picked $($Selected_vm.Name)"
            }
        }while (-not $Selected_vm)
        return $Selected_vm
        }
        catch
        {
        Write-Host "Invalid Folder: $folder" -ForegroundColor "Red"
        }
}
function Select-DB()
{
    Write-Host "Select your Datastore "
   $selected_db = $null

   $datastores = Get-Datastore
   $index = 1

   if ($datastores.Count -eq 0) 
   {
    Write-Host "No Datastore are found. " -ForegroundColor "Red"
    
   }

   foreach ($ds in $datastores)
    {
        Write-Host [$index] $ds.Name
        $index += 1
    }
   
    do 
    {
        $choice = Read-Host "which index number [x] do you wish to pick?"
        if (ErrorHandling -index $choice -maxIndex $datastores.Count) {
            $selected_db = $datastores[$choice - 1]
            Write-Host "You picked " $selected_db.Name
        }
    } while ($null -eq $selected_db) 

    return $selected_db
    
}
function Select-Network([string] $vm)
{
    Write-Host "Select your Network "
    $selected_net=$null

    $networks = Get-NetworkAdapter -VM $vm
    $index=1

    if ($networks.Count -eq 0) 
    {
        Write-Host "No VMs were found " -ForegroundColor "Red"
        return $null
    }

    foreach($net in $networks)
    {
        Write-Host [$index] $net.Name
        $index+=1
    }

    do
    {
        $choice = Read-Host "Which index number [x] do you wish to pick?"
        if (ErrorHandling -index $choice -maxIndex $networks.Count)
        {
            $selected_net = $networks[$choice - 1]
            Write-Host "You picked " $selected_net.Name
        }
    } While ($null -eq $selected_net)
    {
        return $selected_net
    }

}

function FullClone([string] $vm, $snap, $vmhost, $ds, $network)
{
    $linkedName = "{0}.linked" -f $vm
    $linkedVM = New-VM -LinkedClone -Name $linkedName -VM $vm -ReferenceSnapshot $snap -VMHost $vmhost -Datastore $ds
    $newvmname = Read-Host -prompt "Enter name for new VM"
    $newVM = -Name $newvmname -VM $linkedVM -VMHost $VMHost $vmhost -Datastore $ds
    $newVM | Set-NetworkAdapter -NetworkName $network
    $newVM | New-Snapshot -Name "Base"
    $linkedvm | Remove-VM
    $powerOp = Read-Host "would you like turn on the machine" $newVM.Name "(Y/N)?"
    if ($powerOp -match "^[yY]$")
    {
        Start-VM -VM $newVM
        Write-Host $newVM.Name "has turned on"
    } else
    {
        break
    }
}


    
