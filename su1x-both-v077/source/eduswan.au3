;-------------------------------------------------------------------------
; AutoIt script to automate the creation of Wireless Configuration for Eduroam
; 
; Written by Gareth Ayres of Swansea University (g.j.ayres@swansea.ac.uk)
; Based on script written by Jeff deVeer (http://www.autoitscript.com/forum/index.php?showtopic=56479&hl=_EnumWireless)
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
; Based on Wireless API interface by MattyD (http://www.autoitscript.com/forum/index.php?showtopic=91018&st=0)
; 
;
;-------------------------------------------------------------------------

#include "Native_Wifi_Func_V3_1b.au3"
#include <GUIConstants.au3>
#Include <GuiListView.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#Include <String.au3>

;-------------------------------------------------------------------------
; Global variables and stuff




$VERSION = "V0.76"

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
$wpa2check = IniRead("config.ini", "su1x", "wpa2check", "0")
$SSID = IniRead("config.ini", "getprofile", "ssid", "eduroam")
$priority = IniRead("config.ini", "getprofile", "priority", "0")
;---Image Files 
$BANNER = IniRead("config.ini", "images", "BANNER", "lis-header.jpg")
$SPLASHFILE = IniRead("config.ini", "images", "SLPASHFILE", "big.jpg")
$bubblexp = IniRead("config.ini", "images", "bubblexp", "bubble1.jpg")
$bubblevista = IniRead("config.ini", "images", "bubblevista", "bubble-vista.jpg")
;-----SSID
$SSID = IniRead("config.ini", "getprofile", "ssid", "eduroam")
;-----SSID to remove
$removessid = IniRead("config.ini", "remove", "removessid", "0")
$SSID1 = IniRead("config.ini", "remove", "ssid1", "eduroam")
$SSID2 = IniRead("config.ini", "remove", "ssid2", "eduroam-setup")
$SSID3 = IniRead("config.ini", "remove", "ssid3", "unrioam")


; ---------------------------------------------------------------
;Functions

Func DoDebug($text)
	If $DEBUG == 1 Then	
		BlockInput (0)
		SplashOff()
		MsgBox (16, "DEBUG", $text)
	EndIf
EndFunc

Func doHint()
	GUICreate("Configuration Successful", 400, 370, 50,20)
	GUISetState (@SW_SHOW)
	GUICtrlCreateLabel ( $SSID & " configuration was successful!" & @CRLF & @CRLF & "1) Watch for the bubble (As shown in the image below) to appear in the" & @CRLF & "System Tray near the clock. This could take up to a minute to appear.", 5, 5)
	if ($os == "xp") Then 
		GUICtrlCreatePic($bubblexp, 15, 80, 373, 135)
	EndIf
	if ($os == "vista") Then
		GUICtrlCreatePic($bubblevista, 15, 80, 374, 59)
	EndIf
	GUICtrlCreateLabel ( "2) Click the bubble when it appears" & @CRLF & @CRLF &"3) When prompted, enter your username (e.g. "&$username&") and" & @CRLF &"   password but Leave the ""Logon domain"" field blank."& @CRLF & @CRLF &"4) Click ""OK"" on the ""Enter Credentials"" window", 5, 240)
	$finish = GUICtrlCreateButton ( "Finish",  150, 330, 100, 25)
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
	If ($brwoser_reset) Then
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
			If ($brwoser_reset) Then
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
$myedit=GUICtrlCreateEdit ($startText& @CRLF, 10,80,270,110,$ES_MULTILINE+$ES_AUTOVSCROLL+$WS_VSCROLL)
;$myedit=GUICtrlCreateEdit ("Swansea Wireless Internet Service:"& @CRLF, 10,80,270,110,$ES_AUTOVSCROLL+$WS_VSCROLL+$ES_MULTILINE)
GUICtrlCreateLabel("Progress:", 1, 195,48,20)
$progressbar1 = GUICtrlCreateProgress (50,195,200,20)
$exitb = GUICtrlCreateButton("Exit", 230, 280, 50)
;-------------------------------------------------------------------------
;TABS
$tab=GUICtrlCreateTab (1,240,292,70)
$tab1=GUICtrlCreateTabitem ( "Options:") ;--------------------------Setup Tab
$installb = GUICtrlCreateButton("Install", 10, 280, 50)
;$unInstallb = GUICtrlCreateButton("Remove", 80, 280, 50)
;$backupb = GUICtrlCreateButton("Check", 160,280,50)
;-----------------------------------------------------------
GuiSetState(@SW_SHOW)
While 1
 While 1
  $msg = GUIGetMsg()
;-----------------------------------------------------------Exit Tool
  If $msg == $exitb Then 
  exit
    ExitLoop
EndIf
If $msg == $GUI_EVENT_CLOSE Then
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
	    	Else
		$os="xp"
		$sp=0
EndIf
		
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
	GUICtrlSetData ($myedit, "WZC Started!"& @CRLF)
	UpdateProgress(5);
Else
	DoDebug("WZC Running")
EndIf
;cert install
;if ($use_cert==1) Then
;	Run(@ComSpec & ' /c ' & $path & '\certmgr.exe /add ' & $certpath & '\cacert.pem.cer -s Root','',@SW_HIDE)
;	DoDebug("cert install complete")
;EndIf

UpdateOutput("Configuring Wireless Profile...")
UpdateProgress(10);
If (FileExists($xmlfile) == 0) Then
		MsgBox(16, "Error","Config file missing. Exiting...")
		Exit
EndIf	

If ($tryadditional==1) Then 
	If (FileExists($xmlfile2) == 0) Then
		MsgBox(16, "Error","Config file2 missing. Exiting...")
		Exit
	EndIf	
EndIf


$XMLProfile = FileRead($xmlfile)
if ($tryadditional) Then 
	$XMLProfile2 = FileRead($xmlfile2) 
EndIf
	
$hClientHandle = _Wlan_OpenHandle()
$Enum = _Wlan_EnumInterfaces($hClientHandle)
If (UBound($Enum)==0) Then
	doDebug(@error)
	MsgBox(16, "Error","No Wireless Adapter Found. Exiting...")
	Exit
EndIf
$pGUID = $Enum[0][0]
DoDebug($Enum[0][1])	
;Check for profiles to remove
if ($removessid>0) Then
	doDebug("Removing SSID")
	$profiles=_Wlan_GetProfileList($hClientHandle, $pGUID)
	for $ssidremove IN $profiles
		if (StringCompare($ssidremove,$SSID1)) Then
			RemoveSSID($hClientHandle, $pGUID, $ssidremove)
			UpdateOutput("Removed SSID:")
			UpdateOutput($ssidremove)
		EndIf
		if (StringCompare($ssidremove,$SSID2)) Then
			RemoveSSID($hClientHandle, $pGUID, $ssidremove)
			UpdateOutput("Removed SSID:")
			UpdateOutput($ssidremove)
		EndIf
		if (StringCompare($ssidremove,$SSID3)) Then
			RemoveSSID($hClientHandle, $pGUID, $ssidremove)
			UpdateOutput("Removed SSID:")
			UpdateOutput($ssidremove)			
		EndIf
	Next
EndIf

;SET THE PROFILE
UpdateProgress(10);
$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", 0, "wstr", $XMLProfile, "ptr", 0, "int", 1, "ptr", 0, "dword*", 0)
	if ($a_iCall[0]>0) Then
		UpdateOutput("Error: Return code invalid")
		if ($tryadditional==0) Then
			UpdateOutput("Error: Exiting application")
			Exit
		EndIf
	EndIf
;Check return code from setting profile and set additional profile
if ($tryadditional) Then
	DoDebug("Trying additional profile...")
	doDebug("setProfile return code (profile1) ="+$a_iCall[0])
	if ($a_iCall[0]==1169) Then
		$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", 0, "wstr", $XMLProfile2, "ptr", 0, "int", 1, "ptr", 0, "dword*", 0)
		doDebug("setProfile return code (profile2) ="+$a_iCall[0])
	EndIf
EndIf

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
;END OF XP CODE**********************************************************************************************************
Else
;VISTA CODE**************************************************************************************************************
	UpdateOutput("Detected Vista")
	#RequireAdmin
	If 0 = IsAdmin ( ) Then
		Msgbox (16, "Insufficient Privileges", "Administrative rights are required. Please contact IT Support.")
		Exit
	EndIf
	UpdateOutput("Configuring Wireless Profile...")
	UpdateProgress(10);
	
	

If ($tryadditional==1) Then 
	If (FileExists($xmlfile2) == 0) Then
		MsgBox(16, "Error","Config file2 missing. Exiting...")
		Exit
	EndIf	
EndIf


$XMLProfile = FileRead($xmlfile)
if ($tryadditional) Then 
	$XMLProfile2 = FileRead($xmlfile2) 
EndIf
		
$hClientHandle = _Wlan_OpenHandle()
$Enum = _Wlan_EnumInterfaces($hClientHandle)
If (UBound($Enum)==0) Then
	doDebug(@error)
	MsgBox(16, "Error","No Wireless Adapter Found. Exiting...")
	Exit
EndIf
$pGUID = $Enum[0][0]
DoDebug($Enum[0][1])	

;Check for profiles to remove
if ($removessid>0) Then
	doDebug("Removing SSID")
	$profiles=_Wlan_GetProfileList($hClientHandle, $pGUID)
	for $ssidremove IN $profiles
		if (StringCompare($ssidremove,$SSID1)==0) Then
			RemoveSSID($hClientHandle, $pGUID, $ssidremove)
			UpdateOutput("Removed SSID:")
			UpdateOutput($ssidremove)
		EndIf
		if (StringCompare($ssidremove,$SSID2)==0) Then
			RemoveSSID($hClientHandle, $pGUID, $ssidremove)
			UpdateOutput("Removed SSID:")
			UpdateOutput($ssidremove)
		EndIf
		if (StringCompare($ssidremove,$SSID3)==0) Then
			RemoveSSID($hClientHandle, $pGUID, $ssidremove)
			UpdateOutput("Removed SSID:")
			UpdateOutput($ssidremove)			
		EndIf
	Next
EndIf


;SET PROFILE
UpdateProgress(10);
$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", 0, "wstr", $XMLProfile, "ptr", 0, "int", 1, "ptr", 0, "dword*", 0)
	if ($a_iCall[0]>0) Then
		UpdateOutput("Error: Return code invalid")
		if ($tryadditional==0) Then
			UpdateOutput("Error: Exiting application")
			Exit
		EndIf
	EndIf
;Check return code from setting profile and set additional profile
if ($tryadditional) Then
	DoDebug("Trying additional profile...")
	doDebug("setProfile return code (profile1) ="+$a_iCall[0])
	if ($a_iCall[0]==1169) Then
		$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", 0, "wstr", $XMLProfile2, "ptr", 0, "int", 1, "ptr", 0, "dword*", 0)
		doDebug("setProfile return code (profile2) ="+$a_iCall[0])
	EndIf
EndIf

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

 Wend
Wend
;-------------------------------------------------------------------------
;End of Program when loop ends
;-------------------------------------------------------------------------

exit