<# Pagerduty Help Prompt
Purpose: Creates a user interaction window directly to the end user. Originally used as a emergency help button for remove installers.
Author: Mark Gevaert + Matthew Hodgkins Notification Integration
#>
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#Start-Transcript -path "c:\Home Office\notify.log" -append

###### Notification integration ########
<#
.Synopsis
   Send events to the PagerDuty API.
.DESCRIPTION
   Allows you to send Trigger, Acknowledge and Resolve events to the PagerDuty API.
.EXAMPLE
   Send-PagerDutyEvent -Trigger -ServiceKey fbe312204f634360b17ffc5150fctest -Client "PowerShell Function" -Description "Test Description" -IncidentKey "TESTKEY2"
   Creates a new trigger event and specfies its IncidentKey
.EXAMPLE
   Send-PagerDutyEvent -Trigger -ServiceKey fbe312204f634360b17ffc5150fctest -Description "Test Description" -Details $Object
   Creates a new trigger event and without specifying its IncidentKey. Also passing an object to fill in alert details.
.EXAMPLE
   Send-PagerDutyEvent -Acknowledge -ServiceKey fbe312204f634360b17ffc5150fctest -Description "Test Acknowledge" -IncidentKey TESTKEY2
   Acknowledge a pager duty event.
.EXAMPLE
   Send-PagerDutyEvent -Resolve -ServiceKey fbe312204f634360b17ffc5150fctest -Description "Resolved the issue" -IncidentKey "c0173fc0e4b04d6bb6f083817cee4549"
   Resolve a PagerDuty event.
.NOTES
       NAME:      Get-PagerDutyEvent
       AUTHOR:    Matthew Hodgkins
       WEBSITE:   http://www.hodgkins.net.au
       WEBSITE:   https://github.com/MattHodge
#>

function Send-PagerDutyEvent
{
    [CmdletBinding(DefaultParameterSetName='Trigger',
                  ConfirmImpact='Low')]
    [OutputType([String])]
    Param
    (
        # Resolve events cause the referenced incident to enter the resolved state.
        [Parameter(Mandatory=$true,ParameterSetName="Resolve")]
        [switch]$Resolve,

        # Acknowledge events cause the referenced incident to enter the acknowledged state.
        [Parameter(Mandatory=$true,ParameterSetName="Acknowledge")]
        [switch]$Acknowledge,

        # Your monitoring tools should send PagerDuty a trigger event to report a new or ongoing problem. When PagerDuty receives a trigger event, it will either open a new incident, or add a new trigger log entry to an existing incident, depending on the provided incident_key.
        [Parameter(Mandatory=$true,ParameterSetName="Trigger")]
        [switch]$Trigger,

        # The GUID of one of your "Events API" services. This is the "service key" listed on a Generic API's service detail page.
        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$ServiceKey,

        # Identifies the incident to which this trigger event should be applied. If there's no open (i.e. unresolved) incident with this key, a new one will be created. If there's already an open incident with a matching key, this event will be appended to that incident's log. The event key provides an easy way to "de-dup" problem reports. If this field isn't provided, PagerDuty will automatically open a new incident with a unique key.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$IncidentKey,

        # The name of the monitoring client that is triggering this event.
        [Parameter(Mandatory=$false,ParameterSetName="Trigger")]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Client,

        # A short description of the problem that led to this trigger.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [string]$Description,

        # An arbitrary JSON object containing any data you'd like included in the incident log.
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [PSObject[]]$Details
    )

    # Trigger Command
    if ($Trigger)
    {
        # If there are details
        if ($Details -ne $null)
        {
            $body = @{
                        service_key = $ServiceKey
                        incident_key = $IncidentKey
                        event_type = "trigger"
                        description = $Description
                        client = $Client
                        details = $details
                    } | ConvertTo-Json 
        } # End If

        # If there are no details
        else
        {
            $body = @{
                        service_key = $ServiceKey
                        incident_key = $IncidentKey
                        event_type = "trigger"
                        description = $Description
                        client = $Client
                    } | ConvertTo-Json 
        } # End Else
        
        # Invoke Request
        Invoke-RestMethod -Uri https://events.pagerduty.com/generic/2010-04-15/create_event.json -method Post -Body $body -ContentType "application/json"
    }
} # End Function
##############################################################


#### Parameter Section

#Define Service Issues
$service1 = "Wiring Issue"
$service2 = "Peripheral Issue"
$service3 = "Software Issue"
$service4 = "Credit Card Terminal Issues"
$service5 = "General Help Inquiry"

#pagerduty service integrations with issues
$s1pager = "ae3eccc4fa5c484ea0fdc75c09103a56test"
$s3pager = "ed744b37680a4e71b42e1496fe43test"
$s4pager = "012891bbd19b435a81da29fbcdf0test"
#General Help Inquiry
$s5pager = "e57fba8cf72b4739be3106df1057test"
$sERRORpager = "54010714b878490d9f66161b896test"

##### Functions
function Get-Help {
    $form = New-Object System.Windows.Forms.Form 
    $form.Text = "Request Help from I.T."
    $form.Size = New-Object System.Drawing.Size(300,300)
    $form.StartPosition = "Manual"
    $form.Location = new-object System.Drawing.Point(600,100)

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Point(65,200)
    $OKButton.Size = New-Object System.Drawing.Size(90,23)
    $OKButton.Text = "Request Help!"
    $OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $OKButton
    $form.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Point(160,200)
    $CancelButton.Size = New-Object System.Drawing.Size(90,23)
    $CancelButton.Text = "Cancel"
    $CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $CancelButton
    $form.Controls.Add($CancelButton)

    $head = New-Object System.Windows.Forms.Label
    $head.Location = New-Object System.Drawing.Point(10,20) 
    $head.Size = New-Object System.Drawing.Size(280,20) 
    $head.Text = "Please fill out form if you require I.T. assistance."
    $form.Controls.Add($head) 

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10,60) 
    $label.Size = New-Object System.Drawing.Size(280,20) 
    $label.Text = "Please enter your Name in the box below:"
    $form.Controls.Add($label) 

    $textBox = New-Object System.Windows.Forms.TextBox 
    $textBox.Location = New-Object System.Drawing.Point(10,80) 
    $textBox.Size = New-Object System.Drawing.Size(260,20) 
    $form.Controls.Add($textBox) 

    $label1 = New-Object System.Windows.Forms.Label
    $label1.Location = New-Object System.Drawing.Point(10,110) 
    $label1.Size = New-Object System.Drawing.Size(280,20) 
    $label1.Text = "Please enter contact Phone Number Below:"
    $form.Controls.Add($label1) 

    $textBox1 = New-Object System.Windows.Forms.TextBox 
    $textBox1.Location = New-Object System.Drawing.Point(10,130) 
    $textBox1.Size = New-Object System.Drawing.Size(260,20) 
    $form.Controls.Add($textBox1) 

    $form.Topmost = $True

    $form.Add_Shown({$textBox.Select()})
    $result = $form.ShowDialog()
    #Enter in communication method below
    if ($result -eq [System.Windows.Forms.DialogResult]::OK)
        {
        $contact = $textBox.Text + ": "
        $contact += $testBox1.Text
        }

    $x = @()
    $objForm = New-Object System.Windows.Forms.Form 
    $objForm.Text = "Data Entry Form"
    $objForm.Size = New-Object System.Drawing.Size(300,200)
    $objForm.StartPosition = "Manual"
    $objForm.Location = new-object System.Drawing.Point(600,100)


    $objForm.KeyPreview = $True
    #set pagerduty for multiple objects selected
    $objForm.Add_KeyDown({if ($_.KeyCode -eq "Enter") 
        {
            foreach ($objItem in $objListbox.SelectedItems){
                if ($objItem -eq $service1){
                    Send-PagerDutyEvent -Trigger -ServiceKey $s1pager -Description "Contact: $contact Issue: $objItem" -IncidentKey "Incident"
                    
                }
                elseif ($objItem -eq $service2){
                    Send-PagerDutyEvent -Trigger -ServiceKey $s2pager -Description "Contact: $contact Issue: $objItem" -IncidentKey "Incident"
                    
                }
                elseif ($objItem -eq $service3){
                    Send-PagerDutyEvent -Trigger -ServiceKey $s3pager -Description "Contact: $contact Issue: $objItem" -IncidentKey "Incident"
                    
                }
                elseif ($objItem -eq $service4){
                    Send-PagerDutyEvent -Trigger -ServiceKey $s4pager -Description "Contact: $contact Issue: $objItem" -IncidentKey "Incident"
                    
                }
                elseif ($objItem -eq $service5){
                    Send-PagerDutyEvent -Trigger -ServiceKey $s5pager -Description "Contact: $contact Issue: $objItem" -IncidentKey "Incident"
                    
                }
                else {
                    Send-PagerDutyEvent -Trigger -ServiceKey $sERRORpager -Description "Contact: $contact Issue: Undefined" -IncidentKey "Incident"
                    
                }  
            }
            $objForm.Close()
           }
        })

        $objForm.Add_KeyDown({
        if ($_.KeyCode -eq "Escape") {
            $objForm.Close()
            }
        }
        )

    $OKButton = New-Object System.Windows.Forms.Button
    $OKButton.Location = New-Object System.Drawing.Size(75,130)
    $OKButton.Size = New-Object System.Drawing.Size(75,23)
    $OKButton.Text = "OK"
    #trigger pagerduty notification for multiple objects on button press
    $OKButton.Add_Click( 
        { 
         foreach ($objItem in $objListbox.SelectedItems){
            if ($objItem -eq $service1){
                Send-PagerDutyEvent -Trigger -ServiceKey $s1pager -Description "Contact: $contact Issue: $objItem" -IncidentKey "Incident"
                
            }
            elseif ($objItem -eq $service2){
                Send-PagerDutyEvent -Trigger -ServiceKey $s2pager -Description "Contact: $contact Issue: $objItem" -IncidentKey "Incident"
                
            }
            elseif ($objItem -eq $service3){
                Send-PagerDutyEvent -Trigger -ServiceKey $s3pager -Description "Contact: $contact Issue: $objItem" -IncidentKey "Incident"
                
            }
            elseif ($objItem -eq $service4){
                Send-PagerDutyEvent -Trigger -ServiceKey $s4pager -Description "Contact: $contact Issue: $objItem" -IncidentKey "Incident"
                
            }
            elseif ($objItem -eq $service5){
                Send-PagerDutyEvent -Trigger -ServiceKey $s5pager -Description "Contact: $contact Issue: $objItem" -IncidentKey "Incident"
                
            }
            else{
                Send-PagerDutyEvent -Trigger -ServiceKey $sERRORpager -Description "Contact: $contact Issue: Undefined" -IncidentKey "Incident"
                
            } 
        }
        $objForm.Close()
   })
    #set form parameters
    $objForm.Controls.Add($OKButton)

    $CancelButton = New-Object System.Windows.Forms.Button
    $CancelButton.Location = New-Object System.Drawing.Size(150,130)
    $CancelButton.Size = New-Object System.Drawing.Size(75,23)
    $CancelButton.Text = "Cancel"
    $CancelButton.Add_Click({$objForm.Close()})
    $objForm.Controls.Add($CancelButton)

    $objLabel = New-Object System.Windows.Forms.Label
    $objLabel.Location = New-Object System.Drawing.Size(10,20) 
    $objLabel.Size = New-Object System.Drawing.Size(260,20) 
    $objLabel.Text = "Please make a selection from the list below:"
    $objForm.Controls.Add($objLabel) 

    $objListbox = New-Object System.Windows.Forms.Listbox 
    $objListbox.Location = New-Object System.Drawing.Size(10,40) 
    $objListbox.Size = New-Object System.Drawing.Size(260,90) 
    $objListBox.BackColor = "White"
    $objListBox.Forecolor = "Black"
    $objListBox.Font = "Arial Black"


    $objListbox.SelectionMode = "MultiExtended"

    [void] $objListbox.Items.Add($service1)
    [void] $objListbox.Items.Add($service2)
    [void] $objListbox.Items.Add($service3)
    [void] $objListbox.Items.Add($service4)
    [void] $objListbox.Items.Add($service5)

    $objListbox.Height = 90
    $objForm.Controls.Add($objListbox) 
    $objForm.Topmost = $True

    $objForm.Add_Shown({$objForm.Activate()})
    [void] $objForm.ShowDialog()

}

####DO WORK######

Get-Help