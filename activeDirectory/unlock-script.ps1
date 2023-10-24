Import-Module ActiveDirectory
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

###################
# General Variables
###################
$formHeight = 200 #Adjust form height


function confirm-unlock ($user) {
    $heightBuffer=15
    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Please confirm'
    $form.Size = New-Object System.Drawing.Size(300,($formHeight+$heightBuffer)) 


    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(10,($formHeight+$heightBuffer-80))
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'Unlock'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    #Button for Advanced info

    $restartButton = New-Object System.Windows.Forms.Button
    $restartButton.Location = New-Object System.Drawing.Point(100,($formHeight+$heightBuffer-80))
    $restartButton.Size = New-Object System.Drawing.Size(75,23)
    $restartButton.Text = 'Restart'
    $restartButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.AcceptButton = $restartButton
    $form.Controls.Add($restartButton)


    #Button to cancel
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(190,($formHeight+$heightBuffer-80))
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(210,20)
    $label.Text = 'User to be unlocked:'
    $form.Controls.Add($label)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10,40)
    $listBox.Size = New-Object System.Drawing.Size(260,($formHeight+$heightBuffer-130))
    $listBox.Height = ($formHeight+$heightBuffer-130)

    [void] $listBox.Items.Add($user)

    $form.Controls.Add($listBox)

    if ($result -eq [System.Windows.Forms.DialogResult]::OK){
        Unlock-ADAccount $user
        select-user
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Retry) {
        select-user
    }

    $form.Topmost = $True
    $form.Add_Shown({$form.Activate()})
    [void] $form.ShowDialog()
}

function unlock-account {
    $user = select-user
    #Finding Audit Logs
    $PDC = (Get-ADDomainController -Discover -Service PrimaryDC).Name
    #Locate all DCs
    $DCs = (Get-ADDomainController -Filter *).Name #| Select-Object name
    foreach ($DC in $DCs) {
        Get-WinEvent -ComputerName $DC -Logname Security -FilterXPath `
        "*[System[EventID=4740 or EventID=4625 or EventID=4770 or EventID=4771 and TimeCreated[timediff(@SystemTime) <= 3600000]] `
        and EventData[Data[@Name='TargetUserName']='$User']]" | `
        Select-Object TimeCreated,@{Name='User Name';Expression={$_.Properties[0].Value}},`
        @{Name='Source Host';Expression={$_.Properties[1].Value}} -ErrorAction SilentlyContinue | Out-GridView
        confirm-unlock $user
    }
   

}

function get-lockedAccounts {
    $results = Search-ADAccount –LockedOut | Select-Object -ExpandProperty Name
    return $results | Sort-Object -Property Name -Descending
}

function select-user {
    $lockedAccounts = get-lockedAccounts
    #$lockedAccounts = "mark", "jeff", "dan"
    $heightBuffer = $lockedAccounts.count*5
    #Form Creation

    $form = New-Object System.Windows.Forms.Form
    $form.Text = 'Locked out Users'
    $form.Size = New-Object System.Drawing.Size(300,($formHeight+$heightBuffer))
    $form.StartPosition = 'CenterScreen'

    #Button to accept

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(10,($formHeight+$heightBuffer-80))
    $okButton.Size = New-Object System.Drawing.Size(75,23)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)

    #Button to refresh
    $reButton = New-Object System.Windows.Forms.Button
    $reButton.Location = New-Object System.Drawing.Point(190,(10))
    $reButton.Size = New-Object System.Drawing.Size(75,23)
    $reButton.Text = 'Refresh'
    $reButton.DialogResult = [System.Windows.Forms.DialogResult]::Retry
    $form.AcceptButton = $reButton
    $form.Controls.Add($reButton)

    #Button for Advanced info

    $moreButton = New-Object System.Windows.Forms.Button
    $moreButton.Location = New-Object System.Drawing.Point(100,($formHeight+$heightBuffer-80))
    $moreButton.Size = New-Object System.Drawing.Size(75,23)
    $moreButton.Text = 'More'
    $moreButton.DialogResult = [System.Windows.Forms.DialogResult]::Yes
    $form.AcceptButton = $moreButton
    $form.Controls.Add($moreButton)


    #Button to cancel
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(190,($formHeight+$heightBuffer-80))
    $cancelButton.Size = New-Object System.Drawing.Size(75,23)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,20)
    $label.Size = New-Object System.Drawing.Size(210,20)
    $label.Text = 'Please select a locked out user:'
    $form.Controls.Add($label)

    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10,40)
    $listBox.Size = New-Object System.Drawing.Size(260,($formHeight+$heightBuffer-130))
    $listBox.Height = ($formHeight+$heightBuffer-130)

    foreach ($account in $lockedAccounts) {
        [void] $listBox.Items.Add($account)
    }

    $form.Controls.Add($listBox)

    $form.Topmost = $true

    $result = $form.ShowDialog()

    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
    {
        $selection = $listBox.SelectedItem
        
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        get-advuser
        select-user
    } elseif ($result -eq [System.Windows.Forms.DialogResult]::Retry) {
        select-user
    }

    return $selection
}

function get-advuser {
    # Getting the PDC emulator DC
    $pdc = (Get-ADDomain).PDCEmulator
    # Creating filter criteria for events
    $filterHash = @{LogName = "Security"; Id = 4740; StartTime = (Get-Date).AddDays(-1)}
    # Getting lockout events from the PDC emulator
    $lockoutEvents = Get-WinEvent -ComputerName $pdc -FilterHashTable $filterHash -ErrorAction SilentlyContinue
    # Building output based on advanced properties
    $lockoutEvents | Select-Object @{Name = "LockedUser"; Expression = {$_.Properties[0].Value}}, `
                            @{Name = "SourceComputer"; Expression = {$_.Properties[1].Value}}, `
                            @{Name = "DomainController"; Expression = {$_.Properties[4].Value}}, TimeCreated | Out-GridView
}

select-user