#region synopsis
<#
.SYNOPSIS

.DESCRIPTION
	Description of what the script does
	
.PARAMETER Param
    Description for each parameter, describe each param, add params when needed.

.EXAMPLE
    Example of how to run your script
    
	
.EXAMPLE
    another example of how tun run the script

    ff test hierfffff
    ffff


.NOTES
    Authors   : <Full Name>
    Date      : <date>
    Version   : <version>
    Requires  : <dependencies or requirements like snapins>
    Tag       : <Tags comma seperated>

#>
#endregion

Function Write-MRBMessage {
	Param(
		[Parameter(Mandatory = $true)] $Message,
		[Parameter(Mandatory = $true)]
        [ValidateSet('INFO','WARNING','ERROR')]
        [string]$Category,
		[Parameter(Mandatory = $true)] $LogFile
        #[Parameter(Mandatory = $false)][boolean]$NoNewLine = $true
	)
	Try	{
		$Date = ((Get-Date -f dd-MM-yyyy-HH:mm:ss).tostring())
        $Cat = $Null
        switch ($Category) { 
	        "ERROR" {
                $MessageColor = 'red'
                $Cat = 'ERR'
            }
	        "WARNING" {
                $MessageColor = 'yellow'
                $Cat = 'WAR'
            } 
	        "INFO" {
                $MessageColor = 'Green'
                $Cat = 'INF'
            } 
	        default {Write-Host "The category of the message could not be determined" -ForegroundColor Red -BackgroundColor Black}
	    }

        Write-Host -Object "[" -NoNewline -ForegroundColor Cyan
        Write-Host -Object $Date -NoNewline -ForegroundColor White
        Write-Host -Object "]" -NoNewline -ForegroundColor Cyan
        Write-Host -Object " - " -NoNewline -ForegroundColor Green

        Write-Host -Object "[" -NoNewline -ForegroundColor Cyan
        Write-Host -Object $Cat -NoNewline -ForegroundColor White
        Write-Host -Object "]" -NoNewline -ForegroundColor Cyan

        Write-Host -Object " - " -NoNewline -ForegroundColor Green
        Write-Host -Object "[" -NoNewline -ForegroundColor Cyan
        Write-Host -Object $Message -NoNewline -ForegroundColor $MessageColor

        if ($NoNewLine) {
            Write-Host -Object "]" -ForegroundColor Cyan -NoNewline
        }
        else {
            Write-Host -Object "]" -ForegroundColor Cyan
        }

		$Message = $Date + "   " + $Message
		Out-File $LogFile -encoding ASCII -input $message -append
        
        $Date = $Null
        $Message = $Null
        $MessageColor = $Null
	}
	Catch {
		Write-Host "ERROR While trying to write message : $($_.Exception.Message), SCRIPT QUITS with ERROR -1 !!" -BackgroundColor Black -ForegroundColor Red
		Exit -1
	}
}

function returnResults($ip) {
    $Url = 'http://api.ipaddress.com/iptocountry?format=xml&ip=' + $($IP.remoteaddress)
    [xml]$retval = $Script:Web.DownloadString($Url)
    $Country = $retval.location.country_name


    #$Script:speak.SpeakAsync($Country)
    #above is an example on how to pass text to the speech engine, so she or he can read is for you
    <#
    try {
        $Result = ([System.Net.Dns]::gethostentry($ip.remoteaddress)).hostname
    }
    catch {
        $Result = $_.Exception.message
    }
    #>

    try {
        $Processname = ((get-process -id $_.OwningProcess).Name)

    }
    catch {
        $Processname = $_.exception.message
    }

    $Props = [ordered]@{
        IP = $Ip.remoteaddress
        Location = $Country
        remoteport = $ip.RemotePort
        localport = $ip.LocalPort
        localaddress = $ip.LocalAddress
        PID = [int]$ip.OwningProcess
        ProcessName = $Processname
        state = $ip.State
        #resolvedName = $result #timeout makes it to slow for usage, make swithch statement for the script to turn it on or off on demand
    }
    $obj = New-Object psobject -Property $Props
    Return $obj
}

#created By Mark Bakker, use this as template for developing powershell code.
Add-Type -AssemblyName System.speech
$Script:speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
$Obj = Invoke-WebRequest -Uri https://www.pdq.com/blog/powershell-text-to-speech-examples/
$Obj | Show-Object



#$speak.Speak('SO here we can paste information and it will be spoken')

$Script:CWD = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition #Current Dir of script
$Script:LogFile = "$($Env:temp)\$(Get-date -f dd-MM-yyyy-hh-mm-ss)-$($MyInvocation.MyCommand.Name.Replace(".ps1", ".log"))" #CurrentDir van script en hierin logfile
$Script:Web = New-Object System.Net.WebClient

Write-MRBMessage -Message "Script started" -Category INFO -LogFile $Script:LogFile

$CurrentConnectionTCP = Get-NetTCPConnection | where-object  {$_.RemoteAddress -ne '0.0.0.0' -and $_.RemoteAddress -ne '::' -and $_.RemoteAddress -ne '127.0.0.1' -and $_.RemoteAddress -ne '::1'}
$CurrentConnectionUDP = Get-NetUDPEndpoint | Select-Object * | Where-Object   {$_.RemoteAddress -ne '0.0.0.0' -and $_.RemoteAddress -ne '::' -and $_.RemoteAddress -ne '127.0.0.1' -and $_.RemoteAddress -ne '::1'}
#[ValidateRange(1-100)]#$CurrentConnectionUDP | ogv
#$CurrentConnectionTCP

$CurrentConnectionTCP | ForEach-Object {
    returnResults -ip $_
} | ogv

$Script:Web.Dispose()

Write-MRBMessage -Message "Script stopped" -Category INFO -LogFile $Script:LogFile
 
#this is the end of the script and just a test for my versioning control system on github
#ddddddddddd
