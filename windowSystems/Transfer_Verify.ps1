<# Folder Comparison 
Purpose: Compare two folders for files that match, recursively
Author: Mark Gevaet (markgevaert@icloud.com)
#>

<#Global Variables#>
$newcount=0
$oldcount=0

Function Select-FolderDialog ()
{
    param([string]$Description,[string]$RootFolder="Desktop")

 [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
     Out-Null     

   $objForm = New-Object System.Windows.Forms.FolderBrowserDialog
        $objForm.Rootfolder = $RootFolder
        $objForm.Description = $Description
        $Show = $objForm.ShowDialog()
        If ($Show -eq "OK")
        {
            Return $objForm.SelectedPath
        }
        Else
        {
            Write-Error "Operation cancelled by user."
        }
    }

Function Find-CommonPath () {
    #Clip first 2 characters (drive letter or network path)
    $oldPathClip = $opath.SubString(2)
    $newPathClip = $npath.SubString(2)
    #Divide into array for comparison
    $oldResult = $oldPathClip.Split("\")
    $newResult = $newPathClip.Split("\")
    #Find Match
    Foreach ($oFolder in $oldResult){
        Foreach ($nFolder in $newResult){
            if ($nFolder -eq $oFolder){
                $oIndex = $opath.Indexof($ofolder)
                $nIndex = $npath.Indexof($nfolder)
                $ncompare = $npath.SubString($nIndex) | Measure-Object -Character | Foreach { $_.Characters}
                $ocompare = $opath.SubString($oIndex) | Measure-Object -Character | Foreach { $_.Characters}
                if ($ncompare -eq $ocompare){
                    $oldIndex = $opath.Indexof($ofolder)
                    $newIndex = $npath.Indexof($nfolder)
                    
                }
            }
        }
    }

    #report position
    $oldPosition = $opath.SubString(0,$oldIndex) | Measure-Object -Character | Foreach { $_.Characters}
    $newPosition = $npath.SubString(0,$newIndex) | Measure-Object -Character | Foreach { $_.Characters}
    Return $oldPosition, $newPosition
}

Function Compare-Path () {

    $oldpath = Get-ChildItem $opath -Recurse -force
    $newpath = Get-ChildItem $npath -Recurse -force
    $stringMod = Find-CommonPath($opath, $npath)
    $oldStrNum = $stringMod[0]
    $newStrNum = $stringMod[1]

    Foreach ($solpath in $oldpath) {
        write-host $solpath.Fullname
        $count = 0
        foreach ($snepath in $newpath) {
            $solpathstr = $solpath.FullName
            $snepathstr = $snepath.FullName
            if ( $solpathstr.Substring($oldStrNum) -eq $snepathstr.Substring($newStrNum) ) {
                $count++
                }
            }
        if ($count -eq 0){
            $timestamp = (Get-Date).ToString()
            $newCount++
            $result = "$newCount" + " - " + "$timestamp" + " - Not Present on Destination - " + $solpath.Fullname
            $result | Add-Content -Path $nLog
            Write-Host $newCount
            }

        }   

    Foreach ($snepath in $newpath) {
        write-host $snepath.fullname
        $count = 0
        foreach ($solpath in $oldpath) {
            $solpathstr = $solpath.FullName
            $snepathstr = $snepath.FullName
            if ( $solpathstr.Substring($oldStrNum) -eq $snepathstr.Substring($newStrNum) ) {
                $count++
                }
            }
        if ($count -eq 0){
            $timestamp = (Get-Date).ToString()
            $oldCount++
            $result = "$oldCount" + " -  " + "$timestamp" + " - Not Present on Source - " + $snepath.FullName
            $result | Add-Content -Path $oLog
            Write-Host $oldCount
            }

        }

    Write-host "Comparison completed"
    $oldcount
    $newcount
 }

<#Environment Variables#>
$opath = Select-FolderDialog ("Originating Path")
$npath = Select-FolderDialog ("New Path Comparison")
#Log initialization and cleanup
$logpath = Select-FolderDialog ("Select Log Dump Location")
$nLog = $logpath + "MissingDestination.log"
$oLog = $logpath + "MissingSource.log"
If (Test-path $nlog){
    Remove-item -path $nlog
    }
New-Item $nlog -ItemType "file"
if (Test-Path $olog){
    Remove-item -path $olog
    }
New-Item $olog -ItemType "file"


<#Work Area#>

Compare-Path -WhatIf

