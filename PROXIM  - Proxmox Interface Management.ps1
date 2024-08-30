function Find-Module {
    if ($null -eq (Get-Module -ListAvailable | Where-Object { $_.Name -eq "Corsinvest.ProxmoxVE.Api" })) {
        Write-Host "Installing module"
        Install-Module -Name Corsinvest.ProxmoxVE.Api -Force -Scope CurrentUser
    }
}

function Get-PVECredential {
    while ($true) {
        $PVEIPServer = Read-Host "Enter the IP address of your Proxmox server"

        if ($PVEIPServer -notmatch '^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$') {
            Write-Host "Invalid IP address. Please enter a valid IP address."
        } 
        else {
            break
        }
    }

    $choice = Read-Host "For authentication using an API Token, enter '0'; otherwise, leave it blank"

    if ($choice -eq '0') {
        $PVEApiKey = Read-Host "Enter your API Token"

        try {
            $PveTicket = Connect-PveCluster -HostsAndPorts $PVEIPServer -ApiToken $PVEApiKey -SkipCertificateCheck -ErrorAction Stop
        } 
        catch 
        {
            Write-Host "Error: $_"
            Get-PVECredential
        }

        return $PveTicket
    } 
    else {
        $PVEUserName = Read-Host "Enter your user name"

        try {
            $PveTicket = Connect-PveCluster -HostsAndPorts $PVEIPServer -Credentials (Get-Credential -UserName $PVEUserName) -SkipCertificateCheck -ErrorAction Stop
        } 
        catch {
            Write-Host "Error: $_"
            Get-PVECredential
        }

        return $PveTicket
    }
}

function Show-Menu {
    
    Write-Host "Please select an option:"
    Write-Host "1 - Create LXC"
    Write-Host "2 - Groups & Users"
    Write-Host "3 - Exit"

    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        1 {New-LXC}
        2 {Show-GroupsUsersMenu}
        3 { break }
        default {
            Write-Host " "
            Write-Host " "
            Write-Host "Invalid choice. Please try again."
            Show-Menu
        }
    }
}

function New-LXC {
    
    #List Templates
    $vztmplContent = ((get-pvenodesStorageContent -Node pve-01 -Storage local).ToData() | Where-Object content -eq "vztmpl")

    Write-Host "Here are the templates currently installed on your Proxmox instance"
    $counter = 1
    foreach ($tmpl in $vztmplContent.volid)
    {
        Write-Host " $counter -> "($tmpl -split "/")[1]
        $counter++
    }

}


function Show-GroupsUsersMenu {
    
    Write-Host "Please select an option:"
    Write-Host "1 - Create Groups"
    Write-Host "2 - List Groups"
    Write-Host "3 - Create Users"
    Write-Host "4 - List Users"
    Write-Host "5 - Exit"

    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        1 {Show-GroupsMenu} #ok
        2 {Get-Groups} #OK
        3 {}
        4 {}
        5 { Show-Menu }
        default {
            Write-Host " "
            Write-Host " "
            Write-Host "Invalid choice. Please try again."
            Write-Host " "
            Write-Host " "
            Show-GroupsUsersMenu
        }
    }
}

function Show-GroupsMenu {
    
    Write-Host "Please select an option:"
    Write-Host "1 - Import and Create Groups by CSV"
    Write-Host "2 - Create individual Group"
    Write-Host "3 - Exit"

    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        1 {New-GroupCSV} #OK
        2 {New-Group} #OK
        3 {Show-GroupsUsersMenu} #ok
        default {
            Write-Host " "
            Write-Host " "
            Write-Host "Invalid choice. Please try again."
            Write-Host " "
            Write-Host " "
            Show-GroupsMenu
        }
    }
}

function Get-FilePath {
    
    Write-Host "Please select a CSV file to import and create Groups on your Proxmox Server"

    Add-Type -AssemblyName System.Windows.Forms

    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        InitialDirectory = [Environment]::GetFolderPath('Desktop')
        Filter = 'CSV Files (*.csv)|*.csv'
    }

    
    if ($FileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $path = $FileBrowser.FileName
    }
    else {
        Write-Host "Warning : No file select ! Please select a CSV file"
        Get-FilePath
    }

    return $path
}

function New-GroupCSV {
    $GroupsSuccess = 0
    $GroupsError = 0
    $GroupsWarning = 0
    
    $path = Get-FilePath
    $CSVFile = Import-Csv -Path $path

    if (($CSVFile.GroupName).count -ge 1)
    {
        foreach ($groupName in $CSVFile.GroupName)
        {
        
            if ($groupName -notmatch "[^a-zA-Z0-9-_]")
            {
            
                if ((Get-GroupExists $groupName) -EQ $false)
                {
                    try {
                        $command = New-PveAccessGroups -Groupid $groupName -ErrorAction Stop

                        if ($command.IsSuccessStatusCode -eq $true)
                        {
                            Write-Host "Success: The group $groupName has been successfully created"
                            $GroupsSuccess++
                        }
                        else {
                            Write-Host "Error: The group $groupName has not been created -> $($command.ReasonPhrase)"
                            $GroupsError++
                        }
                    }
                    catch {
                        Write-Host "Error: The group $groupName has not been created -> $_"
                        $GroupsError++
                    }
                }
                else {
                    Write-Host "Warning: The group $groupName already exists on your Proxmox server"
                    $GroupsWarning++
                }
            }
            else {
                Write-Host "Error: Your group name $groupName contains special characters"
                $GroupsError++
            }
        }

        Write-Host "Info: The task of creating groups is completed. During the task, there was -> $GroupsSuccess Success -> $GroupsWarning Warning -> $GroupsError Error"

        $choice = Read-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu"
            
        if ($choice -eq 1)
        {
            Clear-Host
            New-GroupCSV
        }
        else {
            Show-GroupsMenu
        }
    }
    else {

        $choice = Read-Host "Error : No value was found in the GroupName field. Type 1 to restart the creation of a group or leave it blank to return to the previous menu"
            
        if ($choice -eq 1)
        {
            Clear-Host
            New-GroupCSV
        }
        else {
            Show-GroupsMenu
        }
    }
}

function New-Group {
    $groupName = Read-Host "Enter name of the new Group"

    if ((Get-GroupExists $groupName) -EQ $false)
    {
        if ($groupName -notmatch "[^a-zA-Z0-9-_]")
        {
            try {
                $command = New-PveAccessGroups -Groupid $groupName -ErrorAction Stop

                if ($command.IsSuccessStatusCode -eq $true)
                {
                    Write-Host "Succes : The group has been successfully created"
                }
                else {
                    Write-Host "Error : " $command.ReasonPhrase
                }
            }
            catch {
                Write-Host "Error : $_"
                $choice = Read-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu"
            
                if ($choice -eq 1)
                {
                    Clear-Host
                    New-Group
                }
                else {
                    Show-GroupsMenu
                }
            }

            $choice = Read-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu"
            
            if ($choice -eq 1)
            {
                Clear-Host
                New-Group
            }
            
        }
        else {
            Write-Host "Error : Your group name contains special characters"
            $choice = Read-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu"
            
            if ($choice -eq 1)
            {
                Clear-Host
                New-Group
            }
        }
    }
    else {
        $choice = Read-Host "Warning : The group already exists on your Proxmox server. Type 1 to restart the creation of a group or leave it blank to return to the previous menu"
        if ($choice -eq 1)
        {
            Clear-Host
            New-Group
        }
    }

    Show-GroupsMenu
    
}


function Get-GroupExists { param ( [string]$groupName )
    $GroupExists = $true

    if ($null -eq ((Get-PveAccessGroups).ToData() | Where-Object groupid -EQ $groupName))
    {
        $GroupExists = $false
    }

    return $GroupExists
}

function Get-Groups {
    Clear-Host
    $groups = (Get-PveAccessGroups).ToData()
    Write-Host "Here are the existing groups on your Proxmox server :"
    $groups.groupid
    
    Show-GroupsUsersMenu
}

function Get-welcome {
    Write-Host ""
    Write-Host " ____  ____   _____  _____ __  __ "
    Write-Host "|  _ \|  _ \ / _ \ \/ /_ _|  \/  |"
    Write-Host "| |_) | |_) | | | \  / | || |\/| |"
    Write-Host "|  __/|  _ <| |_| /  \ | || |  | |"
    Write-Host "|_|   |_| \_\\___/_/\_\___|_|  |_|"
    Write-Host ""
    Write-Host ""
    Write-Host ""
    Write-Host "PROXIN - PROXIM  - Proxmox Interface Management"

}

if (($PSVersionTable.PSVersion.Major) -ge 6) {

    Get-welcome
    #Find-Module
    #$PveTicket = Get-PVECredential

    #Show-Menu

} else {
    Write-Host "Please update your version of PowerShell. Minimum version requirement for PowerShell is 6.0. You currently have the version $($PSVersionTable.PSVersion)"
}


