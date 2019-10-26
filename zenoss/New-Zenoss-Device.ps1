<#
Name: New-ZenossDevice
Purpose: Adding Devices to a Zenoss Server. This is using Powershell and the built-in API for Zenoss.
Author: Mark Gevaert (markgevaert@icloud.com)
#>


Function New-ZenossDevice {
    <#     
    .SYNOPSIS     
        Creates New Device in Zenoss 
         
    .DESCRIPTION   
        Creates a Zenoss Device. This can be any end point you would like to monitor

    .PARAMETER server
        [String] Server IP or DNS Address. Example: 10.0.0.1

    .PARAMETER id
        [String] Network Location of Device Example: device.mycompany.com or 10.0.0.1
    
    .PARAMETER deviceloc
        [String] location of device in Zenoss Example: 

    .PARAMETER productionState
        [Integer] Sets state Production 1000 / Pre-Production 500 / Test 400 / Maintenance 300 / Decommissioned -1
    
    .PARAMETER devicename
        [String] Friendly Name of Device Example: Production Device

    .PARAMETER location
        [string] (Optional) Zenoss Location (Can only be set in API on creation) (default: 'none') Example: "/HomeOffice"

    .PARAMETER group1
        [string] (Optional) Zenoss Group, can be multiple (Can only be set in API on creation)(default: 'none') Example: "/DEV"

    .PARAMETER group2
        [string] (Optional) Zenoss Group, can be multiple (Can only be set in API on creation)(default: 'none') Example: "/DEV/Registers"

    .PARAMETER group3
        [string] (Optional) Zenoss Group, can be multiple (Can only be set in API on creation)(default: 'none') Example: "/DEV/Firewalls"

    .PARAMETER group4
        [string] (Optional) Zenoss Group, can be multiple (Can only be set in API on creation)(default: 'none') Example: "/DEV/Switches"


    .NOTES     
        Name: New-ZenossDevice   
        Author: Mark Gevaert
        DateCreated: 10/10/2018
              
    .LINK     
        https://zenstore.mycompany.com
          
    .EXAMPLE     
        New-ZenossDevice "10.0.0.1" "device.mycompany.com" "/Registers" "Super Cool Device" "/Nowhere" 400 "/DEV" "/QA"
         
    .EXAMPLE     
        New-ZenossDevice "zenstore.mycompany.com" "10.0.0.2" "/Network/Router/Firewall" "Super Lame Firewall" "/Somewhere" 400
    #>
    Param(
        $server, #zenoss update server
        $id, #Device network location
        $deviceloc, #name of organizer
        $devicename, #friendly name
        $location, #location of device
        $productionState, #Production State
        $group1, #group or groups
        $group2, #group or groups
        $group3, #group or groups
        $group4 #group or groups                                    
            )   #End Parameter


    $hash = @([Ordered]@{ action = "DeviceRouter";
        method ="addDevice"
        data = @(
            [Ordered]@{
                deviceName = "$id"
                deviceClass = "$deviceloc"
                title = "$devicename"
                locationPath = "$location"
                groupPaths = "$group1", "$group2", "$group3", "$group4"
                productionState = $productionState
            }
        )
    type = "rpc"
    tid = 1
    }
    )

$JSON = $hash | convertto-json -Depth 3


Invoke-RestMethod -Uri "https://<urlpathtoserver>/zport/dmd/device_router" -Headers $headers  -Method POST -Body $JSON -ContentType "application/json"

return $rest
} #End New-ZenossDevice



########### Do Work ##################
 New-ZenossDevice "zenserver.domain.com" "192.168.1.2" "/Network/Router/Firewall/US" "US-Firewall-Example" "/US-1" 1000 "/VOLUME/1" "/DISTRICT/1"
