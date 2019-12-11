$destination = "\\COMPUTER\C$"
$RoboLog = "C:\robolog.txt"
$UNCItem = ""
$UNCFolder = ""
$userSpecial = "AppData\Local\Mozilla",
"AppData\Local\Google",
"AppData\Roaming\Mozilla"

###############################################################################################################

<# FUNCTIONS #>

Function Show-List ($ulist, $listname) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Select a $listname"
    $form.Size = New-Object System.Drawing.Size(300,200)
    $form.StartPosition = 'CenterScreen'

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(75,120)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = 'OK'
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Point(150,120)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = 'Cancel'
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $CancelButton
    $form.Controls.Add($CancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(280,20)
    $label.Text = "Please select a $listname:"
    $form.Controls.Add($label)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10,40)
    $listBox.Size = New-Object System.Drawing.Size(260,20)
    $listBox.Height = 80
    foreach ($user in $ulist){
    [void] $listBox.Items.Add("$user")
    }

    $form.Controls.Add($listBox)

    $form.Topmost = $true

    $result = $form.ShowDialog()
    return $result
}



#Grab Users
$user = Get-ChildItem "C:\Users\" | Where-Object -Property Name -match "\d"
#Present List
If ($null -ne $user){
    $target = Show-List $user "user"
}
else {
    Write-Host "No Users Found"
    Exit
}
$folders = Get-ChildItem "C:\Users\$target"
$transfer = Show-List $folders.Name "folder(s)"
$transfer = $userSpecial + $transfer
$list = $null
Foreach ($object in $transfer){
    $list += "C:\Users\$target\$object"
}
$list = $list + $UNCFolder

$num = $list.count
foreach ($item in $list){
    robocopy $item $destination /MIR /SEC /TEE /R:2 /LOG:$RoboLog -AsJob
}
While ($state){
    Remove-Job -State Finished
    $jobs = Get-Job
    If ($null -eq $jobs){
        $state = $false
    }
    Clear-Host
    Write-Host "Number of Jobs to complete: $jobs.count"\
}
