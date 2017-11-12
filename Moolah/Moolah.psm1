# Module Constants

  Set-Variable -Name MoolahXML -Value "MoolahDB-$env:COMPUTERNAME.xml" -Option Constant -Scope Script -Visibility Private -Description "XMLDB file";
  Set-Variable -Name MoolahLOG -Value "$PWD\Moolah.log" -Option Constant -Scope Script -Visibility Private -Description "Log file";
  $Script:MoolahDB = $null

#

# Non-Exported Functions

  # Dot Sourced Functions

    #. $PSScriptRoot\Local\NoneAtThisTime.ps1

  #

  function Get-GuiltTrip {
    Clear-Host
    Write-Host "Looks like you have been enjoying " -NoNewline -ForegroundColor Green
    Write-Host "Moolah " -NoNewline
    Write-Host "for a while now and " -NoNewline -ForegroundColor Green
    Write-Host "THANKS!! " -NoNewline
    Write-Host "for doing so." -ForegroundColor Green
    Write-Host " "
    Write-Host "Donations via PayPal, Bitcoin, Bitcoin Cash, Etherum, and LiteCoin are accepted." -ForegroundColor Green
    Write-Host " "
    
    Write-Host "Would like to make a donation to show your graditude "  -ForegroundColor Yellow -NoNewLine
    Write-Host "[Y or N]?"
    $rslt = Read-Host | Out-Null
    Write-Host " "
    
    if ($rslt -match "Y") {
      "Donor" | Out-File -FilePath $PWD\donor.txt -Append -Encoding ascii;
      $URL = http://Moolah.readthedocs.io/en/latest/donate
      Start-Process $URL
    } else {
      Write-Host "Thanks. Perhaps I will nag you later so you can show your graditude."
    }
    
  }

  function Set-NewLog {

    $logext = get-date -format "yyyyMMdd";
    $oldlog = "Moolah-$logext" + ".log"

    Move-Item -Path Moo:MoolahLOG -Destination Moo:$oldlog;

  }

  function Write-LogHdr {
	
    $msg = "Executing Moolah on host " + $env:COMPUTERNAME;
    Write-Log $msg;
    Write-Log "****** Execution Info ********";
    Write-Log "  Execution path: $PWD";
    Write-Log "      Running as: $env:USERNAME";
    Write-Log "        Log File: $Script:MoolahLOG";
    Write-Log " "

  }
  
  function Write-Log {
    param([string]$msg,[bool]$con,[string]$color)
	
    #$logext         = get-date -format "yyyyMMdd";
    #$Script:logname = "$PWD" + "\" + "$MyName" + "_" + "$logext" + ".log";
    $timestamp      = get-date -format "MM/dd/yy HH:mm:ss";
    $logrec1        = "$timestamp : ";
    $logrec1        += $msg;

    if ($con) {
      if ([string]::IsNullOrEmpty($color)) {
        Write-Host $msg
      } else {
        Write-Host $msg -ForegroundColor $color
      }
    }

    if (!(Test-Path $Script:MoolahLOG)) { # file does not exist
      New-Item $Script:MoolahLOG -type file | Out-Null
      Write-LogHdr;
    } else {
      [int]$lncnt = (Get-Content $Script:MoolahLOG | measure-object -line).Lines
      if ($lncnt -ge 1000) {
        $logext = get-date -format "yyyyMMdd";
        $oldlog = "$PWD\Moolah-$logext" + ".log"
        Move-Item -Path $Script:MoolahLOG -Destination $oldlog;
        New-Item $Script:MoolahLOG -type file | Out-Null
        Write-LogHdr;
        if (!(Test-Path $PWD\donor.txt)) {
          Get-GuiltTrip;
        }
      }
    }

    Add-Content $Script:MoolahLOG $logrec1 -force
  }

  function UpDate-SVNServer {
		param([string]$svnPath, [string]$cmd)
    # SVN server is determined by the .SVN directory in the $svnPath parameter

    Write-Host " "
    $logmsg = "Performing SVN $cmd on $svnPath"
    Write-Log $logmsg $true "Green"
    Write-Host "  Warning: VPN session can block access to SVN server" -ForegroundColor Yellow
    $rslt = Read-Host "Enter (Y) to SVN $cmd or (N) to skip or CTRL-C to exit"
    Write-Host " "

    if ($rslt -match "Y") {
      tortoiseproc /command:$cmd /path:$svnpath /closeonend:1
      $ps = "dummy";
      Write-Host "Waiting for TortoiseSVN to complete" -ForegroundColor Green
      While (!([string]::IsNullOrEmpty($ps))) {
        Start-Sleep -Seconds 5;
        $ps = Get-Process | Where-Object {$_.ProcessName -match "TortoiseProc"}
      }
      Write-Host " "
    }
  }
  
  function Start-Code {
    param([string]$fileNM)
    Write-Host "Update $fileNM following the instructions and you'll be done with the setup work" -ForegroundColor Magenta
    Write-Host "Want to launch MicroSoft Visual Code to update $fileNM " -ForegroundColor Green -NoNewline
    Write-Host "[Y or N]?" -NoNewline
    $rslt = Read-Host;
    if ($rslt -match "Y") {
      $URL = "C:\Program Files\Microsoft VS Code\Code.exe"
      Start-Process -FilePath $URL -ArgumentList $fileNM
    } else {
      Write-Host "Update $fileNM with your own favorite ASCII editor." -ForegroundColor
    }

    Write-Host " "
    Write-Host "Once $fileNM has been updated correctly you can launch the wallet application by "
    Write-Host "entering: " -NoNewline
    Write-Host "Start-Wallet " -ForegroundColor Green -NoNewline
    Write-Host "in the PowerShell Console or by clicking on the " -NoNewline
    Write-Host "Moolah shortcut icon " -ForegroundColor Green -NoNewline
    Write-Host "on the desktop."
    Write-Host " "
    Write-Host "Enter 'exit' to termincate the PowerShell console window"

  }

  function Set-MoolahShortCut {

    $moolah_shortcut = $env:USERPROFILE + "\Desktop\Moolah.lnk"
    $arg = '-Command "& { Start-Wallet }" -NoExit'
    $sdesc = "Moolah Wallets"
  
    if (!(Test-Path $moolah_shortcut)) {
      $Shell = New-Object -ComObject ("WScript.Shell")
      $ShortCut = $Shell.CreateShortcut($moolah_shortcut)
      $ShortCut.TargetPath="C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
      $ShortCut.Arguments=$arg
      $ShortCut.WorkingDirectory = $env:LOCALAPPDATA;
      $ShortCut.IconLocation= "$PSScriptRoot\Data\Moolah.ico"
      $ShortCut.Description = $sdesc;
      $ShortCut.Save()
    }
  }

  function Get-MoolahDB {

    $FileIn = $env:Moolah_DL + ":\" + $Script:MoolahXML

		if (Test-Path Moo:$Script:MoolahXML) { # input file exist?
      $Script:MoolahDB = new-object "System.Xml.XmlDocument"
      $Script:MoolahDB.Load($FileIn)
			return $Script:MoolahDB;
		} else {
      $logmsg = "$FileIn not found"
      Write-Log $logmsg $true "Red"
			return $null
		}

  }

  function Wait-ForMount {
    param([string]$driveletter)

    $drltr = $driveletter + ":"
    $dl = Get-WmiObject Win32_Volume | Where-Object {$_.DriveLetter -match $drltr }
    While (!($dl -is [object])) {
      $logmsg = "Waiting for $drltr to be mounted"
      Write-Log $logmsg $true "Green"
      Start-Sleep -Seconds 7
      $dl = Get-WmiObject Win32_Volume | Where-Object {$_.DriveLetter -match $drltr }
    }
  }
  
  function Mount-VeVolume {
    param([string]$volname,[string]$drive)

    try {
      veracrypt /q /v $volname /l $drive
    }
    Catch {
      return $false
    }

    return $true

  }

  function Dismount-VeVolume {
    param ([string]$drive)

    veracrypt /q /d $drive

  }

  function Set-MoolahEnvironment {

    # Set Moolah_Online environment variable
      $default = [Environment]::GetEnvironmentVariable("Moolah_Online","User")
      if ([string]::IsNullOrEmpty($default)) { $default = "C:\bin\app"}
      Write-Host "Enter the Online path to the Moolah VeraCrypt container " -ForegroundColor Green -NoNewline
      Write-Host " [$default]" -NoNewline
      $myOnline = Read-Host
      if ([string]::IsNullOrEmpty($myOnline)) {
        $myOnline = $default;
      }
      Write-Host " ";
      if ($env:Moolah_Online -eq $null) { 
        [Environment]::SetEnvironmentVariable("Moolah_Online",$myOnline,"User");  # Add it for the user permanently
        # [Environment]::SetEnvironmentVariable("Moolah_DB",$null,"User");  # Remove it
        # New-item -Path env:Moolah_Online -Value $myOnline | Out-Null      # add it for this session only
      } else {
        Set-Item -Path env:Moolah_Online -Value $myOnline | Out-Null
      }
      $logmsg = "   Moolah_Online set to $myOnline"
      Write-Log $logmsg $true
      if (!(Test-Path $myOnline)) {
        New-Item -Path $myOnline -ItemType Directory | Out-Null
      }
      Write-Host " "
    #

    # Set Moolah_Offline environment variable
      $default = [Environment]::GetEnvironmentVariable("Moolah_Offline","User")
      if ([string]::IsNullOrEmpty($default)) { $default = "D:\bin\app"}      
      Write-Host "Enter the Offline path to the Moolah VeraCrypt container " -ForegroundColor Green -NoNewline
      Write-Host " [$default]" -NoNewline
      $myOfline = Read-Host
      if ([string]::IsNullOrEmpty($myOfline)) {
        $myOfline = $default;
      }
      Write-Host " "
      if ($env:Moolah_Offline -eq $null) {
        [Environment]::SetEnvironmentVariable("Moolah_Offline",$myOfline,"User");  # Add it for the user permanently
        #New-item -Path env:Moolah_Offline -Value $myOfline | Out-Null
      } else {
        Set-Item -Path env:Moolah_Offline -Value $myOfline | Out-Null
      }
      $logmsg = "  Moolah_Offline set to $myOfline"
      Write-Log $logmsg $true
      if (!(Test-Path $myOfline)) {
        New-Item -Path $myOfline -ItemType Directory | Out-Null
      }
      Write-Host " "
    #
    
    # Set Moolah_VC environment variable
      $default = [Environment]::GetEnvironmentVariable("Moolah_VC","User")
      if ([string]::IsNullOrEmpty($default)) { $default = "Moolah"}
      Write-Host "What is the name of the Moolah VeraCrypt container? " -ForegroundColor Green -NoNewline
      Write-Host " [$default]" -NoNewline
      $myMoolah = Read-Host
      if ([string]::IsNullOrEmpty($myMoolah)) {
        $myMoolah = $default;
      }
      Write-Host " "
      if ($env:Moolah_VC -eq $null) { 
        [Environment]::SetEnvironmentVariable("Moolah_VC",$myMoolah,"User");  # Add it for the user permanently
        #New-item -Path env:Moolah_VC -Value $myMoolah | Out-Null
      } else {
        Set-Item -Path env:Moolah_VC -Value $myMoolah | Out-Null
      }
      $logmsg = "  Moolah_VC set to $myMoolah"
      Write-Log $logmsg $true
      Write-Host " "
    #

    # Set Moolah_DL drive letter environment variable
      $default = [Environment]::GetEnvironmentVariable("Moolah_DL","User")
      if ([string]::IsNullOrEmpty($default)) { $default = "A"}
      Write-Host "What drive letter will be used to mount the Moolah VeraCrypt container? " -ForegroundColor Green -NoNewline
      Write-Host " [$default]" -NoNewline
      $myMount = Read-Host
      if ([string]::IsNullOrEmpty($myMount)) {
        $myMount = $default;
      }
      Write-Host " "
      if ($env:Moolah_DL -eq $null) { 
        [Environment]::SetEnvironmentVariable("Moolah_DL",$myMount,"User");  # Add it for the user permanently
        #New-item -Path env:Moolah_DL -Value $myMount | Out-Null
      } else {
        Set-Item -Path env:Moolah_DL -Value $myMount | Out-Null
      }
      $logmsg = "  Moolah_DL set to $myMount"
      Write-Log $logmsg $true
      Write-Host " "
    #

    # Set Moolah_WL Wallet drive letter environment variable
      $default = [Environment]::GetEnvironmentVariable("Moolah_WL","User")
      if ([string]::IsNullOrEmpty($default)) { $default = "B"}
      Write-Host "What drive letter will be used to mount the Wallet VeraCrypt container? " -ForegroundColor Green -NoNewline
      Write-Host " [$default]" -NoNewline
      $myWallet = Read-Host
      if ([string]::IsNullOrEmpty($myWallet)) {
        $myWallet = "B";
      }
      Write-Host " "
      if ($env:Moolah_WL -eq $null) {
        [Environment]::SetEnvironmentVariable("Moolah_WL",$myWallet,"User");  # Add it for the user permanently 
        New-item -Path env:Moolah_WL -Value $myWallet | Out-Null
      } else {
        Set-Item -Path env:Moolah_WL -Value $myWallet | Out-Null
      }
      $logmsg = "  Moolah_WL set to $myWallet"
      Write-Log $logmsg $true
      Write-Host " "
    #

  }

  function Get-MoolahEnvironment {
    param([string]$WalletNM)

    if (($env:Moolah_VC -eq $null) -or ($WalletNM -match "Init")) {
      Set-MoolahEnvironment;
      if ($WalletNM -match "Init") {
        Set-MoolahShortCut;
        Write-Host "Moolah environmental variables have been updated." -ForegroundColor Magenta
        Write-Host "  To verify these variables exist a new PowerShell console session needs to started";
        Write-Host "  to display the current Moolah environment variables and create the Moolah Database."
        Write-Host " "
        Write-Host "This PowerShell console session is going to be terminated." 
        Write-Host "Start a new PowerShell console session and enter the command: "
        Write-Host " Show-MoolahEnv" -ForegroundColor Green
        Write-Host " "
        Write-Host "Enter any key to continue" -ForegroundColor Green -NoNewline
        Read-Host " "
        # Invoke-Expression 'cmd /c start powershell -Command {Show-MoolahEnv} -NoExit'
      }
    }
  }

  function Initialize-MoolahDB {

    $driveltr = $env:Moolah_DL + ":\";
    $mvc = $env:Moolah_Online + "\" + $env:Moolah_VC;

    if (Test-Path $mvc) { # Moolah container exists
      if (Test-Path $driveltr) { # assume Moolah container mounted
      } else {
        Write-Host "Mount $mvc on drive $env:Moolah_DL " -ForegroundColor Green -NoNewline
        Write-Host "[Y or N]? " -NoNewline
        $rslt = Read-Host;
        Write-Host " "
        if ($rslt -eq "Y") {
          if (Mount-VeVolume $mvc $env:Moolah_DL) {
            $logmsg = "  $mvc is being mounted on $driveltr"
            Write-Log $logmsg $true
          } else {
            $logmsg = "Error mounting $mvc as $driveltr"
            Write-Log $logmsg $true "Red"
            Write-Host " Perhaps the incorrect password was entered?";
            Write-Host "Try executing " -NoNewline
            Write-Host "Show-MoolahEnv " -ForegroundColor Green -NoNewline
            Write-Host "again with the correct password."
            Read-Host "Enter any key to exit"
            exit
          }
        } else {
          Write-Host "$rslt was not the correct response to mount $mvc" -ForegroundColor Red
          Write-Host "Without the MoolahDB present it is not possible to proceed" -ForegroundColor Red
          Read-Host "Enter any key to exit"
          exit
        }
      }
    }

    Wait-ForMount $env:Moolah_DL
    New-PSDrive -Name Moo -PSProvider FileSystem -Root $driveltr | Out-Null
    # Regular drive mount detection only working with PSDrive in
    # this code block for some reason.

    # Copy MoolahDB-<COMPUTERNAME>.xml to Moolah container
      $mDB = $driveltr + $Script:MoolahXML
      if (Test-Path Moo:$Script:MoolahXML) {
        Write-Host "$Script:MoolahXML is already present" -ForegroundColor Green
        Write-Host " "
        Start-Code $mDB
      } else {
        $src = "$PSScriptRoot\Data\MoolahDB.xml"
        Copy-Item -Path $src -Destination Moo:$Script:MoolahXML
        Start-Sleep -Seconds 5
        if (Test-Path Moo:$Script:MoolahXML) {
          Write-Host "Awesome $Script:MoolahXML is now present" -ForegroundColor Green
          Write-Host " "
          Start-Code $mDB
        } else {
          Write-Host "Sorry for some reaon $src was not copied to $driveltr $Script:MoolahXML " -ForegroundColor Red
          Write-Host "$Script:MoolahXML needs to be located on $driveltr and configured correctly" -ForegroundColor Red
          Write-Host " "
          Write-Host "Try copying this file manually to $driveltr";
          Write-Host "$Script:MoolahXML will need to be updated using any ASCII editor to match your configuration." -foreground Green
        }
      }
    #
  }

  function Get-Wallets {
    begin {
      $Script:WalArrays = @();
      $logmsg = "Creating Wallet Object"
      Write-Log $logmsg $false " "
    }
    process {
      $WalletObj = New-Object -typename PSObject
      $WalletObj | Add-Member -MemberType NoteProperty -Name "Wallet" -Value $_.Name
      $WalletObj | Add-Member -MemberType NoteProperty -Name "Application" -Value $_.Application
      $WalletObj | Add-Member -MemberType NoteProperty -Name "KeepOnLine" -Value $_.KeepOnLine
      $Script:WalArrays += $WalletObj
    }
    # return an array of storage arrays
    end { $Script:WalArrays }
  }

#

# Exported Functions

  <#
    .SYNOPSIS
      Displays the currrent Moolah environmental variable settings.

    .Description
      This function is called internally to validate environmental variables
      have been set correctly and to copy the initial MoolahDB-<COMPUTERNAME>.xml file.

      Execute this function anytime after the initial setup to display the
      current Moolah environmental variables.

    .NOTES
      Author: Craig Dayton
        0.1.0: 11/01/2017 - initial release.

    .LINK
      https://github.com/cadayton/Moolah

    .LINK
      http://Moolah.readthedocs.io
    
  #>

  function Show-MoolahEnv {
    [cmdletbinding()] param()

    $logmsg = "Start-MoolahEnv 0.1.0"
    Write-Log $logmsg $true
    Write-Host " "

    Write-Host "Current Enviornment variable for Moolah are:" -ForegroundColor Green
    Get-childitem -Path env: | Where-Object {$_.Name -like "Moolah_*"} | Format-Table -AutoSize
    Write-Host " "
    Write-Host "The variables " -ForegroundColor Green -NoNewline
    Write-Host "Moolah_DL, Moolah_Offline, Moolah_OnLine, Moolah_VC, and Moolah_WL " -NoNewline
    Write-Host "should be displayed." -ForegroundColor Green
    Write-Host " "
    Write-Host "Start-Wallet Init " -ForegroundColor Green -NoNewline
    Write-Host " to change any of the variable values."
    Write-Host " "
    Write-Host "Are the Moolah variables correct " -ForegroundColor Green -NoNewline
    Write-Host " [Y or N or Enter]?" -NoNewline
    $rslt = Read-Host;
    Write-Host " ";

    $driveltr = $env:Moonlah_DL + ":\";
    $mDB = $driveltr + $Script:MoolahXML

    if (!(Test-Path $mDB)) { # MoolahDB not present
      switch ($rslt) {
        "Y" {
          Write-Host "Great with the Moolah variables set correctly, we can continue with the initial setup" -ForegroundColor Green
          Write-Host " ";
          Write-Host "Now verifying that $env:Moolah_VC exists and is mounted as drive letter $env:Moolah_DL"
          Initialize-MoolahDB;
        }
        "N" {
          Write-Host "Please re-execute " -NoNewline
          Write-Host "Start-Wallet Init " -ForegroundColor Green -NoNewline
          Write-Host "to set the variables to the correct values."
        }
        Default {
          Write-Host "$rslt is neither 'Y' or 'N' so input has been ignored" -ForegroundColor Red
        }
      }
    }
  }

  <#
    .SYNOPSIS
      Starts the Password Management application specified in the MoolahDB database.
      
    .DESCRIPTION
      The Password Management application database is contained in a the Moolah VeraCrypt container
      along with the MoolahDB-<COMPUTERNAME>.xml.

      The Moolah (default name) file is a VeraCrypt container that contains the Moolah database, 
      Password Management database and other confidential data files.

    .INPUTS
      File: MoolahDB-<COMPUTERNAME>.xml

      The Moolah database resides in Moolah VeraCrypt container mounted as drive letter 'A'.

    .INPUTS
      File: Moolah

      The file, Moolah is a VeraCrypt container.

    .EXAMPLE
      Start-PwManager
      
      Starts the Password Management application.

    .NOTES
      Author: Craig Dayton
        0.1.0: 11/01/2017 - initial release.
    
    .LINK
      https://github.com/cadayton/Moolah

    .LINK
      http://Moolah.readthedocs.io
    
  #>

  function Start-PwManager {
    [cmdletbinding()] param()

    $logmsg = "Start-PwManager 0.1.0"
    Write-Log $logmsg $true
    Write-Host " "

    Get-MoolahEnvironment;

    # init variables

			$vol      = $env:Moolah_Online.SubString(0,3)
			$ovol     = $env:Moolah_Offline.SubString(0,3)
      $volPath  = $env:Moolah_Online.SubString(3)
      $onPath   = $env:Moolah_Online
      $ofPath   = $env:Moolah_Offline
      $dltr     = $env:Moolah_DL	                              # Drive Letter to mount Moolah VeraCrypt container
      $onLine   = $env:Moolah_Online + "\" + $env:Moolah_VC;    # Full local path of Moolah VeraCrypt container
      $ofLine   = $env:Moolah_Offline + "\" + $env:Moolah_VC;   # Full offline path of Moolah VeraCrypt container
      
      $Script:aPath    = $dltr + ":\"

    #

    # Validate and Restore Online Moolah VeraCrypt container
      if (!(Test-Path $Script:aPath)) { # Moolah VeraCrypt container not mounted
        if (!(Test-Path $onLine) -and !(Test-Path $ofLine)) {
          $logmsg = "Neither $onLine or $ofLine exist!"
          Write-Log $logmsg $true "Red"
          Write-Host "Please read the instructions on how to create the Moolah container or" -ForegroundColor Magenta
          Write-Host "mount your offline media first. " -ForegroundColor Magenta
          Read-Host "Enter any key to exit"
          exit;
        } elseif (!(Test-Path $onLine)) {
          $logmsg = " $onLine not found"
          Write-Log $logmsg $true "Red"
          $rslt = Read-Host "Want to restore from offline copy? (Y or N) or CTRL-C to exit"
          if ($rslt -match "Y") {
            if ((Test-Path $ofLine)) {
              if (!(Test-Path $onPath)) { New-Item -Path $vol -name $volPath -ItemType directory | Out-Null}
                $logmsg = "Restoring $onLine from $ofLine"
                Write-Log $logmsg $true "Magenta"
                Copy-Item -Path $ofLine -Destination $onLine;
            } else {
              $logmsg = "Offline copy $ofLine not found"
              Write-Log $logmsg $true "Red"
            }
          } else {
            Write-Host "Sorry can't proceed without the mounting the $onLine container" -ForegroundColor Red
            Read-Host "Enter any key to exit"
            exit;
          }
        }
      }
    
    #

    # Mount Online Moolah VeraCrypt container on $env:Moolah_DL
      if (!(Test-Path $Script:aPath)) { # Moolah VeraCrypt container not mounted
        if (!(Test-Path $onLine)) {
          $logmsg = " $onLine not found"
          Write-Log $logmsg $true "Red"
          Read-Host "Enter any key to exit"
          exit;
        } else {

          # $logmsg = "Updating offline copy $ofLine"
          # Write-Log $logmsg $true "Green"
          if (!(Test-Path $ofPath)) { New-Item -Path $ovol -name $volPath -ItemType directory | Out-Null };
          # Copy-Item -Path $onLine -Destination $ofLine;

          if (Mount-VeVolume $onLine $dltr) {
            Wait-ForMount $env:Moolah_DL
            New-PSDrive -Name Moo -PSProvider FileSystem -Root $Script:aPath | Out-Null
            # Regular drive mount detection only working with PSDrive in
            # this code block for some reason.

            if (Test-Path Moo:.svn) { # SVN Update process
              UpDate-SVNServer "$Script:aPath" "update";
            }

          } else {
            $logmsg = "Error Mounting $onLine on $dltr"
            Write-Log $logmsg $true "Red"
            Read-Host "Enter any key to exit"
            exit;
          }
        }
      } else {
        $psd = Get-PSDrive | Where-Object {$_.Name -eq "Moo"}
        if (!($psd -is [object])) {
          New-PSDrive -Name Moo -PSProvider FileSystem -Root $Script:aPath | Out-Null
        }
      }
    #

    # Get PwManager parameters
    
      $myDB = Get-MoolahDB;
      if (!($myDB -is [Object])) {
        $logmsg = "Unable to load " + $env:Moolah_DL + ":\" + $Script:MoolahXML
        Write-Log $logmsg $true "Red"
        Read-Host "Enter any key to exit"
        exit
      }

      $PwMgr = $myDB.SelectNodes("//Application") | Where-Object {$_.Name -eq "PwManager"}
      if (!($PwMgr -is [object])) {
        $logmsg = "Application PwManager record not available in the Moolah DB"
        Write-Log $logmsg $true "Red"
        Read-Host "Enter any key to exit"
        exit
      }

      $URL = $PwMgr.Binary;
      $ARG = $Script:aPath + $PwMgr.ARG;
      $bName = $PwMgr.Process;

    #

		# Start PwManager process
      $Script:pwmObj = Get-Process | Where-Object {$_.ProcessName -match $bName}
      if (([string]::IsNullOrEmpty($Script:pwmObj))) {
        Try { Start-Process -FilePath $URL -ArgumentList $ARG }
        Catch {
          $logmsg = "Error starting $URL with $ARG"
          Write-Log $logmsg $true "Red"
          Read-Host "Enter any key to exit.."
          exit
        }
        Start-Sleep -Seconds 1
        $Script:pwmObj = Get-Process | Where-Object {$_.ProcessName -match $bName}
      }
    #
	
  }

  <#
    .SYNOPSIS
      Starts any Crypto Currency Windows desktop wallet application provided
      the application provides a method of loading the wallet data from a
      specific folder.
      
      By default, the Exodus desktop application from https://exodus.io/ is started
      with a specified wallet. If desired, many different wallets can exist but only
      one wallet at a time can be active.

    .DESCRIPTION
      Starts Exodus with a wallet contained in a VeraCrypt container.
      
      A GridView dialog is presented for the seletion of a specific wallet maintained in the
      wallet database.
      
      The Moolah database and Exodus wallet are two separate VeraCrypt containers
      and will be mounted as different drive letters.  The Moolah container will be
      mounted as drive letter 'A' and the Exodus wallet will be mounted drive letter 'B'.

      Both an online, offline, and SVN copy of the Exodus wallet is maintained. The Online term is
      used to refer to a path location on Windows' 'C' drive.  The Offline term is used to refer to
      path location on Windows that contains removable media like a MicroSD or USB drive.
      The SVN copy is optional.

    .PARAMETER Wallet
      The name of the wallet to be mount on drive letter 'B'.

    .INPUTS
      User Enviornment variables for Moolah are:

        Name           Value          Description
        ----           -----          -----------        
        Moolah_DL      A              Driveletter for mounting the Moolah VeraCrypt container
        Moolah_Offline D:\bin\app     Offline location of VeraCrypt containers
        Moolah_Online  C:\bin\app     Online location of VeraCrypt containers
        Moolah_VC      Moolah         Name of the Moolah VeraCrypt container
        Moolah_WL      B              Driveletter for mounting the Wallet VeraCrypt container

    .INPUTS
      File: Moolah (default name)

      The Moolah file is a VeraCrypt container with an Online location of C:\bin\app and a
      offline location of D:\bin\app. Confidential data files such as Moolah database, Password Manager
      database and other confidential files reside in this container. 
      
      The Moolah container file is mounted as drive letter 'A'.
      
    .INPUTS
      File: A:\MoolahDB-<COMPUTERNAME>.xml

      This is an XML database containing wallet and application records.
      The DB structure is as follows:
      
        <MoolahDB version="1.0">
          <Wallet Name="Exodus" Application="Exodus">
            <SVN>0</SVN>
            <KeepOnLine>1</KeepOnLine>
            <Alert>1</Alert>
          </Wallet>
          <Application Name="Exodus">
            <Binary>C:\Users\MrCrypto\AppData\Local\exodus\Exodus.exe</Binary>
            <Process>Exodus<Process>
            <ARG>--datadir</ARG>
          </Application>
        </MoolahDB>

    .INPUTS
      File: B:\<walletname>
      
      A VeraCrypt container containing the Exodus Wallet.

      The default folder for the Exodus Wallet is: C:\Users\<username>\AppData\Roaming\Exodus

      The contents of the default folder is moved to a VeraCrypt container and
      mounted as drive letter B.  The process of moving Exodux's Wallet directory to
      a VeraCrypt container is performed manually prior to invoking the PowerShell
      automation script.

      See the documentation on how to setup the system.

    .OUTPUTS
      A offline backup of the Exodus wallet to a USB or MicroSD drive and 
      optionally performs a SVN commit operation the wallet folder.

    .EXAMPLE
      Start-Wallet Exodus

      Mounts the Moolah VeraCrypt container as drive letter 'A' and the
      named wallet container 'Exodus' as drive letter 'B'.

      The container files are stored in the default online path of C:\bin\app
      and the offline path of D:\bin\app.

      The Password Manager and Exodus application are then launched.

      When the Exodus application is terminated, the contents of the online wallet
      container is copied to the offline path and optionally the online wallet
      container is removed.

    .EXAMPLE
      Start-Wallet

      Processes the same as the previous example, but a table of existing
      wallets is displayed for selection of the desired wallet to use.

      This is the default method used when started from the Moolah shortcut icon.

    .NOTES
      Author: Craig Dayton
        0.1.0: 11/01/2017 - initial release.
    
    .LINK
      https://github.com/cadayton/Moolah

    .LINK
      http://Moolah.readthedocs.io
    
  #>

  function Start-Wallet {

    # Start-Exodus Params
      [cmdletbinding()]
      Param(
        [Parameter(Position=0,
          Mandatory=$false,
          HelpMessage = "Enter a Wallet name (i.e. Exodus)",
          ValueFromPipeline=$True)]
          #[ValidateNotNullorEmpty("^[a-zA-Z0-1]{12}$")]
          [string]$Wallet = $null
      )
    #

    $logmsg = "Start-Wallet 0.1.0"
    Write-Log $logmsg $true
    Write-Host " "

    Get-MoolahEnvironment $Wallet
    if ($Wallet -match "Init") { exit }

    $pwPath = $env:Moolah_DL + ":\"
    if (!(Test-Path $pwPath)) { # Moolah container not mounted
      Start-PwManager
    } else {
      New-PSDrive -Name Moo -PSProvider FileSystem -Root $pwPath | Out-Null
      $myDB = Get-MoolahDB;
      $PwMgr = $myDB.SelectNodes("//Application") | Where-Object {$_.Name -eq "PwManager"}
      $bName = $PwMgr.Process;
      $Script:pwmObj = Get-Process | Where-Object {$_.ProcessName -match $bName}
      $Script:aPath    = $env:Moolah_DL + ":\"
    }

    # Select a Wallet if not specified
      if ([string]::IsNullOrEmpty($Wallet)) {
        $title = "Select a Wallet to open";
        $WalletSel = $Script:MoolahDB.SelectNodes("//Wallet") | Get-Wallets |
          Out-GridView -Title $title -OutputMode Single

        if ($WalletSel -ne $null) {
          $Wallet = $WalletSel.Wallet;
        } else {
          Write-Host "A Wallet must be selected or specified for the Wallet application." -ForegroundColor Red
          Read-Host "Enter any key to exit"
          exit
        }
      }
    #

    $vol = $env:Moolah_Online + "\" + $Wallet;   # Local Path
    $ovol = $env:Moolah_Offline + "\" + $Wallet; # Offline Path
    $dltr = $env:Moolah_WL                       # Wallet drive letter

    # Load Wallet and Application details
      $myWallet = $Script:MoolahDB.SelectNodes("//Wallet") | Where-Object {$_.Name -eq $Wallet}
      if (!($myWallet -is [object])) {
        $logmsg = "Wallet $myWallet record not found in the MoolahDB"
        Write-Log $logmsg $true "Red"
        Read-Host "Enter any key to exit"
        exit
      } else {
        $myAppName = $myWallet.Application
        $myWallet_Onl = $myWallet.KeepOnline
        $myWallet_Alt = $myWallet.Alert

        # Get Wallet application details
          $myApp = $Script:MoolahDB.SelectNodes("//Application") | Where-Object {$_.Name -eq $myAppName}
          if (!($myApp -is [object])) {
            $logmsg = "Application $myAppName record not found in the MoolahDB"
            Write-Log $logmsg $true "Red"
            Read-Host "Enter any key to exit"
            exit
          } else {
            $appBinary  = $myApp.Binary
            $appProcess  = $myApp.Process
            $appARG     = $myApp.ARG;
          }
        #
      }
    #
    
		# Verify Wallet application is not currently running
		$ps = Get-Process | Where-Object {$_.ProcessName -match $appProcess}
		if (!([string]::IsNullOrEmpty($ps))) {
			Write-Host "$appProcess is already running. Only run one instance at a time" -ForegroundColor Yellow
			Read-Host "Press any key to exit";
		} else {
			if (!(Test-Path $vol)) {
        $logmsg = "Wallet $vol not found"
        Write-Log $logmsg $true "Red"
				$rslt = Read-Host "What to restore from offline copy? (Y or N) or CTRL-C to exit"
				if ($rslt -match "Y") {
          $logmsg = "Restoring $vol from $ovol"
          Write-Log $logmsg $true "Magenta"
					Copy-Item -Path $ovol -Destination $vol;
				}
			}

			if (!(Test-Path $vol)) {
        $logmsg = "Wallet $vol not found"
        Write-Log $logmsg $true "Red"
			} else {
				if (Mount-VeVolume $vol $dltr) {

          $mPath = $dltr + ":\";
          
          Wait-ForMount $env:Moolah_WL
          New-PSDrive -Name Wal -PSProvider FileSystem -Root $mPath | Out-Null
          # Regular drive mount detection only working with PSDrive in
          # this code block for some reason.

          Start-Sleep -Seconds 2;

          if (Test-Path Wal:.svn) { # SVN Update
            UpDate-SVNServer $mPath "update"
          }

          $logmsg = "Starting $appBinary with Wallet"
          Write-Log $logmsg $true "Green"
          $logmsg = " $vol"
          Write-Log $logmsg $true
          Write-Host " "
					$URL = $appBinary
					$ARG = $appARG + " " + $mPath;
					Start-Process -FilePath $URL -ArgumentList $ARG
					Start-Sleep -Seconds 4

					$ps = "dummy"
          $logmsg = "Waiting for $appProcess to terminate"
          Write-Log $logmsg $true "Magenta"
					While (!([string]::IsNullOrEmpty($ps))) {
						Start-Sleep -Seconds 10;
						$ps = Get-Process | Where-Object {$_.ProcessName -match $appProcess}
					}

          if (Test-Path Wal:.svn) { # SVN commit
              UpDate-SVNServer $mPath "commit"
          }


          $logmsg = "Unmounting $mpath"
          Write-Log $logmsg $true "Green"
					Dismount-VeVolume $dltr;

					Start-Sleep -Seconds 7;

          $logmsg = "Updating offline copy of $Wallet to $ovol"
          Write-Log $logmsg $true "Green"
          Try {Copy-Item -Path $vol -Destination $ovol;}
          Catch {
             $logmsg = "Error copying $vol to $ovol"
             Write-Log $logmsg $true "Red"
          }
          Write-Host " "

          if ($myWallet_Onl -ne "1") {
            $logmsg = "Removing Online copy of $Wallet $vol"
            Write-Log $logmsg $true "Green"
            Remove-Item -Path $vol | Out-Null
          }

          # Shutting down PW Manager app
            $pwmName = ($Script:pwmObj).ProcessName;
            $logmsg = "Shutting down PW Manager $pwmName"
            Write-Log $logmsg $true "Magenta"
            Stop-Process -InputObject $Script:pwmObj;

            $psd = Get-PSDrive | Where-Object {$_.Name -match "Moo"};
            if (!($psd -is [object])) {
              New-PSDrive -Name Moo -PSProvider FileSystem -Root $Script:aPath | Out-Null
            }
            Start-Sleep -Seconds 1
            if (Test-Path Moo:.svn) { # SVN Commit process
              UpDate-SVNServer $Script:aPath "commit";
            }

            $logmsg = "Unmounting $Script:aPath"
            Write-Log $logmsg $true "Green"
            Dismount-VeVolume $env:Moolah_DL;

            $onLine   = $env:Moolah_Online + "\" + $env:Moolah_VC;    # Full local path of Moolah VeraCrypt container
            $ofLine   = $env:Moolah_Offline + "\" + $env:Moolah_VC;   # Full offline path of Moolah VeraCrypt container

            $logmsg = "Updating offline copy of $env:Moolah_VC container to $ofLine"
            Write-Log $logmsg $true "Green"
            Start-Sleep -Seconds 7
            Try { Copy-Item -Path $onLine -Destination $ofLine -force }
            Catch {
              $logmsg = "Error copying $onLine to $ofLine"
              Write-Log $logmsg $true "Red"
            }
          #

          Write-Host " "
          Write-Host "PowerShell console will close in 7 seconds." -ForegroundColor Green
          Start-Sleep -Seconds 120

				} else {
          $logmsg = "Error mounting $vol"
          Write-Log $logmsg $true "Red"
				}
			}
		}
  }

#