<# Exchange 2007 Public Folder Fix
Purpose: Rename all public folders in prep for upgrade.
Author: Mark Gevaert (markgevaert@icloud.com)
#>

<#Global Variables#>
$logfile = "<path>"
If (!(Test-Path $logfile)){
    New-Item -Path $logfile -ItemType "file"
    }

function Repair-PublicFolder {
    $PFresult = Get-PublicFolder -identity \ -recurse | select identity, name #backslash is to only select non system folders
    $count = $PFresult.count
    $table = @{}
    while($count -ge 0){
        $fixidentity = "" #reset
        $identity = $result[$count].Identity.MapiFolderPath #Array of folders
        $name = $PFresult[$count].name
        if (($name -ne "IPM_SUBTREE") -and ($name -ne "")){ #Throw out root folder and null results
            #Rebuild path from Folder Array
            foreach ($path in $identity){
                $fixidentity += "\" + $path
            }
            $gname = $name -replace '[^a-zA-Z0-9]', '' #Regex to only include characters in range
            if ($gname -ne ""){ #throw out null returns
                if ($gname -ne $name){ #throw out no changes
                    #Logging Changes
                    $Change = "[IDENTITY]$fixidentity" + " [NAME]" + $gname
                    Write-Output $Change
                    $time = Get-Date -format "dd-MMM-yyyy HH:mm"
                    "`n$time : [ORIGIN][IDENTITY]$fixidentity [NAME]$name" | Out-File -FilePath $logfile -append
                    "`n$time : [CHANGE]$change`n"| Out-File -FilePath $logfile -append

                    #Change Folder (Please test first!)
#                    Set-PublicFolder -Identity $fixidentity -Name $gname
                    
                    #Return to continue
                    Return $True
                    Break #Break for Loop
                }
            }
        }
        $count = $count - 1
    }
}


#No Verification
function Approve-Count {
    $continue = $TRUE
    $count = 1 
    While (($count -gt 0) -and ($continue)){
        $continue = $FALSE
        $continue  = Repair-PublicFolder
        $count = $count - 1
    }
}

function Approve-All {
    $continue = $TRUE
    While ($continue){
        $continue = $FALSE
        $continue  = Repair-PublicFolder

    }
}


Approve-Count
#Approve-All
