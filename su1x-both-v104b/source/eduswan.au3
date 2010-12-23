;-------------------------------------------------------------------------
; AutoIt script to automate the creation of Wireless Configuration for Eduroam
; 
; Written by Gareth Ayres of Swansea University (g.j.ayres@swansea.ac.uk)
; Inspired by a script written by Jeff deVeer (http://www.autoitscript.com/forum/index.php?showtopic=56479&hl=_EnumWireless)
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
; Updated 17/06/09 - Gareth Ayres (g.j.ayres@swan.ac.uk)
; To save time, makes use of API interface by MattyD (http://www.autoitscript.com/forum/index.php?showtopic=91018&st=0)
; 
;
;-------------------------------------------------------------------------

#include "Native_Wifi_Func_V3_3b.au3"
#include <GUIConstants.au3>
#Include <GuiListView.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#Include <String.au3>

;-------------------------------------------------------------------------
; Global variables and stuff




$VERSION = "V1.03"

;Check for config File
If (FileExists("config.ini") ==0) Then
	MsgBox(16,"Error","Config file not found.")
	Exit
EndIf

$WZCSVCStarted = 0
$SECURE_MACHINE = IniRead("config.ini", "su1x", "SECURE_MACHINE", "0")
$DEBUG=IniRead("config.ini", "su1x", "DEBUG", "0")
$USESPLASH = IniRead("config.ini", "su1x", "USESPLASH", "0")
$xmlfile = IniRead("config.ini", "su1x", "xmlfile", "exported.xml")
$xmlfile2 = IniRead("config.ini", "su1x", "xmlfile2", "exported-wpa.xml")
$xmlfilexpsp2 = IniRead("config.ini", "su1x", "xmlfilexpsp2", "exported-sp2.xml")
$tryadditional= IniRead("config.ini", "su1x", "tryadditional", "0")
$progress_meter = 0
$startText = IniRead("config.ini", "su1x", "startText", "SWIS")
$title =  IniRead("config.ini", "su1x", "title", "SWIS Eduroam - Setup Tool")
$hint = IniRead("config.ini", "su1x", "hint", "0")
$username = IniRead("config.ini", "su1x", "username", "123456@swansea.ac.uk")
$proxy = IniRead("config.ini", "su1x", "proxy", "1")
$browser_reset = IniRead("config.ini", "su1x", "browser_reset", "0")
$SSID = IniRead("config.ini", "getprofile", "ssid", "eduroam")
$priority = IniRead("config.ini", "getprofile", "priority", "0")

;----Printing
$show_printing = IniRead("config.ini", "print", "printing", "0")
$printer = IniRead("config.ini", "print", "printer", "Swansea Uni Wireless")
$printer_xp = IniRead("config.ini", "print", "printer_xp", "0")
$printer_vista = IniRead("config.ini", "print", "printer_vista", "0")
$printer_7 = IniRead("config.ini", "print", "printer_7", "0")
$printer_port = IniRead("config.ini", "print", "printer_port", "0")
$printer_message_title = IniRead("config.ini", "print", "printer_message_title", "0")
$printer_message = IniRead("config.ini", "print", "printer_message", "0")

;---Image Files 
$BANNER = IniRead("config.ini", "images", "BANNER", "lis-header.jpg")
$SPLASHFILE = IniRead("config.ini", "images", "SLPASHFILE", "big.jpg")
$bubblexp = IniRead("config.ini", "images", "bubblexp", "bubble1.jpg")
$bubblevista = IniRead("config.ini", "images", "bubblevista", "bubble-vista.jpg")
$bubble_xp_connected = IniRead("config.ini", "images", "bubble_xp_connected", "bubble-connected-xp.jpg")
$win7_connected = IniRead("config.ini", "images", "win7_connected", "connected-7.jpg")
$vista_connected = IniRead("config.ini", "images", "vista_connected", "connected-vista.jpg")

;-----SSID
$SSID = IniRead("config.ini", "getprofile", "ssid", "eduroam")
;-----SSID to remove
$removessid = IniRead("config.ini", "remove", "removessid", "0")
$SSID1 = IniRead("config.ini", "remove", "ssid1", "eduroam")
$SSID2 = IniRead("config.ini", "remove", "ssid2", "eduroam-setup")
$SSID3 = IniRead("config.ini", "remove", "ssid3", "unrioam")
;------Certificates
$certificate = IniRead("config.ini", "certs", "cert", "mycert.cer")
$use_cert = IniRead("config.ini", "certs", "usecert", "0")
;------Support
$show_support = IniRead("config.ini", "support", "show_support", "0")
$send_ldap = IniRead("config.ini", "support", "send_ldap", "0")
$send_problem = IniRead("config.ini", "support", "send_problem", "0")
$dump_to_file = IniRead("config.ini", "support", "dump_to_file", "0")

;---------initialise vairables
dim $user
dim $pass
dim $os
dim $compname
dim $arch
dim $ip1
dim $ip2
dim $date
dim $osuser
dim $WZCSVCStarted
dim $wifi_card
dim $wifi_adapter
dim $wifi_state
dim $wifi_eduroam_all
dim $wifi_int_all
dim $response
dim $DriverVersion
dim $DriverDate
dim $HardwareVersion
dim $output
dim $progressbar1
dim $myedit
dim $output
dim $run_already



; ---------------------------------------------------------------
;Functions

Func DoDebug($text)
	If $DEBUG == 1 Then	
		BlockInput (0)
		SplashOff()
		MsgBox (16, "DEBUG", $text)
	EndIf
EndFunc

Func _GetMACFromIP ($sIP)
    Local $MAC,$MACSize
    Local $i,$s,$r,$iIP
   $MAC        = DllStructCreate("byte[6]")
   DllStructSetData($MAC,1,"00:00:00:00:00:00")
   $MACSize    = DllStructCreate("int")
   DllStructSetData($MACSize,1,6)
   $r = DllCall ("Ws2_32.dll", "int", "inet_addr", "str", $sIP)
   $iIP = $r[0]
   ;$iIP = @IPAddress1
;Make the DllCall
    $r = DllCall ("Iphlpapi.dll", "int", "SendARP","int", $iIP,"int", 0,"ptr", DllStructGetPtr($MAC),"ptr", DllStructGetPtr($MACSize))

;Format the MAC address into user readble format: 00:00:00:00:00:00
    $s    = ""
    For $i = 0 To 5
        If $i Then $s = $s & ""
        $s = $s & Hex(DllStructGetData($MAC,1,$i+1),2)
    Next
;Return the user readble MAC address
    Return $s
EndFunc

Func doHint()
	if ($os == "xp") Then 
		$y=200
		$y2=50
		$y3=18
	EndIf
	if ($os == "vista" or $os == "win7") Then
		$y=120
		$y2=0
		$y3=0
	EndIf
  	GUICreate("Configuration Successful", 400, 250+$y+$y2, 50,20)
	GUISetState (@SW_SHOW)
	GUICtrlCreateLabel ( $SSID & " configuration was successful!" & @CRLF & @CRLF & "1) Watch for the network connection icon in the bottom right of your screen. "& @CRLF & @CRLF &" This could take a couple of seconds to change.", 5, 5)
	if ($os == "xp") Then 
		GUICtrlCreatePic($bubble_xp_connected, 15, 80, 344, 100)
	EndIf
	if ($os == "vista") Then
		GUICtrlCreatePic($vista_connected, 15, 80, 33, 30)
	EndIf
	if ($os == "win7") Then
		GUICtrlCreatePic($win7_connected, 15, 80, 56, 44)
	EndIf
	GUICtrlCreateLabel ( "If you seen the image above, you are successfully connected!",5, $y)
	GUICtrlCreateLabel ( "Please click Finish and exit the tool",5, $y+20 )
	;Watch for the bubble (As shown in the image below) to appear in the" & @CRLF & "System Tray near the clock.
	GUICtrlCreateLabel ( "2) If a bubble appears like the image below, click it." & @CRLF & @CRLF &"3) When prompted, enter your username (e.g. "&$username&") and" & @CRLF &"   password but Leave the ""Logon domain"" field blank."& @CRLF & @CRLF &"4) Click ""OK"" on the ""Enter Credentials"" window", 5, $y+40)
	if ($os == "xp") Then 
		GUICtrlCreatePic($bubblexp, 15, $y+130, 373, 135)
	EndIf
	if ($os == "vista" or $os = "win7") Then
		GUICtrlCreatePic($bubblevista, 15, $y+130, 374, 59)
	EndIf
	$finish = GUICtrlCreateButton ( "Finish",  150, $y+$y2+$y3+200, 100, 25)
	While 1
		$msg2 = GUIGetMsg()
        If $msg2 == $GUI_EVENT_CLOSE Then ExitLoop
		If $msg2 == $finish Then ExitLoop
	Wend
		GUISetState (@SW_HIDE)
EndFunc

;Checks if a specified service is running.
;Returns 1 if running.  Otherwise returns 0.
;sc query appears to work in vist and xp
Func IsServiceRunning($ServiceName)
	$pid = Run('sc query ' & $ServiceName, '', @SW_HIDE, 2)
	Global $data
	Do
		$data &= StdOutRead($pid)
	Until @error
	If StringInStr($data, 'running') Then 
		Return 1
	Else 
		Return 0
	EndIf
EndFunc

;updates the progress bar by x percent
Func UpdateProgress($percent)
		$progress_meter = $progress_meter + $percent
		GUICtrlSetData ($progressbar1,$Progress_meter)
EndFunc

;output to edit box
Func UpdateOutput($output)
		GUICtrlSetData ($myedit, $output& @CRLF,@CRLF)
EndFunc
	
Func CloseWindows()
		If WinExists("Network Connections") Then 
			;WinWaitClose("Network Connections","",15)
			WinKill("Network Connections")
			DoDebug("Had to Close Network Connectinos")
		EndIf
		If WinExists("Wireless Network Connection Properties") Then 
			;WinWaitClose("Wireless Network Connection Properties","",15)
			WinKill("Wireless Network Connection Properties")
			DoDebug("Had to Close Wireless Network Connection Properties")
		EndIf		
		
EndFunc

Func RemoveSSID($hClientHandle, $pGUID, $ssidremove)
	DoDebug("Removing a ssid $ssidremove")
	$removed=_Wlan_DeleteProfile($hClientHandle, $pGUID, $ssidremove)
EndFunc

;sets the priority of a ssid profile
Func SetPriority($hClientHandle, $pGUID, $thessid, $priority)
	$setpriority = DllCall($WLANAPIDLL, "dword", "WlanSetProfilePosition", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $thessid ,"dword", $priority, "ptr", 0)
	if ($setpriority[0]>0) Then
		UpdateOutput("Error: Return code invalid for profile priority")
	EndIf
EndFunc

;-------------------------------------------------------------------------
; Does all the prodding required to set the proxy settings in IE and FireFox

Func config_proxy ()
If ($proxy == 1) Then
	;Set the IE proxy settings to Automaticaly Detect
	$key_data = "4600000002000000090000000000000000000000000000000100000000000000506efaa1b4edc90100000000000000000000000001000000020000007f00000100000000000000002b30309d19002f433a5c000000000000000000000000000000000000004c003200000000000000000080006e6f7465786973742e68746d0000300003000400efbe0000000000000000140000006e006f007400650078006900730074002e00680074006d0000001c000000006d002900"
	$key_data = _HexToString($key_data)
	;key sets auto detect settings adn removes all other settings. i think (no IE documentatino to reference)
	If (RegWrite ("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Internet Settings\Connections","DefaultConnectionSettings", "REG_BINARY", $key_data)==1) Then
		DoDebug("Deleted IE Reg key and added new one")
	Else 
		DoDebug("No IE Reg Key")
	EndIf
	UpdateOutput("Configuring Proxy Settings")
	UpdateProgress(10)
	$wasrunning = 0
	;check for IE and kill all IE's ?
	If ($browser_reset == 1) Then
		DoDebug("browser reset=")
		DoDebug($browser_reset)
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
		$original = FileOpen($to,1)
		$in = "user_pref(""network.proxy.type"", 4);"
		FileWriteLine($original,$in)	    
	 FileClose($original)
	If ($wasrunning == 1) Then Run(@ProgramFilesDir & "\Mozilla Firefox\firefox.exe")
	EndIf
EndIf
EndFunc

	
;-------------------------------------------------------------------------
; Start of GUI code
GUICreate($title, 294, 310)
GUISetBkColor (0xffffff) ;---------------------------------white
;GUICtrlCreateLabel("Select Tab Below for Options:", 10, 65)
$n=GUICtrlCreatePic($BANNER,0,0, 294,54) ;--------pic
$myedit=GUICtrlCreateEdit ($startText& @CRLF, 10,80,270,70,$ES_MULTILINE+$ES_AUTOVSCROLL+$WS_VSCROLL+$ES_READONLY)
$userbutton=GUICtrlCreateInput ($username,10,160,150,20)
$passbutton=GUICtrlCreateInput ("password",165,160,120,20,BitOR($GUI_SS_DEFAULT_INPUT, $ES_PASSWORD))
;$myedit=GUICtrlCreateEdit ("Swansea Wireless Internet Service:"& @CRLF, 10,80,270,110,$ES_AUTOVSCROLL+$WS_VSCROLL+$ES_MULTILINE)
GUICtrlCreateLabel("Progress:", 5, 195,48,20)
$progressbar1 = GUICtrlCreateProgress (55,195,200,20)
$exitb = GUICtrlCreateButton("Exit", 230, 270, 50)
;-------------------------------------------------------------------------
;TABS
 ;-------------------------Setup Tab
$tab=GUICtrlCreateTab (1,240,292,70)
$tab1=GUICtrlCreateTabitem("Setup")
$installb = GUICtrlCreateButton("Start Setup", 10, 270, 80)
$remove_wifi = GUICtrlCreateButton("Remove " & $SSID, 100, 270, 100)
;--------------------------Printing Tab
$tab2=GUICtrlCreateTabitem("Printing") 
$print = GUICtrlCreateButton("Setup Printer", 10, 270, 80)
$remove_printer = GUICtrlCreateButton("Remove Printer", 100, 270, 90)
;--------------------------Support Tab
$tab3=GUICtrlCreateTabitem("Help")
$support = GUICtrlCreateButton("Start Checks", 10, 270, 80)
$reset = GUICtrlCreateButton("IP Reset", 100, 270, 80)
$tab = GUICtrlCreateTabItem("") 
;--------------------------End of Tabs
If ($show_printing==0) Then GUICtrlDelete($tab2)
If ($show_support==0) Then GUICtrlDelete($tab3) 
GUICtrlSetState($tab1, $GUI_SHOW)
;$unInstallb = GUICtrlCreateButton("Remove", 80, 280, 50)
;$backupb = GUICtrlCreateButton("Check", 160,280,50)
;-----------------------------------------------------------
;doHint()
GuiSetState(@SW_SHOW)
While 1
 While 1
  $msg = GUIGetMsg()
;-----------------------------------------------------------Exit Tool
  If $msg == $exitb Then 
	  _Wlan_EndSession(-1)
  exit
    ExitLoop
EndIf
If $msg == $GUI_EVENT_CLOSE Then
	_Wlan_EndSession(-1)
	Exit
EndIf
;-----------------------------------------------------------
;If install button clicked
if $msg == $installb Then
;--------check splash on or off
If ($USESPLASH  == 1) Then SplashImageOn("Installing", $SPLASHFILE, 1965, 1895, 0, 0, 1)
;-------------------------------------------------------------------------
; Start Installation
		GUICtrlSetData ($progressbar1,0)
		$progress_meter =0;
		UpdateOutput("***Starting Installation***")
		
;Check OS version
If (StringInStr(@OSVersion, "VISTA", 0)) Then
		$os = "vista"
		#RequireAdmin
EndIf

If (StringInStr(@OSVersion, "7", 0)) Then
		$os = "win7"
		#RequireAdmin
		If 0 = IsAdmin ( ) Then
			Msgbox (16, "Insufficient Privileges", "Administrative rights are required. Please contact IT Support.")
			Exit
		EndIf
EndIf
	
If (StringInStr(@OSVersion, "XP", 0)) Then
		$os = "xp"
		$sp=0
	EndIf
	
;read in username and password
$user=GUICtrlRead($userbutton)
$pass=GUICtrlRead($passbutton)

	
;**************************************************************************************************************
;Check OS then run appropriate code
If $os == "xp" Then
UpdateOutput("Detected Windows XP")
CloseWindows()
UpdateProgress(10);
;Check for Service Pack 2
		If @OSServicePack == "Service Pack 2" Then
			UpdateOutput("Found Service Pack 2") 
			;use xml file with no valid cert setup
			$xmlfile = $xmlfilexpsp2
			;Check if hotfix already installed
			RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion\HotFix\KB918997","Installed")
			If @error Then
				doDebug(@error)
				UpdateOutput("No Hotfix found")
				;run hotfix
				If (MsgBox(16,"Windows Update","The Microsoft update Service Pack 3 is required for this tool to work. Please run Windows Updates or visit http://update.microsoft.com in order to get the updates. You will then need to rerun the tool.")== 6) Then
					$msxml = DllOpen("msxml6.dll")
					if ($msxml = -1) then 
						UpdateOutput("No MSXML 6 found")
						UpdateOutput("Exiting as Windows Updates are required.")
						ExitLoop
					;install it
						;RunWait("msiexec /qn /i msxml6.msi")
					;RunWait("msiexec /i msxml6.msi")
						;UpdateOutput("msxml6 instlalled")
					EndIf
					;UpdateOutput("Installing hot fix. Please wait...")
					;ShellExecuteWait("WindowsXP-KB918997-v6-x86-ENU.exe","/quiet /norestart")
				;ShellExecuteWait("WindowsXP-KB918997-v6-x86-ENU.exe","/norestart")
				;	UpdateOutput("installed hotfix")
				Else
					Exit
				EndIf
				;Once update installed reboot required
				;If (MsgBox(4,"Reboot","Update installed! You must now restart and rerun the tool.")== 6) Then
				;	shutdown(2)
			;	Else
				;	MsgBox(16,"Exiting","Setup is now exiting. Please rerun this tool once you have rebooted")
				;	Exit
			;	EndIf
			Else
				UpdateOutput("Hotfix already instaled")
			EndIf
$sp=2
		EndIf
;Check for Service Pack 3
		If @OSServicePack == "Service Pack 3" Then
			UpdateOutput("Found Service Pack 3") 
			$sp=3
		EndIf
If $sp == 0 Then 
		Msgbox (16, "Updates Needed", "You must have at least Service Pack 2 installed. Please run Windows Update.")
		Exit
	EndIf

UpdateProgress(10);

If 0 = IsAdmin ( ) Then
	Msgbox (16, "Insufficient Privileges", "Administrative rights are required. Please contact IT Support.")
	Exit
EndIf

;Check if the Wireless Zero Configuration Service is running.  If not start it.
If IsServiceRunning("WZCSVC") == 0 Then
	DoDebug("WZC not running")
	;Set Wireless Zero Configuration Service to run automatically
	Run ("sc config WZCSVC start= auto","",@SW_HIDE)
	;Start the Wireless Zero Configuration Service
	RunWait ("net start WZCSVC","",@SW_HIDE)
	;Set $WZCSVCStarted to 1 so we know that WZCSVC had to be started
	$WZCSVCStarted = 1
	UpdateOutput("******Possible supplicant already managing device. WZC Started manually.")
	UpdateProgress(5);
Else
	DoDebug("WZC Running")
EndIf

UpdateOutput("Configuring Wireless Profile...")
UpdateProgress(10);
If (FileExists($xmlfile) == 0) Then
		MsgBox(16, "Error","Config file missing. Exiting...")
		Exit
EndIf	

If ($tryadditional==1) Then 
	If (FileExists($xmlfile2) == 0) Then
		MsgBox(16, "Error","Config file2 missing. ")
		Exit
	EndIf	
EndIf


$XMLProfile = FileRead($xmlfile)
if ($tryadditional) Then 
	$XMLProfile2 = FileRead($xmlfile2) 
EndIf

;Certificate install
If ($use_cert==1) Then
	DoDebug("Cert Install")
	$result = Run(@ScriptDir & "\CertMgr.Exe /add " & $certificate & " /s /r localMachine root", "", @SW_HIDE)	
	doDebug("result of cert="& $result)
	UpdateOutput("Installed certificate")
EndIf
	
if ($run_already<1) Then
$hClientHandle = _Wlan_OpenHandle()
$Enum = _Wlan_EnumInterfaces($hClientHandle)
EndIf

If (UBound($Enum)==0) Then
	doDebug(@error)
	MsgBox(16, "Error","No Wireless Adapter Found.")
	;Exit
	UpdateOutput("***Error - No wireless adapter found***")
	UpdateProgress(100);
	ExitLoop(1)
EndIf
$pGUID = $Enum[0][0]
DoDebug($Enum[0][1])	

;Check for profiles to remove
if ($removessid>0) Then
	doDebug("Removing SSID")
	$profiles=_Wlan_GetProfileList($hClientHandle, $pGUID)
	$doremove=1
	If (UBound($profiles)==0) Then
		doDebug("No wireless profiles found")
		$doremove=0
	EndIf
If ($doremove) Then
	for $ssidremove In $profiles
		if (StringCompare($ssidremove,$SSID1,0)==0) Then
			RemoveSSID($hClientHandle, $pGUID, $ssidremove)
			UpdateOutput("Removed SSID:")
			UpdateOutput($ssidremove)
		EndIf
		if (StringCompare($ssidremove,$SSID2,0)==0) Then
			RemoveSSID($hClientHandle, $pGUID, $ssidremove)
			UpdateOutput("Removed SSID:")
			UpdateOutput($ssidremove)
		EndIf
		if (StringCompare($ssidremove,$SSID3,0)==0) Then
			RemoveSSID($hClientHandle, $pGUID, $ssidremove)
			UpdateOutput("Removed SSID:")
			UpdateOutput($ssidremove)			
		EndIf
	Next
EndIf
EndIf

;SET THE PROFILE
UpdateProgress(10);
$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", 0, "wstr", $XMLProfile, "ptr", 0, "int", 1, "ptr", 0, "dword*", 0)
	if ($a_iCall[0]>0) Then
		if ($tryadditional==0) Then
			UpdateOutput("Error: Return code invalid (WPA2 not supportted?)")
			UpdateOutput("Error: Exiting application")
			Exit
		EndIf
	EndIf
;Check return code from setting profile and set additional profile
if ($tryadditional) Then
	DoDebug("Trying additional profile...")
	if ($a_iCall[0]==1169) Then
		$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", 0, "wstr", $XMLProfile2, "ptr", 0, "int", 1, "ptr", 0, "dword*", 0)
		doDebug("setProfile return code (profile2) =")
		doDebug($a_iCall[0])
	EndIf
EndIf

;*****************************SET  profile EAP credentials
Local $credentials[4]
$credentials[0] = "PEAP-MSCHAP" ; EAP method
$credentials[1] = "" ;domain
$credentials[2] = $user ; username
$credentials[3] = $pass ; password

$setCredentials = _Wlan_SetProfileUserData($hClientHandle, $pGUID, $SSID, $credentials)
If @error Then 
	DoDebug(@ScriptLineNumber & @error & @extended & $setCredentials)
EndIf
DoDebug("Set Credentials=" & $setCredentials)

;set priority of new profile
SetPriority($hClientHandle, $pGUID, $SSID, $priority)

;_ArrayDisplay($a_iCall, "array of return codes")
;if (StringLen(_Wlan_GetErrorMessage($a_iCall[0])) < 30) Then 
;	doDebug("No Wireless Interface exists! Exiting...")
;	Exit
;EndIf
;make sure windows can manage wifi card
DoDebug("Setting windows to manage wifi")
$QI = _Wlan_QueryInterface($hClientHandle, $pGUID, 0)
;The "use Windows to configure my wireless network settings" checkbox - Needs to be enabled for many funtions to work
DoDebug("Query Interface 0:" & $QI & @CRLF)
_Wlan_SetInterface($hClientHandle, $pGUID, 0, "Auto Config Enabled") 
;Auto Config Enabled or Auto Config Disabled 
Sleep(1000)
UpdateProgress(10);
DoDebug("Disconnecting..." & @CRLF)
_Wlan_Disconnect($hClientHandle, $pGUID)
DoDebug("_Wlan_Disconnect has finished" & @CRLF)
Sleep(5000) 
;give the adaptor time to disconnect...
UpdateProgress(10);
DoDebug("Connecting..." & @CRLF)
_Wlan_Connect($hClientHandle, $pGUID, $SSID)
DoDebug("_Wlan_Connect has finished" & @CRLF)
UpdateProgress(10);
;ConsoleWrite("Call Error: " & @error & @LF)
;ConsoleWrite(_Wlan_GetErrorMessage($a_iCall[0]))
sleep(1000)
UpdateOutput("Wireless Profile added...")
UpdateProgress(10);
config_proxy()
;UpdateProgress(10);
;RunWait ("net stop WZCSVC","",@SW_HIDE)
;UpdateProgress(5);
;RunWait ("net start WZCSVC","",@SW_HIDE)
UpdateProgress(10);
$run_already=1
;END OF XP CODE**********************************************************************************************************
Else
;VISTA / 7 CODE**************************************************************************************************************
	UpdateOutput("Detected " & $os)
	#RequireAdmin
	If 0 = IsAdmin ( ) Then
		Msgbox (16, "Insufficient Privileges", "Administrative rights are required. Please contact IT Support.")
		Exit
	EndIf
	UpdateOutput("Configuring Wireless Profile...")
	UpdateProgress(10);
	
	

If ($tryadditional==1) Then 
	If (FileExists($xmlfile2) == 0) Then
		MsgBox(16, "Error","Config file2 missing.")
		Exit
	EndIf	
EndIf


$XMLProfile = FileRead($xmlfile)
if ($tryadditional) Then 
	$XMLProfile2 = FileRead($xmlfile2) 
EndIf

;Check if the Wireless Zero Configuration Service is running.  If not start it.
If IsServiceRunning("WLANSVC") == 0 Then
	DoDebug("WLANSVC not running")
	;Set Wireless Zero Configuration Service to run automatically
	Run ("sc config WLANSVC start= auto","",@SW_HIDE)
	;Start the Wireless Zero Configuration Service
	RunWait ("net start WLANSVC","",@SW_HIDE)
	;Set $WZCSVCStarted to 1 so we know that WZCSVC had to be started
	$WZCSVCStarted = 1
	UpdateOutput("****** Possible supplicant already managing device. WZC Started manually.")
	UpdateProgress(5);
Else
	DoDebug("WLANSVC Running")
EndIf

;Certificate install
If ($use_cert==1) Then
	DoDebug("Cert Install")
	$result = Run(@ScriptDir & "\CertMgr.Exe /add " & $certificate & " /s /r localMachine root", "", @SW_HIDE)	
	doDebug("result of cert="& $result)
	UpdateOutput("Installed certificate")
EndIf

if ($run_already<1) Then
$hClientHandle = _Wlan_OpenHandle()
$Enum = _Wlan_EnumInterfaces($hClientHandle)
EndIf

If (UBound($Enum)==0) Then
	doDebug(@error)
	MsgBox(16, "Error","No Wireless Adapter Found.")
	;Exit
	UpdateOutput("***Error - No wireless adapter found***")
	UpdateProgress(100);
	ExitLoop(1)
EndIf
$pGUID = $Enum[0][0]
DoDebug($Enum[0][1])	

;updateoutput($hClientHandle & "," & $Enum[0][1] & "," &$pGUID)
;Check for profiles to remove
if ($removessid>0) Then
	doDebug("Removing SSID")
	$profiles=_Wlan_GetProfileList($hClientHandle, $pGUID)
	$doremove=1
	If (UBound($profiles)==0) Then
		doDebug("No wireless profiles found")
		$doremove=0
	EndIf
If ($doremove) Then
	for $ssidremove IN $profiles
		if (StringCompare($ssidremove,$SSID1,0)==0) Then
			RemoveSSID($hClientHandle, $pGUID, $ssidremove)
			UpdateOutput("Removed SSID:")
			UpdateOutput($ssidremove)
		EndIf
		if (StringCompare($ssidremove,$SSID2,0)==0) Then
			RemoveSSID($hClientHandle, $pGUID, $ssidremove)
			UpdateOutput("Removed SSID:")
			UpdateOutput($ssidremove)
		EndIf
		if (StringCompare($ssidremove,$SSID3,0)==0) Then
			RemoveSSID($hClientHandle, $pGUID, $ssidremove)
			UpdateOutput("Removed SSID:")
			UpdateOutput($ssidremove)			
		EndIf
	Next
EndIf
EndIf

;SET THE PROFILE
UpdateProgress(10);
$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", 0, "wstr", $XMLProfile, "ptr", 0, "int", 1, "ptr", 0, "dword*", 0)
 ;$a_iCall =  _Wlan_SetProfileXML($hClientHandle, $pGUID, $XMLProfile)
	if ($a_iCall[0]>0) Then
		if ($tryadditional==0) Then
			UpdateOutput("Error: Return code invalid (WPA2 not supportted?)")
			UpdateOutput("Error: Exiting application")
			Exit
		EndIf
	EndIf
;Check return code from setting profile and set additional profile
if ($tryadditional) Then
	DoDebug("Trying additional profile...")
	if ($a_iCall[0]==1169) Then
		$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", 0, "wstr", $XMLProfile2, "ptr", 0, "int", 1, "ptr", 0, "dword*", 0)
		doDebug("setProfile return code (profile2) =")
		doDebug($a_iCall[0])
	EndIf
EndIf

;*****************************SET  profile EAP credentials
Local $credentials[4]
$credentials[0] = "PEAP-MSCHAP" ; EAP method
$credentials[1] = "" ;domain
$credentials[2] = $user ; username
$credentials[3] = $pass ; password

$setCredentials = _Wlan_SetProfileUserData($hClientHandle, $pGUID, $SSID, $credentials)
If @error Then 
	DoDebug(@ScriptLineNumber & @error & @extended & $setCredentials)
	UpdateOutput("User/Pass not set")
EndIf
DoDebug("Set Credentials=" & $setCredentials)

;set priority of new profile
SetPriority($hClientHandle, $pGUID, $SSID, $priority)

;make sure windows can manage wifi card
DoDebug("Setting windows to manage wifi")
$QI = _Wlan_QueryInterface($hClientHandle, $pGUID, 0)
;The "use Windows to configure my wireless network settings" checkbox - Needs to be enabled for many funtions to work
DoDebug("Query Interface 0:" & $QI & @CRLF)
_Wlan_SetInterface($hClientHandle, $pGUID, 0, "Auto Config Enabled") 
;Auto Config Enabled or Auto Config Disabled 
Sleep(1000)
UpdateProgress(10);
DoDebug("Disconnecting..." & @CRLF)
_Wlan_Disconnect($hClientHandle, $pGUID)
DoDebug("_Wlan_Disconnect has finished" & @CRLF)
Sleep(5000) 
;give the adaptor time to disconnect...
UpdateProgress(10);
DoDebug("Connecting..." & @CRLF)
_Wlan_Connect($hClientHandle, $pGUID, $SSID)
DoDebug("_Wlan_Connect has finished" & @CRLF)
UpdateProgress(10);
$run_already=1

;code to connect to SSID instead of waiting for user.
;

;ConsoleWrite("Call Error: " & @error & @LF)
;ConsoleWrite(_Wlan_GetErrorMessage($a_iCall[0]))
sleep(1000)
UpdateProgress(10);
UpdateOutput("Wireless Profile added...")
config_proxy()
;UpdateProgress(10);
;RunWait ("net stop WZCSVC","",@SW_HIDE)
;UpdateProgress(10);
;RunWait ("net start WZCSVC","",@SW_HIDE)	
EndIf
;-----------------------------------END CODE
UpdateOutput("***Setup Complete***")
UpdateProgress(10);
GUICtrlSetData ($progressbar1,100)
;Setup all done, display hint if hint set and turn off splash if on
if ($USESPLASH == 1) Then SplashOff()
if ($hint == 1) Then doHint()
;-------------------------------------------------------------------------
; All done... 
  ExitLoop
  EndIf
  
;-----------------------------------------------------------
;If suport button clicked
if $msg == $support Then
;--------check splash on or off
;-------------------------------------------------------------------------

;vist or xp check
;Check OS version
$output = ""
If (StringInStr(@OSVersion, "VISTA", 0)) Then
		$os = "vista"
		#RequireAdmin
		If 0 = IsAdmin ( ) Then
			Msgbox (16, "Insufficient Privileges", "Administrative rights are required. Please contact IT Support.")
			Exit
		EndIf
EndIf
	
If (StringInStr(@OSVersion, "7", 0)) Then
		$os = "win7"
		#RequireAdmin
		If 0 = IsAdmin ( ) Then
			Msgbox (16, "Insufficient Privileges", "Administrative rights are required. Please contact IT Support.")
			Exit
			EndIf
EndIf
	
If (StringInStr(@OSVersion, "XP", 0)) Then
		$os = "xp"
EndIf
UpdateProgress(10);
		GUICtrlSetData ($progressbar1,0)
		$progress_meter =0;
		;read in username and password
		$user=GUICtrlRead($userbutton)
		$pass=GUICtrlRead($passbutton)
		UpdateOutput("***Starting Checks***")
		
;-------------------------------------------------------------------------GET OS INFO
$osinfo=@OSVersion & ":" & @OSServicePack & ":" & @OSLang
$compname=@ComputerName
$arch=@CPUArch & @OSArch
$ip1=@IPAddress1
$ip2=@IPAddress2
If (StringInStr(@IPAddress1,"127.0.0.1")) Then
	$ip_touse=@IPAddress2
	If (StringInStr(@IPAddress2,"127.0.0.1")) Then
		$ip_touse=@IPAddress3
	EndIf
Else
	$ip_touse=@IPAddress1
EndIf
$mac = _GetMACFromIP ($ip_touse)
		
doDebug($mac)
;MsgBox (0, "MAC Value", $MAC)
$date=@MDAY&@MON&@YEAR
$osuser=@UserName
UpdateProgress(20);
;-------------------------------------------------------------------------GET WIFI INFO
;***************************************
;vista and win 7 specific checks
If (StringInStr(@OSVersion, "7", 0) Or StringInStr(@OSVersion, "VISTA", 0)  ) Then
;Check if the Wireless Zero Configuration Service is running.  If not start it.
	If IsServiceRunning("WLANSVC") == 0 Then
		$WZCSVCStarted = 0
	Else
		$WZCSVCStarted = 1
	EndIf
Else
;ASSUME XP
;***************************************
;win XP specific checks
	If IsServiceRunning("WZCSVC") == 0 Then
		$WZCSVCStarted = 0
	Else
		$WZCSVCStarted = 1
	EndIf
EndIf
If ($WZCSVCStarted) Then 
	UpdateOutput("Wireless Service OK")
	$output &= "Wireless Service [OK]" & @CRLF
Else
	UpdateOutput("***Wireless Service Problem")
	$output &= "Wireless Service [FAIL]" & @CRLF & "Possible other software managing wireless adapter, not Windows" & @CRLF & @CRLF
EndIf
UpdateProgress(10);
	
if ($run_already<1) Then
	$hClientHandle = _Wlan_OpenHandle()
	$Enum = _Wlan_EnumInterfaces($hClientHandle)
EndIf

If (UBound($Enum)==0) Then
		doDebug(@error)
		DoDebug("Error, No Wireless Adapter Found.")
		$wifi_card=0
	Else
		$wifi_card=1
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
	$pGUID = $Enum[0][0]
	$wifi_adapter=$Enum[0][1]
	$wifi_state=$Enum[0][2]
	doDebug("wifi card found")
;$wifi_networks=_Wlan_GetAvailableNetworkList($hClientHandle, $pGUID,0)
;_ArrayDisplay($wifi_networks, "$wifi networks array")
;$wifi_profiles = _Wlan_GetProfileList($hClientHandle, $pGUID)
;_ArrayDisplay($wifi_profiles, "profiles array")
$wifi_eduroam=_Wlan_GetProfile($hClientHandle, $pGUID,$SSID)
$findProfile = _ArrayFindAll($wifi_eduroam, $SSID)
if (@error) Then
	$findProfile=False
Else
	$findProfile=True
EndIf

if ($findProfile) Then
	;_ArrayDisplay($wifi_eduroam, "eduroam array")
	$wifi_eduroam_all=$wifi_eduroam[0] & "," & $wifi_eduroam[1] & "," & $wifi_eduroam[2] & "," & $wifi_eduroam[3] & "," & $wifi_eduroam[4] & "," & $wifi_eduroam[5] & "," & $wifi_eduroam[6] & "," & $wifi_eduroam[7]
	DoDebug($wifi_eduroam_all)
EndIf
If ($findProfile) Then 
	UpdateOutput("Wireless Profile " & $SSID & " OK")
	$output &= "Wireless Profile [OK]" & @CRLF
Else
	UpdateOutput("***Wireless Profile " & $SSID & " Missing")
	$output &= "Wireless Setup [FAIL]" & @CRLF & $SSID & " profile missing, run setup tool again." & @CRLF & @CRLF
EndIf
UpdateProgress(10);
$wifi_state=_Wlan_QueryInterface($hClientHandle, $pGUID,2)
if (StringInStr($wifi_state,"Dis") OR ($wifi_state==0) ) Then
	;do some thing
Else
	$wifi_interface=_Wlan_QueryInterface($hClientHandle, $pGUID,3)
	if (@error) Then
		doDebug("error interface settings:" & @error & $wifi_state)
	EndIf
		;updateoutput("here")
		$wifi_int_all=$wifi_interface[0] & "," & $wifi_interface[1] & "," & $wifi_interface[2] & "," & $wifi_interface[3] & "," & $wifi_interface[4] & "," & $wifi_interface[5] & "," & $wifi_interface[6] & "," & $wifi_interface[7]
	if (@error) Then
		doDebug("error interface array:" & @error)
	EndIf
	DoDebug($wifi_int_all)
EndIf
;*****************************************************
; Get wifi adapter driver details
For $i= 1 to 200
    $var = RegEnumKey("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\", $i)
    If @error <> 0 then ExitLoop
		For $j= 1 to 100
			$var2 = RegEnumKey("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var, $j)
			If @error <> 0 then ExitLoop
			For $k = 1 to 100
				$var3 = RegEnumVal("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var & "\" & $var2, $k)
				if @error <> 0 Then 
						;MsgBox(4096,"error","error reading HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var & "\" & $var2 & "\AdapterModel")
						ExitLoop
					EndIf
				if (StringInStr($var3,"AdapterModel") OR StringInStr($var3,"DriverDesc") ) Then
					$AdapterModel= RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var & "\" & $var2, $var3)
					$DriverDesc= RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var & "\" & $var2, "DriverDesc")
					if (StringInStr($AdapterModel,$wifi_adapter) OR StringInStr($DriverDesc,$wifi_adapter)) Then
						;get data
						$DriverDate= RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var & "\" & $var2, "DriverDate")
						$DriverVersion= RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var & "\" & $var2, "DriverVersion")
						$HardwareVersion= RegRead("HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Class\" & $var & "\" & $var2, "HardwareVersion")
						;MsgBox(4096,"error","Found adpatermodel: " & $AdapterModel)
						;MsgBox(4096,"error","DriverDate: " & $DriverDate)
						;MsgBox(4096,"error","DriverVersion: " & $DriverVersion)
						;MsgBox(4096,"error","HardwareVersion: " & $HardwareVersion)
					EndIf
				EndIf
			next
		Next
Next


;******check wifi card has ip before trying to send https stuff
if ( (StringLen($ip1)==0) OR (StringInStr($ip1,"169.254.")>0) OR (StringInStr($ip1,"127.0.0")>0) ) Then
UpdateOutput("****No IP address found")
	$output &= "Wireless IP [FAIL]" & @CRLF & "No IP Address." & @CRLF & @CRLF
	DoDebug("Disconnecting..." & @CRLF)
	if ($send_ldap==1) Then	
		_Wlan_Disconnect($hClientHandle, $pGUID)
		DoDebug("_Wlan_Disconnect has finished" & @CRLF)
		Sleep(3000) 
		;give the adaptor time to disconnect...
		UpdateProgress(10);
		DoDebug("Connecting..." & @CRLF)
		_Wlan_Connect($hClientHandle, $pGUID,"eduroam-setup")
		DoDebug("_Wlan_Connect has finished" & @CRLF)
		UpdateProgress(10);
	EndIf
Else
	$output &= "Wireless IP [OK]" & @CRLF
	UpdateOutput("****IP found:" & $ip1) 
EndIf

if ( (StringLen($ip1)) OR (StringInStr($ip1,"169.254.")==0) ) Then	

;-------------------------------------------------------------------------Performe LDAP login test
;
;
DoDebug("send_ldap=" & $send_ldap) 
	if ($send_ldap==1) Then
		$ynresponse = MsgBox(4,"Send Support Data","Support data will be sent securely to LIS servers. This includes your username (NOT your password) and wireless adapter settings. Do you want to send support data?")
	EndIf
	if ($send_ldap==1 And $ynresponse == 6) Then
	dim $response = ""
Local $response = InetRead("https://swisweb.swan.ac.uk/swis/eduroam/logintest.php?email="& $user & "&" & "pass=" & $pass,2)
Sleep(3000)
if (@error) Then
	DoDebug("Error with https")
	UpdateOutput("****Wireless Login Test Connection Error") 
	$output &= "Wireless Loging Test [FAIL]" & @CRLF & "No connection to Intranet." & @CRLF & @CRLF
EndIf
$response=BinaryToString($response)
$response2=$response
DoDebug("response="&$response)
;MsgBox(4096, "", "Response: " & @CRLF & @CRLF & BinaryToString($response))
If (StringInStr($response, "Accepted", 0)) Then 
	UpdateOutput("Wireless Username/Password OK")
	$output &= "Wireless Username/Password [OK]" & @CRLF
	EndIf
If (StringInStr($response, "Username not found on LDAP", 0)) Then 
	UpdateOutput("****Wireless Username Error") 
	$output &= "Wireless Username [FAIL]" & @CRLF & "Username "& $user & "is not correct, or not found on wireless servers." & @CRLF & @CRLF
	EndIf
If (StringInStr($response, "Ambigious result", 0)) Then 
	UpdateOutput("****Wireless Username Error Ambigious") 
	$output &= "Wireless Username [FAIL]" & @CRLF & "Ambigious result. Please see IT Support." & @CRLF & @CRLF
	EndIf
If (StringInStr($response, "Password Incorrect", 0)) Then 
	UpdateOutput("****Wireless Password Incorrect") 
	$output &= "Wireless Password [FAIL]" & @CRLF & "The username is correct, but the password is not correct." & @CRLF & @CRLF
	EndIf
UpdateProgress(10)

;-------------------------------------------------------------------------Check Registration tables
dim $regtest = ""
Local $regtest = InetRead("https://swisweb.swan.ac.uk/swis/eduroam/regtest.php?email="& $user & "&" & "mac=" & $mac,2)
Sleep(3000)
if (@error) Then
	DoDebug("Error with reg https")
	UpdateOutput("****Wireless Reg Test Connection Error") 
	$output &= "Wireless Registration Test [FAIL]" & @CRLF & "No connection to Intranet." & @CRLF & @CRLF
EndIf
$regtest=BinaryToString($regtest)
$regtest2=$regtest
DoDebug("regtest="&$regtest)
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

DoDebug("send problem =" & $send_problem) 
if ($send_problem==1 And $ynresponse = 6) Then
;---------------------------------------SEND PROB DATA TO SUPPORT
dim $send = ""
Local $send = InetRead("https://swisweb.swan.ac.uk/swis/eduroam/sendsupport.php?email="& $user & "&" & "os=" & $os & "&" & "compname=" & $compname & "&" & "arch=" & $arch & "&" & "ip1=" & $ip1 & "&" & "ip2=" & $ip2 & "&" & "date=" & $date & "&" & "osuser=" & $osuser & "&" & "WZCSVCStarted=" & $WZCSVCStarted  & "&" & "wifi_adapter=" & $wifi_adapter & "&" & "wifi_state=" & $wifi_state  & "&" & "wifi_eduroam_all=" & $wifi_eduroam_all & "&" & "wifi_int_all=" & $wifi_int_all & "&" & "mac=" & $mac& "&" & "regtest=" & $regtest & "&" & "response=" & $response2 & "&" & "driverVersion=" & $DriverVersion & "&" & "driverDate=" & $DriverDate & "&" & "hardwareVersion=" & $HardwareVersion,2)
Sleep(1000)
if (@error) Then
	DoDebug("Error with send")
	UpdateOutput("****Wireless Data Send Connection Error") 
	$output &= "Wireless Data Send [FAIL]" & @CRLF & "No connection to Intranet." & @CRLF & @CRLF
EndIf
$send=BinaryToString($send)
;UpdateOutput("https://lsayregj.swan.ac.uk/swisweb/swis/eduroam/sendsupport.php?email="& $user & "&" & "pass=" & $pass & "&" & "os=" & $os & "&" & "compname=" & $compname & "&" & "arch=" & $arch & "&" & "ip1=" & $ip1 & "&" & "ip2=" & $ip2 & "&" & "date=" & $date & "&" & "osuser=" & $osuser & "&" & "WZCSVCStarted=" & $WZCSVCStarted  & "&" & "wifi_adapter=" & $wifi_adapter & "&" & "wifi_state=" & $wifi_state  & "&" & "wifi_eduroam_all=" & $wifi_eduroam_all & "&" & "wifi_int_all=" & $wifi_int_all & "&" & "mac=" & $mac & "&" & "regtest=" & $regtest & "&" & "response=" & $response2)
DoDebug("send="&$send)
EndIf

EndIf



;DoDebug("here") 
;end if for ip length
EndIf
;********************************************************
;end code
;********************************************************
DoDebug($user)
DoDebug($pass)
DoDebug("os="&$os)
DoDebug($compname)
DoDebug($arch)
DoDebug($ip1)
DoDebug($ip2)
DoDebug($date)
DoDebug($osuser)
DoDebug("Wifi service="&$WZCSVCStarted)
DoDebug("Wifi Card="&$wifi_card)
DoDebug("Wifi adapter="&$wifi_adapter)
DoDebug("Wifi state="&$wifi_state)
DoDebug("LDAP Test:"&$response) 
$run_already=1

if ($dump_to_file==1) Then
	$file = FileOpen("su1x-dump-"& @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & ".txt", 1)
	; Check if file opened for reading OK
	If ($file == -1) Then
		MsgBox(0, "Error", "Unable to open file.:" & $file)
		Exit
	EndIf
	FileWriteLine($file, "****SU1X Dump of Support Data****")
	FileWriteLine($file, "****date = "& @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC )
	FileWriteLine($file, "****")
	FileWriteLine($file, "User=" & $user)
	FileWriteLine($file, "OS=" & $os)
	FileWriteLine($file, "Compname=" & $compname)
	FileWriteLine($file, "IP1=" & $ip1)
	FileWriteLine($file, "IP2=" & $ip2)
	FileWriteLine($file, "System Date=" & $date)
	FileWriteLine($file, "WZC Serv Started=" & $WZCSVCStarted)
	FileWriteLine($file, "Wifi Adapter=" & $wifi_adapter)
	FileWriteLine($file, "Wifi State=" & $wifi_state)
	FileWriteLine($file, "Wifi Profile=" & $wifi_eduroam_all)
	FileWriteLine($file, "Wifi Interface=" &  $wifi_int_all)
	FileWriteLine($file, "MAC=" & $mac)
	FileWriteLine($file, "Driver Version=" & $DriverVersion)
	FileWriteLine($file, "Driver Date=" & $DriverDate)
	FileWriteLine($file, "Hardware Ver=" & $HardwareVersion)	
	FileWriteLine($file, "****Support Checks Output****")	
	FileWriteLine($file, $output)		
	FileClose($file)
	DoDebug("Dump to file:" & $file)
EndIf


;********************************************************
;end code
;********************************************************

;_Wlan_EndSession(-1)
if (StringInStr($output,"[FAIL]")) Then 
	$output &=@CRLF & "A problem has been detected."
	TrayTip("Problem Detected", $output, 30, 3)
	UpdateOutput("****Problem Detected****")
Else 
	$output &= @CRLF & "No problems detected."
	TrayTip("No Problems Detected", $output, 30, 1)
	UpdateOutput("No Problem Detected")
EndIf
;UpdateOutput("Checks Complete")
;MsgBox(4096,"Support Report",$output)
UpdateProgress(10);
GUICtrlSetData ($progressbar1,100)
;Setup all done, display hint if hint set and turn off splash if on
;if ($USESPLASH == 1) Then SplashOff()
;-------------------------------------------------------------------------
; All done... 
  $msg=""
  ExitLoop
EndIf


;***************************************************************************************RESET
if $msg == $reset Then
	If (StringInStr(@OSVersion, "VISTA", 0)) Then
		$os = "vista"
		#RequireAdmin
		If 0 = IsAdmin ( ) Then
			Msgbox (16, "Insufficient Privileges", "Administrative rights are required. Please contact IT Support.")
			Exit
		EndIf
EndIf
	
If (StringInStr(@OSVersion, "7", 0)) Then
		$os = "win7"
		#RequireAdmin
		If 0 = IsAdmin ( ) Then
			Msgbox (16, "Insufficient Privileges", "Administrative rights are required. Please contact IT Support.")
			Exit
			EndIf
EndIf
	
If (StringInStr(@OSVersion, "XP", 0)) Then
		$os = "xp"
EndIf
	$result = RunWait(@ComSpec & " /c " & "netsh int ip reset reset.log", @SW_HIDE)	
	$netshreset=StdoutRead($result)
	UpdateOutput($netshreset)
	doDebug("result of reset="& $netshreset)	
	MsgBox(4096,"Restart","A system reboot (on/off) is now required." & @CRLF & "You need to do this manually.")
EndIf
;***************************************************************************************END OF RESET INFO

;***************************************************************************************REMOVE EDUROAM
if $msg == $remove_wifi Then
	#RequireAdmin
	If 0 = IsAdmin ( ) Then
		Msgbox (16, "Insufficient Privileges", "Administrative rights are required. Please contact IT Support.")
		Exit
	EndIf
	
$hClientHandle = _Wlan_OpenHandle()
$Enum = _Wlan_EnumInterfaces($hClientHandle)
If (UBound($Enum)==0) Then
	doDebug(@error)
	MsgBox(16, "Error","No Wireless Adapter Found.")
	;Exit
	UpdateOutput("***Error - No wireless adapter found***")
	UpdateProgress(100);
	ExitLoop(1)
EndIf
$pGUID = $Enum[0][0]
;Check for profiles to remove
doDebug("Removing SSID" & $SSID)
	$profiles=_Wlan_GetProfileList($hClientHandle, $pGUID)
	$doremove=1
	If (UBound($profiles)==0) Then
		doDebug("No wireless profiles found")
		$doremove=0
	EndIf
If ($doremove) Then
	for $ssidremove IN $profiles
		if (StringCompare($ssidremove,$SSID,0)==0) Then
			RemoveSSID($hClientHandle, $pGUID, $ssidremove)
			UpdateOutput("Removed SSID:" & $ssidremove)
		EndIf
	Next
EndIf
;code to remove proxy settings also maybe?
EndIf
;***************************************************************************************REMOVE EDUROAM

;***************************************************************************************ADD PRINTER
if $msg == $print Then
	#RequireAdmin
	If 0 = IsAdmin ( ) Then
		Msgbox (16, "Insufficient Privileges", "Administrative rights are required. Please contact IT Support.")
		Exit
	EndIf
	
	dim $printer_model
	
If (StringInStr(@OSVersion, "VISTA", 0)) Then
	$printer_model = $printer_vista
EndIf
	
If (StringInStr(@OSVersion, "7", 0)) Then
		$printer_model = $printer_7
EndIf
	
If (StringInStr(@OSVersion, "XP", 0)) Then
		$printer_model = $printer_xp
EndIf
	
	$progress_meter =0;
	UpdateOutput("***Installing Printer***")
	UpdateProgress(20);
	if (StringLen($printer_message>1)) Then
			Msgbox (16, $printer_message_title,$printer_message)
	EndIf
	UpdateProgress(10);
	$cmd = "rundll32 printui.dll,PrintUIEntry /b """& $printer & """ /x /n ""Nevermind This"" /if /f %windir%\inf\ntprint.inf /r """ & $printer_port & """ /m """ & $printer_model & """ "
	UpdateProgress(30);
	$result = RunWait(@ComSpec & " /c " & $cmd)	
	$print_result=StdoutRead($result)
	UpdateOutput("***Printer Installed***")
	UpdateProgress(40);

;code to remove proxy settings also maybe?
EndIf
;***************************************************************************************ADD PRINTER

;***************************************************************************************ADD PRINTER
if $msg == $remove_printer Then
	#RequireAdmin
	If 0 = IsAdmin ( ) Then
		Msgbox (16, "Insufficient Privileges", "Administrative rights are required. Please contact IT Support.")
		Exit
	EndIf
	
	$progress_meter =0;
	UpdateOutput("***Removing Printer***")
	UpdateProgress(20);
	UpdateProgress(10);
	$cmd = "rundll32 printui.dll PrintUIEntry /dl /n """ & $printer & """"
	UpdateProgress(30);
	$result = RunWait(@ComSpec & " /c " & $cmd)	
	$print_result=StdoutRead($result)
	UpdateOutput("***Printer Removed***")
	UpdateProgress(40);

;code to remove proxy settings also maybe?
EndIf
;***************************************************************************************ADD PRINTER


 Wend
Wend
;-------------------------------------------------------------------------
;End of Program when loop ends
;-------------------------------------------------------------------------

exit