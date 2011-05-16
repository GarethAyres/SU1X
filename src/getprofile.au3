#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=SETUP04.ICO
#AutoIt3Wrapper_outfile=getprofile.exe
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;-------------------------------------------------------------------------
; AutoIt script to automate the creation of Wireless Configuration for Eduroam
;
; Written by Gareth Ayres of Swansea University (g.j.ayres@swansea.ac.uk)
;
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
; Updated 29/01/2011
; added extra check on adapter detection in case of strange adapter descriptions or language issues.
;
; Updated 27/01/2011
; Fixed bug with broadcom wireless adapter selection
;
; Updated 10/12/10
; Added wired profile selection
; Fixed bug with debug
;
; Updated 17/06/09 - Gareth Ayres (g.j.ayres@swan.ac.uk)
; Based on Wireless API interface by MattyD (http://www.autoitscript.com/forum/index.php?showtopic=91018&st=0)
;
;
;-------------------------------------------------------------------------


#include "Native_Wifi_Func_V3_3b.au3"
#include <Date.au3>
#include <GUIConstants.au3>
#Include <GuiListView.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#Include <String.au3>

;-------------------------------------------------------------------------
; Global variables and stuff

;Check for config File
If (FileExists("config.ini") ==0) Then
	MsgBox(16,"Error","Config file not found.")
	Exit
EndIf

$VERSION = "V1.2"
$WZCSVCStarted = 0
$progress_meter = 0
$SSID = IniRead("config.ini", "getprofile", "ssid", "eduroam")
$wireless=IniRead("config.ini", "su1x", "wireless", "1")
$wireless=IniRead("config.ini", "su1x", "wireless", "1")
$DEBUG=IniRead("config.ini", "su1x", "DEBUG", "0")
$progressbar1 = ""

; ---------------------------------------------------------------
;Functions

Func DoDebug($text)
	If $DEBUG > 0 Then
		BlockInput (0)
		MsgBox (16, "DEBUG", $text)
	EndIf
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


;-------------------------------------------------------------------------
; Start of GUI code
GUICreate("Config Capture Tool", 350, 100)
GUISetBkColor (0xffff00) ;---------------------------------white
$progressbar1 = GUICtrlCreateProgress (5,5,340,20)
;----------------------------------------------------------Drop Down menu of Interfaces
	;Get the mac address and network name
	$ip = "localhost"
	$adapter ="";
	$objWMIService = ObjGet("winmgmts:{impersonationLevel = impersonate}!\\" & $ip & "\root\cimv2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapter", "WQL", 0x30)
	$networkcount=0
	$wireless=" [wired]"
        If IsObj($colItems) Then
            For $objItem In $colItems
				if (StringInStr($objItem.netconnectionid,"Local") Or StringInStr($objItem.description,"Wireless") Or StringInStr($objItem.description,"Wi") Or StringInStr($objItem.description,"802.11")) Then
				if (StringInStr($objItem.description,"Wireless") Or StringInStr($objItem.description,"Wi") Or StringInStr($objItem.description,"802.11")) Then $wireless=" [wireless]"
				$networkcount+=1
				$adapter&="Caption: " &$objItem.Caption & @CRLF
				$adapter&="Description: " &$objItem.Description& @CRLF
				$adapter&="Index: " &$objItem.Index & @CRLF
				$adapter&="NetID: " &$objItem.netconnectionid & @CRLF
				$adapter&="Name: " &$objItem.name & @CRLF
				$adapter&="Type: " &$objItem.AdapterType & @CRLF
				$adapter&="MAC Address: "& $objItem.MACAddress & @CRLF
				$adapter&="*********************"
				;DoDebug($adapter)
				;MsgBox(1,"2",$adapter)
				$adapter=""
				if $networkcount=1 Then
					$combo = GUICtrlCreateCombo($objItem.description & $wireless, 5, 30, 340, 20 ) ; create first item
				Else
					GUICtrlSetData(-1,$objItem.description & $wireless) ; add other item snd set a new default
				EndIf
				GUISetState()
			EndIf
			DoDebug("adapter = " & $objItem.netconnectionid & "and desc = " & $objItem.description)
			Next
        Else
            DoDebug("[setup]No Adapters found!")
			MsgBox(1,"Error","No Networking adapters found [language issue?], populating with all possible adapters")
			; list all adapters, including software adapters
				$objWMIService = ObjGet("winmgmts:{impersonationLevel = impersonate}!\\" & $ip & "\root\cimv2")
				$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapter", "WQL", 0x30)
			For $objItem In $colItems
				$networkcount+=1
				$adapter&="Caption: " &$objItem.Caption & @CRLF
				$adapter&="Description: " &$objItem.Description& @CRLF
				$adapter&="Index: " &$objItem.Index & @CRLF
				$adapter&="NetID: " &$objItem.netconnectionid & @CRLF
				$adapter&="Name: " &$objItem.name & @CRLF
				$adapter&="Type: " &$objItem.AdapterType & @CRLF
				$adapter&="MAC Address: "& $objItem.MACAddress & @CRLF
				$adapter&="*********************"
				;DoDebug($adapter)
				;MsgBox(1,"2",$adapter)
				$adapter=""
				if $networkcount=1 Then
					$combo = GUICtrlCreateCombo($objItem.description & $wireless, 5, 30, 340, 20 ) ; create first item
				Else
					GUICtrlSetData(-1,$objItem.description & $wireless) ; add other item snd set a new default
				EndIf
				GUISetState()
			DoDebug("adapter = " & $objItem.netconnectionid & "and desc = " & $objItem.description)
			Next
        EndIf
$exitb = GUICtrlCreateButton("Exit", 290, 60, 50)
;-------------------------------------------------------------------------
;TABS
$installb = GUICtrlCreateButton("Capture", 10, 60, 50)
;-----------------------------------------------------------
GuiSetState(@SW_SHOW)
While 1
 While 1
  $msg = GUIGetMsg()
;-----------------------------------------------------------Exit Tool
  If $msg = $exitb Then
  exit
    ExitLoop
EndIf
If $msg = $GUI_EVENT_CLOSE Then
	Exit
EndIf
;-----------------------------------------------------------
;If install button clicked
if $msg = $installb Then
;-------------------------------------------------------------------------
;select value from drop down menu
$interface = GUICtrlRead($combo)
doDebug("selected interface = " & $interface)
if (StringInStr($interface,"wireless")) Then
;---------------------------------------------------------------------------------------------------WIRELESS Capture
GUICtrlSetData ($progressbar1,0)
UpdateProgress(10);
$hClientHandle = _Wlan_OpenHandle()
if @error Then
		doDebug("No Wireless Interface Found. Exiting... Error Code = " & @error)
		Exit
EndIf
$Enum = _Wlan_EnumInterfaces($hClientHandle)
if @error Then doDebug("No Interface Found")
$pGUID = $Enum[0][0]
if @error Then doDebug("No Interface Found")
UpdateProgress(10);
$profile=_Wlan_GetProfileXML($hClientHandle, $pGUID, $SSID)
;$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanGetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $SSID,"ptr", 0, "wstr*", 0, "ptr*", 0, "ptr*", 0)
if (@error) Then
	doDebug("No "&$SSID&" profile exists! Exiting...")
	MsgBox(1,"Error","No "&$SSID&" profile exists! Exiting...")
	Exit
EndIf

$wifi_eduroam=_Wlan_GetProfile($hClientHandle, $pGUID,$SSID)
$findProfile = _ArrayFindAll($wifi_eduroam, $SSID)
if (@error) Then
	$findProfile=False
Else
	$findProfile=True
EndIf

if ($findProfile) Then
	if ($DEBUG>0) Then _ArrayDisplay($wifi_eduroam, "Details of profile captured")
	$wifi_eduroam_all=$wifi_eduroam[0] & "," & $wifi_eduroam[1] & "," & $wifi_eduroam[2] & "," & $wifi_eduroam[3] & "," & $wifi_eduroam[4] & "," & $wifi_eduroam[5] & "," & $wifi_eduroam[6] & "," & $wifi_eduroam[7]
	;DoDebug($wifi_eduroam_all)
EndIf

;ConsoleWrite("Call Error: " & @error & @LF)
;doDebug(_Wlan_GetErrorMessage($a_iCall[0]))
;ConsoleWrite($a_iCall[5] & @LF)
UpdateProgress(10);
If (FileExists("Profile.xml")) Then
	DoDebug("File exists, Backing up and then deleting...")
	If (FileExists("Profile-backup.xml")) Then FileDelete("Profile-backup.xml")
	FileMove("Profile.xml","Profile-backup.xml");
	FileDelete("Profile.xml")
EndIf
UpdateProgress(10);
$filename = "Profile.xml"
FileWrite($filename, $profile)
$wired_interface = $filename
Else
;---------------------------------------------------------------------------------------------------WIRED Capture
GUICtrlSetData ($progressbar1,0)
UpdateProgress(20);
$filename = "Profile.xml"
$wired_interface = ""
;get description from interface name
	$objWMIService = ObjGet("winmgmts:{impersonationLevel = impersonate}!\\" & $ip & "\root\cimv2")
	$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapter", "WQL", 0x30)
        If IsObj($colItems) Then
            For $objItem In $colItems
				UpdateProgress(10);
				if (StringInStr($interface,$objItem.description)) Then $wired_interface=$objItem.netconnectionid
			Next
        Else
            DoDebug("[setup]No Adapters found!")
			MsgBox(1,"Error","No Networking adapters found")
        EndIf
	;capture profile
	;backup exisiting
		UpdateProgress(20);
	If (FileExists($wired_interface&".xml")) Then
		DoDebug("File exists, Backing up and then deleting...")
		If (FileExists($wired_interface&"-backup.xml")) Then FileDelete($wired_interface&"-backup.xml")
		FileMove($wired_interface&".xml",$wired_interface&"-backup.xml");
		FileDelete($wired_interface&".xml")
	EndIf
	UpdateProgress(10);
	$filename = @ScriptDir
	$cmd = "netsh lan export profile folder=""" & $filename & """ interface=" & """" & $wired_interface & """"
	DoDebug("[setup]802.3 command="& $cmd)
	RunWait($cmd, "", @SW_HIDE)
	$wired_interface&=".xml"

EndIf
	GUICtrlSetData ($progressbar1,100)
	doDebug("Complete. Exported to "&$filename)
	MsgBox (16, "Complete","The profile has been exported to " & $wired_interface &". Do not forget to rename it to wired/wireless.xml and change the config.ini")
;-------------------------------------------------------------------------
; All done... report any errors or anything

;GUICtrlSetData ($myedit, "Installation Complete!"& @CRLF & "To connect to the SWIS you need to double click the 'uws-vpn' icon on your desktop." )
  ExitLoop
  EndIf

 Wend
Wend
;-------------------------------------------------------------------------
;End of Program when loop ends
;-------------------------------------------------------------------------

exit