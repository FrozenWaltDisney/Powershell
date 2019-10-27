## AD Computer Cleanup Script##################################
#
#
#Script checks computers in Workstations OU and moves them
# to deleted OU. Removes deleted objects from disabled computers
#
#Created by Mark Gevaert
# Original: 1/6/2017
#
#########################################################

#set static variables for script
import-module activedirectory  
$domain = "company"  
$DaysInactive = 45  #Days since last login
$time = (Get-Date).Adddays(-($DaysInactive))
$disabledtime = 90  #Days since last login
$deltime = (Get-Date).Adddays(-($disabledtime))




#Moves workstations to disabled depending on checkin time
function Update-DisabledCPU(){
    [string]$moveddisabled = "`n" + "Computers that have been moved to disabled" + "`n"
    $oldcomputers = Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} `
    -searchbase "OU=Workstations,DC=$domain,DC=com" `
    -Properties LastLogonTimeStamp | where-object name -like "*" | `
    select-object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}
    $target = Get-ADOrganizationalUnit -LDAPFilter "(name=Disabled Computers)"
    foreach ($item in $oldcomputers){
        $comp = Get-ADComputer -identity $item.name
        $name = $comp.Name
        $moveddisabled = $moveddisabled + "`n" + $comp
        Move-ADObject $comp -TargetPath $target.DistinguishedName
    }
    return $moveddisabled
}


#deletes computers from Disabled Computers based on time
function Remove-DisabledCPU(){
    [hashtable]$return = @{}
    [string]$deleted = "`n" + "Computers that have been deleted" + "`n"
    [string]$notdeleteddisabled = "`n" + "Computers that are disabled but not deleted" + "`n"
    $disabledcomputers = Get-ADComputer -Filter {LastLogonTimeStamp -lt $time} `
    -searchbase "OU=Disabled Computers,DC=$domain,DC=com" `
    -Properties LastLogonTimeStamp | where-object name -like "*" | `
    select-object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}}

    foreach ($object in $disabledcomputers){
        $oldcomp = Get-ADComputer -identity $object.name
        if ($oldcomp.LastLogonDate -lt $deltime){
            $deleted = $deleted + "`n" + $oldcomp.Name
            Remove-ADObject $oldcomp -Confirm:$false
            }
        else {
            $notdeleteddisabled = $notdeleteddisabled + "`n" + $oldcomp.Name
            $oldcomp.Name
            }
    }
    $Return.notdeleteddisabled = $notdeleteddisabled
    $Return.deleted = $deleted
    return $Return
}


<#####  Work Area  #####>
Update-DisabledCPU
Remove-DisabledCPU
