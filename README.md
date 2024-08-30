# PROXIM  - Proxmox Interface Management

PROXIM is a program based on the PowerShell module [Corsinvest.ProxmoxVE](https://github.com/Corsinvest/cv4pve-api-dotnet). It enables the automation of a number of tasks on a PROXMOX system.


## License
This program is licensed under GPL-3.0. For more information, please refer to [the license](LICENSE).


## Main features
 
 * Create groups and users from a CSV file
 * Deploying VMs and LXC containers for all members of a group
 * Automatic assignment of access rights to a machine during the creation of a VM/LXC for a user
 * Creation of Pool based on Groups
 * And more ...


## Requirement
Minimum version requirement for Powershell is 6.0


## Installation & use
To use PROXIM, you must install the Corsinvest.ProxmoxVE.Api module. To do this, open a PowerShell session as an administrator. Then, run the following command:
```ps
PS C:\Users\coren> Install-Module -Name Corsinvest.ProxmoxVE.Api
```

For more information on installing the module, please refer to this [link](https://github.com/Corsinvest/cv4pve-api-powershell).

After installing the module, you can download the [PROXIM.ps1](PROXIM.ps1) file and open it in a PowerShell window. Then, execute it as follows:
```ps
PS C:\Users\coren\Downloads> PROXIM.ps1
```
## Function
### -> Add Groups by .CSV file :
To create groups from a .CSV file, you must follow the format below:

```csv
GroupName
Professeurs
Etudiants
Administration
```

GroupName is used to identify the column containing the group names.
