get-service
get-date

$psversiontable.psversion

PowerShell is a powerful task automation and configuration management framework from Microsoft. Here's what you can do with it:
- Managing user accounts and groups in Active Directory
- Configuring network settings
- Managing services and processes
- Working with files and folders
- Managing Windows registry

In PowerShell commands, known as cmdlets (pronounced "command-lets"), follow a specific structure:
Verb-Noun
- Verb: Represents the action you want to perform (e.g. Get, Set, Add, Remove)
- Noun: Represents the object you want to work with (e.g. Process, Service, Item, ChildItem)

Get-Service
Get-Date

Get-Service
Get-Date
Get-Command
Get-Command -noun Service
Get-Command -Verb Install
Get-Help Install-Package -Full
#alias
Get-Help Get-Service -Full
#gsv
#Get-Service = gsv
gsv
#to see all aliases
Get-Alias

#variables
#camelCase myVariable, PascalCase MyVariable, snake_case my_variable

$MyVariable = "Automate With Rakesh"
$MyVariable

#we can type clear in below terminal to clean

$MyVariable1 = 'Automate With Rakesh1'
$MyVariable1

$MyVariable = "Automate With Rakesh"
$MyVariable

#we can type clear in below terminal to clean

$MyVariable1 = '06'
$MyVariable1

$MyVariable2 = 06
$MyVariable2

#properties (key symbol)
$MyVariable = "Automate With Rakesh"
$MyVariable
$MyVariable.Length

$MyVariable = '06'
$MyVariable
$MyVariable.Length

#methods (cube symbol)
$MyVariable = '06'
$MyVariable
$MyVariable.GetType()

$MyVariable = 06
$MyVariable
$MyVariable.GetType()

$MyVariable1 = 06
$MyVariable2 = 05
$MyVariable1 + $MyVariable2

$MyVariable1 = 06
$MyVariable2 = 05
$MyVariableResult = $MyVariable1 + $MyVariable2
$MyVariableResult

#Arithmetic Operators
$MyVariable1 = 06
$MyVariable2 = 05
$MyVariableResult = $MyVariable1 + $MyVariable2
$MyVariableResult

$MyVariable1 = 06
$MyVariable2 = 05
$MyVariableResult = $MyVariable1 - $MyVariable2
$MyVariableResult

$MyVariable1 = 06
$MyVariable2 = 05
$MyVariableResult = $MyVariable1 * $MyVariable2
$MyVariableResult

$MyVariable1 = 06
$MyVariable2 = 05
$MyVariableResult = $MyVariable1 / $MyVariable2
$MyVariableResult

#reminder
$MyVariable1 = 06
$MyVariable2 = 05
$MyVariableResult = $MyVariable1 % $MyVariable2
$MyVariableResult

#Boolean Variables
$MyBooleanVariable = $true
$MyBooleanVariable.GetType()

$MyBooleanVariable = $false
$MyBooleanVariable.GetType()

#Comparison Operators
2 -eq 3
2 -ne 3
2 -gt 3
2 -ge 3
2 -lt 3
2 -le 3

#Arrays
$a = 1,2,3,4,5
$a.GetType()
$a.Count
$a[0]
$a[1]
$a[0 .. 3]

$a = 1 .. 10
$a
$a[0 .. 4]

$a = 1 .. 10
$a[-9 .. -5]

$a = 1,2,3,4,5
$a[-2 .. -4]

$a = 1,2,3,4,5
$a[-4 .. -2]

#ForEach Looping Construct
$a = 1 .. 10

foreach ($i in $a)
{
    $i
}


$a = 1 .. 10

foreach ($i in $a)
{
    $i*2
}


#HashTable
#HashTable Dictionary 
#its key value pair
# key must be unique
$settings = @{
    "AppName" = "App1"
    "version" = "1.0.0"
    "maxusers" = 100
}

$settings["appname"]

$settings["appname", "version"]

$settings["version"] = "2.0.0"

$settings["version"]

foreach ($i in $settings){
    $i
}

Name                           Value
----                           -----
maxusers                       100
version                        2.0.0
AppName                        App1


foreach ($i in $settings){
    $i.keys
}

maxusers
version
AppName

foreach ($i in $settings){
    $i.values
}

100
2.0.0
App1


foreach ($i in $settings.keys){
    $i
}

maxusers
version
AppName


foreach ($i in $settings.keys){
    $settings[$i]
}

100
1.0.0
App1





$settings = @{
    "AppName" = "App1"
    "version" = "1.0.0"
    "maxusers" = 100
}

$settings.ContainsKey("version")

True

https://www.youtube.com/watch?v=Hmkyn4yoLNQ
56




icm is alias for invoke-command 

icm is the built-in alias for Invoke-Command, one of PowerShell's most-used cmdlets. 
It runs a script block or script file either locally or on one/many remote computers.

Invoke-Command -ComputerName <String[]> -ScriptBlock { <code> } [-Credential <PSCredential>]
Invoke-Command -Session <PSSession[]> -ScriptBlock { <code> }
Invoke-Command -ScriptBlock { <code> }   # runs locally, in a child scope

Invoke-Command -ComputerName DESKTOP-ULPSU6M -ScriptBlock { Get-Process *oracle*}

Key parameters
-ScriptBlock – the code to run, e.g. { Get-Process }
-ComputerName – one or more remote machine names (uses WinRM under the hood)
-Session – run against an existing PSSession (more efficient for repeated calls, since the connection stays open)
-Credential – alternate credentials for the remote connection
-FilePath – run a local .ps1 script's contents on the remote machine, instead of an inline block
-ArgumentList – pass parameters into the script block
-AsJob – run as a background job instead of waiting synchronously
-ThrottleLimit – max number of concurrent connections when targeting many computers (default 32)


Examples

Run locally:

powershell
icm { Get-Date }

Run on one remote computer:

powershell
icm -ComputerName Server01 -ScriptBlock { Get-Service -Name Spooler }

Run on multiple computers at once (executes in parallel):

powershell
icm -ComputerName Server01,Server02,Server03 -ScriptBlock { Get-Process }


Pass arguments into the script block:

powershell
icm -ComputerName Server01 -ScriptBlock { param($svc) Get-Service $svc } -ArgumentList "Spooler"

Reuse a persistent session (faster for multiple calls):

powershell
$s = New-PSSession -ComputerName Server01
icm -Session $s -ScriptBlock { Get-Process }
icm -Session $s -ScriptBlock { Get-Service }
Remove-PSSession $s

Run a local script file remotely:

powershell
icm -ComputerName Server01 -FilePath C:\Scripts\CheckDisk.ps1

Things worth knowing
Requires PowerShell Remoting to be enabled on the target for -ComputerName usage (Enable-PSRemoting on the remote machine, and it must be reachable over WinRM, usually port 5985/5986).
Output objects from remote runs get deserialized — they lose their original type and methods, becoming a flattened data-only version (properties still work, but you can't call live methods on them).
Variables from your local session aren't automatically available inside the script block when run remotely — use -ArgumentList or the $using: scope modifier:
powershell
  $svcName = "Spooler"
  icm -ComputerName Server01 { Get-Service $using:svcName }
For one-off remote runs, -ComputerName is simpler; for many repeated commands against the same machine, a -Session is more efficient since it avoids reconnecting each time.

Want an example tailored to something specific you're trying to do (e.g., running a command across many servers, or passing complex objects)?