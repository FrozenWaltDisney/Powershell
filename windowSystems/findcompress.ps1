<# Search and Compress
Purpose: Find and compresses files/folder/UNC Path to a designated location
#>

<#Global Variables#>

#Compression
$zipPass = "Test123" #Password to encrypt
$7zipLoc = "C:\Program Files\7-zip\7z.exe"

#Zip Destination
$localDrop = "C:\temp\"

#Search Parameters
$dirComb = "C:\Users\"
$dirName = @(
    "folder1",
    "folder2")

$filName = @(
    "item.log",
    "item.txt")

$fullFileNP=@(
    "C:\Program Files\Git\ReleaseNotes.html",
    "C:\Program Files\Git\bin\bash.exe")

#Trigger Change
$fileChange = @(
    "nofile.test",
    "someotherfile.test"
)

#Full Sync Calendar Day
[int]$numDay = 1

<#Functions#>

#Search the directory specified by $dirCom for folders
function Search-Path {
    $targets = @()
    $dirItems = Get-ChildItem -Path $dirComb -Recurse
    foreach ($value in $dirName){
        $targets += $dirItems | Where-Object -Property name -eq $value | Where-Object { $_.PSIsContainer} | Select-Object -Property FullName
    }
    foreach ($item in $filName){
        $targets += $dirItems | Where-Object -Property name -eq $item | Select-Object -Property Fullname
    }
    foreach ($file in $fullFileNP){
        $targets += Get-Item -path $file
    }
    [string]$logger = $targetDir.Fullname
    $report = $logger.Replace(" ","`n")
    Write-Output "Folder(s) and File(s) found to be copied:`n$report"
    if ($null -eq $targets){
        Return $false
    }
    else {
        Return $targets
    }
} #End Search-Path

#Compared Modified Date of files in $dirComb against the creation date of the zip transfer
function Compare-ModDate ($continue){
    $newFiles = @()
    $zipFile = Get-Item ($localdrop + '*.zip')
    $localFiles = Get-ChildItem -Path $dirComb -Recurse
    foreach ($file in $localFiles){
        foreach ($selectFile in $fileChange){
            if ($file.Name -eq $selectFile){
                #Establishing "trigger" to see if transfer is necessary
                if ($zipFile.CreationTime -lt $file.LastWriteTime){
                    $change = $true
                }
            }
        }
        #Save files that have changed since zip was created
        if ($zipFile.CreationTime -lt $file.LastWriteTime){
            $newFiles += $file.FullName
        }
    }
    if ($change){
        return $newFiles 
    }
    else {
        Write-Output "No new files found...Exiting"
        if ($null -eq $continue){
            Exit
        }
    }
}

#Copies the Specified Directories in $dirComb to the $localDrop location to prep for compression
function Copy-Objects {
    Remove-Item -Path ($localDrop + '/*') -Recurse -Force
    $dirTargets = Search-Path
    if ($null -eq $dirTargets){
        Write-Output "No Target Directories Found"
        return $false
    }
    else {
        Foreach ($target in $dirTargets.FullName){
            #Package Location path of directories / files
            $packLoc = $localDrop + $target.substring(3)
            Write-Output "Transferring $target to package location $packLoc"
            #Get Size in MB
            $targetSize = "{0:N2}" -f ((Get-ChildItem $target -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)
            try {
                #Create Object
                New-Item -Path $packloc.Substring(0, $packloc.lastIndexOf('\')) -ItemType "Directory" -Force
                #Target Folder plus containing File
                Copy-Item $target -Destination $packLoc -Recurse -Force
            }
            catch {
                Write-Output $session 
                Write-Output "An Error occured when trying to copy all objects."
            }
            $transferSize = [int]$targetSize + $transferSize
            Write-Output "File size (in MBS): $targetSize"
            Write-Output "Cumulative Uncompressed transfer size (in MBs): $transferSize"
        }
    }
    Write-Output "Copying Files to Temp Folder is complete."
    Get-ChildItem $localdrop | Where-Object { $_.PSIsContainer} | Select-Object -Property Fullname
} #End Copy-Objects

