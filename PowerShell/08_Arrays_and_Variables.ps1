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

53:36
