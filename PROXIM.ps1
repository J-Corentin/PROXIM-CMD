function Find-Module {
    if ($null -eq (Get-Module -ListAvailable | Where-Object { $_.Name -eq "Corsinvest.ProxmoxVE.Api" })) {
        Write-Host "Error: Module not found, please install this PowerShell module Corsinvest.ProxmoxVE.Api" -ForegroundColor Red
        break
    }
}

function Get-PVECredential {
    while ($true) {
        $PVEIPServer = $(Write-Host "Enter the IP address of your Proxmox server : " -ForegroundColor Yellow -NoNewLine; Read-Host )

        if ($PVEIPServer -notmatch '^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$') {
            Write-Host "Error : Invalid IP address. Please enter a valid IP address." -ForegroundColor Red
        } 
        else {
            break
        }
    }

    $choice = $(Write-Host "For authentication using an API Token, enter '0'; otherwise, leave it blank : " -ForegroundColor Yellow -NoNewline; Read-Host )

    if ($choice -eq '0') {
        $PVEApiKey = $(Write-Host "Enter your API Token : " -ForegroundColor Yellow -NoNewline; Read-Host -AsSecureString)

        try {
            $PveTicket = Connect-PveCluster -HostsAndPorts $PVEIPServer -ApiToken ([Net.NetworkCredential]::new('', $PVEApiKey).Password) -SkipCertificateCheck -ErrorAction Stop
        } 
        catch 
        {
            Write-Host "Error: $_" -ForegroundColor Red
            Get-PVECredential
        }

        return $PveTicket
    } 
    else {
        $PVEUserName = $(Write-Host "Enter your user name : " -ForegroundColor Yellow -NoNewline; Read-Host)  

        try {
            $PveTicket = Connect-PveCluster -HostsAndPorts $PVEIPServer -Credentials (Get-Credential -UserName $PVEUserName) -SkipCertificateCheck -ErrorAction Stop
        } 
        catch {
            Write-Host "Error: $_" -ForegroundColor Red
            Get-PVECredential
        }

        return $PveTicket
    }
}

function Show-Menu {

    # Display the menu header
    Write-Host " "
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host " "

    # Display the menu options
    Write-Host "1 - " -ForegroundColor Green
    Write-Host "2 - Groups & Users" -ForegroundColor Green
    Write-Host "3 - Deploy LXC & VM" -ForegroundColor Green
    Write-Host "4 - Exit" -ForegroundColor Green
    Write-Host " "

    # Prompt the user for a choice
    Write-Host "Enter your choice : " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    # Process the user's choice
    switch ($choice) {
        1 { }
        2 { Show-GroupsUsersMenu }
        3 { Show-MenuDeployVirtualMachine }
        4 { break }
        default {
            Write-Host " "
            Write-Host "Error: Invalid choice. Please try again !!!" -ForegroundColor Red
            Write-Host " "
            Show-Menu
        }
    }
}

function Show-MenuDeployVirtualMachine {
    
    # Display the menu header
    Write-Host " "
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host " "

    # Display the menu options
    Write-Host "1 - Deploying LXC Containers for a Group" -ForegroundColor Green
    Write-Host "2 - " -ForegroundColor Green
    Write-Host "3 - " -ForegroundColor Green
    Write-Host "4 - Exit" -ForegroundColor Green
    Write-Host " "

    # Prompt the user for a choice
    Write-Host "Enter your choice : " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    # Process the user's choice
    switch ($choice) {
        1 { New-DeployLXCGroup }
        2 {  }
        3 {  }
        4 { Show-Menu }
        default {
            Write-Host " "
            Write-Host "Error: Invalid choice. Please try again !!!" -ForegroundColor Red
            Write-Host " "
            Show-MenuDeployVirtualMachine
        }
    }
    
}

function Show-GroupsUsersMenu {


    # Display the menu header
    Write-Host " "
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host " "

    # Display the menu options
    Write-Host "1 - Create Groups" -ForegroundColor Green
    Write-Host "2 - List Groups" -ForegroundColor Green
    Write-Host "3 - Create Users" -ForegroundColor Green
    Write-Host "4 - List Users" -ForegroundColor Green
    Write-Host "5 - Exit" -ForegroundColor Green
    Write-Host " "

    # Prompt the user for a choice
    Write-Host "Enter your choice : " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    switch ($choice) {
        1 {Show-GroupsMenu} #ok
        2 {Get-Groups} #OK
        3 {Show-UsersMenu}
        4 {Get-Users} #OK
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


    # Display the menu header
    Write-Host " "
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host " "

    # Display the menu options
    Write-Host "1 - Import and Create Groups by CSV" -ForegroundColor Green
    Write-Host "2 - Create individual Group" -ForegroundColor Green
    Write-Host "3 - Exit" -ForegroundColor Green
    Write-Host " "

    # Prompt the user for a choice
    Write-Host "Enter your choice : " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

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

function Show-UsersMenu {


    # Display the menu header
    Write-Host " "
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host " "

    # Display the menu options
    Write-Host "1 - Import and Create Users by CSV" -ForegroundColor Green
    Write-Host "2 - Create individual User" -ForegroundColor Green
    Write-Host "3 - Exit" -ForegroundColor Green
    Write-Host " "

    # Prompt the user for a choice
    Write-Host "Enter your choice : " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    switch ($choice) {
        1 {New-UserCSV}
        2 {New-User} 
        3 {Show-GroupsUsersMenu} #ok
        default {
            Write-Host " "
            Write-Host " "
            Write-Host "Invalid choice. Please try again."
            Write-Host " "
            Write-Host " "
            Show-UsersMenu
        }
    }
}

function Get-FilePath {
    Write-Host "Please select a CSV file to import and create Groups on your Proxmox Server" -ForegroundColor Yellow

    Add-Type -AssemblyName System.Windows.Forms

    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        InitialDirectory = [Environment]::GetFolderPath('Desktop')
        Filter = 'CSV Files (*.csv)|*.csv'
    }

    if ($FileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $path = $FileBrowser.FileName
    } else {
        Write-Host "Warning: No file selected! Please select a CSV file." -ForegroundColor Magenta
        Get-FilePath
        return
    }

    return $path
}

function New-GroupCSV {
    $GroupsSuccess = 0
    $GroupsError = 0
    $GroupsWarning = 0

    $path = Get-FilePath

    if ($null -eq $path) {
        Write-Host "Error: No file selected. Please try again." -ForegroundColor Red
        New-GroupCSV
        return
    }

    $CSVFile = Import-Csv -Path $path

    Write-Host " "

    if (($CSVFile.GroupName).Count -ge 1) {
        foreach ($groupName in $CSVFile.GroupName) {
            if ($groupName -notmatch "[^a-zA-Z0-9-_]") {
                if ((Get-GroupExists $groupName) -EQ $false) {
                    try {
                        $command = New-PveAccessGroups -Groupid $groupName -ErrorAction Stop

                        if ($command.IsSuccessStatusCode -eq $true) {
                            Write-Host "Success: The group $groupName has been successfully created" -ForegroundColor Green
                            $GroupsSuccess++
                        } else {
                            Write-Host "Error: The group $groupName has not been created -> $($command.ReasonPhrase)" -ForegroundColor Red
                            $GroupsError++
                        }
                    } catch {
                        Write-Host "Error: The group $groupName has not been created -> $_" -ForegroundColor Red
                        $GroupsError++
                    }
                } else {
                    Write-Host "Warning: The group $groupName already exists on your Proxmox server" -ForegroundColor Magenta
                    $GroupsWarning++
                }
            } else {
                Write-Host "Error: Your group name $groupName contains special characters" -ForegroundColor Red
                $GroupsError++
            }
        }

        Write-Host " "
        Write-Host " "

        # Display the information message
        Write-Host "Info: The task of creating groups is completed. During the task, there was -> " -ForegroundColor Yellow -NoNewline

        # Display the success message in green
        Write-Host "$GroupsSuccess Success" -ForegroundColor Green -NoNewline

        # Display the warning message in magenta
        Write-Host " -> $GroupsWarning Warning" -ForegroundColor Magenta -NoNewline

        # Display the error message in red
        Write-Host " -> $GroupsError Error" -ForegroundColor Red

        Write-Host " "
        $choice = $(Write-Host "Type 1 to restart the creation of a groups or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choice -eq 1) {
            Clear-Host
            New-GroupCSV
        } else {
            Show-GroupsMenu
        }

    } else {
        Write-Host " "
        Write-Host "Error: No value was found in the GroupName field" -ForegroundColor Red
        Write-Host " "
        $choice = $(Write-Host "Type 1 to restart the creation of a groups or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choice -eq 1) {
            Clear-Host
            New-GroupCSV
        } else {
            Show-GroupsMenu
        }
    }
}

function New-Group {
    $groupName = $(Write-Host "Enter name of the new Group : " -ForegroundColor Yellow -NoNewline; Read-Host)
    Write-Host " "

    if ((Get-GroupExists $groupName) -EQ $false)
    {
        if ($groupName -notmatch "[^a-zA-Z0-9-_]")
        {
            try {
                $command = New-PveAccessGroups -Groupid $groupName -ErrorAction Stop

                if ($command.IsSuccessStatusCode -eq $true)
                {
                    Write-Host "Succes : The group has been successfully created" -ForegroundColor Green
                }
                else {
                    Write-Host "Error : " $command.ReasonPhrase -ForegroundColor Red
                }
            }
            catch {
                Write-Host "Error : $_" -ForegroundColor Red
                Write-Host " "
                $choice = $(Write-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)
            
                if ($choice -eq 1)
                {
                    Clear-Host
                    New-Group
                }
                else {
                    Show-GroupsMenu
                }
            }
            
            Write-Host " "
            $choice = $(Write-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)
            
            if ($choice -eq 1)
            {
                Clear-Host
                New-Group
            }
            
        }
        else {
            Write-Host "Error : Your group name contains special characters" -ForegroundColor Red
            Write-Host " "
            $choice = Read-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu : "
            
            if ($choice -eq 1)
            {
                Clear-Host
                New-Group
            }
        }
    }
    else {
        Write-Host "Warning : The group already exists on your Proxmox server." -ForegroundColor Magenta
        Write-Host " "
        $choice = $(Write-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choice -eq 1)
        {
            Clear-Host
            New-Group
        }
    }

    Show-GroupsMenu
}

function Get-Password {
    
    $password = $(Write-Host "Enter the password of the new user : " -ForegroundColor Yellow -NoNewline; Read-Host -AsSecureString)

    if ($password.Length -le 4)
    {
        Write-Host "Error : The password is not long enough. It must be at least 5 characters long" -ForegroundColor Red
        Get-Password
        return
    }

    return $password
}

function Set-UserGroups {param ( [string]$UserName, [string]$GroupName)

    if ((Get-GroupExists $GroupName) -EQ $false)
    {
        $choice = $(Write-Host "Info : The group $GroupName does not exist. Would you like to create it? Type 1 to create the group or leave it blank to ignore" -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choice -eq 1)
        {
            if ($groupName -notmatch "[^a-zA-Z0-9-_]")
            {
                try {
                    $command = New-PveAccessGroups -Groupid $GroupName -ErrorAction Stop
    
                    if ($command.IsSuccessStatusCode -eq $true)
                    {
                        Write-Host "Succes : The group $($GroupName) has been successfully created" -ForegroundColor Green
                    }
                    else {
                        Write-Host "Error : The group $($GroupName) has not been created -> $($command.ReasonPhrase)" -ForegroundColor Red
                    }
                }
                catch {
                    Write-Host "Error : The group $($GroupName) has not been created -> $_" -ForegroundColor Red
                }
            }
            else {
                Write-Host "Error : Your group $($GroupName) contains special characters" -ForegroundColor Red
            }
        }
        else {
            return
        }
    }
    
    try {
        $command = Set-PveAccessUsers -Userid "$UserName@pve" -Groups $GroupName

        if ($command.IsSuccessStatusCode -eq $true)
        {
            Write-Host "Success : The user $($UserName) added the group $($GroupName)" -ForegroundColor Green
        }
        else {
            Write-Host "Error : The user $($UserName) failed to add the group $($GroupName) -> $($command.ReasonPhrase)" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "Error : The user $($UserName) failed to add the group $($GroupName) -> $_" -ForegroundColor Red
    }
    
}

function New-UserCSV {
    $UsersSuccess = 0
    $UsersError = 0
    $UsersWarning = 0
    $nbr = 1

    $path = Get-FilePath

    if ($null -eq $path) {
        Write-Host "Error : No file selected. Please try again." -ForegroundColor Red
        New-UserCSV
        return
    }

    Write-Host " "

    $CSVFile = Import-Csv -Path $path -Delimiter ","

    if (($CSVFile.UserName).Count -ge 1) {
        foreach ($user in $CSVFile) {
            $UserName = $user.UserName
            $PW = $user.Password

            if ($null -eq $UserName) {
                Write-Host "Error : No UserName value found line $nbr" -ForegroundColor Red
                $nbr++
                $UsersError++
            } else {
                if ((Get-UserExists $UserName) -eq $false) {
                    if ($UserName -notmatch "[^a-zA-Z0-9-_]") {
                        if ($null -ne $PW) {
                            if ($PW.Length -gt 5) {
                                $password = ConvertTo-SecureString -String $PW -AsPlainText -Force

                                try {
                                    $command = New-PveAccessUsers -Userid "$UserName@pve" -Password $password -ErrorAction Stop

                                    if ($command.IsSuccessStatusCode -eq $true) {
                                        Write-Host "Succes : The user name $($UserName) has been successfully created" -ForegroundColor Green
                                        $UsersSuccess++

                                        for ($i = 0; $i -lt 10; $i++)
                                        {
                                            $GroupField = "Group$i"
                                            $GroupName = $user.$GroupField

                                            if (-not [string]::IsNullOrEmpty($GroupName)) {
                                                Set-UserGroups $userName $GroupName
                                            }
                                        }

                                    } else {
                                        Write-Host "Error: The user $($UserName) has not been created -> $($command.ReasonPhrase)" -ForegroundColor Red
                                        $UsersError++
                                    }
                                } catch {
                                    Write-Host "Error: The user $($UserName) has not been created -> $_" -ForegroundColor Red
                                    $UsersError++
                                }
                            } else {
                                Write-Host "Error : The password for $($UserName) not respect the minimun length" -ForegroundColor Red
                                $UsersError++
                            }
                        } else {
                            Write-Host "Error : No password found for $($UserName)" -ForegroundColor Red
                            $UsersError++
                        }
                    } else {
                        Write-Host "Error : Your user $($UserName) contains special characters" -ForegroundColor Red
                        $UsersError++
                    }
                } else {
                    Write-Host "Warning: The user $($UserName) already exists on your Proxmox server." -ForegroundColor Magenta
                    $UsersWarning++

                    for ($i = 0; $i -lt 10; $i++)
                    {
                        $GroupField = "Group$i"
                        $GroupName = $user.$GroupField

                        if (-not [string]::IsNullOrEmpty($GroupName)) {
                            Set-UserGroups $userName $GroupName
                        }
                    }
                }

                $nbr++
            }
        }

        Write-Host " "
        Write-Host " "

        # Display the information message
        Write-Host "Info: The task of creating users is completed. During the task, there was -> " -ForegroundColor Yellow -NoNewline

        # Display the success message in green
        Write-Host "$UsersSuccess Success" -ForegroundColor Green -NoNewline

        # Display the warning message in magenta
        Write-Host " -> $UsersWarning Warning" -ForegroundColor Magenta -NoNewline

        # Display the error message in red
        Write-Host " -> $UsersError Error" -ForegroundColor Red

        Write-Host " "
        $choice = $(Write-Host "Type 1 to restart the creation of a users or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choice -eq 1) {
            Clear-Host
            New-UserCSV
        } else {
            Show-UsersMenu
        }

    } else {
        Write-Host " "
        Write-Host "Error : No value was found in the UserName field" -ForegroundColor Red
        Write-Host " "
        $choice = $(Write-Host "Type 1 to restart the creation of a users or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choice -eq 1) {
            Clear-Host
            New-UserCSV
        } else {
            Show-UsersMenu
        }
    }
}

function New-User {
    $userName = $(Write-Host "Enter name of the new User : " -ForegroundColor Yellow -NoNewline; Read-Host)

    if ((Get-UserExists $userName) -eq $false) 
    {
        if ($userName -notmatch "[^a-zA-Z0-9-_]")
        {
            
            $password = Get-Password

            try {
                $command = New-PveAccessUsers -Userid "$userName@pve" -Password $password -ErrorAction Stop

                if ($command.IsSuccessStatusCode -eq $true)
                {
                    Write-Host " "
                    Write-Host "Succes : The user has been successfully created" -ForegroundColor Green
                }
                else {
                    Write-Host " "
                    Write-Host "Error: The user $userName has not been created -> $($command.ReasonPhrase)" -ForegroundColor Red
                }
            }
            catch {
                Write-Host " "
                Write-Host "Error: The user $userName has not been created -> $_" -ForegroundColor Red
                Write-Host " "
                $choice = $(Write-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)
            
                if ($choice -eq 1)
                {
                    Clear-Host
                    New-User
                }
                else {
                    Show-UsersMenu
                }
            }

            
        }
        else {
            Write-Host " "
            Write-Host "Error : Your user name contains special characters" -ForegroundColor Red
            Write-Host " "
            $choice = $(Write-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)
            
            if ($choice -eq 1)
            {
                Clear-Host
                New-User
            }
        }
        
    }
    else {
        Write-Host "Warning : The user already exists on your Proxmox server." -ForegroundColor Magenta
        Write-Host " "
        $choice = $(Write-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choice -eq 1) {
            Clear-Host
            New-User
        }
    }
    
    Show-UsersMenu
}

function Get-GroupExists { param ( [string]$groupName )
    $GroupExists = $true

    if ($null -eq ((Get-PveAccessGroups).ToData() | Where-Object groupid -EQ $groupName))
    {
        $GroupExists = $false
    }

    return $GroupExists
}

function Get-UserExists {param ( [string]$userName )
    $UserExists = $true

    if($null -eq ((Get-PveAccessUsers).ToData() | Where-Object userid -eq "$userName@pve"))
    {
        $UserExists = $false
    }

    return $UserExists
    
}

function Get-Groups {
    Clear-Host
    $groups = (Get-PveAccessGroups).ToData()
    Write-Host "Here are the existing groups on your Proxmox server :" -ForegroundColor Yellow
    Write-Host "=====================================================" -ForegroundColor Cyan
    $groups.groupid
    
    Show-GroupsUsersMenu
}

function Get-Users {
    $users = (Get-PveAccessUsers).ToData()
    Write-Host "Here are the existing users on your Proxmox server :" -ForegroundColor Yellow
    Write-Host "=====================================================" -ForegroundColor Cyan
    $users.userid
    
    Show-GroupsUsersMenu
}

function Get-Welcome {
    Clear-Host

    # Define the welcome page information
    $programName = "PROXIM"
    $version = "v1.0"
    $developer = "Corentin"
    $module = "Corsinvest.ProxmoxVE.Api"

    # Draw the program name in ASCII
    $asciiArt = @"
     ____  ____   _____  _____ __  __
    |  _ \|  _ \ / _ \ \/ /_ _|  \/  |
    | |_) | |_) | | | \  / | || |\/| |
    |  __/|  _ <| |_| /  \ | || |  | |
    |_|   |_| \_\\___/_/\_\___|_|  |_|
"@

    # Display the welcome page
    Write-Host $asciiArt 
    Write-Host " "
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "Welcome to $programName $version" -ForegroundColor Yellow
    Write-Host "Developed by: $developer" -ForegroundColor Yellow
    Write-Host "Based on the module: $module" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host " "

    # Optional: Add a pause to allow the user to read the welcome page
    #Read-Host "Press Enter to continue..."
}

function Get-GroupDeploy {
    $nbr = 1
    
    # Retrieve groups and convert to Data
    $groups = (Get-PveAccessGroups).ToData()
    
    if ($groups.Groupid.Count -ge 1) {
        Clear-Host
        Write-Host "Here are the groups that exist:" -ForegroundColor Yellow
        Write-Host "=================================" -ForegroundColor Cyan

        # List groups
        foreach ($group in $groups) {
            Write-Host "$nbr -> $($group.Groupid)"
            $nbr++
        }

        while ($true) {
            Write-Host " "
            $choix = $(Write-Host "Which group would you like to deploy virtual machines to? (Use the number to indicate the group). Press E to exit the function : " -ForegroundColor Yellow -NoNewline; Read-Host)

            # Handle numeric input
            if ($choix -match '^\d+$') {
                $choix = [int]$choix
                $GroupsCount = $groups.Groupid.Count

                if ($choix -ge 1 -and $choix -le $GroupsCount) {
                    $choix = $choix - 1
                    return $groups.Groupid[$choix]
                } else {
                    Write-Host " "
                    Write-Host "Error : Please enter a number between 1 and $GroupsCount, or 'E' to exit." -ForegroundColor Red
                }
            } elseif ($choix -eq "E") {
                Show-MenuDeployVirtualMachine
                return
            } else {
                Write-Host " "
                Write-Host "Error : Please enter a valid number or 'E' to exit." -ForegroundColor Red
            }
        }
    } else {
        Write-Host " "
        Write-Host "Error : No group was found" -ForegroundColor Red
        Show-MenuDeployVirtualMachine
        return
    }
}

function Get-CpuNbr { param ( [string]$NodeName )
    $Maxcpu = (Get-PveNode -Node $NodeName).maxcpu

    while ($true) {

        $NbrCpu = 0

        #Write-Host " "
        Clear-Host
        Write-Host "CPU Config :" -ForegroundColor Yellow
        Write-Host "=============" -ForegroundColor Cyan
        $choice = $(Write-Host "Please enter a number between 1 and $Maxcpu for the number of cores to assign to the LXC : " -ForegroundColor Yellow -NoNewline ; Read-Host) 

        if ([int]::TryParse($choice, [ref]$NbrCpu) -and $NbrCpu -ge 1 -and $NbrCpu -le $Maxcpu) {
            return $NbrCpu
            break
        }
        else {
            Write-Host " "
            Write-Host "Error : Please enter a valid value" -ForegroundColor Red
        } 
    }
}

function Get-Ram { param ( [string]$NodeName )

    $Maxram = (Get-PveNode -Node $NodeName).maxmem

    $Maxram = [Math]::Floor($Maxram / (1024 * 1024))

    while ($true) {

        $NbrRam = 0

        Clear-Host
        Write-Host "RAM Config :" -ForegroundColor Yellow
        Write-Host "=============" -ForegroundColor Cyan
        $choice = $(Write-Host "Please enter a number between 512 and $Maxram for the amount of RAM in MB to assign to the LXC : " -ForegroundColor Yellow -NoNewline ; Read-Host)

        if ([int]::TryParse($choice, [ref]$NbrRam) -and $NbrRam -ge 512 -and $NbrRam -le $Maxram) {
            return $NbrRam
            break
        }
        else {
            Write-Host " "
            Write-Host "Error : Please enter a valid value" -ForegroundColor Red
        } 
    }
}

function New-DeployLXCGroup {
    
    $CPU = 1
    $Ram = 1024
    $HdSize = 16
    $HdPath = "local-lvm"
    $NicEth = "eth0"
    $HDDrive = $null
    $Password = "ApplePie"
    $LXCName = $null

    $groupName = Get-GroupDeploy

    if ($null -eq $groupName)
    {
        return
    }

    $NbrDeployLXC = (Get-PveAccessGroupsIdx -Groupid $groupName).ToData().Members.Count
    $Vmid = (Get-LastVMID) + 1
    
    if ((Get-PveAccessGroupsIdx -Groupid $groupName).ToData().members.count -ge 1)
    {
        $ListPools = (Get-PvePools).ToData()

        if (-not ($ListPools | Where-Object poolid -eq $groupName)) {
            $null = New-PvePools -Poolid $groupName
        }
        
        $Template = Get-LXCTemplate

        $LXCName = $Template.volid.Split("/")[1].Split("-")[0]

        Clear-Host
        Write-Host "Default Configuration for LXC :" -ForegroundColor Yellow
        Write-Host "===============================" -ForegroundColor Cyan
        Write-Host "CPU -> $Cpu core(s)"
        Write-Host "RAM -> $Ram MB"
        Write-Host "Hard Disk -> $HdSize GB at $HdPath"
        Write-Host "NIC -> $NicEth (vmbr0)"
        Write-Host "OS -> $(($Template.volid).Split("/")[-1])"
        Write-Host "Password -> $Password"
        Write-Host "Name LXC -> $LXCName-VMID"

        while ($true) {
            Write-Host " "
            $choice = $(Write-Host "Press 1 to use the default configuration, or press 2 to modify the values or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)
        
            if ($choice -eq 1) {
                $Nic = @{1='name=eth0,bridge=vmbr0,ip=dhcp'}
                $HDDrive = $HdPath + ":" + $HdSize
                $Password = ConvertTo-SecureString $Password -AsPlainText -Force

                Clear-Host

                foreach($user in (Get-PveAccessGroupsIdx -Groupid $groupName).ToData().members)
                {
                    $name = $LXCName + "-" + $Vmid
                    $command = Set-LXC -NodeName $Template.Node -Cpu $CPU -Ram $Ram -HDDrive $HDDrive -Ostemplate $Template.volid -Vmid $Vmid -LXCName $name -Password $Password -Nic $Nic 

                    if ($true -eq $command) {
                        $command  = Set-PveAccessAcl -Roles PVEVMUser -Users $user -Path /vms/$Vmid
                    }

                    $Vmid++
                }

                break
            }
            elseif ($choice -eq 2) {
                $CPU = Get-CpuNbr $Template.Node
                $Ram = Get-Ram $Template.Node
                $Nic = Get-Nic $Template.Node
                $HDDrive = Get-disk $Template.Node

                Clear-Host
                Write-Host "Custom Configuration for LXC :" -ForegroundColor Yellow
                Write-Host "===============================" -ForegroundColor Cyan
                Write-Host "CPU -> $Cpu core(s)"
                Write-Host "RAM -> $Ram MB"
                Write-Host "Hard Disk -> $($HDDrive.split(":")[1]) GB at $($HDDrive.split(":")[0])"
                if($nic.Values.split("=").split(",").count -eq 6)
                {
                    Write-Host "NIC -> $($nic.Values.split("=").split(",")[1]) (vmbr0)"
                }
                elseif ($nic.Values.split("=").split(",").count -eq 8) {
                    Write-Host "NIC -> $($nic.Values.split("=").split(",")[1]) (vmbr0) VLAN $($nic.Values.split("=").split(",")[7])"
                }
                $Nic
                Write-Host "OS -> $(($Template.volid).Split("/")[-1])"
                Write-Host "Name LXC -> $LXCName-VMID"

                while ($true) {
                    Write-Host " "
                    $choix = $(Write-Host "Is the configuration correct? (Y/N)" -ForegroundColor Yellow -NoNewline; Read-Host)
            
                    if ($choix -eq "Y" -or $choix -eq "N") {
            
                        if ($choix -eq "Y") {
                            if (Get-DiskSpaceOK -NodeName $Template.Node -HDDrive $HDDrive -NbrDeploy $NbrDeployLXC) {
                                $Password = Get-PasswordLXC

                                Clear-Host

                                foreach($user in (Get-PveAccessGroupsIdx -Groupid $groupName).ToData().members)
                                {
                                    $name = $LXCName + "-" + $Vmid
                                    $Nic= "hello"
                                    $command = Set-LXC -NodeName $Template.Node -Cpu $CPU -Ram $Ram -HDDrive $HDDrive -Ostemplate $Template.volid -Vmid $Vmid -LXCName $name -Password $Password -Nic $Nic -21 "Hello"

                                    if ($true -eq $command) {
                                        $command  = Set-PveAccessAcl -Roles PVEVMUser -Users $user -Path /vms/$Vmid
                                    }

                                    $Vmid++
                                }
                            }
                            else {
                                Write-Host "Error : Unable to create $NbrDeployLXC machines for the group $groupName" -ForegroundColor Red
                                break
                            }   

                            break
                        }
                        else {
                            Show-MenuDeployVirtualMachine
                            break
                        }
            
                        break
                    }
                    else {
                        Write-Host " "
                        Write-Host "Error : Please enter a valid value" -ForegroundColor Red
                    }
                }
                break
            }
            elseif ([string]::IsNullOrWhiteSpace($choice)) {
                Show-MenuDeployVirtualMachine
                return
            }
            else {
                Write-Host " "
                Write-Host "Error : Please enter a correct value" -ForegroundColor Red
            }
        }        
    }
    else {
        Write-Host " "
        Write-Host "Error : The group $groupName does not contain any users." -ForegroundColor Red
    }

    Show-MenuDeployVirtualMachine
    
}

function Set-LXC { param ([string]$NodeName, [int]$Cpu, [int]$Ram, [string]$HDDrive, [string]$Ostemplate, [int]$Vmid,[System.Security.SecureString]$Password, [string]$LXCName, [string]$21 )

    #$Nic
    $21

    <#$command = New-PvenodesLxc -Node $NodeName -Vmid $Vmid -Ostemplate $Ostemplate -Cores $Cpu -Memory $Ram -Rootfs $HDDrive -NetN $Nic -Password $Password -Hostname $LXCName

    #/if ($command.IsSuccessStatusCode -eq $true)
    {
        Write-Host "Succes : The LXC container $LXCName has been successfully created" -ForegroundColor Green
        return $true
    }
    else {
        Write-Host "Error : The LXC container $LXCName cannot be created -> $($command.ReasonPhrase)" -ForegroundColor Red
        return $false
    }#>
}

function Get-LXCTemplate {
    $nbr = 1
    $templates = New-Object System.Collections.Generic.List[PSCustomObject]

    # Retrieve node data
    $nodes = (Get-PveNodes).ToData()

    Clear-Host
    Write-Host "Here are the templates that exist:" -ForegroundColor Yellow
    Write-Host "===================================" -ForegroundColor Cyan

    foreach ($node in $nodes) {
        # Retrieve storage content
        $storage = (Get-PveNodesStorageContent -Node $node.node -Storage local).ToData() | Where-Object { $_.content -eq "vztmpl" }

        if ($storage.Count -ge 1) {
            Write-Host "Node -> $($node.node)" -ForegroundColor Yellow
            
            foreach ($item in $storage) {
                $templateName = ($item.volid).Split("/")[-1]

                Write-Host "$nbr -> $templateName"

                $templates.Add([PSCustomObject]@{
                    Index = $nbr
                    Node = $node.node
                    Volid = $item.volid
                })

                $nbr++
            }

            Write-Host " "
        }
    }

    if ($templates.Count -ge 1) {
        while ($true) {
            Write-Host " "
            $choix = $(Write-Host "Which system did you want to use for the deployment of your LXC? (Use the number to indicate the template). Press E to exit the function : " -ForegroundColor Yellow -NoNewline; Read-Host)

            # Validate input
            if ($choix -match '^\d+$') {
                $choix = [int]$choix
                if ($choix -ge 1 -and $choix -le $templates.Count) {
                    $choix = $choix - 1
                    return $templates[$choix]
                } else {
                    Write-Host " "
                    Write-Host "Error : Please enter a number between 1 and $($templates.Count), or 'E' to exit." -ForegroundColor Red
                }
            } elseif ($choix -eq "E") {
                Show-MenuDeployVirtualMachine
                return
            } else {
                Write-Host " "
                Write-Host "Error : Please enter a valid number or 'E' to exit." -ForegroundColor Red
            }
        }
    } else {
        Write-Host "Error : No template was found" -ForegroundColor Red
        Show-MenuDeployVirtualMachine
        return
    }
}

function Get-Nic { param ( [string]$NodeName )
    $ListNic = (Get-PveNodesNetwork -node $NodeName).ToData() | Where-Object type -eq 'bridge'

    $nbr = 1

    Clear-Host
    Write-Host "NIC on your Proxmox Server :" -ForegroundColor Yellow
    Write-Host "=============================" -ForegroundColor Cyan

    foreach($Nic in $ListNic)
    {
        Write-Host "$nbr -> $($Nic.iface)"
        $nbr++
    } 

    $NicCount = $ListNic.Count
    
    while ($true) {
        Write-Host " "
        $choix = $(Write-Host "Choose a network card by providing its number : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choix -match '^\d+$')
        {
            $choix = [int]$choix

            if ($choix -ge 1 -and $choix -le $NicCount) {
                $choix = $choix - 1
                $Nic = $ListNic[$choix]
                break
            }
            else {
                Write-Host " "
                Write-Host "Error : Please enter a number between 1 and $NicCount." -ForegroundColor Red
            }
        }
        else {
            Write-Host " "
            Write-Host "Error : Please enter a valid number" -ForegroundColor Red
        }
    }

    while ($true) {
        Write-Host " "
        $choix = $(Write-Host "Do you want to configure a VLAN on the network card ? (Y/N)" -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choix -eq "Y" -or $choix -eq "N") {

            if ($choix -eq "Y") {
                $vlan = Get-Vlan

                $NetworkCard = @{1="name=eth0,bridge=$($Nic.iface),ip=dhcp,tag=$vlan"}
                
                return $NetworkCard
            }

            $NetworkCard = @{1="name=eth0,bridge=$($Nic.iface),ip=dhcp"}

            Return $NetworkCard
        }
        else {
            Write-Host " "
            Write-Host "Error : Please enter a valid value" -ForegroundColor Red
        }
        
    }
}

function Get-Vlan {

    while ($true) {

        Write-Host " "
        $choix = $(Write-Host "Please indicate the VLAN number to configure (1-4094) : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choix -match '^\d+$')
        {
            $choix = [int]$choix

            if ($choix -ge 1 -and $choix -le 4094) {
                return $choix
                break
            }
            else {
                Write-Host " "
                Write-Host "Error : Please enter a number between 1 and 4094." -ForegroundColor Red
            }
        }
        else {
            Write-Host " "
            Write-Host "Error : Please enter a number between 1 and 4094." -ForegroundColor Red
        }
        
    }
}

function Get-LastVMID {
    
    $maxVmid = (Get-PveVm).vmid | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
    return $maxVmid
}

function Get-Disk { param ( [string]$NodeName )

    $nbr = 1
    $Disk = $null
    $DiskSize = $null
    
    $Storages = (Get-PveNodesStorage -node $NodeName).ToData() | Where-Object {$_.content -eq "rootdir,images" -or $_.content -eq "images,rootdir"} | Sort-Object -Property storage

    Clear-Host
    Write-Host "Storage Pool available on your Proxmox server :" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Cyan

    foreach ($Storage in $Storages)
    {
        Write-Host "$nbr -> $($Storage.storage)"
        $nbr++
    }

    while ($true) {

        Write-Host " "
        $choix = $(Write-Host "Select the storage pool for your LXC container : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choix -match '^\d+$') {
            $choix = [int]$choix

            if ($choix -ge 1 -and $choix -le ($Storages.Count)) {
                $choix = $choix -1

                $Disk = $Storages[$choix]
                $DiskSize = Get-SizeDisk

                $Drive = "$($Disk.storage):$DiskSize"

                return $Drive
                break
            }
            else {
                Write-Host " "
                Write-Host "Error : Please enter a valid number" -ForegroundColor Red
            }
        }
        else {
            Write-Host " "
            Write-Host "Error : Please enter a valid number" -ForegroundColor Red
        }
    }
}

function Get-SizeDisk {
    
    

    while ($true) {
        Write-Host " "
        $choix = $(Write-Host "Please indicate the size of the disk in GB (Min 8GB/ Max 32GB) : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choix -match '^\d+$')
        {
            $choix = [int]$choix

            if ($choix -ge 8 -and $choix -le 32) {
                return $choix
                break
            }
            else {
                Write-Host " "
                Write-Host "Error : Please enter a number between 8GB and 32GB." -ForegroundColor Red
            }
        }
        else {
            Write-Host " "
            Write-Host "Error : Please enter a number between 8GB and 32GB." -ForegroundColor Red
        }
    }
}

function Get-DiskSpaceOK {param ([string]$NodeName, [string]$HDDrive, [int]$NbrDeploy)


    $Disk = $HDDrive.Split(":")
    
    $SpaceRequired = [int]$Disk[1] * $NbrDeploy

    $TypeDisk = (Get-PveNodesStorage -Node $NodeName).ToData() | Where-Object storage -eq $Disk[0]

    if($TypeDisk.type -eq "lvmthin")
    {
        $DiskInfo = (Get-PveNodesStorage -Node $NodeName).ToData() | Where-Object { $_.storage -eq $Disk[0] }

        $FreeSpace = [Math]::Floor($DiskInfo.avail / (1024 * 1024 * 1024))

        if ($SpaceRequired -lt $FreeSpace) {
            return $true
        }
        else {
            Write-Host " "
            Write-Host "Error: There is not enough space to create all the machines. Free space -> $FreeSpace GB, Required space -> $SpaceRequired GB" -ForegroundColor Red
            return $false
        }
    }
    elseif ($TypeDisk.type -eq "zfspool") {

        $DiskInfo = (Get-PveNodesStorage -Node $NodeName).ToData() | Where-Object { $_.storage -eq $Disk[0] }

        $FreeSpace = [Math]::Floor($DiskInfo.avail / (1024 * 1024 * 1024))

        if ($SpaceRequired -lt $FreeSpace) {
            return $true
        }
        else {
            Write-Host " "
            Write-Host "Error: There is not enough space to create all the machines. Free space -> $FreeSpace GB, Required space -> $SpaceRequired GB" -ForegroundColor Red
            return $false
        }
        
    }
    else {
        Write-Host " "
        Write-Host "Error : The disk $($Disk[0]) is in the format $($TypeDisk.type). This format is not yet supported " -ForegroundColor Red
    }
    
}

function Get-PasswordLXC {
    Clear-Host
    Write-Host "Password Configuration :" -ForegroundColor Yellow
    Write-Host "=========================" -ForegroundColor Cyan

    while ($true) {
        $choice = $(Write-Host "Please enter the password to set for the LXC (minimum of 5 characters long) : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choice.Length -ge 5) {
            <# Action to perform if the condition is true #>

            $Password = ConvertTo-SecureString $choice -AsPlainText -Force
            return $Password
        }
        else {
            Write-Host " "
            Write-Host "Error : The password must be at least 5 characters long" -ForegroundColor Red
            Write-Host " "
        }
    }
    
}

if (($PSVersionTable.PSVersion.Major) -ge 6) {

    Get-welcome #ok
    Find-Module #ok
    $PveTicket = Get-PVECredential #ok

    Show-Menu

} else {
    Write-Host "Please update your version of PowerShell. Minimum version requirement for PowerShell is 6.0. You currently have the version $($PSVersionTable.PSVersion)"
}
