# Credits :
# ---------

# Program: PROXIM
# Version: v1.0
# Developer: Corentin
# Module: Corsinvest.ProxmoxVE.Api
# Date: 2024-10-03

#===================================================================================================
#===================================================================================================
# Function :
# ----------

# Function to find a specific PowerShell module
function Find-Module {

    # Check if the module "Corsinvest.ProxmoxVE.Api" is available
    if ($null -eq (Get-Module -ListAvailable | Where-Object { $_.Name -eq "Corsinvest.ProxmoxVE.Api" })) {
        # If the module is not found, display an error message and return false
        Write-Host "Error: Module not found, please install this PowerShell module Corsinvest.ProxmoxVE.Api" -ForegroundColor Red
        return $false
    }
    else {
        # If the module is found, return true
        return $true
    }
}

# Function to get Proxmox VE credentials
function Get-PVECredential {
    # Loop to ensure a valid IP address is entered
    while ($true) {
        # Prompt user to enter the IP address of the Proxmox server
        $PVEIPServer = $(Write-Host "Enter the IP address of your Proxmox server : " -ForegroundColor Yellow -NoNewLine; Read-Host )

        # Check if the entered IP address is valid
        if ($PVEIPServer -notmatch '^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$') {
            # Display error message if the IP address is invalid
            Write-Host "Error : Invalid IP address. Please enter a valid IP address." -ForegroundColor Red
        }
        else {
            # Break the loop if the IP address is valid
            break
        }
    }

    # Prompt user to choose authentication method
    $choice = $(Write-Host "For authentication using an API Token, enter '0'; otherwise, leave it blank : " -ForegroundColor Yellow -NoNewline; Read-Host )

    # If the user chooses API Token authentication
    if ($choice -eq '0') {
        # Prompt user to enter the API Token
        $PVEApiKey = $(Write-Host "Enter your API Token : " -ForegroundColor Yellow -NoNewline; Read-Host -AsSecureString)

        try {
            # Attempt to connect to the Proxmox server using the API Token
            $PveTicket = Connect-PveCluster -HostsAndPorts $PVEIPServer -ApiToken ([Net.NetworkCredential]::new('', $PVEApiKey).Password) -SkipCertificateCheck -ErrorAction Stop
        }
        catch {
            # Display error message if the connection fails
            Write-Host "Error: $_" -ForegroundColor Red
            # Recall the function to prompt the user again
            Get-PVECredential
        }

        # Return the connection ticket
        return $PveTicket
    }
    else {
        # Prompt user to enter the username
        $PVEUserName = $(Write-Host "Enter your user name : " -ForegroundColor Yellow -NoNewline; Read-Host)

        try {
            # Attempt to connect to the Proxmox server using the username and password
            $PveTicket = Connect-PveCluster -HostsAndPorts $PVEIPServer -Credentials (Get-Credential -UserName $PVEUserName) -SkipCertificateCheck -ErrorAction Stop
        }
        catch {
            # Display error message if the connection fails
            Write-Host "Error: $_" -ForegroundColor Red
            # Recall the function to prompt the user again
            Get-PVECredential
        }

        # Return the connection ticket
        return $PveTicket
    }
}

#Function to show Home menu
function Show-Menu {

    # Display the menu header
    Write-Host " "
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host " "

    # Display the menu options
    Write-Host "1 - Groups & Users" -ForegroundColor Green
    Write-Host "2 - Deploy/Remove LXC & VM" -ForegroundColor Green
    Write-Host "3 - Exit" -ForegroundColor Green
    Write-Host " "

    # Prompt the user for a choice
    Write-Host "Enter your choice : " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    # Process the user's choice
    switch ($choice) {
        1 {
            # Call the function to show the Groups & Users menu
            Show-GroupsUsersMenu
        }
        2 {
            # Call the function to show the Deploy Virtual Machine menu
            Show-MenuDeployVirtualMachine
        }
        3 {
            # Exit the menu
            break
        }
        default {
            # Display an error message for invalid choices
            Write-Host " "
            Write-Host "Error: Invalid choice. Please try again !!!" -ForegroundColor Red
            Write-Host " "
            # Recall the menu function to prompt the user again
            Show-Menu
        }
    }
}

#Function to show Deploy VM or LXC menu
function Show-MenuDeployVirtualMachine {
    
    # Display the menu header
    Write-Host " "
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "Please select an option:" -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host " "

    # Display the menu options
    Write-Host "1 - Deploying LXC Containers for a Group" -ForegroundColor Green
    Write-Host "2 - Deploying Qemu VM for a Group" -ForegroundColor Green
    Write-Host "3 - Deploying Template (VM or LXC) for a Group" -ForegroundColor Green
    Write-Host "4 - Remove the machines from a pool" -ForegroundColor Green
    Write-Host "5 - Exit" -ForegroundColor Green
    Write-Host " "

    # Prompt the user for a choice
    Write-Host "Enter your choice : " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    # Process the user's choice
    switch ($choice) {
        1 { New-DeployLXCGroup }
        2 { New-DeployQemuGroup }
        3 { New-CloneTemplate }
        4 { Remove-PoolMembers }
        5 { Show-Menu }
        default {
            Write-Host " "
            Write-Host "Error: Invalid choice. Please try again !!!" -ForegroundColor Red
            Write-Host " "
            Show-MenuDeployVirtualMachine
        }
    } 
}

#Function to show Users and Groups management menu
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
    Write-Host "3 - Create/Remove Users" -ForegroundColor Green
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

#Function to show Groups menu
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

#Function to show Users menu
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
    Write-Host "3 - Remove users from a group" -ForegroundColor Green
    Write-Host "4 - Exit" -ForegroundColor Green
    Write-Host " "

    # Prompt the user for a choice
    Write-Host "Enter your choice : " -ForegroundColor Yellow -NoNewline
    $choice = Read-Host

    switch ($choice) {
        1 {New-UserCSV}
        2 {New-User}
        3 { Remove-AllUsersGroup} 
        4 {Show-GroupsUsersMenu} #ok
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

# Function to get the file path of a CSV file
function Get-FilePath {
    # Display a message to the user to select a CSV file
    Write-Host "Please select a CSV file to import and create Groups on your Proxmox Server" -ForegroundColor Yellow

    # Add the necessary assembly for Windows Forms
    Add-Type -AssemblyName System.Windows.Forms

    # Create a new OpenFileDialog object with initial directory set to the desktop and filter for CSV files
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{
        InitialDirectory = [Environment]::GetFolderPath('Desktop')
        Filter = 'CSV Files (*.csv)|*.csv'
    }

    # Show the file dialog and check if the user selected a file
    if ($FileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        # If a file is selected, store the file path in the $path variable
        $path = $FileBrowser.FileName
    } else {
        # If no file is selected, display a warning message and call the function again
        Write-Host "Warning: No file selected! Please select a CSV file." -ForegroundColor Magenta
        Get-FilePath
        return
    }

    # Return the file path
    return $path
}

# Function to create Group(s) by CSV file
function New-GroupCSV {
    # Initialize counters for success, error, and warning
    $GroupsSuccess = 0
    $GroupsError = 0
    $GroupsWarning = 0

    # Get the file path from the user
    $path = Get-FilePath

    # Check if the file path is null
    if ($null -eq $path) {
        Write-Host "Error: No file selected. Please try again." -ForegroundColor Red
        # Recall the function to retry
        New-GroupCSV
        return
    }

    # Import the CSV file from the specified path
    $CSVFile = Import-Csv -Path $path

    Write-Host " "

    # Check if there are any group names in the CSV file
    if (($CSVFile.GroupName).Count -ge 1) {
        # Iterate through each group name in the CSV file
        foreach ($groupName in $CSVFile.GroupName) {
            # Check if the group name contains only allowed characters
            if ($groupName -notmatch "[^a-zA-Z0-9-_]") {
                # Check if the group already exists
                if ((Get-GroupExists $groupName) -EQ $false) {
                    try {
                        # Attempt to create the new group
                        $command = New-PveAccessGroups -Groupid $groupName -ErrorAction Stop

                        # Check if the group was created successfully
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

        # Display the summary of the group creation task
        Write-Host "Info: The task of creating groups is completed. During the task, there was -> " -ForegroundColor Yellow -NoNewline

        Write-Host "$GroupsSuccess Success" -ForegroundColor Green -NoNewline

        Write-Host " -> $GroupsWarning Warning" -ForegroundColor Magenta -NoNewline

        Write-Host " -> $GroupsError Error" -ForegroundColor Red

        Write-Host " "
        # Prompt the user to restart the group creation or return to the previous menu
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
        # Prompt the user to restart the group creation or return to the previous menu
        $choice = $(Write-Host "Type 1 to restart the creation of a groups or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choice -eq 1) {
            Clear-Host
            New-GroupCSV
        } else {
            Show-GroupsMenu
        }
    }
}

# Function to create a new group
function New-Group {
    # Prompt the user to enter the name of the new group
    $groupName = $(Write-Host "Enter name of the new Group : " -ForegroundColor Yellow -NoNewline; Read-Host)
    Write-Host " "

    # Check if the group already exists
    if ((Get-GroupExists $groupName) -EQ $false)
    {
        # Check if the group name contains only allowed characters
        if ($groupName -notmatch "[^a-zA-Z0-9-_]")
        {
            try {
                # Attempt to create the new group
                $command = New-PveAccessGroups -Groupid $groupName -ErrorAction Stop

                # Check if the group creation was successful
                if ($command.IsSuccessStatusCode -eq $true)
                {
                    Write-Host "Success: The group has been successfully created" -ForegroundColor Green
                }
                else {
                    Write-Host "Error: " $command.ReasonPhrase -ForegroundColor Red
                }
            }
            catch {
                # Handle any errors that occur during group creation
                Write-Host "Error: $_" -ForegroundColor Red
                Write-Host " "
                $choice = $(Write-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

                # Prompt the user to restart the group creation process or return to the previous menu
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

            # Prompt the user to restart the group creation process or return to the previous menu
            if ($choice -eq 1)
            {
                Clear-Host
                New-Group
            }

        }
        else {
            # Display an error message if the group name contains special characters
            Write-Host "Error: Your group name contains special characters" -ForegroundColor Red
            Write-Host " "
            $choice = $(Write-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

            # Prompt the user to restart the group creation process or return to the previous menu
            if ($choice -eq 1)
            {
                Clear-Host
                New-Group
            }
        }
    }
    else {
        # Display a warning message if the group already exists
        Write-Host "Warning: The group already exists on your Proxmox server." -ForegroundColor Magenta
        Write-Host " "
        $choice = $(Write-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

        # Prompt the user to restart the group creation process or return to the previous menu
        if ($choice -eq 1)
        {
            Clear-Host
            New-Group
        }
    }

    # Display the groups menu
    Show-GroupsMenu
}

# Function to get a password from the user
function Get-Password {

    # Prompt the user to enter a password
    $password = $(Write-Host "Enter the password of the new user : " -ForegroundColor Yellow -NoNewline; Read-Host -AsSecureString)

    # Check if the password length is less than or equal to 4 characters
    if ($password.Length -le 4)
    {
        # Display an error message if the password is too short
        Write-Host "Error : The password is not long enough. It must be at least 5 characters long" -ForegroundColor Red

        # Recursively call the function to prompt the user again
        Get-Password

        # Exit the function
        return
    }

    # Return the password if it meets the length requirement
    return $password
}

# Function to set user groups
function Set-UserGroups {
    param (
        [string]$UserName,  # The username to be added to the group
        [string]$GroupName # The group name to which the user will be added
    )

    # Check if the group exists
    if ((Get-GroupExists $GroupName) -EQ $false) {
        # Prompt the user to create the group if it does not exist
        $choice = $(Write-Host "Info : The group $GroupName does not exist. Would you like to create it? Type 1 to create the group or leave it blank to ignore" -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choice -eq 1) {
            # Validate the group name to ensure it does not contain special characters
            if ($GroupName -notmatch "[^a-zA-Z0-9-_]") {
                try {
                    # Attempt to create the group
                    $command = New-PveAccessGroups -Groupid $GroupName -ErrorAction Stop

                    if ($command.IsSuccessStatusCode -eq $true) {
                        Write-Host "Success : The group $($GroupName) has been successfully created" -ForegroundColor Green
                    } else {
                        Write-Host "Error : The group $($GroupName) has not been created -> $($command.ReasonPhrase)" -ForegroundColor Red
                    }
                } catch {
                    Write-Host "Error : The group $($GroupName) has not been created -> $_" -ForegroundColor Red
                }
            } else {
                Write-Host "Error : Your group $($GroupName) contains special characters" -ForegroundColor Red
            }
        } else {
            return
        }
    }

    try {
        # Attempt to add the user to the group
        $command = Set-PveAccessUsers -Userid "$UserName@pve" -Groups $GroupName

        if ($command.IsSuccessStatusCode -eq $true) {
            Write-Host "Success : The user $($UserName) added the group $($GroupName)" -ForegroundColor Green
        } else {
            Write-Host "Error : The user $($UserName) failed to add the group $($GroupName) -> $($command.ReasonPhrase)" -ForegroundColor Red
        }
    } catch {
        Write-Host "Error : The user $($UserName) failed to add the group $($GroupName) -> $_" -ForegroundColor Red
    }
}

# Function to create User(s) by CSV file
function New-UserCSV {
    # Initialize counters for successful, error, and warning user operations
    $UsersSuccess = 0
    $UsersError = 0
    $UsersWarning = 0
    $nbr = 1

    # Get the file path from the user
    $path = Get-FilePath

    # Check if the path is null (no file selected)
    if ($null -eq $path) {
        Write-Host "Error : No file selected. Please try again." -ForegroundColor Red
        # Recall the function to prompt the user again
        New-UserCSV
        return
    }

    Write-Host " "

    # Import the CSV file
    $CSVFile = Import-Csv -Path $path -Delimiter ","

    # Check if the CSV file contains at least one UserName
    if (($CSVFile.UserName).Count -ge 1) {
        # Loop through each user in the CSV file
        foreach ($user in $CSVFile) {
            $UserName = $user.UserName
            $PW = $user.Password

            # Check if UserName is null
            if ($null -eq $UserName) {
                Write-Host "Error : No UserName value found line $nbr" -ForegroundColor Red
                $nbr++
                $UsersError++
            } else {
                # Check if the user already exists
                if ((Get-UserExists $UserName) -eq $false) {
                    # Validate UserName format
                    if ($UserName -notmatch "[^a-zA-Z0-9-_]") {
                        # Check if Password is not null
                        if ($null -ne $PW) {
                            # Check if Password length is greater than 5
                            if ($PW.Length -gt 5) {
                                # Convert password to SecureString
                                $password = ConvertTo-SecureString -String $PW -AsPlainText -Force

                                try {
                                    # Create the user
                                    $command = New-PveAccessUsers -Userid "$UserName@pve" -Password $password -ErrorAction Stop

                                    # Check if the user creation was successful
                                    if ($command.IsSuccessStatusCode -eq $true) {
                                        Write-Host "Succes : The user name $($UserName) has been successfully created" -ForegroundColor Green
                                        $UsersSuccess++

                                        # Assign user to groups
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

                    # Assign user to groups
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

# Function to create a new user
function New-User {
    # Prompt the user to enter the name of the new user
    $userName = $(Write-Host "Enter name of the new User : " -ForegroundColor Yellow -NoNewline; Read-Host)

    # Check if the user already exists
    if ((Get-UserExists $userName) -eq $false)
    {
        # Validate the username to ensure it does not contain special characters
        if ($userName -notmatch "[^a-zA-Z0-9-_]")
        {
            # Get the password for the new user
            $password = Get-Password

            try {
                # Attempt to create the new user
                $command = New-PveAccessUsers -Userid "$userName@pve" -Password $password -ErrorAction Stop

                # Check if the user creation was successful
                if ($command.IsSuccessStatusCode -eq $true)
                {
                    Write-Host " "
                    Write-Host "Success: The user has been successfully created" -ForegroundColor Green
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
                # Prompt the user to retry or return to the previous menu
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
            Write-Host "Error: Your user name contains special characters" -ForegroundColor Red
            Write-Host " "
            # Prompt the user to retry or return to the previous menu
            $choice = $(Write-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

            if ($choice -eq 1)
            {
                Clear-Host
                New-User
            }
        }
    }
    else {
        Write-Host "Warning: The user already exists on your Proxmox server." -ForegroundColor Magenta
        Write-Host " "
        # Prompt the user to retry or return to the previous menu
        $choice = $(Write-Host "Type 1 to restart the creation of a group or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choice -eq 1) {
            Clear-Host
            New-User
        }
    }

    # Display the users menu
    Show-UsersMenu
}

# Function to check if a group exists
function Get-GroupExists {
    # Define the parameter for the function
    param (
        [string]$groupName
    )

    # Initialize the variable to true, assuming the group exists
    $GroupExists = $true

    # Check if the group does not exist in the list of access groups
    if ($null -eq ((Get-PveAccessGroups).ToData() | Where-Object groupid -EQ $groupName))
    {
        # If the group does not exist, set the variable to false
        $GroupExists = $false
    }

    # Return the result indicating whether the group exists or not
    return $GroupExists
}

# Function to check if a user exists
function Get-UserExists {
    # Define the parameter for the function
    param (
        [string]$userName
    )

    # Initialize the variable to true
    $UserExists = $true

    # Check if the user exists in the Proxmox VE access users list
    if($null -eq ((Get-PveAccessUsers).ToData() | Where-Object userid -eq "$userName@pve"))
    {
        # If the user does not exist, set the variable to false
        $UserExists = $false
    }

    # Return the result
    return $UserExists
}

# Function to retrieve and display groups from a Proxmox server
function Get-Groups {
    # Clear the console screen
    Clear-Host

    # Retrieve the groups from the Proxmox server and convert them to data
    $groups = (Get-PveAccessGroups).ToData()

    # Display a message indicating the list of existing groups
    Write-Host "Here are the existing groups on your Proxmox server :" -ForegroundColor Yellow

    # Display a separator line
    Write-Host "=====================================================" -ForegroundColor Cyan

    # Display the group IDs
    $groups.groupid

    # Call the function to show the groups and users menu
    Show-GroupsUsersMenu
}

# Function to retrieve and display users from a Proxmox server
function Get-Users {
    # Retrieve the list of users from the Proxmox server and convert it to data
    $users = (Get-PveAccessUsers).ToData()

    # Display a message indicating the list of existing users
    Write-Host "Here are the existing users on your Proxmox server :" -ForegroundColor Yellow

    # Display a separator line for better readability
    Write-Host "=====================================================" -ForegroundColor Cyan

    # Display the user IDs of the retrieved users
    $users.userid

    # Call the function to show the groups and users menu
    Show-GroupsUsersMenu
}

# Function to display Welcome message
function Get-Welcome {
    # Clear the console screen
    Clear-Host

    # Define the welcome page information
    $programName = "PROXIM"
    $version = "v1.0"
    $developer = "Corentin"
    $module = "Corsinvest.ProxmoxVE.Api"

    # Draw the program name in ASCII art
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
    # Read-Host "Press Enter to continue..."
}

# Function to get Group for a job
function Get-GroupDeploy {
    param (
        $type
    )

    $nbr = 1

    # Retrieve groups and convert to Data
    $groups = (Get-PveAccessGroups).ToData() | Sort-Object -Property Groupid

    # Check if there are any groups
    if ($groups.Groupid.Count -ge 1) {
        Clear-Host
        Write-Host "Here are the groups that exist:" -ForegroundColor Yellow
        Write-Host "=================================" -ForegroundColor Cyan

        # List groups
        foreach ($group in $groups) {
            Write-Host "$nbr -> $($group.Groupid)"
            $nbr++
        }

        # Loop to get user input
        while ($true) {
            Write-Host " "
            if ($type) {
                $choix = $(Write-Host "Which group would you like to remove this user from? (Use the number to indicate the group). Press E to exit the function : " -ForegroundColor Yellow -NoNewline; Read-Host)
            }
            else {
                $choix = $(Write-Host "Which group would you like to deploy virtual machines to? (Use the number to indicate the group). Press E to exit the function : " -ForegroundColor Yellow -NoNewline; Read-Host)
            }

            # Handle numeric input
            if ($choix -match '^\d+$') {
                $choix = [int]$choix
                $GroupsCount = $groups.Groupid.Count

                # Check if the input is within the valid range
                if ($choix -ge 1 -and $choix -le $GroupsCount) {
                    $choix = $choix - 1

                    # Check if the group has members
                    if ((Get-PveAccessGroupsIdx -Groupid $groups.Groupid[$choix]).ToData().Members.Count -ge 1) {
                        return $groups.Groupid[$choix]
                    }
                    else {
                        Write-Host " "
                        Write-Host "Error : The group $($groups.Groupid[$choix]) has no users." -ForegroundColor Red
                    }
                } else {
                    Write-Host " "
                    Write-Host "Error : Please enter a number between 1 and $GroupsCount, or 'E' to exit." -ForegroundColor Red
                }
            } elseif ($choix -eq "E") {
                if ($type) {
                    return $null
                }
                else {
                    Show-MenuDeployVirtualMachine
                    return
                }
            } else {
                Write-Host " "
                Write-Host "Error : Please enter a valid number or 'E' to exit." -ForegroundColor Red
            }
        }
    } else {
        Write-Host " "
        Write-Host "Error : No group was found" -ForegroundColor Red
        if ($type) {
            return $null
        }
        else {
            Show-MenuDeployVirtualMachine
            return
        }
    }
}

# Function to get the number of CPU cores to assign to an LXC/VM
function Get-CpuNbr {
    param (
        [string]$NodeName  # Parameter for the node name
    )

    # Get the maximum number of CPUs available on the specified node
    $Maxcpu = (Get-PveNode -Node $NodeName).maxcpu

    # Infinite loop to prompt the user until a valid input is provided
    while ($true) {

        $NbrCpu = 0  # Initialize the number of CPUs to 0

        # Clear the console and display the CPU configuration prompt
        Clear-Host
        Write-Host "CPU Config :" -ForegroundColor Yellow
        Write-Host "=============" -ForegroundColor Cyan

        # Prompt the user to enter a number between 1 and the maximum number of CPUs
        $choice = $(Write-Host "Please enter a number between 1 and $Maxcpu for the number of cores to assign to the machine(s) : " -ForegroundColor Yellow -NoNewline ; Read-Host)

        # Check if the input is a valid integer and within the specified range
        if ([int]::TryParse($choice, [ref]$NbrCpu) -and $NbrCpu -ge 1 -and $NbrCpu -le $Maxcpu) {
            return $NbrCpu  # Return the valid number of CPUs
            break  # Exit the loop
        }
        else {
            # Display an error message if the input is not valid
            Write-Host " "
            Write-Host "Error : Please enter a valid value" -ForegroundColor Red
        }
    }
}

# Function to get the amount of RAM to assign to an LXC/VM
function Get-Ram {
    # Parameter: NodeName - The name of the Proxmox node
    param (
        [string]$NodeName
    )

    # Get the maximum memory available on the specified Proxmox node
    $Maxram = (Get-PveNode -Node $NodeName).maxmem

    # Convert the maximum memory from bytes to megabytes and round down
    $Maxram = [Math]::Floor($Maxram / (1024 * 1024))

    # Loop until a valid RAM value is entered
    while ($true) {
        # Initialize the RAM value to 0
        $NbrRam = 0

        # Clear the console
        Clear-Host

        # Display the RAM configuration prompt
        Write-Host "RAM Config :" -ForegroundColor Yellow
        Write-Host "=============" -ForegroundColor Cyan

        # Prompt the user to enter a RAM value between 512 and the maximum available RAM
        $choice = $(Write-Host "Please enter a number between 512 and $Maxram for the amount of RAM in MB to assign to the machine(s) : " -ForegroundColor Yellow -NoNewline ; Read-Host)

        # Check if the entered value is a valid integer and within the specified range
        if ([int]::TryParse($choice, [ref]$NbrRam) -and $NbrRam -ge 512 -and $NbrRam -le $Maxram) {
            # Return the valid RAM value and exit the loop
            return $NbrRam
            break
        }
        else {
            # Display an error message if the entered value is invalid
            Write-Host " "
            Write-Host "Error : Please enter a valid value" -ForegroundColor Red
        }
    }
}

# Function to get LXC Template
function Get-LXCTemplate {
    $nbr = 1
    $templates = New-Object System.Collections.Generic.List[PSCustomObject]

    # Retrieve node data
    $nodes = (Get-PveNodes).ToData() | Sort-Object -Property Node

    Clear-Host
    Write-Host "Here are the templates that exist:" -ForegroundColor Yellow
    Write-Host "===================================" -ForegroundColor Cyan

    # Loop through each node
    foreach ($node in $nodes.node)
    {
        Write-Host "Node -> $($node)" -ForegroundColor Yellow

        # Retrieve storage data for the current node
        $storages = (Get-PveNodesStorage -Node $node).ToData() | Where-Object { $_.content -match "vztmpl" } | Sort-Object -Property storage

        # Loop through each storage
        foreach($storage in $storages)
        {
            # Retrieve template data for the current storage
            $TemplateNode = (Get-PveNodesStorageContent -Node $node -Storage $storage.storage).ToData() | Where-Object { $_.content -eq "vztmpl" } | Sort-Object -Property volid

            # Check if there are any templates
            if ($TemplateNode.Count -ge 1) {

                # Loop through each template
                foreach ($item in $TemplateNode) {
                    $templateName = ($item.volid).Split("/")[-1]

                    Write-Host "$nbr -> $templateName"

                    # Add template to the list
                    $templates.Add([PSCustomObject]@{
                        Index = $nbr
                        Node = $node
                        Volid = $item.volid
                    })

                    $nbr++
                }
            }
        }

        Write-Host " "
    }

    # Check if there are any templates found
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

# Function to configure LXC Deploy for a group
function New-DeployLXCGroup {

    # Default values for CPU, RAM, Hard Disk size, and other parameters
    $CPU = 1
    $Ram = 1024
    $HdSize = 16
    $HdPath = "local-lvm"
    $NicEth = "eth0"
    $HDDrive = $null
    $Password = "ApplePie"
    $LXCName = $null
    $ListNodesOk = @()
    $NodesList = @()
    $nodeIndex = 0

    # Get the group name for deployment
    $groupName = Get-GroupDeploy
    $HADeploy = Set-HALXCQemu

    # If group name is null, exit the function
    if ($null -eq $groupName) {
        return
    }

    # Get the number of deployments for the group
    $NbrDeploy = (Get-PveAccessGroupsIdx -Groupid $groupName).ToData().Members.Count
    $Vmid = (Get-LastVMID) + 1

    # Check if the group has members
    if ((Get-PveAccessGroupsIdx -Groupid $groupName).ToData().members.count -ge 1) {
        # Get the list of pools
        $ListPools = (Get-PvePools).ToData()

        # If the pool does not exist, create a new pool
        if (-not ($ListPools | Where-Object poolid -eq $groupName)) {
            $null = New-PvePools -Poolid $groupName
        }

        # Set access control for the pool
        $null = Set-PveAccessAcl -Path "/pool/$groupName" -Groups $groupName -Roles "PVEPoolUser"

        # Get the LXC template
        $Template = Get-LXCTemplate

        # Extract the LXC name from the template
        $LXCName = $Template.volid.Split("/")[1].Split("-")[0]

        # Clear the console and display default configuration
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

        # Loop to get user choice for configuration
        while ($true) {
            Write-Host " "
            $choice = $(Write-Host "Press 1 to use the default configuration, or press 2 to modify the values or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

            if ($choice -eq 1) {
                # Set default NIC, HDDrive, and Password
                $Nic = @{1='name=eth0,firewall=1,bridge=vmbr0,ip=dhcp'}
                $HDDrive = $HdPath + ":" + $HdSize
                $Password = ConvertTo-SecureString $Password -AsPlainText -Force

                # Get the list of nodes
                $ListNodes = ((Get-PveNodes).ToData() | Sort-Object -Property node).node

                # Filter nodes based on storage and template availability
                foreach($node in $ListNodes) {
                    if((Get-PveNodesStorage -Node $node).ToData() | Where-Object storage -eq $($HDDrive.split(":")[0])) {
                        if ((Get-PveNodesStorageContent -Node $node -Storage ($Template.volid.Split(":")[0])).ToData() | Where-Object { $_.volid -eq $Template.volid }) {
                            $NodesList += $node
                        }
                    }
                }

                # Check disk space on nodes
                foreach ($node in $NodesList) {
                    if (Get-DiskSpaceOK -NodeName $node -HDDrive $HDDrive -NbrDeploy $NbrDeploy) {
                        $ListNodesOk += $node
                    }
                }

                # Deploy LXC containers if there are enough nodes with sufficient disk space
                if ($ListNodesOk.count -ge 1) {
                    Clear-Host

                    foreach($user in (Get-PveAccessGroupsIdx -Groupid $groupName).ToData().members) {
                        if ($ListNodesOk.Count -eq 1) {
                            $node = $ListNodesOk[0]
                        } else {
                            $node = $ListNodesOk[$nodeIndex]
                        }

                        $name = $LXCName + "-" + $Vmid
                        $command = Set-LXC -NodeName $Node -Cpu $CPU -Ram $Ram -HDDrive $HDDrive -Ostemplate $Template.volid -Vmid $Vmid -LXCName $name -Password $Password -Nic $Nic -group $groupName

                        if ($true -eq $command) {
                            $command  = Set-PveAccessAcl -Roles PVEVMUser -Users $user -Path /vms/$Vmid

                            if ($true -eq $command.IsSuccessStatusCode) {
                                if ($HADeploy -and $HADeploy.Count -eq 1) {
                                    $null = New-PveClusterHaResources -Sid $Vmid -Group $HADeploy -MaxRelocate 1 -MaxRestart 1 -State ignored
                                }
                            }
                        }

                        $Vmid++
                        $nodeIndex = ($nodeIndex + 1) % $ListNodesOk.Count
                    }
                } else {
                    Write-Host "Error : Unable to create $NbrDeploy machines for the group $groupName" -ForegroundColor Red
                }

                break
            } elseif ($choice -eq 2) {
                # Get custom configuration values
                $CPU = Get-CpuNbr $Template.Node
                $Ram = Get-Ram $Template.Node
                $Nic = Get-NicLXC $Template.Node

                $diskLxc = Get-Disk -NodeName $Template.Node -type "rootdir"
                $sizeDiskLxc = Get-SizeDiskLXC
                $HDDrive = "$($diskLxc.Storage):$($sizeDiskLxc)"
                $DynamicDeploy = Get-DynamicDeploy

                # Clear the console and display custom configuration
                Clear-Host
                Write-Host "Custom Configuration for LXC :" -ForegroundColor Yellow
                Write-Host "===============================" -ForegroundColor Cyan
                Write-Host "CPU -> $Cpu core(s)"
                Write-Host "RAM -> $Ram MB"
                Write-Host "Hard Disk -> $($HDDrive.split(":")[1]) GB at $($HDDrive.split(":")[0])"
                if($nic.Values.split("=").split(",").count -eq 6) {
                    Write-Host "NIC -> $($nic.Values.split("=").split(",")[1]) (vmbr0)"
                } elseif ($nic.Values.split("=").split(",").count -eq 8) {
                    Write-Host "NIC -> $($nic.Values.split("=").split(",")[1]) (vmbr0) VLAN $($nic.Values.split("=").split(",")[7])"
                }
                Write-Host "OS -> $(($Template.volid).Split("/")[-1])"
                Write-Host "Name LXC -> $LXCName-VMID"

                # Loop to confirm custom configuration
                while ($true) {
                    Write-Host " "
                    $choix = $(Write-Host "Is the configuration correct? (Y/N)" -ForegroundColor Yellow -NoNewline; Read-Host)

                    if ($choix -eq "Y" -or $choix -eq "N") {

                        if ($choix -eq "Y") {

                            # If dynamic deployment is enabled, get the list of nodes
                            if($true -eq $DynamicDeploy) {
                                $ListNodes = ((Get-PveNodes).ToData() | Sort-Object -Property node).node

                                foreach($node in $ListNodes) {
                                    if((Get-PveNodesStorage -Node $node).ToData() | Where-Object storage -eq $($HDDrive.split(":")[0])) {
                                        if ((Get-PveNodesStorageContent -Node $node -Storage ($Template.volid.Split(":")[0])).ToData() | Where-Object { $_.volid -eq $Template.volid }) {
                                            $NodesList += $node
                                        }
                                    }
                                }
                            } else {
                                $NodesList += $Template.Node
                            }

                            # Check disk space on nodes
                            foreach ($node in $NodesList) {
                                if (Get-DiskSpaceOK -NodeName $node -HDDrive $HDDrive -NbrDeploy $NbrDeploy) {
                                    $ListNodesOk += $node
                                }
                            }

                            # Deploy LXC containers if there are enough nodes with sufficient disk space
                            if ($ListNodesOk.count -ge 1) {
                                Clear-Host

                                $Password = Get-PasswordLXC

                                Clear-Host

                                foreach($user in (Get-PveAccessGroupsIdx -Groupid $groupName).ToData().members) {
                                    if ($ListNodesOk.Count -eq 1) {
                                        $node = $ListNodesOk[0]
                                    } else {
                                        $node = $ListNodesOk[$nodeIndex]
                                    }

                                    $name = $LXCName + "-" + $Vmid
                                    $command = Set-LXC -NodeName $node -Cpu $CPU -Ram $Ram -HDDrive $HDDrive -Ostemplate $Template.volid -Vmid $Vmid -LXCName $name -Password $Password -Nic $Nic -group $groupName

                                    if ($true -eq $command) {
                                        $command  = Set-PveAccessAcl -Roles PVEVMUser -Users $user -Path /vms/$Vmid

                                        if ($true -eq $command.IsSuccessStatusCode) {
                                            if ($HADeploy -and $HADeploy.Count -eq 1) {
                                                $null = New-PveClusterHaResources -Sid $Vmid -Group $HADeploy -MaxRelocate 1 -MaxRestart 1 -State ignored
                                            }
                                        }
                                    }

                                    $Vmid++
                                    $nodeIndex = ($nodeIndex + 1) % $ListNodesOk.Count
                                }
                            } else {
                                Write-Host "Error : Unable to create $NbrDeploy machines for the group $groupName" -ForegroundColor Red
                            }

                            break
                        } else {
                            Show-MenuDeployVirtualMachine
                            break
                        }

                        break
                    } else {
                        Write-Host " "
                        Write-Host "Error : Please enter a valid value" -ForegroundColor Red
                    }
                }
                break
            } elseif ([string]::IsNullOrWhiteSpace($choice)) {
                Show-MenuDeployVirtualMachine
                return
            } else {
                Write-Host " "
                Write-Host "Error : Please enter a correct value" -ForegroundColor Red
            }
        }
    } else {
        Write-Host " "
        Write-Host "Error : The group $groupName does not contain any users." -ForegroundColor Red
    }

    Show-MenuDeployVirtualMachine
}

# Function to set up an LXC container
function Set-LXC {
    param (
        [string]$NodeName,     # The name of the node where the LXC container will be created
        [int]$Cpu,              # The number of CPU cores to allocate to the LXC container
        [int]$Ram,              # The amount of RAM to allocate to the LXC container
        [string]$HDDrive,       # The root filesystem for the LXC container
        [string]$Ostemplate,    # The operating system template to use for the LXC container
        [int]$Vmid,             # The VM ID for the LXC container
        [System.Security.SecureString]$Password, # The password for the LXC container
        [string]$LXCName,       # The hostname for the LXC container
        [hashtable]$Nic,        # The network configuration for the LXC container
        [string]$group          # The resource pool for the LXC container
    )

    # Create the LXC container using the provided parameters
    $command = New-PvenodesLxc -Node $NodeName -Vmid $Vmid -Ostemplate $Ostemplate -Cores $Cpu -Memory $Ram -Rootfs $HDDrive -NetN $Nic -Password $Password -Hostname $LXCName -Pool $group

    # Check if the command was successful
    if ($command.IsSuccessStatusCode -eq $true)
    {
        # If successful, display a success message
        Write-Host "Success: The LXC container $LXCName has been successfully created" -ForegroundColor Green
        return $true
    }
    else {
        # If not successful, display an error message with the reason
        Write-Host "Error: The LXC container $LXCName cannot be created -> $($command.ReasonPhrase)" -ForegroundColor Red
        return $false
    }
}

# Function to check if there is enough disk space for deployment
function Get-DiskSpaceOK {
    param (
        [string]$NodeName,  # The name of the node
        [string]$HDDrive,   # The hard drive information in the format "DriveLetter:Size"
        [int]$NbrDeploy     # The number of deployments
    )

    # Split the hard drive information into drive letter and size
    $Disk = $HDDrive.Split(":")

    # Calculate the total space required for the deployments
    $SpaceRequired = [int]$Disk[1] * $NbrDeploy

    # Get the disk information for the specified node and storage
    $DiskInfo = (Get-PveNodesStorage -Node $NodeName).ToData() | Where-Object { $_.storage -eq $Disk[0] }

    # Calculate the free space available in GB
    $FreeSpace = [Math]::Floor($DiskInfo.avail / (1024 * 1024 * 1024))

    # Check if the required space is less than the available free space
    if ($SpaceRequired -lt $FreeSpace) {
        return $true  # Return true if there is enough space
    }
    else {
        Write-Host " "
        # Display an error message if there is not enough space
        Write-Host "Error: There is not enough space to create all the machines. Free space -> $FreeSpace GB, Required space -> $SpaceRequired GB" -ForegroundColor Red
        return $false  # Return false if there is not enough space
    }
}

# Function to get network interface card (NIC) for LXC
function Get-NicLXC {
    param (
        [string]$NodeName  # The name of the Proxmox node
    )

    # Get the list of network interfaces of type 'bridge' for the specified node
    $ListNic = (Get-PveNodesNetwork -node $NodeName).ToData() | Where-Object type -eq 'bridge'

    # Initialize a counter for the network interfaces
    $nbr = 1

    # Clear the console
    Clear-Host

    # Display a header for the network interfaces
    Write-Host "NIC on your Proxmox Server :" -ForegroundColor Yellow
    Write-Host "=============================" -ForegroundColor Cyan

    # Loop through each network interface and display its details
    foreach($Nic in $ListNic)
    {
        Write-Host "$nbr -> $($Nic.iface)"
        $nbr++
    }

    # Get the count of network interfaces
    $NicCount = $ListNic.Count

    # Loop until a valid network interface number is chosen
    while ($true) {
        Write-Host " "
        $choix = $(Write-Host "Choose a network card by providing its number : " -ForegroundColor Yellow -NoNewline; Read-Host)

        # Check if the input is a valid number
        if ($choix -match '^\d+$')
        {
            $choix = [int]$choix

            # Check if the number is within the valid range
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

    # Loop until a valid choice for VLAN configuration is made
    while ($true) {
        Write-Host " "
        $choix = $(Write-Host "Do you want to configure a VLAN on the network card ? (Y/N)" -ForegroundColor Yellow -NoNewline; Read-Host)

        # Check if the input is 'Y' or 'N'
        if ($choix -eq "Y" -or $choix -eq "N") {

            if ($choix -eq "Y") {
                # Get the VLAN ID if the user chooses to configure a VLAN
                $vlan = Get-Vlan

                # Create a network card configuration with VLAN
                $NetworkCard = @{1="name=eth0,firewall=1,bridge=$($Nic.iface),ip=dhcp,tag=$vlan"}

                return $NetworkCard
            }

            # Create a network card configuration without VLAN
            $NetworkCard = @{1="name=eth0,firewall=1,bridge=$($Nic.iface),ip=dhcp"}

            Return $NetworkCard
        }
        else {
            Write-Host " "
            Write-Host "Error : Please enter a valid value" -ForegroundColor Red
        }
    }
}

# Function to get a valid VLAN number from the user
function Get-Vlan {

    # Infinite loop to keep asking for input until a valid VLAN number is provided
    while ($true) {

        # Print a blank line for better readability
        Write-Host " "

        # Prompt the user to enter a VLAN number between 1 and 4094
        $choix = $(Write-Host "Please indicate the VLAN number to configure (1-4094) : " -ForegroundColor Yellow -NoNewline; Read-Host)

        # Check if the input is a number
        if ($choix -match '^\d+$') {

            # Convert the input to an integer
            $choix = [int]$choix

            # Check if the number is within the valid range (1-4094)
            if ($choix -ge 1 -and $choix -le 4094) {
                # Return the valid VLAN number and exit the loop
                return $choix
                break
            }
            else {
                # Print a blank line for better readability
                Write-Host " "
                # Display an error message if the number is not within the valid range
                Write-Host "Error : Please enter a number between 1 and 4094." -ForegroundColor Red
            }
        }
        else {
            # Print a blank line for better readability
            Write-Host " "
            # Display an error message if the input is not a number
            Write-Host "Error : Please enter a number between 1 and 4094." -ForegroundColor Red
        }

    }
}

# Function to get the last VM ID from Proxmox VE
function Get-LastVMID {
    # Retrieve all VM IDs from Proxmox VE
    $maxVmid = (Get-PveVm).vmid | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum

    # If no VM IDs are found, set the maximum VM ID to 99
    if ($null -eq $maxVmid) {
        $maxVmid = 99
    }

    # Return the maximum VM ID
    return $maxVmid
}

# Function to get the size of the disk for LXC
function Get-SizeDiskLXC {

    # Infinite loop to keep asking for input until a valid size is entered
    while ($true) {
        # Print a new line for better readability
        Write-Host " "

        # Prompt the user to enter the size of the disk in GB
        $choix = $(Write-Host "Please indicate the size of the disk in GB (Min 8GB/ Max 32GB) : " -ForegroundColor Yellow -NoNewline; Read-Host)

        # Check if the input is a number
        if ($choix -match '^\d+$') {
            # Convert the input to an integer
            $choix = [int]$choix

            # Check if the number is within the valid range (8GB to 32GB)
            if ($choix -ge 8 -and $choix -le 32) {
                # Return the valid size and exit the loop
                return $choix
                break
            }
            else {
                # Print a new line for better readability
                Write-Host " "
                # Display an error message if the number is not within the valid range
                Write-Host "Error : Please enter a number between 8GB and 32GB." -ForegroundColor Red
            }
        }
        else {
            # Print a new line for better readability
            Write-Host " "
            # Display an error message if the input is not a number
            Write-Host "Error : Please enter a number between 8GB and 32GB." -ForegroundColor Red
        }
    }
}

# Function to get a template clone from Proxmox
function Get-TemplateClone {
    # Initialize the counter
    $nbr = 1

    # Get the list of templates from Proxmox where the template flag is set to 1
    $ListTemplate = (Get-PveVm) | Where-Object template -eq 1

    # Check if there are any templates available
    if ($ListTemplate.count -ge 1) {
        # Clear the console
        Clear-Host

        # Display the header for the list of templates
        Write-Host "Template that exists on your Proxmox :" -ForegroundColor Yellow
        Write-Host "=======================================" -ForegroundColor Cyan

        # Loop through each template and display its name and type
        foreach($Template in $ListTemplate) {
            Write-Host "$nbr -> $($Template.name) type $($Template.type)"
            $nbr++
        }

        # Loop to get user input for template selection
        while ($true) {
            Write-Host " "
            # Prompt the user to choose a template by number
            $choix = $(Write-Host "Please choose a template ! (Use the number to indicate the template): " -ForegroundColor Yellow -NoNewline; Read-Host)

            # Handle numeric input
            if ($choix -match '^\d+$') {
                $choix = [int]$choix
                $ListTemplateCount = $ListTemplate.Count

                # Check if the input number is within the valid range
                if ($choix -ge 1 -and $choix -le $ListTemplateCount) {
                    $choix = $choix - 1
                    # Return the selected template
                    return $ListTemplate[$choix]
                } else {
                    Write-Host " "
                    # Display error message if the input number is out of range
                    Write-Host "Error : Please enter a number between 1 and $ListTemplateCount." -ForegroundColor Red
                }
            } else {
                Write-Host " "
                # Display error message if the input is not a valid number
                Write-Host "Error : Please enter a valid number." -ForegroundColor Red
            }
        }
    } else {
        Write-Host " "
        # Display error message if no templates are found
        Write-Host "Error : No template was found" -ForegroundColor Red
        # Call the function to show the virtual machine deployment menu
        Show-MenuDeployVirtualMachine
        return
    }
}

# Function to get a password for LXC configuration
function Get-PasswordLXC {
    # Clear the console screen
    Clear-Host

    # Display a header for the password configuration section
    Write-Host "Password Configuration :" -ForegroundColor Yellow
    Write-Host "=========================" -ForegroundColor Cyan

    # Loop until a valid password is entered
    while ($true) {
        # Prompt the user to enter a password that is at least 5 characters long
        $choice = $(Write-Host "Please enter the password to set for the LXC (minimum of 5 characters long) : " -ForegroundColor Yellow -NoNewline; Read-Host)

        # Check if the entered password meets the minimum length requirement
        if ($choice.Length -ge 5) {
            # Convert the entered password to a secure string
            $Password = ConvertTo-SecureString $choice -AsPlainText -Force
            # Return the secure string password
            return $Password
        }
        else {
            # Display an error message if the password is too short
            Write-Host " "
            Write-Host "Error : The password must be at least 5 characters long" -ForegroundColor Red
            Write-Host " "
        }
    }
}

# Function to clone a template
function New-CloneTemplate {
    # Get the group name for deployment
    $groupName = Get-GroupDeploy

    # Check if the group name is null
    if($null -eq $groupName)
    {
        # If group name is null, show the deploy virtual machine menu and return
        Show-MenuDeployVirtualMachine
        return
    }

    # Get the list of pools
    $ListPools = (Get-PvePools).ToData()

    # Check if the group name exists in the list of pools
    if (-not ($ListPools | Where-Object poolid -eq $groupName)) {
        # If the group name does not exist, create a new pool with the group name
        $null = New-PvePools -Poolid $groupName
    }

    # Set access ACL for the pool
    $null = Set-PveAccessAcl -Path "/pool/$groupName" -Groups $groupName -Roles "PVEPoolUser"

    # Set HA deployment configuration
    $HADeploy = Set-HALXCQemu

    # Get the number of deployments for the group
    $NbrDeploy = (Get-PveAccessGroupsIdx -Groupid $groupName).ToData().Members.Count
    # Get the template to clone
    $Template = Get-TemplateClone
    # Get the last VM ID and increment by 1
    $Vmid = (Get-LastVMID) + 1
    # Initialize network interfaces array
    $networkInterfaces = @()
    # Set full clone flag to true
    $FullClone = $true
    # Initialize node index
    $nodeIndex = 0
    # Initialize list of OK nodes
    $ListNodesOk = @()
    # Initialize list of nodes
    $NodesList =@()

    # Check if the template type is LXC
    if($Template.type -eq "lxc")
    {
        # Get the LXC configuration for the template
        $LxcConfig = (Get-PveNodesLxcConfig -Node $Template.node -Vmid $Template.vmid).ToData()

        # Extract network interfaces from the LXC configuration
        foreach($line in $LxcConfig.PSObject.Properties)
        {
            if ($line.Name -match '^net\d+$') {
                $networkInterfaces += $line.Value
            }
        }

        # Clear the console and display LXC template configuration
        Clear-Host
        Write-Host "Template Clone LXC Config :" -ForegroundColor Yellow
        Write-Host "===========================" -ForegroundColor Cyan
        Write-Host "CPU -> $($LxcConfig.cores) core(s)"
        Write-Host "RAM -> $($LxcConfig.memory) MB"
        Write-Host "Hard Disk -> $($LxcConfig.rootfs.Split(":").Split(",").Split("=")[-1]) GB at $($LxcConfig.rootfs.Split(":")[0])"

        # Display network interfaces
        if ($networkInterfaces.Count -ge 1) {
            foreach($Nic in $networkInterfaces)
            {
                if($Nic.Split(",").Count -eq 7)
                {
                    if($Nic.Split(",").Split("=")[10] -eq "tag")
                    {
                        Write-Host "NIC -> $($nic.split("=").split(",")[1]) VLAN $($nic.split("=").split(",")[11])"
                    }
                    else {
                        Write-Host "NIC -> $($nic.split("=").split(",")[1])"
                    }
                }
                elseif($Nic.Split(",").Count -eq 8)
                {
                    if($Nic.Split(",").Split("=")[12] -eq "tag")
                    {
                        Write-Host "NIC -> $($nic.split("=").split(",")[1]) VLAN $($nic.split("=").split(",")[13])"
                    }
                    else {
                        Write-Host "NIC -> $($nic.split("=").split(",")[1])"
                    }
                }
                else {
                    Write-Host "NIC -> $($nic.split("=").split(",")[1])"
                }
            }
        }
        else {
            Write-Host "Nic -> No network card found"
        }

        Write-Host "OS -> $($LxcConfig.ostype)"
        Write-Host "Name LXC -> $($LxcConfig.hostname)-VMID"

        # Loop to get user choice for configuration
        while ($true) {
            Write-Host " "
            $choice = $(Write-Host "Press 1 to use the current configuration, or press 2 to modify storage Pool or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

            if ($choice -eq 1)
            {
                $FullClone = Get-FullClone
                Clear-Host
                $HDDrive = "$($LxcConfig.rootfs.Split(":")[0]):$($LxcConfig.rootfs.Split(":").Split(",").Split("=")[-1].Replace("G", " "))"

                # Get list of nodes with available storage
                $ListNodes = ((Get-PveNodes).ToData() | Sort-Object -Property node).node

                foreach($node in $ListNodes)
                {
                    if((Get-PveNodesStorage -Node $node).ToData() | Where-Object storage -eq $($HDDrive.split(":")[0]))
                    {
                        $NodesList += $node
                    }
                }

                foreach ($node in $NodesList) {
                    if (Get-DiskSpaceOK -NodeName $node -HDDrive $HDDrive -NbrDeploy $NbrDeploy) {
                        $ListNodesOk += $node
                    }
                }

                if ($ListNodesOk.count -ge 1) {
                    Clear-Host

                    foreach($user in (Get-PveAccessGroupsIdx -Groupid $groupName).ToData().members)
                    {
                        $name = $LxcConfig.hostname + "-" + $Vmid

                        if ($ListNodesOk.Count -eq 1) {
                            $node = $ListNodesOk[0]
                        }
                        else {
                            $node = $ListNodesOk[$nodeIndex]
                        }

                        $command = New-CloneLXCTemplate -LxcConfig $LxcConfig -Template $Template -name $name -Vmid $Vmid -groupName $groupName -Storage $Disk -FullClone $FullClone -Node $Node

                        if ($true -eq $command) {
                            $command  = Set-PveAccessAcl -Roles PVEVMUser -Users $user -Path /vms/$Vmid

                            if ($true -eq $command.IsSuccessStatusCode) {
                                if ($HADeploy -and $HADeploy.Count -eq 1) {
                                    $null = New-PveClusterHaResources -Sid $Vmid -Group $HADeploy -MaxRelocate 1 -MaxRestart 1 -State ignored
                                }
                            }
                        }

                        $Vmid++
                        $nodeIndex = ($nodeIndex + 1) % $ListNodesOk.Count
                    }
                }
                else
                {
                    Write-Host "Error : Unable to create $NbrDeploy machines for the group $groupName" -ForegroundColor Red
                }

                break
            }
            elseif ($choice -eq 2) {
                $diskLxc = Get-Disk -NodeName $Template.Node -type "rootdir" -shared $true
                $Disk = $diskLxc.Storage
                $Node = $diskLxc.node

                $DynamicDeploy = Get-DynamicDeploy

                while ($true) {
                    Write-Host " "
                    $choix = $(Write-Host "Are you sure to use the storage pool $Disk for the deployment? (Y/N)" -ForegroundColor Yellow -NoNewline; Read-Host)

                    if ($choix -eq "Y" -or $choix -eq "N") {
                        if ($choix -eq "Y") {
                            if ($Disk -eq $LxcConfig.rootfs.Split(":")[0]) {
                                $FullClone = Get-FullClone
                            }

                            $HDDrive = "$($Disk):$($LxcConfig.rootfs.Split(":").Split(",").Split("=")[-1].Replace("G", " "))"

                            if($true -eq $DynamicDeploy)
                            {
                                $ListNodes = ((Get-PveNodes).ToData() | Sort-Object -Property node).node

                                foreach($node in $ListNodes)
                                {
                                    if((Get-PveNodesStorage -Node $node).ToData() | Where-Object storage -eq $($HDDrive.split(":")[0]))
                                    {
                                        $NodesList += $node
                                    }
                                }
                            }
                            else{
                                $NodesList += $node
                            }

                            foreach ($node in $NodesList) {
                                if (Get-DiskSpaceOK -NodeName $node -HDDrive $HDDrive -NbrDeploy $NbrDeploy) {
                                    $ListNodesOk += $node
                                }
                            }

                            if ($ListNodesOk.count -ge 1) {
                                Clear-Host

                                foreach($user in (Get-PveAccessGroupsIdx -Groupid $groupName).ToData().members)
                                {
                                    $name = $LxcConfig.hostname + "-" + $Vmid

                                    if ($ListNodesOk.Count -eq 1) {
                                        $node = $ListNodesOk[0]
                                    }
                                    else {
                                        $node = $ListNodesOk[$nodeIndex]
                                    }

                                    $command = New-CloneLXCTemplate -LxcConfig $LxcConfig -Template $Template -name $name -Vmid $Vmid -groupName $groupName -Storage $Disk -FullClone $FullClone -Node $Node

                                    if ($true -eq $command) {
                                        $command  = Set-PveAccessAcl -Roles PVEVMUser -Users $user -Path /vms/$Vmid

                                        if ($true -eq $command.IsSuccessStatusCode) {
                                            if ($HADeploy -and $HADeploy.Count -eq 1) {
                                                $null = New-PveClusterHaResources -Sid $Vmid -Group $HADeploy -MaxRelocate 1 -MaxRestart 1 -State ignored
                                            }
                                        }
                                    }

                                    $Vmid++
                                    $nodeIndex = ($nodeIndex + 1) % $ListNodesOk.Count
                                }
                            }
                            else
                            {
                                Write-Host "Error : Unable to create $NbrDeploy machines for the group $groupName" -ForegroundColor Red
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

        Show-MenuDeployVirtualMachine
        return
    }
    elseif($Template.type -eq "qemu")
    {
        # Get the QEMU configuration for the template
        $QemuConfig = (Get-PveNodesQemuConfig -Node $Template.node -Vmid $Template.vmid).ToData()

        # Extract disks and network interfaces from the QEMU configuration
        $ListDisks = $QemuConfig.PSObject.Properties | Where-Object {
            $_.Value -match "vm-$($Template.vmid)-disk" -or $_.Value -match "base-$($Template.vmid)-disk" -and
            $_.Name -notmatch "efidisk\d+" -and $_.Name -notmatch "tpmstate\d+"
        }

        foreach($line in $QemuConfig.PSObject.Properties)
        {
            if ($line.Name -match '^net\d+$') {
                $networkInterfaces += $line.Value
            }
        }

        $NbrDisk = 1
        $NbrNic = 1

        # Clear the console and display QEMU template configuration
        Clear-Host
        Write-Host "Template Clone VM Config :" -ForegroundColor Yellow
        Write-Host "===========================" -ForegroundColor Cyan
        Write-Host "CPU -> $($QemuConfig.cores) core(s)"
        Write-Host "RAM -> $($QemuConfig.memory) MB"

        # Display disks
        foreach($Disk in $ListDisks)
        {
            Write-Host "Hard Disk $NbrDisk-> $($Disk.value.Split("=")[-1].Replace("G", " "))GB at $($Disk.value.Split(":")[0])"

            $NbrDisk++
        }

        # Display network interfaces
        if ($networkInterfaces.Count -ge 1) {
            foreach($Nic in $networkInterfaces)
            {
                if($Nic.Split(",").Count -eq 4)
                {
                    if($Nic.Split(",").Split("=")[6] -eq "tag")
                    {
                        Write-Host "NIC $NbrNic-> $($nic.split("=").split(",")[3]) VLAN $($nic.split("=").split(",")[7])"
                    }
                    else {
                        Write-Host "NIC $NbrNic-> $($nic.split("=").split(",")[3])"
                    }
                }
                elseif($Nic.Split(",").Count -eq 3)
                {
                    if($Nic.Split(",").Split("=")[4] -eq "tag")
                    {
                        Write-Host "NIC $NbrNic-> $($nic.split("=").split(",")[3]) VLAN $($nic.split("=").split(",")[5])"
                    }
                    else {
                        Write-Host "NIC $NbrNic-> $($nic.split("=").split(",")[3]) "
                    }
                }
                else {
                    Write-Host "NIC $NbrNic-> $($nic.split("=").split(",")[3])"
                }

                $NbrNic++
            }
        }
        else {
            Write-Host "Nic -> No network card found"
        }

        Write-Host "OS -> $($QemuConfig.ostype)"
        Write-Host "Name VM -> $($QemuConfig.name)-VMID"

        # Loop to get user choice for configuration
        while ($true) {
            Write-Host " "
            $choice = $(Write-Host "Press 1 to use the current configuration, or press 2 to modify storage Pool or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

            if ($choice -eq 1)
            {
                $FullClone = Get-FullClone

                Clear-Host

                $SystemDisk = $QemuConfig.PSObject.Properties | Where-Object {
                    $_.Value -match "base-$($Template.vmid)-disk" -and
                    $_.Name -notmatch "efidisk\d+" -and $_.Name -notmatch "tpmstate\d+"
                }

                $HDDrive = "$($SystemDisk.value.Split(":")[0]):$($SystemDisk.value.Split("=")[-1].Replace("G", " "))"

                # Get list of nodes with available storage
                $ListNodes = ((Get-PveNodes).ToData() | Sort-Object -Property node).node

                foreach($node in $ListNodes)
                {
                    if((Get-PveNodesStorage -Node $node).ToData() | Where-Object storage -eq $($HDDrive.split(":")[0]))
                    {
                        $NodesList += $node
                    }
                }

                foreach ($node in $NodesList) {
                    if (Get-DiskSpaceOK -NodeName $node -HDDrive $HDDrive -NbrDeploy $NbrDeploy) {
                        $ListNodesOk += $node
                    }
                }

                if ($ListNodesOk.count -ge 1) {
                    Clear-Host

                    foreach($user in (Get-PveAccessGroupsIdx -Groupid $groupName).ToData().members)
                    {
                        $name = $QemuConfig.name + "-" + $Vmid

                        if ($ListNodesOk.Count -eq 1) {
                            $node = $ListNodesOk[0]
                        }
                        else {
                            $node = $ListNodesOk[$nodeIndex]
                        }

                        $command = New-CloneVMTemplate -QemuConfig $QemuConfig -Template $Template -name $name -Vmid $Vmid -groupName $groupName -FullClone $FullClone -Node $node

                        if ($true -eq $command) {
                            $command  = Set-PveAccessAcl -Roles PVEVMUser -Users $user -Path /vms/$Vmid

                            if ($true -eq $command.IsSuccessStatusCode) {
                                if ($HADeploy -and $HADeploy.Count -eq 1) {
                                    $null = New-PveClusterHaResources -Sid $Vmid -Group $HADeploy -MaxRelocate 1 -MaxRestart 1 -State ignored
                                }
                            }
                        }

                        $Vmid++
                        $nodeIndex = ($nodeIndex + 1) % $ListNodesOk.Count
                    }
                }
                else
                {
                    Write-Host "Error : Unable to create $NbrDeploy machines for the group $groupName" -ForegroundColor Red
                }

                Break
            }
            elseif ($choice -eq 2) {
                $DiskQemu = Get-Disk -NodeName $Template.node -type "images" -shared $true
                $Disk = $diskQemu.Storage
                $node = $DiskQemu.node

                $DynamicDeploy = Get-DynamicDeploy

                while ($true) {
                    Write-Host " "
                    $choix = $(Write-Host "Are you sure to use the storage pool $Disk for the deployment? (Y/N)" -ForegroundColor Yellow -NoNewline; Read-Host)

                    if ($choix -eq "Y" -or $choix -eq "N") {
                        if ($choix -eq "Y") {
                            Clear-Host

                            $SystemDisk = $QemuConfig.PSObject.Properties | Where-Object {
                                $_.Value -match "base-$($Template.vmid)-disk" -and
                                $_.Name -notmatch "efidisk\d+" -and $_.Name -notmatch "tpmstate\d+"
                            }

                            if ($Disk -eq $SystemDisk.value.Split(":")[0]) {
                                $FullClone = Get-FullClone
                            }

                            $HDDrive = "$($Disk):$($SystemDisk.value.Split("=")[-1].Replace("G", " "))"

                            if($true -eq $DynamicDeploy)
                            {
                                $ListNodes = ((Get-PveNodes).ToData() | Sort-Object -Property node).node

                                foreach($node in $ListNodes)
                                {
                                    if((Get-PveNodesStorage -Node $node).ToData() | Where-Object storage -eq $($HDDrive.split(":")[0]))
                                    {
                                        $NodesList += $node
                                    }
                                }
                            }
                            else{
                                $NodesList += $node
                            }

                            foreach ($node in $NodesList) {
                                if (Get-DiskSpaceOK -NodeName $node -HDDrive $HDDrive -NbrDeploy $NbrDeploy) {
                                    $ListNodesOk += $node
                                }
                            }

                            if ($ListNodesOk.count -ge 1) {
                                Clear-Host

                                foreach($user in (Get-PveAccessGroupsIdx -Groupid $groupName).ToData().members)
                                {
                                    $name = $QemuConfig.name + "-" + $Vmid

                                    if ($ListNodesOk.Count -eq 1) {
                                        $node = $ListNodesOk[0]
                                    }
                                    else {
                                        $node = $ListNodesOk[$nodeIndex]
                                    }

                                    $command = New-CloneVMTemplate -QemuConfig $QemuConfig -Template $Template -name $name -Vmid $Vmid -groupName $groupName -Storage $Disk -FullClone $FullClone -Node $node

                                    if ($true -eq $command) {
                                        $command  = Set-PveAccessAcl -Roles PVEVMUser -Users $user -Path /vms/$Vmid

                                        if ($true -eq $command.IsSuccessStatusCode) {
                                            if ($HADeploy -and $HADeploy.Count -eq 1) {
                                                $null = New-PveClusterHaResources -Sid $Vmid -Group $HADeploy -MaxRelocate 1 -MaxRestart 1 -State ignored
                                            }
                                        }
                                    }

                                    $Vmid++
                                    $nodeIndex = ($nodeIndex + 1) % $ListNodesOk.Count
                                }
                            }
                            else
                            {
                                Write-Host "Error : Unable to create $NbrDeploy machines for the group $groupName" -ForegroundColor Red
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

                Break
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

        Show-MenuDeployVirtualMachine
        return
    }
    else {
        Write-Host " "
        Write-Host "Error : The type $($Template.type) is currently not supported" -ForegroundColor Red
    }
}

# Function to clone a VM template
function New-CloneVMTemplate {
    param (
        $QemuConfig,       # QEMU configuration object
        $Template,         # Template object to clone
        [string]$name,     # Name of the new VM
        [int]$Vmid,        # VM ID of the new VM
        [string]$groupName,# Group name for the new VM
        [string]$Storage,  # Storage location for the new VM
        $FullClone,        # Boolean indicating if it's a full clone
        [string]$Node      # Node where the new VM will be created
    )

    # Check if Storage parameter is null
    if ($null -eq $Storage) {
        # If FullClone is true, perform a full clone
        if ($true -eq $FullClone) {
            $command = New-PveNodesQemuClone -Target $node -Node $Template.node -Vmid $Template.vmid -Full -name $name -Newid $Vmid -Pool $groupName
        }
        else {
            # Perform a regular clone
            $command = New-PveNodesQemuClone -Target $node -Node $Template.node -Vmid $Template.vmid -name $name -Newid $Vmid -Pool $groupName
        }
    }
    else {
        # If Storage parameter is provided
        if ($true -eq $FullClone) {
            # Perform a full clone with specified storage
            $command = New-PveNodesQemuClone -Target $node -Node $Template.node -Vmid $Template.vmid -Full -name $name -Newid $Vmid -Pool $groupName -Storage $Storage
        }
        else {
            # Perform a regular clone with specified storage
            $command = New-PveNodesQemuClone -Target $node -Node $Template.node -Vmid $Template.vmid -name $name -Newid $Vmid -Pool $groupName -Storage $Storage
        }
    }

    # Check if the command was successful
    if ($true -eq $command.IsSuccessStatusCode) {
        Write-Host "Success: The VM $name has been successfully created" -ForegroundColor Green
        return $true
    }
    else {
        # If the command failed, display an error message
        Write-Host "Error: The VM $name cannot be created -> $($command.ReasonPhrase)" -ForegroundColor Red
        return $false
    }
}

# Function to clone an LXC template
function New-CloneLXCTemplate {
    param (
        $LxcConfig,      # Configuration object for the LXC container
        $Template,       # Template object to clone from
        [string]$name,   # Name of the new LXC container
        [int]$Vmid,      # VM ID of the new LXC container
        [string]$groupName, # Group name for the new LXC container
        [string]$Storage, # Storage location for the new LXC container
        $FullClone,      # Boolean indicating if a full clone is required
        [string]$Node    # Target node for the new LXC container
    )

    # If storage is not provided, use the rootfs from the LxcConfig
    if ($null -eq $Storage) {
        $Storage = $LxcConfig.rootfs.Split(":")[0]
    }

    # Determine the command based on whether a full clone is required
    if ($true -eq $FullClone) {
        $command = New-PveNodesLxcClone -Target $node -Node $Template.node -Full -Hostname $name -Newid $Vmid -Storage $Storage -Vmid $Template.vmid -Pool $groupName
    } else {
        $command = New-PveNodesLxcClone -Target $node -Node $Template.node -Hostname $name -Newid $Vmid -Vmid $Template.vmid -Pool $groupName # -Storage $Storage
    }

    # Loop until the command is successful or a different error occurs
    while ($true) {
        if ($command.ReasonPhrase -eq "CT is locked (disk)") {
            Start-Sleep -Seconds 2
            if ($true -eq $FullClone) {
                $command = New-PveNodesLxcClone -Target $node -Node $Template.node -Full -Hostname $name -Newid $Vmid -Storage $Storage -Vmid $Template.vmid -Pool $groupName
            } else {
                $command = New-PveNodesLxcClone -Target $node -Node $Template.node -Hostname $name -Newid $Vmid -Vmid $Template.vmid -Pool $groupName # -Storage $Storage
            }
        } else {
            break
        }
    }

    # Check if the command was successful and return the appropriate message
    if ($true -eq $command.IsSuccessStatusCode) {
        Write-Host "Success: The LXC container $Name has been successfully created" -ForegroundColor Green
        return $true
    } else {
        Write-Host "Error: The LXC container $name cannot be created -> $($command.ReasonPhrase)" -ForegroundColor Red
        return $false
    }
}

# Fonction to get Disk
function Get-Disk {
    param (
        $NodeName,
        $type,
        $shared
    )

    # Initialize counter and disk list
    $nbr = 1
    $diskList = @()

    # Clear the console and display header
    Clear-Host
    Write-Host "Storage Pool available on your Proxmox server(s) :" -ForegroundColor Yellow
    Write-Host "================================================" -ForegroundColor Cyan

    # If no specific node is provided, list all nodes
    if ($null -eq $NodeName) {
        $ListNodes = (Get-PveNodes).ToData() | Sort-Object -Property node

        foreach ($node in $ListNodes.node) {
            Write-Host "Node -> $node" -ForegroundColor Yellow
            Write-Host "----------------------" -ForegroundColor Cyan

            # Get storage pools of the specified type for the current node
            $listStorage = (Get-PveNodesStorage -Node $node).ToData() | Where-Object { $_.content -match "$type" } | Sort-Object -Property storage

            foreach ($storage in $listStorage) {
                Write-Host "$nbr -> $($storage.storage)"
                $diskList += [PSCustomObject]@{
                    Node = $node
                    Storage = $storage.storage
                }
                $nbr++
            }

            Write-Host " "
        }
    }
    else {
        # If shared storage is requested
        if ($true -eq $shared) {
            Write-Host "Node -> $NodeName (Local)" -ForegroundColor Yellow
            Write-Host "----------------------------" -ForegroundColor Cyan

            # Get local storage pools of the specified type for the specified node
            $listStorage = (Get-PveNodesStorage -Node $NodeName).ToData() | Where-Object { $_.content -match "$type" } | Sort-Object -Property storage

            foreach ($storage in $listStorage) {
                Write-Host "$nbr -> $($storage.storage)"
                $diskList += [PSCustomObject]@{
                    Node = $NodeName
                    Storage = $storage.storage
                }
                $nbr++
            }

            Write-Host " "

            # Get other nodes for shared storage
            $ListNodes = (Get-PveNodes).ToData() | Where-Object { $_.node -notmatch "$NodeName" } | Sort-Object -Property node

            foreach ($node in $ListNodes.node) {
                Write-Host "Node -> $node (Distant)" -ForegroundColor Yellow
                Write-Host "----------------------------" -ForegroundColor Cyan

                # Get shared storage pools of the specified type for the current node
                $listStorage = (Get-PveNodesStorage -Node $node).ToData() | Where-Object { $_.content -match "$type" -and $_.shared -eq 1 } | Sort-Object -Property storage

                foreach ($storage in $listStorage) {
                    Write-Host "$nbr -> $($storage.storage)"
                    $diskList += [PSCustomObject]@{
                        Node = $node
                        Storage = $storage.storage
                    }
                    $nbr++
                }

                Write-Host " "
            }
        }
        else {
            Write-Host "Node -> $NodeName" -ForegroundColor Yellow
            Write-Host "----------------------" -ForegroundColor Cyan

            # Get storage pools of the specified type for the specified node
            $listStorage = (Get-PveNodesStorage -Node $NodeName).ToData() | Where-Object { $_.content -match "$type" } | Sort-Object -Property storage

            foreach ($storage in $listStorage) {
                Write-Host "$nbr -> $($storage.storage)"
                $diskList += [PSCustomObject]@{
                    Node = $NodeName
                    Storage = $storage.storage
                }
                $nbr++
            }
        }
    }

    # Loop to prompt user for storage pool selection
    while ($true) {
        Write-Host " "
        $choix = $(Write-Host "Select the storage pool for your VM : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choix -match '^\d+$') {
            $choix = [int]$choix

            if ($choix -ge 1 -and $choix -le ($diskList.count)) {
                $choix = $choix - 1

                $Disk = $diskList[$choix]

                return $Disk
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

# Function to get user choice for clone type
function Get-FullClone {

    # Infinite loop to keep asking for input until a valid choice is made
    while ($true) {
        # Print a blank line for better readability
        Write-Host " "

        # Prompt the user to enter a choice
        $choice = $(Write-Host "Enter 1 to make a full clone, otherwise 2 to make a linked clone : " -ForegroundColor Yellow -NoNewline; Read-Host)

        # Check if the user chose to make a full clone
        if ($choice -eq 1) {
            # Return true to indicate a full clone
            return $true
            break
        }
        # Check if the user chose to make a linked clone
        elseif ($choice -eq 2) {
            # Return false to indicate a linked clone
            return $false
            break
        }
        else {
            # Print a blank line for better readability
            Write-Host " "
            # Display an error message for invalid input
            Write-Host "Error : Please enter a valid value" -ForegroundColor Red
        }
    }
}

# Function to configure Qemu Deploy for a group 
function New-DeployQemuGroup {
    # Initialize variables
    $nodeIndex = 0
    $ListNodesOK = @()
    $NodesList = @()
    $CPU = 2
    $Ram = 2048
    $NicEth = "vmbr0"
    $NicType = "virtio"
    $HDDrive = @{ 1 = 'local-lvm:32' }
    $Name

    # Get the group name for deployment
    $groupName = Get-GroupDeploy
    # Set HA deployment settings
    $HADeploy = Set-HALXCQemu

    # If group name is null, return
    if ($null -eq $groupName) {
        return
    }

    # Get the number of QEMU deployments for the group
    $NbrDeployQemu = (Get-PveAccessGroupsIdx -Groupid $groupName).ToData().Members.Count
    # Get the next available VMID
    $Vmid = (Get-LastVMID) + 1

    # If the group has members
    if ((Get-PveAccessGroupsIdx -Groupid $groupName).ToData().Members.Count -ge 1) {
        # Get the list of pools
        $ListPools = (Get-PvePools).ToData()

        # If the group pool does not exist, create it
        if (-not ($ListPools | Where-Object { $_.poolid -eq $groupName })) {
            $null = New-PvePools -Poolid $groupName
        }

        # Set ACL for the group pool
        $null = Set-PveAccessAcl -Path "/pool/$groupName" -Groups $groupName -Roles "PVEPoolUser"

        # Get the VM name
        $NameVM = Get-NameQemu

        # Clear the console and display default configuration
        Clear-Host
        Write-Host "Default Configuration for VM :" -ForegroundColor Yellow
        Write-Host "===============================" -ForegroundColor Cyan
        Write-Host "CPU -> $CPU core(s)"
        Write-Host "RAM -> $Ram MB"
        Write-Host "Hard Disk -> $($HDDrive[1].split(":")[1]) GB at $($HDDrive[1].split(":")[0])"
        Write-Host "NIC -> $NicEth - $NicType"
        Write-Host "Name VM -> $NameVM-VMID"

        # Loop to get user choice
        while ($true) {
            Write-Host " "
            $choice = $(Write-Host "Press 1 to use the default configuration, or press 2 to modify the values or leave it blank to return to the previous menu : " -ForegroundColor Yellow -NoNewline; Read-Host)

            # If user chooses default configuration
            if ($choice -eq 1) {
                $Nic = @{ 1 = "model=virtio,bridge=vmbr0,firewall=1" }
                $ListNodes = ((Get-PveNodes).ToData() | Sort-Object -Property node).node
                $ListNodesOk = @()

                # Check disk space on nodes
                foreach ($node in $ListNodes) {
                    if (Get-DiskSpaceOK -NodeName $node -HDDrive $HDDrive[1] -NbrDeploy $NbrDeployQemu) {
                        $ListNodesOk += $node
                    }
                }

                # If at least one node has sufficient disk space
                if ($ListNodesOk.Count -ge 1) {
                    Clear-Host

                    # Deploy VMs for each user in the group
                    foreach ($user in (Get-PveAccessGroupsIdx -Groupid $groupName).ToData().Members) {
                        $name = $NameVM + "-" + $Vmid

                        # Select a node for deployment
                        if ($ListNodesOk.Count -eq 1) {
                            $node = $ListNodesOk[0]
                        }
                        else {
                            $node = $ListNodesOk[$nodeIndex]
                        }

                        # Deploy the VM
                        $command = Set-Qemu -NodeName $node -Cpu $CPU -Ram $Ram -HDDrive $HDDrive -Vmid $Vmid -QemuVMName $name -Nic $Nic -group $groupName

                        # Set ACL for the VM
                        if ($true -eq $command) {
                            $command = Set-PveAccessAcl -Roles PVEVMUser -Users $user -Path "/vms/$Vmid"

                            # If HA deployment is enabled, configure HA resources
                            if ($true -eq $command.IsSuccessStatusCode) {
                                if ($HADeploy -and $HADeploy.Count -eq 1) {
                                    $null = New-PveClusterHaResources -Sid $Vmid -Group $HADeploy -MaxRelocate 1 -MaxRestart 1 -State ignored
                                }
                            }
                        }

                        $Vmid++
                        $nodeIndex = ($nodeIndex + 1) % $ListNodesOk.Count
                    }
                }
                else {
                    Write-Host "Error : Unable to create $NbrDeployQemu machines for the group $groupName" -ForegroundColor Red
                }

                break

            } elseif ($choice -eq 2) {
                # Get custom configuration values
                $diskQemu = Get-Disk -type "images"
                $node = $diskQemu.node
                $sizeDiskQemu = Get-SizeDiskQemu
                $disk = "$($diskQemu.Storage):$($sizeDiskQemu)"
                $HDDrive = @{ 1 = ($disk) }

                $CPU = Get-CpuNbr -NodeName $node
                $Ram = Get-Ram -NodeName $node
                $Nic = Get-NicQemu -NodeName $node
                $DynamicDeploy = Get-DynamicDeploy

                # Display custom configuration
                Clear-Host
                Write-Host "Custom Configuration for VM :" -ForegroundColor Yellow
                Write-Host "===============================" -ForegroundColor Cyan
                Write-Host "CPU -> $CPU core(s)"
                Write-Host "RAM -> $Ram MB"
                Write-Host "Hard Disk -> $($HDDrive[1].split(":")[1]) GB at $($HDDrive[1].split(":")[0])"

                if($Nic[1].Split(",").Count -eq 4)
                {
                    Write-Host "NIC -> $($Nic[1].Split(",").Split("=")[3]) VLAN $($Nic[1].Split(",").Split("=")[7]) TYPE $($Nic[1].Split(",").Split("=")[3])"
                }
                else {
                    Write-Host "NIC -> $($Nic[1].Split(",").Split("=")[3]) TYPE $($Nic[1].Split(",").Split("=")[3])"
                }

                Write-Host "Name VM -> $NameVM-VMID"

                # Loop to confirm custom configuration
                while ($true) {
                    Write-Host " "
                    $choix = $(Write-Host "Is the configuration correct? (Y/N)" -ForegroundColor Yellow -NoNewline; Read-Host)

                    if ($choix -eq "Y" -or $choix -eq "N") {

                        if ($choix -eq "Y") {

                            if($true -eq $DynamicDeploy)
                            {
                                $ListNodes = ((Get-PveNodes).ToData() | Sort-Object -Property node).node

                                foreach($node in $ListNodes)
                                {
                                    if((Get-PveNodesStorage -Node $node).ToData() | Where-Object storage -eq $($HDDrive[1].split(":")[0]))
                                    {
                                        $NodesList += $node
                                    }
                                }
                            }
                            else{
                                $NodesList += $node
                            }

                            foreach ($node in $NodesList) {
                                if (Get-DiskSpaceOK -NodeName $node -HDDrive $HDDrive[1] -NbrDeploy $NbrDeployQemu) {
                                    $ListNodesOk += $node
                                }
                            }

                            if ($ListNodesOk.Count -ge 1) {
                                Clear-Host

                                foreach ($user in (Get-PveAccessGroupsIdx -Groupid $groupName).ToData().Members) {
                                    $name = $NameVM + "-" + $Vmid

                                    if ($ListNodesOk.Count -eq 1) {
                                        $node = $ListNodesOk[0]
                                    }
                                    else {
                                        $node = $ListNodesOk[$nodeIndex]
                                    }

                                    $command = Set-Qemu -NodeName $node -Cpu $CPU -Ram $Ram -HDDrive $HDDrive -Vmid $Vmid -QemuVMName $name -Nic $Nic -group $groupName

                                    if ($true -eq $command) {
                                        $command = Set-PveAccessAcl -Roles PVEVMUser -Users $user -Path "/vms/$Vmid"

                                        if ($true -eq $command.IsSuccessStatusCode) {
                                            if ($HADeploy -and $HADeploy.Count -eq 1) {
                                                $null = New-PveClusterHaResources -Sid $Vmid -Group $HADeploy -MaxRelocate 1 -MaxRestart 1 -State ignored
                                            }
                                        }
                                    }

                                    $Vmid++
                                    $nodeIndex = ($nodeIndex + 1) % $ListNodesOk.Count
                                }
                            }
                            else {
                                Write-Host "Error : Unable to create $NbrDeployQemu machines for the group $groupName" -ForegroundColor Red
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

            } elseif ([string]::IsNullOrWhiteSpace($choice)) {

                Show-MenuDeployVirtualMachine
                return

            } else {
                Write-Host " "
                Write-Host "Error : Please enter a correct value" -ForegroundColor Red
            }
        }
    } else {
        Write-Host " "
        Write-Host "Error : The group $groupName does not contain any users." -ForegroundColor Red
    }

    Show-MenuDeployVirtualMachine
}

# Function to set up a QEMU VM on a Proxmox node
function Set-Qemu {
    param (
        [string]$NodeName,  # The name of the Proxmox node
        [int]$Cpu,          # The number of CPU cores for the VM
        [int]$Ram,          # The amount of RAM for the VM
        $HDDrive,           # The hard drive configuration for the VM
        [int]$Vmid,         # The VM ID
        [string]$QemuVMName,# The name of the QEMU VM
        [hashtable]$Nic,    # The network interface configuration
        [string]$group      # The resource pool group
    )

    # Construct the command to create the QEMU VM
    $command = New-PveNodesQemu -Node $NodeName -SataN $HDDrive -Cores $Cpu -Cpu "host" -Memory $Ram -name $QemuVMName -NetN $Nic -Vmid $Vmid -Machine "q35" -Efidisk0 "$($HDDrive[1].split(":")[0]):1" -Tpmstate0 "$($HDDrive[1].split(":")[0]):1" -Bios "ovmf" -Scsihw "virtio-scsi-single"

    # Check if the command was successful
    if ($command.IsSuccessStatusCode -eq $true) {
        Write-Host "Success : The VM $QemuVMName has been successfully created" -ForegroundColor Green
        # Add the VM to the specified resource pool
        $null = Set-PvePools -Poolid $group -Vms $Vmid
        return $true
    } else {
        Write-Host "Error : The VM $QemuVMName cannot be created -> $($command.ReasonPhrase)" -ForegroundColor Red
        return $false
    }
}

#Function to get network interface card (NIC) for Qemu
function Get-NicQemu {
    param (
        [string]$NodeName
    )

    # Initialize variables
    $Vlan = $null
    $Type = $null
    $Nic = $null
    $NetworkCard = $null

    # Get the list of network interfaces of type 'bridge' for the specified node
    $ListNic = (Get-PveNodesNetwork -node $NodeName).ToData() | Where-Object { $_.type -eq 'bridge' }

    # Initialize counter for network interfaces
    $nbr = 1

    # Clear the console and display the list of network interfaces
    Clear-Host
    Write-Host "NIC on your Proxmox Server :" -ForegroundColor Yellow
    Write-Host "=============================" -ForegroundColor Cyan

    foreach ($Nic in $ListNic) {
        Write-Host "$nbr -> $($Nic.iface)"
        $nbr++
    }

    # Get the count of network interfaces
    $NicCount = $ListNic.Count

    # Loop until a valid network interface number is chosen
    while ($true) {
        Write-Host " "
        $choix = $(Write-Host "Choose a network card by providing its number : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choix -match '^\d+$') {
            $choix = [int]$choix

            if ($choix -ge 1 -and $choix -le $NicCount) {
                $choix = $choix - 1
                $Nic = $ListNic[$choix]
                break
            } else {
                Write-Host " "
                Write-Host "Error : Please enter a number between 1 and $NicCount." -ForegroundColor Red
            }
        } else {
            Write-Host " "
            Write-Host "Error : Please enter a valid number" -ForegroundColor Red
        }
    }

    # Loop until a valid choice for VLAN configuration is made
    while ($true) {
        Write-Host " "
        $choix = $(Write-Host "Do you want to configure a VLAN on the network card ? (Y/N)" -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choix -eq "Y" -or $choix -eq "N") {
            if ($choix -eq "Y") {
                $Vlan = Get-Vlan
            }
            break
        } else {
            Write-Host " "
            Write-Host "Error : Please enter a valid value" -ForegroundColor Red
        }
    }

    # Clear the console and display the list of network card models
    Clear-Host
    Write-Host "Network card model available :" -ForegroundColor Yellow
    Write-Host "==============================" -ForegroundColor Cyan
    Write-Host "1 -> e1000"
    Write-Host "2 -> e1000e"
    Write-Host "3 -> rtl8139"
    Write-Host "4 -> virtio"
    Write-Host "5 -> vmxnet3"

    # Loop until a valid network card model is chosen
    while ($true) {
        Write-Host " "
        $choix = $(Write-Host "Choose a network card model : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choix -gt 0 -and $choix -le 5) {
            switch ($choix) {
                1 { $Type = "e1000" }
                2 { $Type = "e1000e" }
                3 { $Type = "rtl8139" }
                4 { $Type = "virtio" }
                5 { $Type = "vmxnet3" }
            }
            break
        } else {
            Write-Host " "
            Write-Host "Error : Please enter a valid number" -ForegroundColor Red
        }
    }

    # Construct the network card configuration
    if ($null -eq $Vlan) {
        $NetworkCard = @{1 = "model=$Type,bridge=$($Nic.iface),firewall=1" }
    } else {
        $NetworkCard = @{1 = "model=$Type,bridge=$($Nic.iface),firewall=1,tag=$Vlan" }
    }

    # Return the network card configuration
    return $NetworkCard
}

# Function to get a valid name for a QEMU virtual machine
function Get-NameQemu {
    # Infinite loop to keep asking for a name until a valid one is provided
    while ($true) {
        # Print a blank line for better readability
        Write-Host " "

        # Prompt the user to choose a name for the VM
        $choix = $(Write-Host "Choose a name for the VM : " -ForegroundColor Yellow -NoNewline; Read-Host)

        # Check if the length of the chosen name is greater than 3 characters
        if($choix.Length -gt 3) {
            # Check if the chosen name contains only alphanumeric characters, hyphens, or underscores
            if ($choix -notmatch "[^a-zA-Z0-9-_]") {
                # If the name is valid, return it and exit the loop
                return $choix
                break
            } else {
                # If the name contains special characters, display an error message
                Write-Host " "
                Write-Host "Error : Your VM name contains special characters" -ForegroundColor Red
            }
        } else {
            # If the name is too short, display an error message
            Write-Host " "
            Write-Host "Error : The length of the VM name must be a minimum of 3 characters" -ForegroundColor Red
        }
    }
}

# Function to determine if a dynamic deployment should be performed
function Get-DynamicDeploy {
    # Get the list of nodes and convert it to data
    $ListNodes = (Get-PveNodes).ToData()

    # Check if there is only one node
    if($ListNodes.node.count -eq 1)
    {
        # If there is only one node, return false as dynamic deployment is not needed
        return $false
    }
    else {
        # Clear the console
        Clear-Host

        # Infinite loop to keep asking for user input until a valid response is given
        while ($true) {
            # Prompt the user for input
            $choice = $(Write-Host "Did you want to perform a Dynamic deployment to distribute the workload across all the nodes in your system? (Y/N) : " -ForegroundColor Yellow -NoNewline; Read-Host)

            # Convert the user input to uppercase for case-insensitive comparison
            $choice = $choice.ToUpper()

            # Check if the input is either 'Y' or 'N'
            if ($choice -eq "Y" -or $choice -eq "N") {

                # If the input is 'Y', return true to indicate dynamic deployment should be performed
                if ($choice -eq "Y") {
                    return $true
                }
                else {
                    # If the input is 'N', return false to indicate dynamic deployment should not be performed
                    return $false
                }

                # Break the loop as a valid input has been received
                break
            }
            else {
                # If the input is not valid, display an error message
                Write-Host " "
                Write-Host "Error : Please enter a valid value" -ForegroundColor Red
            }
        }
    }
}

# Function to get the size of the disk for QEMU
function Get-SizeDiskQemu {

    # Infinite loop to keep asking for input until a valid size is entered
    while ($true) {
        # Print a new line for better readability
        Write-Host " "

        # Prompt the user to enter the size of the disk in GB (between 8GB and 64GB)
        $choix = $(Write-Host "Please indicate the size of the disk in GB (Min 8GB/ Max 64GB) : " -ForegroundColor Yellow -NoNewline; Read-Host)

        # Check if the input is a number
        if ($choix -match '^\d+$') {
            # Convert the input to an integer
            $choix = [int]$choix

            # Check if the number is between 8 and 64 (inclusive)
            if ($choix -ge 8 -and $choix -le 64) {
                # Return the valid size and break the loop
                return $choix
                break
            }
            else {
                # Print a new line for better readability
                Write-Host " "
                # Display an error message if the number is not within the valid range
                Write-Host "Error : Please enter a number between 8GB and 64GB." -ForegroundColor Red
            }
        }
        else {
            # Print a new line for better readability
            Write-Host " "
            # Display an error message if the input is not a number
            Write-Host "Error : Please enter a number between 8GB and 64GB." -ForegroundColor Red
        }
    }
}

# Function to set HA for QEMU machines
function Set-HALXCQemu {
    # Clear the console
    Clear-Host
    $nbr = 1

    # Loop to ask the user if they want to configure HA
    while ($true) {
        # Prompt the user for input
        $choix = $(Write-Host "Do you want to configure HA for your machines? (Y/N) : " -ForegroundColor Yellow -NoNewline; Read-Host)

        # Check if the input is valid (Y or N)
        if ($choix -eq "Y" -or $choix -eq "N") {
            if ($choix -eq "Y") {
                # If the user chooses Y, break the loop
                break
            }
            else {
                # If the user chooses N, return false and exit the function
                return $false
            }
            break
        }
        else {
            # If the input is invalid, display an error message
            Write-Host " "
            Write-Host "Error : Please enter a valid value" -ForegroundColor Red
        }
    }

    # Get the list of HA groups from the Proxmox cluster
    $ListsHaGroups = (Get-PveClusterHaGroups).ToData().group

    # Check if there are at least 2 HA groups
    if($ListsHaGroups.count -ge 2)
    {
        # Clear the console
        Clear-Host
        # Display the available HA groups
        Write-Host "HA Groups available on your Proxmox server(s) :" -ForegroundColor Yellow
        Write-Host "================================================" -ForegroundColor Cyan
        foreach($HaGroup in $ListsHaGroups)
        {
            # Display each HA group with a number
            Write-Host "$nbr -> $HaGroup"
            $nbr++
        }

        # Loop to ask the user to select an HA group
        while ($true) {
            Write-Host " "
            $choix = $(Write-Host "Select HA Group : " -ForegroundColor Yellow -NoNewline; Read-Host)

            # Check if the input is a valid number
            if ($choix -match '^\d+$') {
                $choix = [int]$choix

                # Check if the number is within the valid range
                if ($choix -ge 1 -and $choix -le ($ListsHaGroups.count)) {
                    $choix = $choix -1

                    # Get the selected HA group
                    $HaGroup = $ListsHaGroups[$choix]

                    # Return the selected HA group and exit the function
                    return $HaGroup
                    break
                }
                else {
                    # If the number is invalid, display an error message
                    Write-Host " "
                    Write-Host "Error : Please enter a valid number" -ForegroundColor Red
                }
            }
            else {
                # If the input is not a number, display an error message
                Write-Host " "
                Write-Host "Error : Please enter a valid number" -ForegroundColor Red
            }
        }
    }
    # If there is exactly 1 HA group
    elseif ($ListsHaGroups.count -eq 1) {
        # Return the single HA group and exit the function
        return $ListsHaGroups
    }
    else {
        # If there are no HA groups, display an error message
        Write-Host "Error : No HA Group found on your Proxmox server(s)" -ForegroundColor Red
        return $false
    }
}

# Function to remove pool members from a Proxmox pool
function Remove-PoolMembers {
    # Get the list of pools from Proxmox and convert it to data
    $ListPools = (Get-PvePools).ToData()
    $nbr = 1

    # Clear the console
    Clear-Host

    # Display the existing pools on the Proxmox system
    Write-Host "Pool(s) that exist on your Proxmox system : " -ForegroundColor Yellow
    Write-Host "============================================" -ForegroundColor Cyan

    # Iterate through each pool and display its index and pool ID
    foreach($Pool in $ListPools)
    {
        Write-Host "$nbr -> $($Pool.poolid)"
        $nbr++
    }

    # Loop to get user input for pool selection
    while ($true) {
        Write-Host " "
        $choix = $(Write-Host "Please choose a pool or leave blank to exit : " -ForegroundColor Yellow -NoNewline; Read-Host)

        # Handle numeric input
        if ($choix -match '^\d+$') {
            $choix = [int]$choix
            $PoolsCount = $ListPools.poolid.Count

            if ($choix -ge 1 -and $choix -le $PoolsCount) {
                $choix = $choix - 1

                # Get the selected pool name
                $PoolName = $ListPools[$choix].poolid
                break
            } else {
                Write-Host " "
                Write-Host "Error : Please enter a number between 1 and $PoolsCount, or 'E' to exit." -ForegroundColor Red
            }
        } elseif ($choix -eq "E") {
            # Exit the function if 'E' is entered
            Show-MenuDeployVirtualMachine
            return
        } else {
            Write-Host " "
            Write-Host "Error : Please enter a valid number or 'E' to exit." -ForegroundColor Red
        }
    }

    # Clear the console
    Clear-Host

    # Check if the selected pool exists
    if (-not ($ListPools | Where-Object poolid -eq $PoolName)) {
        Write-Host "Error : No pool found for the group $PoolName" -ForegroundColor Red
        Show-MenuDeployVirtualMachine
        return
    }

    # Get the members of the selected pool and sort them by VM ID
    $PoolMembers = (Get-PvePools -Poolid $PoolName).ToData().members | Sort-Object -Property Vmid

    # Check if the pool has any members
    if ($PoolMembers.Count -eq 0) {
        Write-Host "Error : No machine(s) found in the pool $PoolName" -ForegroundColor Red
        Show-MenuDeployVirtualMachine
        return
    }

    # Display the members of the selected pool
    Write-Host "Machine(s) belonging to the pool $PoolName :" -ForegroundColor Yellow
    Write-Host "=================================================" -ForegroundColor Cyan
    foreach ($Member in $PoolMembers) {
        Write-Host "Vmid -> $($Member.Vmid) Name -> $($Member.name)"
    }

    # Loop to get user confirmation for deleting pool members
    while ($true) {
        Write-Host " "
        $choix = $(Write-Host "Do you want to delete all machines from the pool $PoolName? (Y/N) : " -ForegroundColor Yellow -NoNewline; Read-Host)

        if ($choix -eq "Y" -or $choix -eq "N") {
            break
        }
        else {
            Write-Host " "
            Write-Host "Error : Please enter a valid value" -ForegroundColor Red
        }
    }

    # Clear the console
    Clear-Host

    # Perform the deletion if the user confirms
    if ($choix -eq "Y") {
        foreach($Member in $PoolMembers)
        {
            # Handle LXC containers
            if ($Member.type -eq "lxc") {
                $command = Remove-PveNodesLxc -Node $Member.node -Vmid $Member.vmid -DestroyUnreferencedDisks -Force -Purge

                if ($command.IsSuccessStatusCode) {
                    Write-Host "Success : The machine $($Member.vmid) has been deleted" -ForegroundColor Green
                }
                else {
                    Write-Host "Error : The machine $($Member.vmid) was not deleted. -> $($command.ReasonPhrase)" -ForegroundColor Red
                }
            }
            # Handle QEMU VMs
            elseif ($Member.type -eq "qemu") {
                $command = Remove-PveNodesQemu  -Node $Member.node -Vmid $Member.vmid -DestroyUnreferencedDisks -Purge

                if ($command.IsSuccessStatusCode) {
                    Write-Host "Success : The machine $($Member.vmid) has been deleted" -ForegroundColor Green
                }
                else {
                    Write-Host "Error : The machine $($Member.vmid) was not deleted. -> $($command.ReasonPhrase)" -ForegroundColor Red
                }
            }
            else {
                Write-Host "Error : The machine $($Member.vmid) is in an unsupported format $($Member.type)." -ForegroundColor Red
            }
        }
    }

    # Return to the main menu
    Show-MenuDeployVirtualMachine
    return
}

# Function to remove User members from a Proxmox group
function Remove-AllUsersGroup {
    # Get the group name from the deployment
    $GroupName = Get-GroupDeploy -type $true

    # If the group name is null, show the users menu and return
    if ($null -eq $GroupName) {
        Show-UsersMenu
        return
    }

    # Get the list of users in the group
    $listUsers = (Get-PveAccessGroupsIdx -Groupid $GroupName).ToData().members

    # If no users are found in the group, display an error message and show the users menu
    if ($listUsers.count -eq 0) {
        Write-Host "Error : No user found in the group $GroupName"
        Show-UsersMenu
        return
    }

    # Clear the console and display the users in the group
    Clear-Host
    Write-Host "Here are the users of the group $GroupName : " -ForegroundColor Yellow
    Write-Host "=============================================" -ForegroundColor Cyan
    $listUsers

    # Ask the user if they want to delete all users from the group
    while ($true) {
        Write-Host " "
        $choix = $(Write-Host "Do you want to delete all user(s) from the group $GroupName ? (Y/N) : " -ForegroundColor Yellow -NoNewline; Read-Host)

        # Validate the user's choice
        if ($choix -eq "Y" -or $choix -eq "N") {
            break
        }
        else {
            Write-Host " "
            Write-Host "Error : Please enter a valid value" -ForegroundColor Red
        }
    }

    Clear-Host

    # If the user chooses to delete all users, remove each user from the group
    if ($choix -eq "Y") {
        foreach($user in $listUsers)
        {
            $command = Remove-PveAccessUsers -Userid $user

            # Check if the user was successfully deleted
            if ($command.IsSuccessStatusCode) {
                Write-Host "Success : The user $user has been deleted" -ForegroundColor Green
            }
            else {
                Write-Host "Error : The user $user was not deleted. -> $($command.ReasonPhrase)" -ForegroundColor Red
            }
        }
    }

    # If the group is empty and the user chose to delete all users, ask if they want to delete the group and pool
    if ((Get-PveAccessGroupsIdx -Groupid $GroupName).ToData().members.count -eq 0 -and $choix -eq "Y") {
        while ($true) {
            Write-Host " "
            $choix = $(Write-Host "Do you want to delete the group $GroupName and the pool $GroupName? (Y/N) : " -ForegroundColor Yellow -NoNewline; Read-Host)

            # Validate the user's choice
            if ($choix -eq "Y" -or $choix -eq "N") {
                break
            }
            else {
                Write-Host " "
                Write-Host "Error : Please enter a valid value" -ForegroundColor Red
            }
        }
    }

    # If the user chooses to delete the group and pool, remove them
    if ($choix -eq "Y") {
        $command = Remove-PveAccessGroups -Groupid $GroupName

        # Check if the group was successfully deleted
        if ($command.IsSuccessStatusCode) {
            $command = Remove-PvePools -Poolid $GroupName

            Write-Host "Success : The group $GroupName has been deleted" -ForegroundColor Green

            # Check if the pool was successfully deleted
            if ($command.IsSuccessStatusCode) {
                Write-Host "Success : The pool $GroupName has been deleted" -ForegroundColor Green
            }
            else {
                Write-Host "Error : The pool $GroupName was not deleted. -> $($command.ReasonPhrase)" -ForegroundColor Red
            }
        }
        else {
            Write-Host "Error : The group $GroupName was not deleted. -> $($command.ReasonPhrase)" -ForegroundColor Red
        }
    }

    # Show the users menu and return
    Show-UsersMenu
    return
}

# Function to display an exit message with ASCII art and program information
function Exit-Program {

    # Define the program name
    $programName = "PROXIM"

    # Define the program version
    $version = "v1.0"

    # Define the developer's name
    $developer = "Corentin"

    # Define the module name
    $module = "Corsinvest.ProxmoxVE.Api"

    # Define the ASCII art to be displayed
    $asciiArt = @"
     ____  ____   _____  _____ __  __
    |  _ \|  _ \ / _ \ \/ /_ _|  \/  |
    | |_) | |_) | | | \  / | || |\/| |
    |  __/|  _ <| |_| /  \ | || |  | |
    |_|   |_| \_\\___/_/\_\___|_|  |_|
"@

    # Display the ASCII art
    Write-Host $asciiArt

    # Add a blank line for spacing
    Write-Host " "

    # Display a separator line in cyan color
    Write-Host "=============================================" -ForegroundColor Cyan

    # Display a thank you message with the program name and version in yellow color
    Write-Host "Thank you for using $programName $version" -ForegroundColor Yellow

    # Display the developer's name in yellow color
    Write-Host "Developed by: $developer" -ForegroundColor Yellow

    # Display the module name in yellow color
    Write-Host "Based on the module: $module" -ForegroundColor Yellow

    # Display a separator line in cyan color
    Write-Host "=============================================" -ForegroundColor Cyan

    # Add a blank line for spacing
    Write-Host " "
}

#===================================================================================================
#===================================================================================================
# Main :
# ------

# Check if the PowerShell version is 6 or higher
if (($PSVersionTable.PSVersion.Major) -ge 6) {

    # Check if the Find-Module cmdlet is available
    if(Find-Module)
    {
        # Display the welcome message
        Get-welcome

        # Get the PVE credentials
        $PveTicket = Get-PVECredential

        # Show the main menu
        Show-Menu

        # Exit the program
        Exit-Program
    }

} else {
    # Display a message asking the user to update their PowerShell version
    Write-Host "Please update your version of PowerShell. Minimum version requirement for PowerShell is 6.0. You currently have the version $($PSVersionTable.PSVersion)"
}
