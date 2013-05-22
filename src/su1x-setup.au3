#RequireAdmin
#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=SETUP07.ICO
#AutoIt3Wrapper_outfile=..\bin\su1x-setup.exe
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=Swansea Eduroam Tool
#AutoIt3Wrapper_Res_Description=Swansea Eduroam Tool
#AutoIt3Wrapper_Res_Fileversion=2.0.0.32
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_ProductVersion=1.8.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Gareth Ayres - Swansea University
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****

;-------------------------------------------------------------------------
; AutoIt script to automate the creation of Wireless / Wired Configuration for Eduroam
;
; Written by Gareth Ayres of Swansea University (g.j.ayres@swansea.ac.uk)
; Inspired by a script written by Jeff deVeer (http://www.autoitscript.com/forum/index.php?showtopic=56479&hl=_EnumWireless)
; Code contribution for wired 802.1x from Paul Coates [Paul.Coates@ncl.ac.uk]
; Code contribution for bug fixes from Arnaud Loonstra [arnaud@z25.org]
;
;   Copyright 2009 Swansea University Licensed under the
;	Educational Community License, Version 2.0 (the "License"); you may
;	not use this file except in compliance with the License. You may
;	obtain a copy of the License at
;
;	http://www.osedu.org/licenses/ECL-2.0
;
;	Unless required by applicable law or agreed to in writing,
;	software distributed under the License is distributed on an "AS IS"
;	BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
;	or implied. See the License for the specific language governing
;	permissions and limitations under the License.
;
;
;
; Gareth Ayres (g.j.ayres@swan.ac.uk)
; To save time, makes use of wirelss API interface by MattyD (http://www.autoitscript.com/forum/index.php?showtopic=91018&st=0)
;


#include "Native_Wifi_Func_V4.au3"
#include <GUIConstants.au3>
#include <GuiListView.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <String.au3>


;-------------------------------------------------------------------------
; Global variables and stuff

;Main config file
$CONFIGFILE = "config.ini"

;Check for config File
FileChangeDir(@ScriptDir)
If (FileExists($CONFIGFILE) == 0) Then
	MsgBox(16, "Error", "Config file not found.")
	Exit
EndIf

$WZCSVCStarted = 0
$SECURE_MACHINE = IniRead($CONFIGFILE, "su1x", "SECURE_MACHINE", "0")
$DEBUG = IniRead($CONFIGFILE, "su1x", "DEBUG", "0")
$wireless = IniRead($CONFIGFILE, "su1x", "wireless", "1")
$wired = IniRead($CONFIGFILE, "su1x", "wired", "0")
$USESPLASH = IniRead($CONFIGFILE, "su1x", "USESPLASH", "0")
$wired_xmlfile = IniRead($CONFIGFILE, "su1x", "wiredXMLfile", "Wired_Profile.xml")
$progress_meter = 0
$startText = IniRead($CONFIGFILE, "su1x", "startText", "SWIS")
$title = IniRead($CONFIGFILE, "su1x", "title", "SWIS Eduroam - Setup Tool")
$hint = IniRead($CONFIGFILE, "su1x", "hint", "0")
$exitoncomplete = IniRead($CONFIGFILE, "su1x", "exit_on_complete", "0")
$username = IniRead($CONFIGFILE, "su1x", "username", "123456@swansea.ac.uk")
$proxy = IniRead($CONFIGFILE, "su1x", "proxy", "1")
$browser_reset = IniRead($CONFIGFILE, "su1x", "browser_reset", "0")
;$SSID = IniRead($CONFIGFILE, "getprofile", "ssid", "eduroam")
$nap = IniRead($CONFIGFILE, "su1x", "nap", "0")
$showup = IniRead($CONFIGFILE, "su1x", "showup", "0")
$showuptick = IniRead($CONFIGFILE, "su1x", "showtick", "0")
$scheduletask = IniRead($CONFIGFILE, "su1x", "scheduletask", "0")


;----Printing
$show_printing = IniRead($CONFIGFILE, "print", "printing", "0")
$printer = IniRead($CONFIGFILE, "print", "printer", "Swansea Uni Wireless")
$printer_xp = IniRead($CONFIGFILE, "print", "printer_xp", "0")
$printer_vista = IniRead($CONFIGFILE, "print", "printer_vista", "0")
$printer_7 = IniRead($CONFIGFILE, "print", "printer_7", "0")
$printer_port = IniRead($CONFIGFILE, "print", "printer_port", "0")
$printer_message_title = IniRead($CONFIGFILE, "print", "printer_message_title", "0")
$printer_message = IniRead($CONFIGFILE, "print", "printer_message", "0")

;---Image Files
$BANNER = IniRead($CONFIGFILE, "images", "BANNER", "lis-header.jpg")
$SPLASHFILE = IniRead($CONFIGFILE, "images", "SLPASHFILE", "big.jpg")
$bubblexp = IniRead($CONFIGFILE, "images", "bubblexp", "bubble1.jpg")
$bubblevista = IniRead($CONFIGFILE, "images", "bubblevista", "bubble-vista.jpg")
$bubble_xp_connected = IniRead($CONFIGFILE, "images", "bubble_xp_connected", "bubble-connected-xp.jpg")
$win7_connected = IniRead($CONFIGFILE, "images", "win7_connected", "connected-7.jpg")
$vista_connected = IniRead($CONFIGFILE, "images", "vista_connected", "connected-vista.jpg")

;-----SSID
$SSID = IniRead($CONFIGFILE, "getprofile", "ssid", "eduroam")
$SSID_Fallback = IniRead($CONFIGFILE, "getprofile", "ssid_fallback", "")

;-----SSID to remove
$removessid = IniRead($CONFIGFILE, "remove", "removessid", "0")
$SSID1 = IniRead($CONFIGFILE, "remove", "ssid1", "eduroam")
$SSID2 = IniRead($CONFIGFILE, "remove", "ssid2", "eduroam-setup")
$SSID3 = IniRead($CONFIGFILE, "remove", "ssid3", "unrioam")

;------Certificates
$certificate = IniRead($CONFIGFILE, "certs", "cert", "mycert.cer")
$use_cert = IniRead($CONFIGFILE, "certs", "usecert", "0")

;------Support
$show_support = IniRead($CONFIGFILE, "support", "show_support", "0")
$send_ldap = IniRead($CONFIGFILE, "support", "send_ldap", "0")
$send_problem = IniRead($CONFIGFILE, "support", "send_problem", "0")
$ldap_url = IniRead($CONFIGFILE, "support", "ldap_url", "0")
$regtest_url = IniRead($CONFIGFILE, "support", "regtest_url", "0")
$sendsupport_url = IniRead($CONFIGFILE, "support", "sendsupport_url", "0")
$sendsupport_dept = IniRead($CONFIGFILE, "support", "sendsupport_dept", "0")
$report_problem_url = IniRead($CONFIGFILE, "support", "report_problem_url", "")
$radioMap = IniRead($CONFIGFILE, "support", "radioMap", "0")
$radioMap_url = IniRead($CONFIGFILE, "support", "radioMap_url", "")


;------------------------------------------------------------------------------------------------------------
;---------Variable Initialisation
;------------------------------------------------------------------------------------------------------------
Dim $user
Dim $pass
Dim $os
Dim $compname
Dim $arch
Dim $ip1
Dim $ip2
Dim $date
Dim $osuser
Dim $WZCSVCStarted
Dim $wifi_card
Dim $wifi_adapter
Dim $wifi_state
Dim $wifi_eduroam_all
Dim $wifi_int_all
Dim $response
Dim $DriverVersion
Dim $DriverDate
Dim $HardwareVersion
Dim $output
Dim $progressbar1
Dim $myedit
Dim $output
Dim $loopcheck = 0
Dim $loopcheck2 = 0
Dim $debugResult
Dim $showall
Dim $file
Dim $filename
Dim $num_arguments = 0
Dim $tryconnect = "no"
Dim $probdesc = ""
Dim $userbutton
Dim $passbutton
Dim $remove_wifi_arg = 0
Dim $winreconnect = 0
Global $hClientHandle = 0
Global $pGUID = 0
Global $Enum
Dim $user_enter = 0



;------------------------------------------------------------------------------------------------
;Set up Debugging
;------------------------------------------------------------------------------------------------
If ($DEBUG > 0) Then
	$filename = "su1x-dump-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & ".txt"
	$file = FileOpen($filename, 1)
	; Check if file opened for reading OK
	If ($file == -1) Then
		MsgBox(16, "DEBUG", "Unable to open debug dump file.:" & $file)
	EndIf
Else
	FileClose($file)
EndIf
;------------------------------------------------------------------------------------------------

;---------------------
;Arguements used for scheduled task loading of su1x
$num_arguments = $CmdLine[0] ;is number of parameters
If ($num_arguments > 0) Then
	$argument1 = $CmdLine[1] ;is param 1
	DoDebug("Got argument=" & $argument1)
Else
	$argument1 = 0;
EndIf



;------------------------------------------------------------------------------------------------------------
;---------Functions
;------------------------------------------------------------------------------------------------------------
Func DoDebug($text)
	If $DEBUG == 1 Then
		BlockInput(0)
		SplashOff()
		$debugResult = $debugResult & @CRLF & $text
	EndIf
	If $DEBUG == 2 Then
		BlockInput(0)
		SplashOff()
		MsgBox(16, "DEBUG", $text)
		$debugResult = $debugResult & @CRLF & $text
	EndIf
	;Write to file
	$file = FileOpen($filename, 1)
	If (Not ($file = -1)) Then
		FileWriteLine($file, $text)
		FileClose($file)
	EndIf
EndFunc   ;==>DoDebug

;Write text to debug file
Func DoDump($text)
	BlockInput(0)
	SplashOff()
	;Write to file
	$file = FileOpen($filename, 1)
	If (Not ($file = -1)) Then
		FileWriteLine($file, $text)
		FileClose($file)
	EndIf
EndFunc   ;==>DoDump

;Function to configure a wireless adapter
Func ConfigWired1x()
	;Check if the DOT1XSVC (Wired LAN Auto Config) Service is running.  If not start it.
	CheckService("DOT3SVC")

	;check XML profile files are ok
	UpdateOutput("Configuring Wired Profile...")
	UpdateProgress(10);
	If (FileExists($wired_xmlfile) == 0) Then
		MsgBox(16, "Error", "Wired Config file missing. Exiting...")
		Exit
	EndIf

	;Get the mac address and network name
	$ip = "localhost"
	Dim $adapter = "";
	$query = "SELECT * FROM Win32_NetworkAdapter WHERE " & _
			"AdapterTypeID = 0 " & _
			"AND " & _
			"Manufacturer != 'Microsoft' " & _
			"AND " & _
			"NOT PNPDeviceID LIKE 'ROOT\\%'" & _
			"AND " & _
			"MACAddress IS NOT NULL"
	$objWMIService = ObjGet("winmgmts:{impersonationLevel = impersonate}!\\localhost\root\cimv2")
	$colItems = $objWMIService.ExecQuery($query, "WQL", 0x30)
	Dim $networkcount = 0
	UpdateProgress(20);
	If IsObj($colItems) Then
		For $objItem In $colItems
			If ($objItem.AdapterType == "Ethernet 802.3") Then
				If (StringInStr($objItem.netconnectionid, "Blue") == 0 And StringInStr($objItem.netconnectionid, "1394") == 0 And StringInStr($objItem.netconnectionid, "Wireless") == 0) Then
					$adapter &= "*********************"
					$adapter &= "Caption: " & $objItem.Caption & @CRLF
					$adapter &= "Description: " & $objItem.Description & @CRLF
					$adapter &= "Index: " & $objItem.Index & @CRLF
					$adapter &= "NetID: " & $objItem.netconnectionid & @CRLF
					$wired_interface = $objItem.netconnectionid
					$adapter &= "Name: " & $objItem.name & @CRLF
					$adapter &= "Type: " & $objItem.AdapterType & @CRLF
					;Ethernet 802.3
					$adapter &= "MAC Address: " & $objItem.MACAddress & @CRLF
					DoDebug("[setup] Applying profile to :" & $adapter)
					Dim $adapter = ""
					$networkcount += 1
					UpdateOutput("Configuring " & $objItem.netconnectionid)
					$cmd = "netsh lan add profile filename=""" & $wired_xmlfile & """ interface=""" & $wired_interface & """"
					DoDebug("[setup]802.3 command=" & $cmd)
					RunWait($cmd, "", @SW_HIDE)
					UpdateProgress(20);
					SetEAPCred("", 2, $wired_interface)
				Else
					DoDebug("[setup] " & $objItem.netconnectionid & "( " & $objItem.AdapterType & "," & $objItem.Description & ") does no match as LAN")
				EndIf
			Else
				DoDebug("[setup] No 802.3 adapter found (" & $objItem.Caption & "," & $objItem.Description & ") ")
			EndIf
		Next
	Else
		DoDebug("[setup]No 802.3 Adapter found!")
	EndIf
	UpdateOutput("Wired 8021x profile added")
	UpdateProgress(10);
EndFunc   ;==>ConfigWired1x

Func SetCert()
	;Certificate install
	DoDebug("[setup]Cert Install = " & $certificate)
	$result = Run(@ScriptDir & "\CertMgr.Exe /all /add " & $certificate & " /s /r localMachine root", "", @SW_HIDE)
	;$result = Run(@ScriptDir & "\CertMgr.Exe /add " & $certificate & " /s /r localMachine root", "", @SW_HIDE)
	DoDebug("[setup]result of cert=" & $result)
	UpdateOutput("Installed certificate")
EndFunc   ;==>SetCert

Func GetMac($adapterType)
	$ip = "localhost"
	$mac = ""
	$query = "SELECT * FROM Win32_NetworkAdapter WHERE " & _
			"AdapterTypeID = 0 " & _
			"AND " & _
			"Manufacturer != 'Microsoft' " & _
			"AND " & _
			"NOT PNPDeviceID LIKE 'ROOT\\%'" & _
			"AND " & _
			"MACAddress IS NOT NULL"
	$objWMIService = ObjGet("winmgmts:{impersonationLevel = impersonate}!\\" & $ip & "\root\cimv2")
	$colItems = $objWMIService.ExecQuery($query, "WQL", 0x30)
	If IsObj($colItems) Then
		For $objItem In $colItems
			If ($objItem.AdapterType == "Ethernet 802.3") Then
				If (StringCompare($adapterType, "wireless") == 0) Then
					If (StringInStr($objItem.description, "Wi") Or StringInStr($objItem.description, "Wireless") Or StringInStr($objItem.description, "802.11")) Then
						DoDebug("[support]802.11 Adapter mac address found" & $objItem.MACAddress)
						$mac &= $objItem.MACAddress
					EndIf
				EndIf
				;WIRED
				If (StringCompare($adapterType, "wired") == 0) Then
					If (StringInStr($objItem.netconnectionid, "Local") And StringInStr($objItem.description, "Blue") == 0 And StringInStr($objItem.description, "1394") == 0 And StringInStr($objItem.description, "Wireless") == 0) Then
						DoDebug("[support]802.3 Adapter mac address found" & $objItem.MACAddress)
						$mac &= $objItem.MACAddress
					EndIf
				EndIf
			EndIf
			;ExitLoop
		Next
	Else
		DoDebug("[support]No 802.3 Adapter found for mac address!")
	EndIf
	;Return the user readble MAC address
	Return $mac
EndFunc   ;==>GetMac

;Remove any ssids as specified by config file
Func RemoveSSIDs($hClientHandle, $pGUID)
	;Check for profiles to remove
	If ($removessid > 0) Then
		DoDebug("[setup]Removing SSID")
		$profiles = _Wlan_GetProfileList($hClientHandle, $pGUID)
		If (UBound($profiles) == 0) Then
			DoDebug("[setup]No wireless profiles to remove found")
		Else
			For $ssidremove In $profiles
				If (StringCompare($ssidremove, $SSID1, 0) == 0) Then
					RemoveSSID($hClientHandle, $pGUID, $ssidremove)
					UpdateOutput("Removed SSID:" & $ssidremove)
				EndIf
				If (StringCompare($ssidremove, $SSID2, 0) == 0) Then
					RemoveSSID($hClientHandle, $pGUID, $ssidremove)
					UpdateOutput("Removed SSID:" & $ssidremove)
				EndIf
				If (StringCompare($ssidremove, $SSID3, 0) == 0) Then
					RemoveSSID($hClientHandle, $pGUID, $ssidremove)
					UpdateOutput("Removed SSID:" & $ssidremove)
				EndIf
			Next
		EndIf
	EndIf
EndFunc   ;==>RemoveSSIDs

;Function to check a service is running
Func CheckService($ServiceName)
	If IsServiceRunning($ServiceName) == 0 Then
		DoDebug("[CheckService]" & $ServiceName & " not running")
		Run("sc config " & $ServiceName & " start= auto", "", @SW_HIDE)
		RunWait("net start " & $ServiceName, "", @SW_HIDE)
		_Wlan_SetInterface($hClientHandle, $pGUID, 0, "Auto Config Enabled")
		If IsServiceRunning($ServiceName) == 0 Then
			UpdateOutput("******Problem starting service:" & $ServiceName)
			UpdateProgress(5);
			DoDebug("[CheckService]" & $ServiceName & " start failure")
			Return 0
		Else
			UpdateOutput("******Started service:" & $ServiceName)
			UpdateProgress(5);
		EndIf
	Else
		DoDebug("[CheckService]" & $ServiceName & " Already Running")
	EndIf
	Return 1
EndFunc   ;==>CheckService

;Function to start wifi dll connection and check its not already open
Func WlanAPIConnect()
	;hClientHandle returned as @extended
	If (UBound($Enum)) Then
		If (StringLen($Enum[0][1]) > 0) Then
			DoDebug("[WLANConnect]WLANAPI connected")
			Return 1
		Else
			DoDebug("[WLANConnect]WLANAPI connected, but no adapter found")
			Return 0
		EndIf
	Else
		Local $interfaceWifi = _Wlan_StartSession()
		If @error Then
			MsgBox(16, "DEBUG", "Wifi DLL Open Error: " & @extended & $interfaceWifi)
			Return 0
		EndIf
		$hClientHandle = @extended
		$pGUID = $interfaceWifi[0][0]
		$Enum = _Wlan_EnumInterfaces($hClientHandle)
		DoDebug("[WLANConnect]WLANAPI connected:" & $Enum[0][1])
		Return 1
	EndIf
EndFunc   ;==>WlanAPIConnect

;Function to start wifi dll connection and check its not already open
Func WlanAPIClose()
	;hClientHandle returned as @extended
	_Wlan_EndSession($hClientHandle)
	If @error Then
		MsgBox(16, "DEBUG", "Wifi DLL Close Error")
	EndIf
	$pGUID = 0
	$hClientHandle = 0
	$Enum = 0
EndFunc   ;==>WlanAPIClose

;Function to check if wlanapi in use already. return true if so.
Func WlanAPICheck()
	If (Not ($hClientHandle) Or @error > 0) Then
		WlanAPIConnect()
		If @error Then
			MsgBox(16, "DEBUG", "Wifi DLL Open Error")
			Return 0
		ElseIf (UBound($Enum) == 0) Then
			UpdateOutput("***Wireless Adapter Problem")
			MsgBox(16, "Error", "No Wireless Adapter Found.")
			Return 0
		ElseIf (StringLen($Enum[0][1]) < 1) Then
			UpdateOutput("***Wireless Adapter Problem")
			MsgBox(16, "Error", "No Wireless Adapter Found.")
			Return 0
		Else
			Return 1
		EndIf
	Else
		Return 1
	EndIf
	Return 1
EndFunc   ;==>WlanAPICheck


Func FallbackConnect()
	;connect to fallback network for support funcs to work
	If (StringLen($SSID_Fallback) > 0) Then
		DoDebug("[fallback]connecting to fallback:" & $SSID_Fallback)
		If (StringInStr(GetOSVersion(), "win7", 0) Or StringInStr(GetOSVersion(), "vista", 0) Or StringInStr(GetOSVersion(), "8", 0)) Then
			;Check if the Wireless Zero Configuration Service is running.  If not start it.
			CheckService("WLANSVC")
		Else
			;XP
			CheckService("WZCSVC")
		EndIf

		;Check that serviec running before disconnect
		WlanAPIConnect()
		If (Not (WlanAPICheck())) Then
			Return 0
		Else

			;check if already connected to fallback network
			Sleep(1000)
			$fallback_state = _Wlan_QueryInterface($hClientHandle, $pGUID, 2)
			DoDebug("fallback_state=" & $fallback_state)
			If (StringCompare("Connected", $fallback_state, 0) == 0) Then
				$fallback_state = _Wlan_QueryInterface($hClientHandle, $pGUID, 3)
				If (StringCompare($SSID_Fallback, $fallback_state[1], 0) == 0) Then
					;already connected
					DoDebug("[fallback]Fallback already connected")
				Else
					_Wlan_Disconnect($hClientHandle, $pGUID)
					Sleep(1500)
					;is fallback in profile list?
					$fallback = _Wlan_GetProfile($hClientHandle, $pGUID, $SSID_Fallback)
					$findfallback = _ArrayFindAll($fallback, $SSID_Fallback)
					If (@error) Then
						$findfallback = False
					Else
						$findfallback = True
					EndIf

					If ($findfallback == False) Then
						;set profile
						Local $SSID_Fallback_profile[1]
						$SSID_Fallback_profile[0] = $SSID_Fallback
						_Wlan_SetProfile($hClientHandle, $pGUID, $SSID_Fallback_profile)
						SetPriority($hClientHandle, $pGUID, $SSID_Fallback, 11)
						DoDebug("Added fallback profile and set priority")
					EndIf

					;connect
					_Wlan_Connect($hClientHandle, $pGUID, $SSID_Fallback)
					DoDebug("[fallback]_Wlan_Connect has finished" & @CRLF)
					UpdateOutput("***Connected to fallback network...")
					Sleep(1000)
				EndIf
			Else
				;is fallback in profile list?
				$fallback = _Wlan_GetProfile($hClientHandle, $pGUID, $SSID_Fallback)
				$findfallback = _ArrayFindAll($fallback, $SSID_Fallback)
				If (@error) Then
					$findfallback = False
				Else
					$findfallback = True
				EndIf

				If ($findfallback == False) Then
					;set profile
					Local $SSID_Fallback_profile[1]
					$SSID_Fallback_profile[0] = $SSID_Fallback
					_Wlan_SetProfile($hClientHandle, $pGUID, $SSID_Fallback_profile)
					SetPriority($hClientHandle, $pGUID, $SSID_Fallback, 11)
					DoDebug("Added fallback profile and set priority")
					UpdateOutput("***Connected to fallback network...")
				EndIf
				Sleep(1000)
				_Wlan_Connect($hClientHandle, $pGUID, $SSID_Fallback)
				DoDebug("[fallback]_Wlan_Connect has finished" & @CRLF)
				Sleep(1000)
			EndIf
			Return 1
		EndIf
	Else
		DoDebug("No fallback network")
		Return 0
	EndIf
EndFunc   ;==>FallbackConnect

;return OS string for use in XML file
Func GetOSVersion()
	Dim $os
	Dim $sp = StringRight(@OSServicePack, 1)
	Switch @OSVersion
		Case "WIN_8"
			$os = "win8"
		Case "WIN_7"
			$os = "win7"
		Case "WIN_VISTA"
			$os = "vista"
		Case "WIN_XP", "WIN_XPe"
			$os = "xp"
			; we state to the *user* you need SP3 when really you can get away with SP2+KB918997
			Switch $sp
				Case 3
					;UpdateOutput("Found Service Pack 3")
				Case 2
					RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\HotFix\KB918997", "Installed")
					If @error Then
						DoDebug("[setup] hotfix" & @error)
						UpdateOutput("No Hotfix found")
						ContinueCase
					EndIf
				Case 0 To 2
					MsgBox(16, "Updates Needed", "You must have at least Service Pack 3 installed. Please run Windows Update.")
					Exit
			EndSwitch
		Case Else
			MsgBox(16, "Incompatible Operating System", "You need to be running at least Microsoft Windows XP")
			Exit
	EndSwitch

	Return $os
EndFunc   ;==>GetOSVersion

;Function to load user hint window after a connection attempt
Func doHint()
	If (GetOSVersion() == "xp") Then
		$y = 200
		$y2 = 50
		$y3 = 18
	EndIf
	If (GetOSVersion() == "vista" Or GetOSVersion() == "win7" Or GetOSVersion() == "win8") Then
		$y = 120
		$y2 = 0
		$y3 = 0
	EndIf
	GUICreate("Configuration Successful", 400, 250 + $y + $y2, 50, 20)
	GUISetState(@SW_SHOW)
	GUICtrlCreateLabel($SSID & " configuration was successful!" & @CRLF & @CRLF & "1) Watch for the network connection icon in the bottom right of your screen. " & @CRLF & @CRLF & " This could take a couple of seconds to change.", 5, 5)
	If (GetOSVersion() == "xp") Then
		GUICtrlCreatePic($bubble_xp_connected, 15, 80, 344, 100)
	EndIf
	If (GetOSVersion() == "vista") Then
		GUICtrlCreatePic($vista_connected, 15, 80, 33, 30)
	EndIf
	If (GetOSVersion() == "win7" Or GetOSVersion() == "win8") Then
		GUICtrlCreatePic($win7_connected, 15, 80, 56, 44)
	EndIf
	GUICtrlCreateLabel("If you seen the image above, you are successfully connected!", 5, $y)
	GUICtrlCreateLabel("Please click Finish and exit the tool", 5, $y + 20)
	;Watch for the bubble (As shown in the image below) to appear in the" & @CRLF & "System Tray near the clock.
	GUICtrlCreateLabel("2) If a bubble appears like the image below, click it." & @CRLF & @CRLF & "3) When prompted, enter your username (e.g. " & $username & ") and" & @CRLF & "   password but Leave the ""Logon domain"" field blank." & @CRLF & @CRLF & "4) Click ""OK"" on the ""Enter Credentials"" window", 5, $y + 40)
	If (GetOSVersion() == "xp") Then
		GUICtrlCreatePic($bubblexp, 15, $y + 130, 373, 135)
	EndIf
	If (GetOSVersion() == "vista" Or GetOSVersion() = "win7" Or GetOSVersion() == "win8") Then
		GUICtrlCreatePic($bubblevista, 15, $y + 130, 374, 59)
	EndIf
	$finish = GUICtrlCreateButton("Finish", 150, $y + $y2 + $y3 + 200, 100, 25)
	While 1
		$msg2 = GUIGetMsg()
		If $msg2 == $GUI_EVENT_CLOSE Then ExitLoop
		If $msg2 == $finish Then ExitLoop
	WEnd
	GUISetState(@SW_HIDE)
EndFunc   ;==>doHint

;Problem submission window
Func doGetHelpInfo()
	GUICreate("Help Information", 400, 250, @DesktopHeight / 2 - 100, @DesktopHeight / 2 - 100)
	GUISetState(@SW_SHOW)
	GUICtrlCreateLabel("Please enter a description of the problem:", 5, 5)
	$probdesc = GUICtrlCreateEdit("Problem Description:" & @CRLF, 10, 20, 385, 200, $ES_MULTILINE + $ES_AUTOVSCROLL + $WS_VSCROLL + $ES_WANTRETURN)
	$finish = GUICtrlCreateButton("Send", 150, 220, 100, 25)
	While 1
		$msg2 = GUIGetMsg()
		If $msg2 == $GUI_EVENT_CLOSE Then ExitLoop
		If $msg2 == $finish Then ExitLoop
	WEnd
	GUISetState(@SW_HIDE)
EndFunc   ;==>doGetHelpInfo


;Checks if a specified service is running.
;Returns 1 if running.  Otherwise returns 0.
;sc query appears to work in vist and xp
Func IsServiceRunning($ServiceName)
	$pid = Run('sc query ' & $ServiceName, '', @SW_HIDE, 2)
	Global $data = ""
	Do
		$data &= StdoutRead($pid)
	Until @error
	;DoDebug("data=" & $data)
	If StringInStr($data, 'running') Then
		Return 1
	Else
		Return 0
	EndIf
EndFunc   ;==>IsServiceRunning

;updates the progress bar by x percent
Func UpdateProgress($percent)
	$progress_meter = $progress_meter + $percent
	GUICtrlSetData($progressbar1, $progress_meter)
EndFunc   ;==>UpdateProgress

;output to edit box
Func UpdateOutput($output)
	GUICtrlSetData($myedit, $output & @CRLF, @CRLF)
	DoDebug("UserOutput:" & $output)
EndFunc   ;==>UpdateOutput

Func CloseWindows()
	If WinExists("Network Connections") Then
		;WinWaitClose("Network Connections","",15)
		WinKill("Network Connections")
		DoDebug("[setup]Had to Close Network Connectinos")
	EndIf
	If WinExists("Wireless Network Connection Properties") Then
		;WinWaitClose("Wireless Network Connection Properties","",15)
		WinKill("Wireless Network Connection Properties")
		DoDebug("[setup]Had to Close Wireless Network Connection Properties")
	EndIf

EndFunc   ;==>CloseWindows

Func CloseConnectWindows()
	;first bring su1x to front
	WinSetOnTop($title, "", 1)
	$winexist = False
	;If WinExists("[CLASS:tooltips_class32]") Then
	;	$text = WinGetText("[CLASS:tooltips_class32]", "")
	;	MsgBox(0, "Text read was:", $text)
	;	WinKill("[CLASS:tooltips_class32]")
	;	DoDebug("Closed [CLASS:tooltips_class32]")
	;	$winexist = True
	;EndIf
	If WinExists("Connect to a Network", "logon") Then
		WinKill("Connect to a Network")
		$winreconnect = 1
		DoDebug("Closed Connect to a Network")
		$winexist = True
	EndIf
	If WinExists("Windows Security") Then
		WinKill("Windows Security")
		$winreconnect = 1
		DoDebug("Closed Windows Security")
		$winexist = True
	EndIf
	If WinExists("Click to provide additional information.") Then
		WinKill("Click to provide additional information.")
		$winreconnect = 1
		DoDebug("Closed Click to provide additional information.")
		$winexist = True
	EndIf

	Return $winexist
EndFunc   ;==>CloseConnectWindows

Func RemoveSSID($hClientHandle, $pGUID, $ssidremove)
	DoDebug("[setup]Removing a ssid:" & $ssidremove)
	$removed = _Wlan_DeleteProfile($hClientHandle, $pGUID, $ssidremove)
EndFunc   ;==>RemoveSSID

;sets the priority of a ssid profile
Func SetPriority($hClientHandle, $pGUID, $thessid, $priority)
	$setpriority = DllCall($WLANAPIDLL, "dword", "WlanSetProfilePosition", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $thessid, "dword", $priority, "ptr", 0)
	DoDebug("[SetPriority] ssid=" & $thessid & " and priority=" & $priority)
	If ($setpriority[0] > 0) Then
		UpdateOutput("Error: Return code invalid for profile " & $thessid & " priority " & $priority)
		If $setpriority[0] Then DoDebug("[SetWirelessPriority]Error Msg=" & _Wlan_GetErrorMessage($setpriority[0]))
		Return 0
	EndIf
	DoDebug("[SetPriority] Success ssid=" & $thessid & " and priority=" & $priority)
	Return 1
EndFunc   ;==>SetPriority

;-------------------------------------------------------------------------
; Does all the prodding required to set the proxy settings in IE and FireFox

Func RemoveProxy()
	;removes proxy settings
	If ($proxy == 1) Then
		$orig_key = RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections", "WiFiConfigBackup")
		If @error = 0 Then
			$removeProxy1 = RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections", "DefaultConnectionSettings")
			RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections", "DefaultConnectionSettings", "REG_BINARY", $orig_key)
			$removeProxy2 = RegDelete("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections", "WiFiConfigBackup")
			DoDebug("[remove] Moved backed up proxy reg key back")
		EndIf
	EndIf
EndFunc   ;==>RemoveProxy

Func ConfigProxy()
	If ($proxy == 1) Then
		;Set the IE proxy settings to Automaticaly Detect
		$key_data = RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections", "DefaultConnectionSettings")
		If @error = 0 Then
			;backup current value
			If (RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections", "WiFiConfigBackup", "REG_BINARY", $key_data) == 1) Then
				;if both previous operations have been successful then proceed with setting Automatically Detect tick box
				;stitch the existing key together in parts
				$new_data = Hex(BinaryMid($key_data, 1, 8)) ;first 8 bytes
				$new_data = $new_data & Hex(BitOR(BinaryMid($key_data, 9, 1), 0x09), 2) ;important byte, set the correct bit of the bit mask
				$new_data = $new_data & Hex(BinaryMid($key_data, 10, BinaryLen($key_data))) ;remaining bytes
				$new_data = _HexToString($new_data)
				RegWrite("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections", "DefaultConnectionSettings", "REG_BINARY", $new_data)
				DoDebug("[setup]Backed up IE Reg key to WiFiConfigBackup and added new one")
			EndIf
		EndIf
		UpdateOutput("Configuring Proxy Settings")
		UpdateProgress(5)
		$wasrunning = 0
		;check for IE and kill all IE's ?
		If ($browser_reset == 1) Then
			DoDebug("[setup]browser reset=" & $browser_reset)
			If (ProcessExists("iexplore.exe")) Then
				MsgBox(48, "IE Detected", "IE configured. RestartingIE to bring changes into effect...")
				While (ProcessExists("iexplore.exe"))
					$wasrunning = 1
					ProcessClose("iexplore.exe")
				WEnd
				Sleep(100)
			EndIf
			If ($wasrunning == 1) Then Run(@ProgramFilesDir & "\Internet Explorer\iexplore.exe")
		EndIf

		$wasrunning = 0
		If (FileExists(@ProgramFilesDir & "\Mozilla Firefox\firefox.exe")) Then
			If ($browser_reset == 1) Then
				If (ProcessExists("firefox.exe")) Then
					MsgBox(48, "FireFox Detected", "FireFox configured. Restarting Firefox to bring changes into effect...")
					While (ProcessExists("firefox.exe"))
						$wasrunning = 1
						ProcessClose("firefox.exe")
					WEnd
					Sleep(100)
				EndIf
			EndIf
			$line = FileReadLine(@AppDataDir & "\Mozilla\Firefox\profiles.ini", 7) ; line 7 contains the random string associated with the profile
			$path = StringTrimLeft($line, 14)
			$to = @AppDataDir & "\Mozilla\Firefox\Profiles\" & $path & "\prefs.js"
			$original = FileOpen($to, 1)
			$in = "user_pref(""network.proxy.type"", 4);"
			FileWriteLine($original, $in)
			FileClose($original)
			If ($wasrunning == 1) Then Run(@ProgramFilesDir & "\Mozilla Firefox\firefox.exe")
		EndIf
	EndIf
EndFunc   ;==>ConfigProxy

Func setScheduleTask()
	If (FileExists(@ScriptDir & "\su1x-auth-task.xml")) Then

		$stxml = FileOpen(@ScriptDir & "\su1x-auth-task.xml")
		If ($stxml = -1) Then
			DoDebug("ERROR opening ST XML File")
		EndIf

		If (FileExists(@ScriptDir & "\su1x-auth-task-custom.xml")) Then
			FileDelete(@ScriptDir & "\su1x-auth-task-custom.xml")
		EndIf
		$newstxml = FileOpen(@ScriptDir & "\su1x-auth-task-custom.xml", 1)
		If ($newstxml = -1) Then
			DoDebug("ERROR opening new ST XML File")
		EndIf

		While 1
			$stline = FileReadLine($stxml)
			If @error = -1 Then ExitLoop
			If (StringInStr($stline, "Command") > 0) Then
				FileWriteLine($newstxml, "<Command>" & @ScriptFullPath & "</Command>")
			ElseIf (StringInStr($stline, "WorkingDirectory") > 0) Then
				FileWriteLine($newstxml, "<WorkingDirectory>" & @WorkingDir & "\</WorkingDirectory>")
			Else
				FileWriteLine($newstxml, $stline)
			EndIf
		WEnd
		FileClose($stxml)
		FileClose($newstxml)
		#RequireAdmin
		;install scheduled task
		$stresult = RunWait(@ComSpec & " /c " & "schtasks.exe /create /tn ""su1x-auth-start-tool"" /xml """ & @ScriptDir & "\su1x-auth-task-custom.xml""", "", @SW_HIDE)
		$st_result = StdoutRead($stresult)
		DoDebug("Scheduled Task:" & $st_result)
		;schtasks.exe /create /tn "su1x-auth-start-tool" /xml "f:\eduroam tool\event triggers\su1x-auth-start-orig.xml"
	EndIf
EndFunc   ;==>setScheduleTask

Func alreadyRunning()
	;kill windows sup gui first
	$quick = CloseConnectWindows()

	$list = ProcessList(@ScriptName)
	;_ArrayDisplay($list, "2D array")
	If ($list[0][0] > 1) Then
		DoDebug("Already running, exiting...")
		Exit
	EndIf

	;check if reauth, give time to see if windows supplicant successfull before loading su1x
	If (StringInStr($argument1, "auth") > 0) Then
		DoDebug("[reauth-start]Give time to connect")
		Local $loop_count = 0
		If (WlanAPICheck()) Then
			DoDebug("[reauth-start]Got wifi card:" & $Enum[0][1])
			If ($quick) Then
				$loopmax = 0
				$loop_count = 1
			Else
				$loopmax = 4
			EndIf
			TrayTip("Reconnecting to " & $SSID, "Attempting to reconnect to " & $SSID, 10, 2)
			While 1
				;check if connected and got an ip
				CloseConnectWindows()
				$retry_state = _Wlan_QueryInterface($hClientHandle, $pGUID, 2)
				If (Not @error) Then
					If (StringCompare("Connected", $retry_state, 0) == 0) Then
						$ip1 = @IPAddress1
						If ((StringLen($ip1) == 0) Or (StringInStr($ip1, "169.254.") > 0) Or (StringInStr($ip1, "127.0.0") > 0)) Then
						Else
							DoDebug("[reauth-start]Connected, so exiting...")
							Exit
						EndIf
					EndIf
					If (StringCompare("Disconnected", $retry_state, 0) == 0) Then
						DoDebug("[reauth-start]Disconnected")
					EndIf

					If (StringCompare("Authenticating", $retry_state, 0) == 0) Then
						DoDebug("[reauth-start]Authenticating...")
					EndIf
				EndIf
				If ($quick == False) Then Sleep(2000)
				If ($loop_count > $loopmax) Then ExitLoop
				$loop_count = $loop_count + 1
			WEnd

			$retry_state = _Wlan_QueryInterface($hClientHandle, $pGUID, 2)
			If (Not @error) Then
				If (StringCompare("Connected", $retry_state, 0) == 0) Then
					If ((StringLen($ip1) == 0) Or (StringInStr($ip1, "169.254.") > 0) Or (StringInStr($ip1, "127.0.0") > 0)) Then
						DoDebug("[reauth-start]Connected but not yet got an IP Address...")
					EndIf
				Else
					DoDebug("[reauth-start]ERROR:Failed to connected so load tool")
				EndIf
			EndIf
		EndIf
	EndIf

	If (StringInStr($argument1, "remove") > 0) Then
		$remove_wifi_arg = 1
	EndIf

EndFunc   ;==>alreadyRunning

;Function to check isf admin
Func CheckAdmin()
	#RequireAdmin
	If Not (IsAdmin()) Then
		MsgBox(16, "Insufficient Privileges", "Administrative rights are required.")
		Exit
	EndIf
	Return 1
EndFunc   ;==>CheckAdmin

Func SetEAPCred($thessid, $inttype, $interface)
	;*****************************SET  profile EAP credentials
	If ($showup > 0) Then
		;read in username and password
		Dim $user = GUICtrlRead($userbutton)
		Dim $pass = GUICtrlRead($passbutton)
		;additional regex from ini maybe?

		;check username
		If (StringInStr($user, "123456") > 0 Or StringLen($user) < 1) Then
			UpdateProgress(10)
			UpdateOutput("ERROR: Please enter a username")
			Return 0
		EndIf

		;check password
		If (StringLen($pass) < 1) Then
			UpdateProgress(10)
			UpdateOutput("ERROR: Please enter a password")
			Return 0
		EndIf
		Local $credentials[4]
		$credentials[0] = "PEAP-MSCHAP" ; EAP method
		$credentials[1] = "" ;domain
		$credentials[2] = $user ; username
		$credentials[3] = $pass ; password
		;INTTYPE = 1 FOR WIRELESS EAP CRED
		If ($inttype == 1) Then
			DoDebug("[EAPCred]_Wlan_SetProfileUserData" & $hClientHandle & " " & $pGUID & " " & $thessid & " " & $credentials[2])
			$setCredentials = _Wlan_SetProfileUserData($hClientHandle, $pGUID, $thessid, $credentials)
			If @error Then
				DoDebug("[EAPCred]Set credential error:" & @ScriptLineNumber & @error & @extended & $setCredentials & $thessid)
				Return 0
			EndIf
		EndIf
		;INTTYPE = 2 FOR WIRED EAP CRED
		If ($inttype == 2) Then
			$customeapxml = @ScriptDir & "\WiredEAPCredentials-custom.xml"
			$stxml = FileOpen(@ScriptDir & "\WiredEAPCredentials.xml")

			If ($stxml = -1) Then
				DoDebug("ERROR opening Wired EAPCred XML File")
			EndIf

			If (FileExists(@ScriptDir & $customeapxml)) Then
				FileDelete(@ScriptDir & $customeapxml)
			EndIf
			$newstxml = FileOpen($customeapxml, 1)
			If ($newstxml = -1) Then
				DoDebug("ERROR opening new Wired EAPCred XML File")
			EndIf

			While 1
				$stline = FileReadLine($stxml)
				If @error = -1 Then ExitLoop
				If (StringInStr($stline, "Username") > 0) Then
					FileWriteLine($newstxml, "<MsChapV2:Username>" & $user & "</MsChapV2:Username>")
				ElseIf (StringInStr($stline, "Password") > 0) Then
					FileWriteLine($newstxml, "<MsChapV2:Password>" & $pass & "</MsChapV2:Password>")
				Else
					FileWriteLine($newstxml, $stline)
				EndIf
			WEnd
			FileClose($stxml)
			FileClose($newstxml)

			$cmd = "netsh lan set eapuserdata filename=""" & $customeapxml & """ allusers=yes interface=""" & $interface & """"
			DoDebug("[setup]802.3 Set EAP Credentials command=" & $cmd)
			$setCredentials = RunWait($cmd, "", @SW_HIDE)
			UpdateProgress(20);
			If (FileExists($customeapxml)) Then
				FileDelete($customeapxml)
			EndIf
		EndIf
		DoDebug("[EAPCred]Set Credentials Success=" & $credentials[2] & " " & $setCredentials)
	EndIf

	Return 1
EndFunc   ;==>SetEAPCred

;function to interage through all profiles and install them
Func GetProfiles()
	;get profiles from profiles directory
	If (FileExists(@ScriptDir & "\profiles\")) Then
		$search_profile = FileFindFirstFile(@ScriptDir & "\profiles\" & "*.xml")
		Dim $count = 0
		Dim $profilesXML[1]
		While 1
			$found_profile = FileFindNextFile($search_profile)
			If @error Then ExitLoop
			ReDim $profilesXML[$count + 1]
			$profilesXML[$count] = @ScriptDir & "\profiles\" & $found_profile
			$count = $count + 1
		WEnd
		DoDebug("[GetProfiles]found " & UBound($profilesXML) & " config files")
		_ArraySort($profilesXML)
		Dim $tempprofiles[1]
		For $afilename In $profilesXML
			If (StringInStr($afilename, "WPA2")) Then _ArrayAdd($tempprofiles, $afilename)
		Next
		For $afilename In $profilesXML
			If (StringInStr($afilename, "WPA_")) Then _ArrayAdd($tempprofiles, $afilename)
		Next
		For $afilename In $profilesXML
			If (StringInStr($afilename, "WPA2-PSK")) Then _ArrayAdd($tempprofiles, $afilename)
		Next
		For $afilename In $profilesXML
			If (StringInStr($afilename, "WPA-PSK")) Then _ArrayAdd($tempprofiles, $afilename)
		Next
		For $afilename In $profilesXML
			If (StringInStr($afilename, "_OPEN_")) Then _ArrayAdd($tempprofiles, $afilename)
		Next
		_ArrayDelete($tempprofiles, 0)
		Return $tempprofiles
		;get profiles
	Else
		DoDebug("[GetProfiles]No profiles dir found in script dir")
		Return 0
	EndIf
EndFunc   ;==>GetProfiles

;function to set a wireless profile
Func SetWirelessProfile($XMLProfile, $thessid, $priority, $theauth)
	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", 0, "wstr", $XMLProfile, "ptr", 0, "int", 1, "ptr", 0, "dword*", 0)
	If ($a_iCall[0] > 0) Then
		If $a_iCall[8] Then DoDebug("[SetWirelessProfile]Reason Code=" & _Wlan_ReasonCodeToString($a_iCall[8]))
		If $a_iCall[0] Then DoDebug("[SetWirelessProfile]Error Msg=" & _Wlan_GetErrorMessage($a_iCall[0]))
		DoDebug("WPA2 profile not supported")
		Return 0
	Else
		;set priority of new profile
		Sleep(500)
		SetPriority($hClientHandle, $pGUID, $thessid, $priority)
		;*****************************SET  profile EAP credentials if a wpa or wpa2 enterprise network
		If (StringCompare($theauth, "WPA") == 0 Or StringCompare($theauth, "WPA2") == 0) Then
			If (Not (SetEAPCred($thessid, 1, $pGUID))) Then
				DoDebug("[SetWirelessProfile]Failed to set eap credentials for " & $thessid)
				UpdateOutput("Failed to set username/password for " & $thessid)
			EndIf
		EndIf
		UpdateProgress(5);
		Return 1
	EndIf
EndFunc   ;==>SetWirelessProfile

;function to config the wireless adapter
Func ConfigWireless($profilesXML)
	If (UBound($profilesXML)) Then
		Dim $failcount = 0
		;iterate through profiles
		For $afilename In $profilesXML
			Dim $tempafilename = _StringExplode($afilename, "\");
			$afilename_orig = $afilename
			$afilename = $tempafilename[UBound($tempafilename) - 1];
			Dim $theprofile = _StringExplode($afilename, "_")
			;loop to build ssid with underscore values in, as used as delimiter
			If (UBound($theprofile) > 4) Then
				While (UBound($theprofile) > 4)
					$theprofile[0] = $theprofile[0] & "_" & $theprofile[1];
					_ArrayDelete($theprofile, 1);
				WEnd
			EndIf
			If (UBound($theprofile) == 4) Then
				;looks like the correct file name type
				Dim $XMLProfileFile = FileOpen($afilename_orig)
				Dim $XMLProfile = FileRead($XMLProfileFile)
				Dim $thessid_array = _StringExplode($theprofile[0], "\")
				Dim $thessid = $thessid_array[UBound($thessid_array) - 1]
				Dim $theauth = $theprofile[1]
				Dim $theos = $theprofile[2]
				Dim $thepriority = StringTrimRight($theprofile[3], 4)
				Dim $setprofile = 0
				; if more than one profile file, check os. else use the one profile for all os's
				;If (UBound($profilesXML) > 1 And NOT (GetOSVersion() == $theos)) Then ContinueLoop
				If (UBound($profilesXML) == 1) Then
					DoDebug("[ConfigWireless]Setting profile " & $thessid & " with auth=" & $theauth)
					Dim $profile_result = SetWirelessProfile($XMLProfile, $thessid, $thepriority, $theauth)
					$setprofile = 1
				Else
					If (GetOSVersion() == $theos) Then
						DoDebug("[ConfigWireless]Setting profile " & $thessid & " with auth=" & $theauth)
						Dim $profile_result = SetWirelessProfile($XMLProfile, $thessid, $thepriority, $theauth)
						$setprofile = 1
					EndIf
				EndIf
				If $setprofile Then
					If (Not ($profile_result)) Then
						UpdateOutput("Error: Return code invalid for " & $thessid & " (" & $theauth & "). WPA2 not supportted?")
						$failcount = $failcount + 1
					Else
						UpdateOutput("Added Wireless Profile " & $thessid & " (" & $theauth & ")")
					EndIf
				EndIf
			Else
				DoDebug("Incorrrect profile found: " & $afilename)
				;ignore it, wrong file name
			EndIf
		Next
	Else
		DoDebug("No profile files found, aborting...")
		Return 0
		;exitloop
	EndIf

	If ($failcount >= (UBound($profilesXML))) Then
		;no profiles added correctly
		Return 0
	Else
		Return 1
	EndIf
EndFunc   ;==>ConfigWireless

;function to build a radio map of crowd sourced wifi fingerprints
Func BuildRadioMap()
	$radioFile = "radioMap.txt"
	;if file exists remove it
	If FileExists($radioFile) Then
		FileDelete($radioFile)
	EndIf
	$cmd = "netsh wlan show networks mode=Bssid > " & $radioFile
	;DoDebug("cmd=" & $cmd)
	$result = RunWait(@ComSpec & " /c " & $cmd, "", @SW_HIDE)
	;*****************************************************
	;read in radio map Files
	$mapFile = FileOpen($radioFile, 0)
	; Check if file opened for reading OK
	If $mapFile = -1 Then
		DoDebug("[radioMap]Unable to open radio map file:" & $radioFile)
	Else
		DoDebug("[radioMap]wlan trace file ok:" & $radioFile)
		Dim $aline
		Dim $radio_ssid
		Dim $radio_bssid
		Dim $radio_network_type
		Dim $radio_auth
		Dim $radio_enc
		Dim $radio_signal
		Dim $radio_chan
		Dim $radio_basic_rates
		Dim $radio_other_rates
		Dim $wifi_tmp_mac = GetMac("wireless")
		$wifi_tmp_mac = StringReplace($wifi_tmp_mac, ":", "", 0, 0)

		While 1
			;SSID 1 : eduroam
			;Network type            : Infrastructure
			;Authentication          : WPA2-Enterprise
			;Encryption              : CCMP
			;BSSID 1                 : 00:18:19:1f:1a:f0
			; Signal             : 15%
			; Radio type         : 802.11g
			;Channel            : 1
			;Basic rates (Mbps) : 1 2 5.5 11
			;Other rates (Mbps) : 6 9 12 18 24 36 48 54

			$aline = FileReadLine($mapFile)
			If @error = -1 Then ExitLoop
			;get ssid
			If (StringInStr($aline, "SSID", 0, 1, 1, 4)) Then
				$sub = StringSplit($aline, ":")
				If (IsArray($sub)) Then
					$sub = StringTrimLeft($sub[2], 1)
					$radio_ssid = $sub
				Else
					$radio_ssid = "error"
					ExitLoop;
				EndIf
				DoDebug("SSID=" & $radio_ssid)

				;Loop for each ssid
				While 1
					;read in each line of this subsection
					$aline = FileReadLine($mapFile)
					If @error = -1 Then ExitLoop
					If (StringInStr($aline, "BSSID")) Then
						$sub = StringSplit($aline, ":")
						If (IsArray($sub)) Then
							Dim $tmpmac = '';

							For $i = 2 To UBound($sub) - 1
								$tmpmac &= $sub[$i]
							Next

							$tmpmac = StringTrimLeft($tmpmac, 1)
							$sub = StringReplace($tmpmac, ":", "", 0, 0)
							$radio_bssid = $sub

							;another sub section for each bssid
							For $i = 4 To 1 Step -1
								;read in each line of this subsection
								$aline = FileReadLine($mapFile)
								If @error = -1 Then ExitLoop

								;check its not next section, if so exit loop
								If (StringInStr($aline, "BSSID")) Then
									ExitLoop
								EndIf

								;check for signal value
								If (StringInStr($aline, "Signal")) Then
									$sub = StringSplit($aline, ":")
									If (Not IsArray($sub)) Then ExitLoop
									$sub = StringReplace($sub[2], " ", "")
									$sub = StringReplace($sub, "%", "")
									$radio_signal = $sub
								EndIf

								;check for signal value
								If (StringInStr($aline, "Radio Type")) Then
									$sub = StringSplit($aline, ":")
									If (Not IsArray($sub)) Then ExitLoop
									$sub = StringReplace($sub[2], " ", "")
									$sub = StringReplace($sub, "802.11", "")
									$radio_network_type = $sub
								EndIf
								If @error = -1 Then ExitLoop
							Next

							;all ok then send off to locpris server
							Dim $radio_url = $radioMap_url & "?mac=" & $wifi_tmp_mac & "&bssid=" & $radio_bssid & "&ssid=" & $radio_ssid & "&rss=" & $radio_signal & "&type=" & $radio_network_type
							dodebug("url=" & $radio_url)
							Local $response = InetGet($radio_url, "", 1, 1)
							If (@error) Then
								DoDebug("Radio map upload error")
							EndIf

						Else
							$radio_bssid = "error"
							dodebug("error with bssid")
							ExitLoop;
						EndIf
					EndIf

					If @error = -1 Then ExitLoop
				WEnd

			EndIf
			$showall = $showall & $aline & @CRLF
			If @error = -1 Then ExitLoop
		WEnd
		FileClose($mapFile)
		;DoDump("aline=" & $aline)
	EndIf

EndFunc   ;==>BuildRadioMap

;used to captue enter press on password box to start install.
Func SetHotkeyAuth()
	$user_enter = 1
EndFunc   ;==>SetHotkeyAuth

;------------------------------------------------------------------------------------------------------------
;---------GUI code
;------------------------------------------------------------------------------------------------------------
DoDebug("***Starting SU1X***")
CheckAdmin()
alreadyRunning()
GUICreate($title, 294, 310)
GUISetBkColor(0xffffff) ;---------------------------------white
$n = GUICtrlCreatePic($BANNER, 0, 0, 295, 60) ;--------pic
If ($showup > 0) Then
	$myedit = GUICtrlCreateEdit($startText & @CRLF, 10, 70, 270, 70, $ES_MULTILINE + $ES_AUTOVSCROLL + $WS_VSCROLL + $ES_READONLY)
	GUICtrlCreateLabel("Username:", 10, 145, 60, 20)
	GUICtrlCreateLabel("Password:", 165, 145, 60, 20)
	$userbutton = GUICtrlCreateInput($username, 10, 160, 150, 20)
	$passbutton = GUICtrlCreateInput("password", 165, 160, 120, 20, BitOR($GUI_SS_DEFAULT_INPUT, $ES_PASSWORD))
	GUICtrlSendMsg($passbutton, 0x00CC, 42, 0)
	;GUICtrlSetData($passbutton, $GUI_FOCUS)
	If ($showuptick > 0) Then
		$showPass = GUICtrlCreateCheckbox("Show Password", 170, 185, 100, 20)
	EndIf
Else
	$showuptick = 0
	;showuptick must be 0 if showup 0, force set to avoid bad config
	$myedit = GUICtrlCreateEdit($startText & @CRLF, 10, 70, 270, 130, $ES_MULTILINE + $ES_AUTOVSCROLL + $WS_VSCROLL + $ES_READONLY)
EndIf
GUICtrlCreateLabel("Progress:", 15, 210, 48, 20)
$progressbar1 = GUICtrlCreateProgress(65, 210, 200, 20)
$exitb = GUICtrlCreateButton("Exit", 230, 270, 50)
;-------------------------------------------------------------------------
;TABS
$tab = GUICtrlCreateTab(1, 240, 292, 70)
;only show this tab if argument set by scheduled task
If (StringInStr($argument1, "auth") > 0) Then
	;-------------------------Connect Tab
	$tab0 = GUICtrlCreateTabItem("Connect")
	$tryconnect = GUICtrlCreateButton("Reconnect to " & $SSID, 60, 270, 150)
	;GUICtrlSetState(-1, $GUI_SHOW); will be display first
EndIf
;--------------------------Setup Tab
$tab1 = GUICtrlCreateTabItem("Setup")
$installb = GUICtrlCreateButton("Start Setup", 10, 270, 80)
$remove_width = StringLen($SSID) * 10
If ($remove_width < 90) Then
	$remove_wifi = GUICtrlCreateButton("Remove " & $SSID, 95, 270, 50 + $remove_width)
Else
	$remove_wifi = GUICtrlCreateButton("Remove", 95, 270, 90)
EndIf
;--------------------------Printing Tab
$tab2 = GUICtrlCreateTabItem("Printing")
$print = GUICtrlCreateButton("Setup Printer", 10, 270, 80)
$remove_printer = GUICtrlCreateButton("Remove Printer", 100, 270, 90)
;--------------------------Support Tab
$tab3 = GUICtrlCreateTabItem("Help")
$support = GUICtrlCreateButton("Start Checks", 10, 270, 80)
;$reset = GUICtrlCreateButton("IP Reset", 100, 270, 80)
$gethelp = GUICtrlCreateButton("Get Help", 100, 270, 80)
;--------------------------
$tab = GUICtrlCreateTabItem("")
;--------------------------End of Tabs
If ($show_printing == 0) Then GUICtrlDelete($tab2)
If ($show_support == 0) Then GUICtrlDelete($tab3)
;$unInstallb = GUICtrlCreateButton("Remove", 80, 280, 50)
;$backupb = GUICtrlCreateButton("Check", 160,280,50)

;set hotkey for enter press, so connected on enter press
Local $AccelKeys[1][2] = [["{ENTER}", $installb]]
GUISetAccelerators($AccelKeys)

GUISetState(@SW_SHOW)
;-----------------------------------------------------------
;START MAIN LOOP
;-----------------------------------------------------------
While 1
	;two while loops so exitlooop can be used to escape button functions
	While 1
		CloseConnectWindows()
		$msg = GUIGetMsg()
		If ($showuptick > 0 And $showup > 0) Then
			$checkbox = GUICtrlRead($showPass)
		Else
			$checkbox = 0
		EndIf
		;-----------------------------------------------------------Exit Tool
		If $msg == $exitb Then
			WlanAPIClose()
			DoDebug("***Exiting SU1X***")
			Exit
			ExitLoop
		EndIf

		If $msg == $GUI_EVENT_CLOSE Then
			WlanAPIClose()
			DoDebug("***Exiting SU1X***")
			;close file if dump set
			If ($DEBUG > 0) Then
				DoDump("****Tool Debug Output****")
				DoDump($debugResult)
			EndIf
			Exit
		EndIf

		;---------------------------------------------------------- Show Password
		; If checkbox ticked, show password
		If ($showuptick > 0) Then
			If $checkbox == $GUI_CHECKED Then
				If ($loopcheck == 0) Then
					$pass_tmp = GUICtrlRead($passbutton)
					GUICtrlSendMsg($passbutton, 0x00CC, 0, 0)
					GUICtrlSetData($passbutton, $pass_tmp)
				EndIf
				$loopcheck = 1
				$loopcheck2 = 0
			Else
				If ($loopcheck2 == 0) Then
					$pass_tmp = GUICtrlRead($passbutton)
					GUICtrlSendMsg($passbutton, 0x00CC, 42, 0)
					GUICtrlSetData($passbutton, $pass_tmp)
				EndIf
				$loopcheck = 0
				$loopcheck2 = 1
			EndIf
		EndIf

		;-----------------------------------------------------------
		;If install button clicked
		If ($msg == $installb Or StringInStr($argument1, "silent") > 0 Or $user_enter == 1) Then
			$user_enter = 0;
			;-----------------------------------------------------------check wired OR wireless
			If ($wired == 0 And $wireless == 0) Then
				DoDebug("Wired AND Wireless set to false in config")
				MsgBox(1, "error", "Wired AND Wireless set to false in config")
				Exit
			EndIf
			;--------check splash on or off
			If ($USESPLASH == 1) Then SplashImageOn("Installing", $SPLASHFILE, 1965, 1895, 0, 0, 1)
			;-------------------------------------------------------------------------
			; Start Installation
			GUICtrlSetData($progressbar1, 0)
			$progress_meter = 0;
			UpdateOutput("***Starting Installation***")

			Local $probconnect = 0
			$os = GetOSVersion()

			;------------------------------------------------------------------------------------------------------WIRELESS CONFIG
			If ($wireless == 1) Then

				;**************************************************************************************************************
				;Check OS then run appropriate code
				If $os == "xp" Then
					UpdateOutput("Detected Windows XP")
					;Check if the Wireless Zero Configuration Service is running.  If not start it.
					CheckService("WZCSVC")
				Else
					UpdateOutput("Detected " & $os)
					;Check if the Wireless Zero Configuration Service is running.  If not start it.
					CheckService("WLANSVC")
				EndIf

				CloseWindows()
				UpdateProgress(10);

				;Certificate install
				If ($use_cert == 1) Then SetCert()

				;check XML profile files are ok
				UpdateOutput("Configuring Wireless Profile...")
				UpdateProgress(10);

				If (Not (WlanAPIConnect())) Then
					If (Not (WlanAPICheck())) Then ExitLoop
				EndIf

				DoDebug("[setup]Adapter=" & $Enum[0][1])

				;Check for profiles to remove
				If ($removessid > 0) Then RemoveSSIDs($hClientHandle, $pGUID)
				;SET THE PROFILE
				UpdateProgress(10)

				;*****************************SET  profile
				Dim $profilesXML = GetProfiles()
				If (Not (ConfigWireless($profilesXML))) Then
					UpdateOutput("Wireless Configuration failed, aborting...")
					ExitLoop
				EndIf
				UpdateProgress(10)

				DoDebug("[setup]Disconnecting..." & @CRLF)
				_Wlan_Disconnect($hClientHandle, $pGUID)
				DoDebug("[setup]_Wlan_Disconnect has finished" & @CRLF)
				Sleep(5000)
				;give the adaptor time to disconnect...
				UpdateProgress(10);
				DoDebug("[setup]Connecting..." & @CRLF)
				_Wlan_Connect($hClientHandle, $pGUID, $SSID)
				DoDebug("[setup]_Wlan_Connect has finished" & @CRLF)
				UpdateProgress(10);
				Sleep(1000)
				CloseConnectWindows()
				UpdateOutput("Wireless Profile added...")
				Sleep(1500)
				;check if connected, if not, connect to fallback network
				Local $loop_count = 0
				While 1
					;check if connected and got an ip
					CloseConnectWindows()
					UpdateProgress(5)
					$retry_state = _Wlan_QueryInterface($hClientHandle, $pGUID, 2)
					If (Not @error) Then
						If (StringCompare("Connected", $retry_state, 0) == 0) Then
							$ip1 = @IPAddress1
							If ((StringLen($ip1) == 0) Or (StringInStr($ip1, "169.254.") > 0) Or (StringInStr($ip1, "127.0.0") > 0)) Then
								UpdateOutput("Getting an IP Address...")
							Else
								$retry_state2 = _Wlan_QueryInterface($hClientHandle, $pGUID, 3)
								If (IsArray($retry_state2)) Then
									$connectedssid = $retry_state2[1]
									If (StringLen($connectedssid)) > 0 Then
										If (StringCompare($SSID, $connectedssid) == 0) Then
											DoDebug("[setup]Connected")
											UpdateOutput($SSID & " connected with ip=" & $ip1)
											TrayTip("Connected", "You are now connected to " & $SSID & ".", 30, 1)
											;connected, so build radio map
											If ($radioMap) Then
												;check registry for key allowing radio map, set by installer
												Dim $radio_ok = RegRead("HKEY_CURRENT_USER\Software\su1x\", "radioMap")
												If StringCompare($radio_ok, "y") == 0 Then BuildRadioMap()
											EndIf
											Sleep(2000)
											ExitLoop
										Else
											DoDebug("[setup]Connected to wrong network")
											UpdateOutput($connectedssid & " connected with ip=" & $ip1)
											TrayTip("Problem", $SSID & " Failed. You are now connected to " & $connectedssid & ".", 30, 1)
											Sleep(2000)
											ExitLoop
										EndIf
									EndIf
								EndIf
								;error msg here?
							EndIf
						EndIf

						If (StringCompare("Disconnected", $retry_state, 0) == 0) Then
							DoDebug("[setup]Disconnected")
							UpdateOutput($SSID & " disconnected")
							DoDebug("[setup]Trying to connect to " & $SSID & " again..." & @CRLF)
							UpdateOutput("Trying to connect to " & $SSID & " again...")
							_Wlan_Connect($hClientHandle, $pGUID, $SSID)
						EndIf

						If (StringCompare("Authenticating", $retry_state, 0) == 0) Then
							DoDebug("[setup]Authenticating...")
							UpdateOutput($SSID & " authenticating...")
						EndIf
					Else
						DoDebug("[setup]Interface State Problem")
						UpdateOutput($SSID & " Failed... retrying... ")
					EndIf
					Sleep(3000)
					If ($loop_count > 9) Then
						$probconnect = 1
						ExitLoop
					EndIf
					$loop_count = $loop_count + 1
				WEnd

				$retry_state = _Wlan_QueryInterface($hClientHandle, $pGUID, 2)
				If (Not @error) Then
					If (StringCompare("Connected", $retry_state, 0) == 0) Then
						If ((StringLen($ip1) == 0) Or (StringInStr($ip1, "169.254.") > 0) Or (StringInStr($ip1, "127.0.0") > 0)) Then
							UpdateOutput("Connected but not yet got an IP Address...")
						EndIf
					Else
						UpdateOutput("ERROR:Failed to connected.")
						CloseConnectWindows()
						$probconnect = 1
					EndIf
				EndIf
				UpdateProgress(10);
				ConfigProxy()
				UpdateProgress(10);
			EndIf
			;------------------------------------------------------------------------------------------------------WIRED CONFIG
			If ($wired == 1) Then ConfigWired1x()
			;------------------------------------------------------------------------------------------------------NAP/SoH CONFIG
			;Enable NAP
			If ($nap == 1) Then
				DoDebug("[setup]Enabling NAP")
				;Check if the NAP Agent service is running.
				CheckService("napagent")
				;enable Wireless EAPOL NAP client enfrocement
				$cmd = "netsh nap client set enforcement id=79620 admin=enable"
				UpdateProgress(5);
				$result = RunWait($cmd, "", @SW_HIDE)
			EndIf

			;END OF CONFIG CODE**********************************************************************************************************

			;install scheduled task
			If ($scheduletask == 1) Then
				setScheduleTask();
				UpdateOutput("Added scheduled task")
			EndIf

			;-----------------------------------END CODE
			UpdateOutput("***Setup Complete***")
			If ($probconnect > 0) Then
				UpdateOutput("***POSSIBLE PROBLEM CONNECTING...")
				CloseConnectWindows()
				TrayTip($SSID & " Failed", "Check your username and password then click Start Setup again.", 30, 3)
			EndIf
			UpdateProgress(10);
			GUICtrlSetData($progressbar1, 100)
			If ($hint == 1 And ($probconnect > 0 Or $scheduletask == 0)) Then doHint()
			;Setup all done, display hint if hint set and turn off splash if on
			If ($USESPLASH == 1) Then SplashOff()
			;exit tool on completiong if all successfull
			If ($exitoncomplete == 1 And $probconnect == 0) Then
				If (StringInStr($argument1, "silent") == 0) Then MsgBox(1, $SSID & "Success", "Installation successful! Exiting...")
				Exit
			EndIf
		EndIf
		;-------------------------------------------------------------------------
		; All done...

		;-----------------------------------------------------------
		;If suport button clicked
		If ($msg == $support Or $msg == $gethelp) Then
			;-------------------------------------------------------------------------
			$output = ""
			WinSetOnTop($title, "", 0)
			UpdateProgress(10);
			GUICtrlSetData($progressbar1, 0)
			$progress_meter = 0;
			;read in username and password
			If ($showup > 0) Then
				$user = GUICtrlRead($userbutton)
				$pass = GUICtrlRead($passbutton)
			EndIf
			UpdateOutput("***Starting Checks***")

			If ($msg == $gethelp) Then
				;check username
				If (StringInStr($user, "123456") > 0 Or StringLen($user) < 1) Then
					UpdateProgress(100)
					UpdateOutput("ERROR: Please enter a username")
					ExitLoop
				EndIf

				;check password
				If (StringLen($pass) < 1) Then
					UpdateProgress(100)
					UpdateOutput("ERROR: Please enter a password")
					ExitLoop
				EndIf

				If (StringLen($SSID_Fallback) > 0) Then
					DoDebug("***GET HELP***")
					UpdateOutput("***Connecting to fallback:" & $SSID_Fallback & "***")
					UpdateProgress(20)
					If (Not (FallbackConnect())) Then
						UpdateOutput("Failed to connect to fallback network:" & $SSID_Fallback)
						ExitLoop
					EndIf
				EndIf

				;doGetHelpInfo()
				;$probdesc = GUICtrlRead($probdesc)
				;DoDebug("[support]Prob Description=" & $probdesc)
			EndIf



			;-------------------------------------------------------------------------GET OS INFO
			$osinfo = @OSVersion & ":" & @OSServicePack & ":" & @OSLang
			$os = GetOSVersion()
			$compname = @ComputerName
			$arch = @CPUArch & @OSArch
			$ip1 = @IPAddress1
			$ip2 = @IPAddress2
			If (StringInStr(@IPAddress1, "127.0.0.1")) Then
				$ip_touse = @IPAddress2
				If (StringInStr(@IPAddress2, "127.0.0.1")) Then
					$ip_touse = @IPAddress3
				EndIf
			Else
				$ip_touse = @IPAddress1
			EndIf
			$mac = GetMac("wireless")

			DoDebug("[support]mac=" & $mac)
			;MsgBox (0, "MAC Value", $MAC)
			$date = @MDAY & @MON & @YEAR
			$osuser = @UserName
			UpdateProgress(20);
			;-------------------------------------------------------------------------GET WIFI INFO
			;***************************************
			;vista and win 7 specific checks
			If (StringInStr(GetOSVersion(), "7", 0) Or StringInStr(GetOSVersion(), "vista", 0) Or StringInStr(GetOSVersion(), "8", 0)) Then
				;Check if the Wireless Zero Configuration Service is running.  If not start it.
				$WZCSVCStarted = IsServiceRunning("WLANSVC")
			Else
				;ASSUME XP
				;***************************************
				;win XP specific checks
				$WZCSVCStarted = IsServiceRunning("WZCSVC")
			EndIf
			If ($WZCSVCStarted) Then
				UpdateOutput("Wireless Service OK")
				$output &= "Wireless Service [OK]" & @CRLF
			Else
				UpdateOutput("***Wireless Service Problem")
				$output &= "Wireless Service [FAIL]" & @CRLF & "Possible other software managing wireless adapter, not Windows" & @CRLF & @CRLF
			EndIf
			UpdateProgress(10);

			If (Not (WlanAPIConnect())) Then
				If (Not (WlanAPICheck())) Then
					$wifi_card = 0
				Else
					$wifi_card = 1
				EndIf
			Else
				$wifi_card = 1
			EndIf
			If ($wifi_card) Then
				UpdateOutput("Wireless Adapter OK")
				$output &= "Wireless Adapter [OK]" & @CRLF
			Else
				UpdateOutput("***Wireless Adapter Problem")
				$output &= "Wireless Adapter [FAIL]" & @CRLF & "No wireless adapter found. Make sure wifi switch is on" & @CRLF & @CRLF
			EndIf
			UpdateProgress(10);


			If ($wifi_card) Then
				$wifi_adapter = $Enum[0][1]
				$wifi_state = $Enum[0][2]
				DoDebug("[support]wifi card found")
				;$wifi_networks=_Wlan_GetAvailableNetworkList($hClientHandle, $pGUID,0)
				;_ArrayDisplay($wifi_networks, "$wifi networks array")
				;$wifi_profiles = _Wlan_GetProfileList($hClientHandle, $pGUID)
				;_ArrayDisplay($wifi_profiles, "profiles array")
				$wifi_eduroam = _Wlan_GetProfile($hClientHandle, $pGUID, $SSID)
				$findProfile = _ArrayFindAll($wifi_eduroam, $SSID)
				If (@error) Then
					$findProfile = False
				Else
					$findProfile = True
				EndIf

				If ($findProfile) Then
					;_ArrayDisplay($wifi_eduroam, "eduroam array")
					$wifi_eduroam_all = $wifi_eduroam[0] & "," & $wifi_eduroam[1] & "," & $wifi_eduroam[2] & "," & $wifi_eduroam[3] & "," & $wifi_eduroam[4] & "," & $wifi_eduroam[5] & "," & $wifi_eduroam[6] & "," & $wifi_eduroam[7]
					DoDebug("[support]wifi profile = " & $wifi_eduroam_all)
				EndIf
				If ($findProfile) Then
					UpdateOutput("Wireless Profile " & $SSID & " OK")
					$output &= "Wireless Profile [OK]" & @CRLF
				Else
					UpdateOutput("***Wireless Profile " & $SSID & " Missing")
					$output &= "Wireless Setup [FAIL]" & @CRLF & $SSID & " profile missing, run setup tool again." & @CRLF & @CRLF
				EndIf
				UpdateProgress(10);
				$wifi_state = _Wlan_QueryInterface($hClientHandle, $pGUID, 2)
				If (StringInStr($wifi_state, "Dis") Or ($wifi_state == 0)) Then
					;do some thing
				Else
					$wifi_interface = _Wlan_QueryInterface($hClientHandle, $pGUID, 3)
					If (@error) Then
						DoDebug("[support]error interface settings:" & @error & $wifi_state)
					EndIf
					;updateoutput("here")
					$wifi_int_all = $wifi_interface[0] & "," & $wifi_interface[1] & "," & $wifi_interface[2] & "," & $wifi_interface[3] & "," & $wifi_interface[4] & "," & $wifi_interface[5] & "," & $wifi_interface[6] & "," & $wifi_interface[7]
					If (@error) Then
						DoDebug("[support]error interface array:" & @error)
					EndIf
					DoDebug("[support]wifi int=" & $wifi_int_all)
				EndIf
				;*****************************************************
				; Get wifi adapter driver details
				For $i = 1 To 200
					$var = RegEnumKey("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\", $i)
					If @error <> 0 Then ExitLoop
					For $j = 1 To 100
						$var2 = RegEnumKey("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var, $j)
						If @error <> 0 Then ExitLoop
						For $k = 1 To 100
							$var3 = RegEnumVal("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var & "\" & $var2, $k)
							If @error <> 0 Then
								;MsgBox(4096,"error","error reading HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var & "\" & $var2 & "\AdapterModel")
								ExitLoop
							EndIf
							If (StringInStr($var3, "AdapterModel") Or StringInStr($var3, "DriverDesc")) Then
								$AdapterModel = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var & "\" & $var2, $var3)
								$DriverDesc = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var & "\" & $var2, "DriverDesc")
								If (StringInStr($AdapterModel, $wifi_adapter) Or StringInStr($DriverDesc, $wifi_adapter)) Then
									;get data
									$DriverDate = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var & "\" & $var2, "DriverDate")
									$DriverVersion = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var & "\" & $var2, "DriverVersion")
									$HardwareVersion = RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var & "\" & $var2, "HardwareVersion")
									;MsgBox(4096,"error","Found adpatermodel: " & $AdapterModel)
									;MsgBox(4096,"error","DriverDate: " & $DriverDate)
									;MsgBox(4096,"error","DriverVersion: " & $DriverVersion)
									;MsgBox(4096,"error","HardwareVersion: " & $HardwareVersion)
								EndIf
							EndIf
						Next
					Next
				Next

				$ipok = 0
				;******check wifi card has ip before trying to send https stuff
				If ((StringLen($ip1) == 0) Or (StringInStr($ip1, "169.254.") > 0) Or (StringInStr($ip1, "127.0.0") > 0)) Then
					UpdateOutput("****No IP address found")
					$output &= "Wireless IP [FAIL]" & @CRLF & "No IP Address." & @CRLF & @CRLF
				Else
					$output &= "Wireless IP [OK]" & @CRLF
					UpdateOutput("****IP found:" & $ip1)
					$ipok = 1
				EndIf

				If ($ipok == 1 And $msg == $gethelp) Then

					;-------------------------------------------------------------------------Performe LDAP login test
					;
					;
					DoDebug("[support]send_ldap=" & $send_ldap)
					If ($send_ldap == 1 And $msg == $gethelp) Then
						$ynresponse = MsgBox(4, "Send Support Data", "Support data will be sent securely to " & $sendsupport_dept & " servers. This includes your username (NOT your password) and wireless adapter / device settings. Do you want to send support data?")
					EndIf
					If ($send_ldap == 1 And $ynresponse == 6 And $msg == $gethelp) Then
						Dim $response = ""
						;encode pass
						$pass = StringToASCIIArray($pass)
						$pass = _ArrayToString($pass, "|")
						DoDebug("[support]pass=" & $pass)
						DoDebug("[support]" & $ldap_url & "?email=" & $user & "&" & "pass=" & $pass)
						Local $response = InetRead($ldap_url & "?email=" & $user & "&" & "pass=" & $pass, 1)
						Sleep(3000)
						If (@error) Then
							DoDebug("[support]Error with https")
							UpdateOutput("****Wireless Login Test Connection Error")
							$output &= "Wireless Loging Test [FAIL]" & @CRLF & "No connection to Intranet." & @CRLF & @CRLF
						EndIf
						$response = BinaryToString($response)
						$response2 = $response
						DoDebug("[support]response=" & $response)
						;MsgBox(4096, "", "Response: " & @CRLF & @CRLF & BinaryToString($response))
						If (StringInStr($response, "Accepted", 0)) Then
							UpdateOutput("Wireless Username/Password OK")
							$output &= "Wireless Username/Password [OK]" & @CRLF
						EndIf
						If (StringInStr($response, "Username not found on LDAP", 0)) Then
							UpdateOutput("****Wireless Username Error")
							$output &= "Wireless Username [FAIL]" & @CRLF & "Username " & $user & "is not correct, or not found on wireless servers." & @CRLF & @CRLF
						EndIf
						If (StringInStr($response, "Ambigious result", 0)) Then
							UpdateOutput("****Wireless Username Error Ambigious")
							$output &= "Wireless Username [FAIL]" & @CRLF & "Ambigious result. Please see IT Support." & @CRLF & @CRLF
						EndIf
						If (StringInStr($response, "Password Incorrect", 0)) Then
							UpdateOutput("****Wireless Password Incorrect")
							$output &= "Wireless Password [FAIL]" & @CRLF & "Incorrect password." & @CRLF
							;$output &= "Wireless Password [FAIL]" & @CRLF & "The username is correct, but the password is not correct." & @CRLF & @CRLF
						EndIf
						UpdateProgress(10)

						;-------------------------------------------------------------------------Check Registration tables
						Dim $regtest = ""
						Local $regtest = InetRead($regtest_url & "?email=" & $user & "&" & "mac=" & $mac, 1)
						DoDebug($regtest_url & "?email=" & $user & "&" & "mac=" & $mac)
						Sleep(3000)
						If (@error) Then
							DoDebug("[support]Error with reg https")
							UpdateOutput("****Wireless Reg Test Connection Error")
							$output &= "Wireless Registration Test [FAIL]" & @CRLF & "No connection to Intranet." & @CRLF & @CRLF
						EndIf
						$regtest = BinaryToString($regtest)
						$regtest2 = $regtest
						DoDebug("[support]regtest=" & $regtest)
						;MsgBox(4096, "", "Response: " & @CRLF & @CRLF & BinaryToString($response))
						If (StringInStr($regtest, "Registration OK", 0)) Then
							UpdateOutput("Wireless Registration OK")
							$output &= "Wireless Registartion [OK]" & @CRLF
						EndIf
						If (StringInStr($regtest, "Device not in DHCP table", 0)) Then
							UpdateOutput("****Registration Error:DHCP table")
							$output &= "Wireless Registartion [FAIL]" & @CRLF & "Device missing from DHCP. Reregister or see IT Support." & @CRLF & @CRLF
						EndIf
						If (StringInStr($regtest, "Device Not Registered", 0)) Then
							UpdateOutput("****Registration Error: Not Registered")
							$output &= "Wireless Registartion [FAIL]" & @CRLF & "Device not Registerd. Please regsiter this device." & @CRLF & @CRLF
						EndIf
						If (StringInStr($regtest, "Database Failure (usergroup)", 0)) Then
							UpdateOutput("****Registration Error: User not in DB")
							$output &= "Wireless Registartion [FAIL]" & @CRLF & $user & " not found on wireles system." & @CRLF & @CRLF
						EndIf
						If (StringInStr($regtest, "Database Failure (ambigious username)", 0)) Then
							UpdateOutput("****Registration Error: Ambigious username")
							$output &= "Wireless Registartion [FAIL]" & @CRLF & $user & " ambigious. Please see IT Support." & @CRLF & @CRLF
						EndIf
						If (StringInStr($regtest, "Mac/User mismatch", 0)) Then
							UpdateOutput("****Registration Error: MAC Device Mismatch")
							$output &= "Wireless Registartion [FAIL]" & @CRLF & $user & " not registered keeper of this device." & @CRLF & @CRLF
						EndIf
					EndIf
					;response to YES or NO msg box
					UpdateProgress(10)

					DoDebug("[support]send problem =" & $send_problem)
					If ($send_problem == 1 And $ynresponse = 6 And $msg == $gethelp) Then
						;---------------------------------------SEND PROB DATA TO SUPPORT
						Dim $send = ""
						Local $send = InetRead($sendsupport_url & "?email=" & $user & "&" & "os=" & $os & "&" & "compname=" & $compname & "&" & "arch=" & $arch & "&" & "ip1=" & $ip1 & "&" & "ip2=" & $ip2 & "&" & "date=" & $date & "&" & "osuser=" & $osuser & "&" & "WZCSVCStarted=" & $WZCSVCStarted & "&" & "wifi_adapter=" & $wifi_adapter & "&" & "wifi_state=" & $wifi_state & "&" & "wifi_eduroam_all=" & $wifi_eduroam_all & "&" & "wifi_int_all=" & $wifi_int_all & "&" & "mac=" & $mac & "&" & "regtest=" & $regtest & "&" & "response=" & $response2 & "&" & "driverVersion=" & $DriverVersion & "&" & "driverDate=" & $DriverDate & "&" & "hardwareVersion=" & $HardwareVersion & "&" & "problemDesc=" & $probdesc, 1)
						Sleep(1000)
						If (@error) Then
							DoDebug("[support]Error with send")
							UpdateOutput("****Wireless Data Send Connection Error")
							$output &= "Wireless Data Send [FAIL]" & @CRLF & "No connection to Intranet." & @CRLF & @CRLF
						EndIf
						$send = BinaryToString($send)
						DoDebug("[support]send=" & $send)
					EndIf

				EndIf

				;end if for ip length
			EndIf
			;********************************************************
			;end code
			;********************************************************

			DoDump("****SU1X Dump of Support Data****")
			DoDump("****date = " & @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC)
			DoDump("****")
			DoDump("User=" & $user)
			DoDump("OS=" & $os)
			DoDump("CompName=" & $compname)
			DoDump("IP1=" & $ip1)
			DoDump("IP2=" & $ip2)
			DoDump("System Date=" & $date)
			DoDump("WZC Serv Started=" & $WZCSVCStarted)
			DoDump("Wifi Adapter=" & $wifi_adapter)
			DoDump("Wifi State=" & $wifi_state)
			DoDump("Wifi Profile=" & $wifi_eduroam_all)
			DoDump("Wifi Interface=" & $wifi_int_all)
			DoDump("MAC=" & $mac)
			DoDump("Driver Version=" & $DriverVersion)
			DoDump("Driver Date=" & $DriverDate)
			DoDump("Hardware Ver=" & $HardwareVersion)
			DoDump("****Support Checks Output****")
			DoDump("Data Send=" & $output)
			DoDebug("[support]LDAP Test:" & $response)
			$cmd = "netsh wlan show all > " & @WindowsDir & "\tracing\showall.txt"
			;DoDebug("cmd=" & $cmd)
			$result = RunWait(@ComSpec & " /c " & $cmd, "", @SW_HIDE)
			;$netshResult=StdoutRead($result)
			;*****************************************************
			;read in trace Files
			$tracefile = FileOpen(@WindowsDir & "\tracing\showall.txt", 0)
			; Check if file opened for reading OK
			If $tracefile = -1 Then
				DoDebug("[support]Unable to open trace file:" & $tracefile)
			Else
				DoDebug("[support]wlan trace file ok:" & $tracefile)
				While 1
					$aline = FileReadLine($tracefile)
					If @error = -1 Then ExitLoop
					$showall = $showall & $aline & @CRLF
				WEnd
				FileClose($tracefile)

				DoDump("****Netsh Output****")
				DoDump($showall)
			EndIf

			;********************************************************
			;end code
			;********************************************************

			If (StringInStr($output, "[FAIL]")) Then
				$output &= @CRLF & "A problem has been detected."
				TrayTip("Problem Detected", $output, 30, 3)
				UpdateOutput("****Problem Detected****")
				If ($msg == $gethelp And StringLen($report_problem_url) > 0) Then
					;open help website
					$ynresponse = MsgBox(4, "Report a Problem", "Would you like to report a problem? Click YES to open the Problem Reporting website.")
					WinSetOnTop("Report a Problem", "", 1)
					If ($ynresponse == 6) Then
						ShellExecute($report_problem_url)
					EndIf
				EndIf
			Else
				$output &= @CRLF & "No problems detected."
				TrayTip("No Problems Detected", $output, 30, 1)
				UpdateOutput("No Problem Detected")
			EndIf
			;UpdateOutput("Checks Complete")
			;MsgBox(4096,"Support Report",$output)
			UpdateProgress(10);
			GUICtrlSetData($progressbar1, 100)
			;Setup all done, display hint if hint set and turn off splash if on
			;if ($USESPLASH == 1) Then SplashOff()
			;-------------------------------------------------------------------------
			; All done...
			$msg = ""
			;ExitLoop
			WinSetOnTop($title, "", 1)
		EndIf

		;***************************************************************************************REMOVE EDUROAM
		If ($msg == $remove_wifi Or $remove_wifi_arg == 1) Then
			;if wireless
			If ($wireless == 1) Then
				If (Not (WlanAPIConnect())) Then
					If (Not (WlanAPICheck())) Then ExitLoop
				EndIf
				;Check for profiles to remove
				DoDebug("[remove]Removing SSID" & $SSID)
				RemoveSSIDs($hClientHandle, $pGUID)

				;remove scheduled task
				$stresult = RunWait(@ComSpec & " /c " & "schtasks.exe /delete /tn ""su1x-auth-start-tool"" /F", "", @SW_HIDE)
				$st_result = StdoutRead($stresult)
				DoDebug("Scheduled Task removed:" & $st_result)
				UpdateOutput("Removed Scheduled Task")
			EndIf

			If ($wired == 1) Then
				$ip = "localhost"
				$adapter = ""
				$objWMIService = ObjGet("winmgmts:{impersonationLevel = impersonate}!\\" & $ip & "\root\cimv2")
				$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapter", "WQL", 0x30)
				$networkcount = 0
				UpdateProgress(20);
				UpdateOutput("Removing Profile...")
				If IsObj($colItems) Then
					For $objItem In $colItems
						If ($objItem.AdapterType == "Ethernet 802.3") Then
							If (StringInStr($objItem.netconnectionid, "Local") And StringInStr($objItem.description, "Blue") == 0 And StringInStr($objItem.description, "1394") == 0 And StringInStr($objItem.description, "Wireless") == 0) Then
								$adapter &= "Caption: " & $objItem.Caption & @CRLF
								$adapter &= "Description: " & $objItem.Description & @CRLF
								$adapter &= "Index: " & $objItem.Index & @CRLF
								$adapter &= "NetID: " & $objItem.netconnectionid & @CRLF
								$wired_interface = $objItem.netconnectionid
								$adapter &= "Name: " & $objItem.name & @CRLF
								$adapter &= "Type: " & $objItem.AdapterType & @CRLF
								;Ethernet 802.3
								$adapter &= "MAC Address: " & $objItem.MACAddress & @CRLF
								$adapter &= "*********************"
								DoDebug("[remove] Removing profile to :" & $adapter)
								$adapter = ""
								$networkcount += 1
								UpdateOutput("Configuring " & $objItem.netconnectionid)
								$cmd = "netsh lan delete profile interface=""" & $wired_interface & """"
								DoDebug("[remove]802.3 command=" & $cmd)
								RunWait($cmd, "", @SW_HIDE)
								UpdateProgress(20);
								UpdateOutput("Removed profile from:" & $wired_interface)
							EndIf
						EndIf
						;ExitLoop
					Next
				Else
					DoDebug("[remove]No 802.3 Adapter found!")
				EndIf
				UpdateProgress(10);
				If ($networkcount < 1) Then UpdateOutput("No devices found to remove profile")
			EndIf
			RemoveProxy()
			TrayTip("Removed " & $SSID, "Tool and wireless networks removed", 30, 3)
			UpdateProgress(100);
			If ($remove_wifi_arg == 1) Then
				Sleep(1000)
				Exit
			EndIf
			$remove_wifi_arg = 0
			;code to remove proxy settings also maybe?
		EndIf
		;***************************************************************************************REMOVE EDUROAM

		;***************************************************************************************ADD PRINTER
		If $msg == $print Then

			Dim $printer_model

			If (StringInStr(GetOSVersion(), "vista", 0)) Then
				$printer_model = $printer_vista
			EndIf

			If (StringInStr(GetOSVersion(), "7", 0)) Then
				$printer_model = $printer_7
			EndIf

			If (StringInStr(GetOSVersion(), "8", 0)) Then
				$printer_model = $printer_7
			EndIf

			If (StringInStr(GetOSVersion(), "XP", 0)) Then
				$printer_model = $printer_xp
			EndIf

			$progress_meter = 0;
			UpdateOutput("***Installing Printer***")
			UpdateProgress(20);
			If (StringLen($printer_message > 1)) Then
				MsgBox(16, $printer_message_title, $printer_message)
			EndIf
			UpdateProgress(10);
			$cmd = "rundll32 printui.dll,PrintUIEntry /b """ & $printer & """ /x /n ""Nevermind This"" /if /f %windir%\inf\ntprint.inf /r """ & $printer_port & """ /m """ & $printer_model & """ "
			UpdateProgress(30);
			$result = RunWait(@ComSpec & " /c " & $cmd)
			$print_result = StdoutRead($result)
			UpdateOutput("***Printer Installed***")
			UpdateProgress(40);

			;code to remove proxy settings also maybe?
		EndIf
		;***************************************************************************************ADD PRINTER

		;***************************************************************************************REMOVE PRINTER
		If $msg == $remove_printer Then
			$progress_meter = 0;
			UpdateOutput("***Removing Printer***")
			UpdateProgress(20);
			UpdateProgress(10);
			$cmd = "rundll32 printui.dll PrintUIEntry /dl /n """ & $printer & """"
			UpdateProgress(30);
			$result = RunWait(@ComSpec & " /c " & $cmd)
			$print_result = StdoutRead($result)
			UpdateOutput("***Printer Removed***")
			UpdateProgress(40);
			;code to remove proxy settings also maybe?
		EndIf
		;***************************************************************************************REMOVE PRINTER

		;***************************************************************************************TRY TO CONNECT
		If $msg == $tryconnect Or $winreconnect == 1 Then
			DoDebug("***TRY TO REAUTH***")
			$progress_meter = 0;
			$winreconnect = 0
			UpdateProgress(0);
			UpdateOutput("***Trying to Connect to:" & $SSID & "***")
			UpdateProgress(0);
			;check profile set
			UpdateProgress(10)

			If (StringInStr(GetOSVersion(), "7", 0) Or StringInStr(GetOSVersion(), "vista", 0) Or StringInStr(GetOSVersion(), "8", 0)) Then
				;Check if the Wireless Zero Configuration Service is running.  If not start it.
				CheckService("WLANSVC")
			Else
				;ASSUME XP
				;***************************************
				;win XP specific checks
				CheckService("WZCSVC")
			EndIf

			If (Not (WlanAPIConnect())) Then
				If (Not (WlanAPICheck())) Then ExitLoop
			EndIf

			$wifi_eduroam = _Wlan_GetProfile($hClientHandle, $pGUID, $SSID)
			$findProfile = _ArrayFindAll($wifi_eduroam, $SSID)
			If (@error) Then
				$findProfile = False
			Else
				$findProfile = True
			EndIf

			UpdateProgress(20)
			If ($findProfile == False) Then
				UpdateOutput("***" & $SSID & " Profile missing, plrease run setup again.")
				TrayTip("Profile Missing", "Profile for " & $SSID & " missing. Run setup.", 30, 1)
				UpdateProgress(100)
				ExitLoop
			Else
				_Wlan_SetInterface($hClientHandle, $pGUID, 0, "Auto Config Enabled")
				DoDebug("[reauth]Disconnecting..." & @CRLF)
				_Wlan_Disconnect($hClientHandle, $pGUID)
				CloseConnectWindows()
				Sleep(500)
				;reset EAP credentials
				If (Not (SetEAPCred($SSID, 1, $pGUID))) Then
					ExitLoop
				EndIf
				UpdateProgress(30)
				;set priority of new profile
				SetPriority($hClientHandle, $pGUID, $SSID, 0)
				DoDebug("[reauth]Connecting..." & @CRLF)
				_Wlan_Connect($hClientHandle, $pGUID, $SSID)
				UpdateOutput("***Connecting...")
				Sleep(1500)
				;check if connected, if not, connect to fallback network
				Local $loop_count = 0
				While 1
					;check if connected and got an ip
					CloseConnectWindows()
					UpdateProgress(5)
					$retry_state = _Wlan_QueryInterface($hClientHandle, $pGUID, 2)
					If (Not @error) Then
						If (StringCompare("Connected", $retry_state, 0) == 0) Then
							$ip1 = @IPAddress1
							If ((StringLen($ip1) == 0) Or (StringInStr($ip1, "169.254.") > 0) Or (StringInStr($ip1, "127.0.0") > 0)) Then
								UpdateOutput("Getting an IP Address...")
							Else
								DoDebug("[reauth]Connected")
								UpdateOutput($SSID & " connected with ip=" & $ip1)
								TrayTip("Connected", "You are now connected to " & $SSID & ".", 30, 1)
								If ($radioMap) Then
									;check registry for key allowing radio map, set by installer
									Dim $radio_ok = RegRead("HKEY_CURRENT_USER\Software\su1x\", "radioMap")
									If StringCompare($radio_ok, "y") == 0 Then BuildRadioMap()
								EndIf
								Sleep(2000)
								ExitLoop
								Exit
							EndIf
						EndIf

						If (StringCompare("Disconnected", $retry_state, 0) == 0) Then
							DoDebug("[reauth]Disconnected")
							UpdateOutput($SSID & " disconnected")
						EndIf

						If (StringCompare("Authenticating", $retry_state, 0) == 0) Then
							DoDebug("[reauth]Authenticating...")
							UpdateOutput($SSID & " authenticating...")
						EndIf
					Else
						DoDebug("[reauth]failed...")
						UpdateOutput($SSID & " failed...")
					EndIf

					Sleep(2000)
					If ($loop_count > 5) Then ExitLoop
					$loop_count = $loop_count + 1
				WEnd

				$retry_state = _Wlan_QueryInterface($hClientHandle, $pGUID, 2)
				If (Not @error) Then
					If (StringCompare("Connected", $retry_state, 0) == 0) Then
						If ((StringLen($ip1) == 0) Or (StringInStr($ip1, "169.254.") > 0) Or (StringInStr($ip1, "127.0.0") > 0)) Then
							UpdateOutput("Connected but not yet got an IP Address...")
							TrayTip("Failed", "Failed to get IP address on " & $SSID & ".", 30, 1)
						EndIf
					Else
						TrayTip("Failed", "Failed to connect to " & $SSID & ".", 30, 1)
						UpdateOutput("ERROR:Failed to connect. Check username/password and run ""Setup > Start Setup"" again")
					EndIf
				EndIf
				$winreconnect = 0
				UpdateProgress(100)
			EndIf
		EndIf

		;***************************************************************************************TRY TO CONNECT

		;***************************************************************************************MANAGE WIRELESS REAUTH
		;This code runs once, then must reset $auth so it doesnt run again
		If (StringInStr($argument1, "auth") > 0) Then
			DoDebug("[reauth]Disconnecting wifi to retry auth")
			If (StringInStr(@OSVersion, "7", 0) Or StringInStr(@OSVersion, "VISTA", 0) Or StringInStr(@OSVersion, "8", 0)) Then
				;Check if the Wireless Zero Configuration Service is running.  If not start it.
				CheckService("WLANSVC")
			Else
				;ASSUME XP
				;***************************************
				;win XP specific checks
				CheckService("WZCSVC")
			EndIf
			If (Not (WlanAPIConnect())) Then
				If (Not (WlanAPICheck())) Then
					$argument1 = "fail"
					ExitLoop
				EndIf
			EndIf

			;make sure windows can manage wifi card
			DoDebug("[reauth]Setting windows to manage wifi")
			$QI = _Wlan_QueryInterface($hClientHandle, $pGUID, 0)
			;The "use Windows to configure my wireless network settings" checkbox - Needs to be enabled for many funtions to work
			_Wlan_SetInterface($hClientHandle, $pGUID, 0, "Auto Config Enabled")
			DoDebug("[reauth]Disconnecting..." & @CRLF)
			_Wlan_Disconnect($hClientHandle, $pGUID)
			$argument1 = "done"
			CloseConnectWindows()
			TrayTip("Reconnect to " & $SSID, "Enter your username and password again then click reconnect", 30, 3)
		EndIf

		;***************************************************************************************MANAGE WIRELESS REAUTH


	WEnd

WEnd
;-------------------------------------------------------------------------
;End of Program when loop ends
;-------------------------------------------------------------------------

Exit

