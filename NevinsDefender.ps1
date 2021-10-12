## RILEY'S WINDOWS DEFENDER POWERSHELL SCRIPT
## AUTHOR: RILEY J. NEVINS 
## CREATED ON: 9/20/2021
## MODIFIED ON: 9/21/2021
## INTENT: Provide users an interactive command line way to easily maintain/execute
##         Windows Defender commands. 

###################################################

$nevins_defender_root_dir = 'C:\NevinsDefender'
$nevins_defender_service_dir = 'C:\NevinsDefender\Services'
$nevins_realtime_output_file = 'C:\NevinsDefender\Services\realtime_output.txt'
$nevins_primary_error_file = 'C:\NevinsDefender\error.txt' ## Would be used if I got custom error handling working (I don't want this over 400 lines)

## Create required filesystem.
if (Test-Path -Path $nevins_defender_root_dir) { ## Path exists!
    if (Test-Path -Path $nevins_defender_service_dir) { 
    }

    else {
        New-Item -Path $nevins_defender_service_dir -ItemType Directory | Out-Null ## Mute output (silent).
    }

    menu ## Move on to main function only if required file system exists.

}

else { ## Create root path in C:\. 
    New-Item -Path $nevins_defender_root_dir -ItemType Directory | Out-Null ## Mute output (silent).

    if (Test-Path -Path $nevins_defender_service_dir) { ## Path exists!
        menu ## Move on to main function.
    }

    else { ## Create it.
        New-Item -Path $nevins_defender_service_dir -ItemType Directory | Out-Null ## Mute output (silent).
    }
}

## Ensure clean math file on start.
if (Test-Path -Path $nevins_realtime_output_file -PathType Leaf) { ## EXISTS!
    Remove-Item $nevins_realtime_output_file ## REMOVE MATH FILE ON START! WILL CREATE IN LATER FUNCTION!
}

function menu {
    Clear-Host
    Write-Host "#############################################################" -ForegroundColor DarkGreen -BackgroundColor DarkGreen
    Write-Host "" 
    Write-Host "    ______ ___________ _____ _   _______ ___________         " -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host "    |  _  \  ___|  ___|  ___| \ | |  _  \  ___| ___ \        " -ForegroundColor White -BackgroundColor DarkGreen  
    Write-Host "    | | | | |__ | |_  | |__ |  \| | | | | |__ | |_/ /        " -ForegroundColor White -BackgroundColor DarkGreen    
    Write-Host "    | | | |  __||  _| |  __|| . `  | | | |  __||    /         " -ForegroundColor White -BackgroundColor DarkGreen   
    Write-Host "    | |/ /| |___| |   | |___| |\  | |/ /| |___| |\ \         " -ForegroundColor White -BackgroundColor DarkGreen 
    Write-Host "    |___/ \____/\_|   \____/\_| \_/___/ \____/\_| \_| v1.0.0 " -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host ""
    Write-Host "# WINDOWS DEFENDER MGT SCRIPT:" -ForegroundColor White -BackgroundColor DarkGreen
    Write-Host ""
    Write-Host "#`n#" -ForegroundColor Yellow
    Write-Host "# [i] An interactive commandline interface to manage Windows Defender.`n#`n#     From the options below, select the apropriate task.`n#`n#     Designed by Riley Nevins 9/20/2021" -ForegroundColor Yellow
    Write-Host "#`n#" -ForegroundColor Yellow                                  
    Write-Host ""
    Write-Host "#############################################################" -ForegroundColor DarkGreen -BackgroundColor DarkGreen
    Write-Host ""
    Write-Host "# [i] Windows Defender Options:" -ForegroundColor Green
    Write-Host "#    1 - Update Definitions" -ForegroundColor Gray
    Write-Host "#    2 - Perform Scan Now" -ForegroundColor Gray
    Write-Host "#    3 - Remove Threats Now" -ForegroundColor Gray
    Write-Host "#    4 - [BONUS] Realtime Protect Status" -ForegroundColor Green
    Write-Host "#    5 - [BONUS] View Defender Settings" -ForegroundColor Green
    Write-Host "#    6 - [BONUS] Export Identified Threat Log" -ForegroundColor Green
    Write-Host "#    7 - [BONUS] Export Antivirus Settings Log" -ForegroundColor Green
    Write-Host "#    8 - Exit" -ForegroundColor Cyan
    Write-Host ""
    $menuselection = Read-Host "Enter a menu selection --------> "
    
    # Menu selection.
    Switch ($menuselection)
    {
        1 { UPDATE_DEF }
        2 { SCAN_NOW }
        3 { REMOVE_THREATS }
        4 { LIVE_PROTECT }
        5 { DEFENDER_SETTINGS }
        6 { EXPORT_LOG }
        7 { EXPORT_SETTING }
        8 { EXIT_APP }
    }

    menu

    }
    function UPDATE_DEF { ## Updates Threat Signatures.
        Clear-Host
        Write-Host "# [i] Updating Windows Defender Threat Signatures!" -ForegroundColor White -BackgroundColor DarkGreen
        Update-MpSignature 
        Pause
        menu
    }

    function SCAN_NOW { ## Runs Windows Defender Scan.
        Clear-Host
        Write-Host "# [i] Running Windows Defender Scan..." -ForegroundColor White -BackgroundColor DarkGreen
        Start-MpScan 
        Pause
        menu
    }

    function REMOVE_THREATS { ## Removes Identified Threat(s).
        Clear-Host
        Write-Host "# [i] Removing Identified Threats..." -ForegroundColor White -BackgroundColor DarkGreen
        Remove-MpThreat 
        Pause
        menu
    }

    function LIVE_PROTECT {
        Clear-Host
        #New-Item $nevins_backend_root_dir\realtime_output.txt | Out-Null # Create needed math file mute output.
        Get-MpComputerStatus | Select-Object RealTimeProtectionEnabled | Out-File -FilePath "C:\NevinsDefender\Services\realtime_output.txt"
        $is_inactive = Select-String -Path $nevins_realtime_output_file -Pattern "False" -SimpleMatch -Quiet ## Returns boolean.
        if ($is_inactive -like "true") {
            Write-Host ""
            Write-Host "     ______      _____ _        " -ForegroundColor White -BackgroundColor Red
            Write-Host "    |  ____/\   |_   _| |       " -ForegroundColor White -BackgroundColor Red
            Write-Host "    | |__ /  \    | | | |       " -ForegroundColor White -BackgroundColor Red
            Write-Host "    |  __/ /\ \   | | | |       " -ForegroundColor White -BackgroundColor Red
            Write-Host "    | | / ____ \ _| |_| |____   " -ForegroundColor White -BackgroundColor Red
            Write-Host "    |_|/_/    \_\_____|______|  " -ForegroundColor White -BackgroundColor Red
            Write-Host ""
            Write-Host "# [i] REALTIME DEFENCE STATUS: Disabled" -ForegroundColor Red -BackgroundColor White
            Write-Host "#     Would you like to enable realtime protection now? [YES/NO]" -ForegroundColor Red -BackgroundColor White
            Write-Host ""
            $enable_reply = Read-Host "#     Enter a menu selection -------->"

            if ($enable_reply -like "no") {
                Clear-Host
                if (Test-Path -Path $nevins_realtime_output_file -PathType Leaf) { ## EXISTS!
                    Remove-Item $nevins_realtime_output_file ## REMOVE MATH FILE ON START! WILL CREATE IN LATER FUNCTION!
                }
                menu
            }

            if ($enable_reply -like "yes") { 
                Clear-Host
                Write-Host "# [i] Enabling Realtime Protection..." -ForegroundColor White -BackgroundColor DarkGreen
                Set-MpPreference -DisableRealtimeMonitoring 0 ## Should in theory set this option to true (enabling realtime protection).
                Pause
                menu
            }

            else {
        
                if (Test-Path -Path $nevins_realtime_output_file -PathType Leaf) { ## EXISTS!
                    Remove-Item $nevins_realtime_output_file ## REMOVE MATH FILE ON START! WILL CREATE IN LATER FUNCTION!
                }

                LIVE_PROTECT
            }

        }

        if ($is_inactive -like "false") {
            Write-Host ""
            Write-Host "    _____  ____   ____  _____      " -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "    / ____|/ __ \ / __ \|  __ \    " -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "   | |  __| |  | | |  | | |  | |   " -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "   | | |_ | |  | | |  | | |  | |   " -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "   | |__| | |__| | |__| | |__| |   " -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "    \_____|\____/ \____/|_____/    "-ForegroundColor White -BackgroundColor DarkGreen
            Write-Host ""
            Write-Host "# [i] REALTIME DEFENCE STATUS: Enabled" -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host "#     Your device is being protected in real time!" -ForegroundColor White -BackgroundColor DarkGreen
            Write-Host ""
            Pause ## Wait for user-input.
            menu
        }

        else {
            LIVE_PROTECT ## Go back to this function's start.
            ## This will only happen if there were issues creading information from the realtime_output.txt file.
            pause
        }

        Pause
        menu

    }

    function DEFENDER_SETTINGS {
        ## Fetch and store needed data from Defender Settings Log function.

         ## Could be redone by creating an array containing all Defender Settings Variables, and storing them one at time in a for each loop. 

        ## RealTimeProtectionEnabled
        Get-MpComputerStatus | Select-Object RealTimeProtectionEnabled | Out-File -FilePath "C:\NevinsDefender\Services\settings_RealTimeProtectionEnabled.txt"
        $is_RealTimeProtectionEnabled = Select-String -Path "C:\NevinsDefender\Services\settings_RealTimeProtectionEnabled.txt" -Pattern "True" -SimpleMatch -Quiet ## Returns boolean.

        ## AntivirusEnabled
        Get-MpComputerStatus | Select-Object RealTimeProtectionEnabled | Out-File -FilePath "C:\NevinsDefender\Services\settings_AntivirusEnabled.txt"
        $is_AntivirusEnabled = Select-String -Path "C:\NevinsDefender\Services\settings_AntivirusEnabled.txt" -Pattern "True" -SimpleMatch -Quiet ## Returns boolean.

        ## AntispywareEnabled
        Get-MpComputerStatus | Select-Object AntispywareEnabled | Out-File -FilePath "C:\NevinsDefender\Services\settings_AntispywareEnabled.txt"
        $is_AntispywareEnabled = Select-String -Path "C:\NevinsDefender\Services\settings_AntispywareEnabled.txt" -Pattern "True" -SimpleMatch -Quiet ## Returns boolean.

        ## AMServiceEnabled
        Get-MpComputerStatus | Select-Object AMServiceEnabled | Out-File -FilePath "C:\NevinsDefender\Services\settings_AMServiceEnabled.txt"
        $is_AMServiceEnabled = Select-String -Path "C:\NevinsDefender\Services\settings_AMServiceEnabled.txt" -Pattern "True" -SimpleMatch -Quiet ## Returns boolean.
        
        ## BehaviorMonitorEnabled
        Get-MpComputerStatus | Select-Object BehaviorMonitorEnabled | Out-File -FilePath "C:\NevinsDefender\Services\settings_BehaviorMonitorEnabled.txt"
        $is_BehaviorMonitorEnabled = Select-String -Path "C:\NevinsDefender\Services\settings_BehaviorMonitorEnabled.txt" -Pattern "True" -SimpleMatch -Quiet ## Returns boolean.

        $coverage_score = 0
        Clear-Host

        Write-Host ""
        Write-Host "    _____ ____  _   _ ______ _____ _____    " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "   / ____/ __ \| \ | |  ____|_   _/ ____|   " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "  | |   | |  | |  \| | |__    | || |  __    " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "  | |   | |  | | . ` |  __|   | || | |_ |    " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "  | |___| |__| | |\  | |     _| || |__| |   " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "   \_____\____/|_| \_|_|    |_____\_____|   " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host ""

        ## Determine and return output based on boolean (just for coloring).
        ## Could be redone by creating an array containing all Defender Settings Variables, and displaying them one at a time in a for each loop. 

        if ($is_RealTimeProtectionEnabled -like "true") {
            Write-Host "# Realtime Protection: " -ForegroundColor white -nonewline; Write-Host $is_RealTimeProtectionEnabled.ToString() -ForegroundColor Green
        }

        else {

            ## On all "else" operators here, we increase the value of coverage_score. 

            Write-Host "# Realtime Protection: " -ForegroundColor white -nonewline; Write-Host $is_RealTimeProtectionEnabled.ToString() -ForegroundColor Red
            $coverage_score++ 
        }

        if ($is_AntivirusEnabled -like "True") {
            Write-Host "# Antivirus Protection: " -ForegroundColor white -nonewline; Write-Host $is_AntivirusEnabled.ToString() -ForegroundColor Green
        }

        else {
            Write-Host "# Antivirus Protection: " -ForegroundColor white -nonewline; Write-Host $is_AntivirusEnabled.ToString() -ForegroundColor Red
            $coverage_score++ 
        }

        if ($is_AntispywareEnabled -like "True") {
            Write-Host "# Antispyware Protection: " -ForegroundColor white -nonewline; Write-Host $is_AntispywareEnabled.ToString() -ForegroundColor Green
        }

        else {
            Write-Host "# Antispyware Protection: " -ForegroundColor white -nonewline; Write-Host $is_AntispywareEnabled.ToString() -ForegroundColor Red
            $coverage_score++ 
        }

        if ($is_AMServiceEnabled -like "True") {
            Write-Host "# Defender Running: " -ForegroundColor white -nonewline; Write-Host $is_AMServiceEnabled.ToString() -ForegroundColor Green
        }

        else {
            Write-Host "# Defender Running: " -ForegroundColor white -nonewline; Write-Host $is_AMServiceEnabled.ToString() -ForegroundColor Red
            $coverage_score++ 
        }

        if ($is_BehaviorMonitorEnabled -like "True") {
            Write-Host "# Behavior Monitoring: " -ForegroundColor white -nonewline; Write-Host $is_BehaviorMonitorEnabled.ToString() -ForegroundColor Green
        }

        else {
            Write-Host "# Behavior Monitoring: " -ForegroundColor white -nonewline; Write-Host $is_BehaviorMonitorEnabled.ToString() -ForegroundColor Red
            $coverage_score++ 
        }

        ## coverage_score math. 

        if ($coverage_score -ge 2 -AND !$coverage_score -ge 4) {
            Write-Host ""
            Write-Host "# WARNING! " -ForegroundColor Red -nonewline; Write-Host " Two or more of your protection services are NOT running!" -ForegroundColor White   
            Write-Host "Your device is not evenly covered protection wise. It is recommended you enable the red services above."
            Write-Host ""
            Write-Host "Coverage Score: " $coverage_score
        }

        if ($coverage_score -ge 4) {
            Write-Host ""
            Write-Host "# WARNING! " -ForegroundColor DarkRed -nonewline; Write-Host " FOUR or more of your protection services are NOT running!" -ForegroundColor Red   
            Write-Host "Your device is at serious risk. It is highly recommended you enable the red services above."
            Write-Host ""
            Write-Host "Coverage Score: " $coverage_score
        }

        Write-Host ""

        ## Cleanup any created files from this module (all were created with a "settings_" prefix).
        Remove-Item -Path C:\NevinsDefender\Services\* -Include settings_*.txt -Force
        $coverage_score = 0
        Pause
        menu

    }

    function EXPORT_LOG {
        Clear-Host
        $defender_log_dir = 'C:\NevinsDefender\ThreatLogs'
        $log_syntax = "export-" + (Get-Date -Format "yyy-mm-dd-ss")
        $current_date = Get-Date -Format "yyy-mm-dd-ss"

        ## Check for log_path.

        if (Test-Path -Path $defender_log_dir) { ## EXISTS!
            ## Format the new log file, prepare it for command output append.
            New-Item $defender_log_dir\$log_syntax.txt | Out-Null ## Create log file. 
            Add-Content $defender_log_dir\$log_syntax.txt "#"
            Add-Content $defender_log_dir\$log_syntax.txt "# DEFENDER LOG OUTPUT"
            Add-Content $defender_log_dir\$log_syntax.txt "# CREATED ON: $current_date"
            Add-Content $defender_log_dir\$log_syntax.txt "# [i]   File empty? Check Settings Log file to see if Defender is enabled."
            Add-Content $defender_log_dir\$log_syntax.txt "#       Or, there is a possibility you have had ZERO infections."
            Add-Content $defender_log_dir\$log_syntax.txt "#"
            Add-Content $defender_log_dir\$log_syntax.txt ""
            Get-MpThreatDetection | Out-File -FilePath $defender_log_dir\$log_syntax.txt -Append ## Execute now that file structure agrees, append results to new file.
        }

        else { ## Create path.
            Write-Host "# [i] Creating directory `"$defender_log_dir`" for it does NOT exist!" -ForegroundColor Yellow
            New-Item -Path 'C:\NevinsDefender\ThreatLogs' -ItemType Directory | Out-Null ## Out-Null prevents this command from printing results. (Ugly).
            New-Item $defender_log_dir\$log_syntax.txt | Out-Null ## Create log file.
            Add-Content $defender_log_dir\$log_syntax.txt "#"
            Add-Content $defender_log_dir\$log_syntax.txt "# DEFENDER LOG OUTPUT"
            Add-Content $defender_log_dir\$log_syntax.txt "# CREATED ON: $current_date"
            Add-Content $defender_log_dir\$log_syntax.txt "# [i]   File empty? Check Settings Log file to see if Defender is enabled."
            Add-Content $defender_log_dir\$log_syntax.txt "#       Or, there is a possibility you have had ZERO infections."
            Add-Content $defender_log_dir\$log_syntax.txt "#"
            Add-Content $defender_log_dir\$log_syntax.txt ""
            Get-MpThreatDetection | Out-File -FilePath $defender_log_dir\$log_syntax.txt -Append ## Execute now that file structure agrees.
        }

        Write-Host ""
        Write-Host "        _____    __      ________ _____         " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "        / ____|  /\ \    / /  ____|  __ \       " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "       | (___   /  \ \  / /| |__  | |  | |      " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "        \___ \ / /\ \ \/ / |  __| | |  | |      " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "        ____) / ____ \  /  | |____| |__| |      " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "       |_____/_/    \_\/   |______|_____/       " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host ""
        Write-Host "# [i] Threat identification/detection logs have been exported as: $defender_log_dir/$log_syntax.txt" -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "#     It's recommended you review this document from time to time, ensure all is well!" -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host ""
        Pause
        menu
    }

    function EXPORT_SETTING { ## Exports Windows Defender Setting Output.
        Clear-Host
        $setting_log_dir = 'C:\NevinsDefender\SettingsLogs'
        $log_syntax = "export-" + (Get-Date -Format "yyy-mm-dd-ss")
        
        ## Check for log_path.

        if (Test-Path -Path $setting_log_dir) { ## Path exists!
            ## Format the new log file, prepare it for command output append.
            New-Item $setting_log_dir\$log_syntax.txt | Out-Null # Create log file.
            Add-Content $setting_log_dir\$log_syntax.txt "#"
            Add-Content $setting_log_dir\$log_syntax.txt "# DEFENDER SETTINGS OUTPUT"
            Add-Content $setting_log_dir\$log_syntax.txt "# CREATED ON: $current_date"
            Add-Content $setting_log_dir\$log_syntax.txt "#"
            Get-MpComputerStatus | Out-File -FilePath $setting_log_dir\$log_syntax.txt -Append # Execute now that file structure agrees, append results to new file.
        }

        else { ## Create path
            Write-Host "# [i] Creating directory `"$setting_log_dir`" for it does NOT exist!" -ForegroundColor Yellow
            New-Item -Path 'C:\NevinsDefender\SettingsLogs' -ItemType Directory | Out-Null # Out-Null prevents this command from printing results. (Ugly).
            New-Item $setting_log_dir\$log_syntax.txt | Out-Null # Create log file.
            Add-Content $setting_log_dir\$log_syntax.txt "#"
            Add-Content $setting_log_dir\$log_syntax.txt "# DEFENDER SETTINGS OUTPUT"
            Add-Content $setting_log_dir\$log_syntax.txt "# CREATED ON: $current_date"
            Add-Content $setting_log_dir\$log_syntax.txt "#"
            Get-MpComputerStatus | Out-File -FilePath $setting_log_dir\$log_syntax.txt -Append # Execute now that file structure agrees.
        }

        Write-Host ""
        Write-Host "        _____    __      ________ _____         " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "        / ____|  /\ \    / /  ____|  __ \       " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "       | (___   /  \ \  / /| |__  | |  | |      " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "        \___ \ / /\ \ \/ / |  __| | |  | |      " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "        ____) / ____ \  /  | |____| |__| |      " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "       |_____/_/    \_\/   |______|_____/       " -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host ""
        Write-Host "# [i] Windows Defender Settings logs have been exported at: $setting_log_dir/$log_syntax.txt" -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host "#     It's recommended you review this document from time to time, ensure all is well!" -ForegroundColor White -BackgroundColor DarkGreen
        Write-Host ""
        Pause
        menu
    }

    function EXIT_APP {
        Clear-Host
        exit ## Quit The Application!
    }

    #function CLEAN { 
    #    Remove-Item -Path C:\NevinsDefender\Services\* -Include settings_*.txt -Force ## Cleans settings function filesystem.
    #
    #    if (Test-Path -Path $nevins_realtime_output_file -PathType Leaf) { ## REALTIME FILE EXISTS!
    #        Remove-Item $nevins_realtime_output_file ## REMOVE MATH FILE ON START! WILL CREATE IN LATER FUNCTION!
    #    }

    menu
