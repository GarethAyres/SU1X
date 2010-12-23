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

$VERSION = "V0.5"
$WZCSVCStarted = 0
$DEBUG=1
$progress_meter = 0
$SSID = IniRead("config.ini", "getprofile", "ssid", "eduroam")

; ---------------------------------------------------------------
;Functions

Func DoDebug($text)
	If $DEBUG == 1 Then	
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
GUICreate("Wireless Config Capture Tool", 200, 100)
GUISetBkColor (0xffff00) ;---------------------------------white
$progressbar1 = GUICtrlCreateProgress (5,5,190,20)
$exitb = GUICtrlCreateButton("Exit", 140, 50, 50)
;-------------------------------------------------------------------------
;TABS
$installb = GUICtrlCreateButton("Capture", 10, 50, 50)
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
	_ArrayDisplay($wifi_eduroam, "Details of profile captured")
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
GUICtrlSetData ($progressbar1,100)
doDebug("Complete. Exported to "&$filename)
MsgBox (16, "Complete","The profile "&$SSID&" has been exported to Profile.xml. Do not forget to rename it to exported.xml or change the config.ini")
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