<# Performance Capture
Original Purpose was to run on remote machines using a remote execute program like "BigFix"
in a hardened retail environment. The output will be a BLG file which can get quite large.

Author: Mark Gevaert (markgevaert@icloud.com)

#>

 
#variables
$time = "Time" + (get-date -UFormat %m%d%y)
$computername = $env:COMPUTERNAME
$filename = $computername + $time
$localpath = "C:\Temp\"
$UNCPath = $localpath + "$filename.blg"
$captime = 10

 
function New-PerformanceStat { 
 $CtrList = @(
        "\System\Processor Queue Length",
        "\Memory\Pages/sec",
        "\Memory\Available MBytes",
        "\Processor(*)\% Processor Time",
        "\Network Interface(*)\Bytes Received/sec",
        "\Network Interface(*)\Bytes Sent/sec",
        "\LogicalDisk(C:)\% Free Space",
        "\LogicalDisk(*)\Avg. Disk Queue Length"
        )
    Get-Counter -Counter $CtrList -SampleInterval 5 -MaxSamples $captime | Export-Counter -Path $UNCPath -FileFormat BLG -Force
}
#run system info
New-PerformanceStat
