# PROXIM-CMD  - Proxmox Interface Management

PROXIM is a program based on the PowerShell module [Corsinvest.ProxmoxVE](https://github.com/Corsinvest/cv4pve-api-powershell). It enables the automation of a number of tasks on a PROXMOX system.


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
## Function using CSV File
### -> Add Groups by .CSV file :
To create groups from a .CSV file, you must follow the format below:

```csv
GroupName
Professeurs
Etudiants
Administration
```

`GroupName` is used to identify the column containing the group names.

### -> Add Users by .CSV file
To create users from a .CSV file, you must follow the format below:

```csv
UserName,Password,Group0,Group1,Group2,Group3,Group4,Group5,Group6,Group7,Group8,Group9,
hello,PommeLover123,Professeurs,
Pomme,PommeLover123@,,,,,,,,78,,,
```

This function allows you to create a user and configure their password, as well as assign groups via the Group[0-9] fields.



## Proxmox Connection
To connect, first enter the address of your Proxmox server. If it is a cluster, then enter the IP address of any node.
Next, select your authentication method; there are two options: by API Token or by user (username + password).

### API tokens
To use API tokens, you need to follow a specific format. Here is an example:

```ps
prxadmim@pam!hello=d8dc0050-18e2-462f-bbfe-262cf1987e02
```
- The first part, `prxadmim@pam`, corresponds to the API key's username followed by its realm.
- Next comes the token name, `hello`.
- Finally, the token key is `d8dc0050-18e2-462f-bbfe-262cf1987e02`.

## Reporting Issues and Feature Requests

If you encounter a problem, have a question, or have an idea for a new feature, please follow these steps:

1. **Check Existing Issues**: Before creating a new issue, please check if a similar issue or feature request already exists.
2. **Create a New Issue**: If you don't find an existing issue, feel free to open a new issue. Please provide as much detail as possible to help us understand the problem or your idea.
3. **Submit a Pull Request**: If you have a solution or a new feature to propose, you can submit a pull request. Make sure to follow the contribution guidelines.

Your feedback and contributions are greatly appreciated!
