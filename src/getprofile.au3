#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=..\..\SETUP04.ICO
#AutoIt3Wrapper_outfile=..\bin\getprofile.exe
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=SU1X wireless and wired profile capture tool
#AutoIt3Wrapper_Res_Description=SU1X wireless and wired profile capture tool
#AutoIt3Wrapper_Res_Fileversion=2.0.1.0
#AutoIt3Wrapper_Res_LegalCopyright=Gareth Ayres, Swansea University
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#AutoIt3Wrapper_Run_Tidy=y
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****
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
; Updated 22/06/2011
; Changed most of the script to be more efficient
; All Wireless profiles are now grabbed from selected device and saved to a profile based filename
; Made use of code from Alexander van der Mey and Alexander Clouter
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
#include <GuiListView.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <String.au3>

;-------------------------------------------------------------------------
; Global variables and stuff

;Check for config File
If (FileExists("config.ini") == 0) Then
	MsgBox(16, "Error", "Config file not found.")
	Exit
EndIf

$WZCSVCStarted = 0
$progress_meter = 0
$SSID = IniRead("config.ini", "getprofile", "ssid", "eduroam")
$wireless = IniRead("config.ini", "su1x", "wireless", "1")
$wireless = IniRead("config.ini", "su1x", "wireless", "1")
$DEBUG = IniRead("config.ini", "su1x", "DEBUG", "0")
$progressbar1 = ""

; ---------------------------------------------------------------
;Functions

Func DoDebug($text)
	If $DEBUG > 0 Then
		BlockInput(0)
		MsgBox(16, "DEBUG", $text)
	EndIf
EndFunc   ;==>DoDebug

;Checks if a specified service is running.
;Returns 1 if running.  Otherwise returns 0.
;sc query appears to work in vist and xp
Func IsServiceRunning($ServiceName)
	$pid = Run('sc query ' & $ServiceName, '', @SW_HIDE, 2)
	Global $data
	Do
		$data &= StdoutRead($pid)
	Until @error
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

;return OS string for use in XML file
Func GetOSVersion()
	Select
		Case StringInStr(@OSVersion, "VISTA", 0)
			Return "vista"
		Case StringInStr(@OSVersion, "7", 0)
			Return "win7"
		Case StringInStr(@OSVersion, "XP", 0)
			If @OSServicePack == "Service Pack 2" Then
				Return "xpsp2"
			Else
				Return "xp"
			EndIf
	EndSelect
EndFunc   ;==>GetOSVersion


;function to save a profile to a file
Func SaveXMLProfile($name, $profile, $priority, $authentication)
	$filename = @ScriptDir & "\profiles\" & $name & "_" & $authentication & "_" & GetOSVersion() & "_" & $priority & ".xml"
	If (FileExists($filename)) Then
		$backup_filename = $filename & ".backup"
		DoDebug("File exists, Backing up and then deleting...")
		If (FileExists($backup_filename)) Then FileDelete($backup_filename)
		FileMove($filename, $backup_filename)
		FileDelete($filename)
	EndIf
	FileWrite($filename, $profile)
	Return $filename
EndFunc   ;==>SaveXMLProfile

;function to save the wired profile to a file
Func SaveWiredXMLProfile($interface)
	$filename = @ScriptDir & "\profiles\" & $interface & ".xml"
	If (FileExists($filename)) Then
		$backup_filename = $filename & ".backup"
		DoDebug("File exists, Backing up and then deleting...")
		If (FileExists($backup_filename)) Then FileDelete($backup_filename)
		FileMove($filename, $backup_filename)
		FileDelete($filename)
	EndIf
	$cmd = "netsh lan export profile folder=""" & @ScriptDir & """ interface=" & """" & $interface & """"
	DoDebug("[setup]802.3 command=" & $cmd)
	RunWait($cmd, "", @SW_HIDE)
	Return $filename
EndFunc   ;==>SaveWiredXMLProfile

;-------------------------------------------------------------------------
; Start of GUI code
GUICreate("Config Capture Tool", 350, 100)
GUISetBkColor(0xffff00) ;---------------------------------white
$progressbar1 = GUICtrlCreateProgress(5, 5, 340, 20)
;----------------------------------------------------------Drop Down menu of Interfaces
;Get the mac address and network name
$ip = "localhost"
$adapter = "";
; borrowed some wisdom from
; http://weblogs.sqlteam.com/mladenp/archive/2010/11/04/find-only-physical-network-adapters-with-wmi-win32_networkadapter-class.aspx
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
Dim $interfaceList
If IsObj($colItems) Then
	For $objItem In $colItems
		Local $adapter = ""
		If IsArray($interfaceList) Then
			ReDim $interfaceList[UBound($interfaceList) + 1]
		Else
			Dim $interfaceList[1]
		EndIf
		$adapter &= "Caption: " & $objItem.Caption & @CRLF
		$adapter &= "Description: " & $objItem.Description & @CRLF
		$adapter &= "Index: " & $objItem.Index & @CRLF
		$adapter &= "NetID: " & $objItem.NetConnectionID & @CRLF
		$adapter &= "Name: " & $objItem.Name & @CRLF
		$adapter &= "Type: " & $objItem.AdapterType & @CRLF
		$adapter &= "MAC Address: " & $objItem.MACAddress & @CRLF
		;DoDebug($adapter)
		DoDebug("adapter = " & $objItem.NetConnectionID & "and desc = " & $objItem.Description)
		if (StringInStr($objItem.description, "Wireless") Or StringInStr($objItem.description, "Wi") Or StringInStr($objItem.description, "802.11")) Then
			$wireless = " [wireless]"
		Else
			$wireless = " [wired]"
		EndIf

		$interfaceList[UBound($interfaceList) - 1] = $objItem.Description & $wireless
	Next
Else
	MsgBox(1, "Error", "No Suitable Networking adapters found")
	Exit
EndIf

If Not (IsArray($interfaceList)) Then
	MsgBox(1, "Error", "No Suitable Networking adapters found")
	Exit
EndIf

$combo = GUICtrlCreateCombo($interfaceList[0], 5, 30, 340, 20)
For $i = 1 To UBound($interfaceList) - 1;
	GUICtrlSetData(-1, $interfaceList[$i])
Next


$exitb = GUICtrlCreateButton("Exit", 290, 60, 50)
;-------------------------------------------------------------------------
;TABS
$installb = GUICtrlCreateButton("Capture", 10, 60, 50)
;-----------------------------------------------------------
GUISetState(@SW_SHOW)
While 1
	$msg = GUIGetMsg()
	;-----------------------------------------------------------Exit Tool
	If $msg = $exitb Then
		Exit
		ExitLoop
	EndIf
	If $msg = $GUI_EVENT_CLOSE Then
		Exit
	EndIf
	;-----------------------------------------------------------
	;If install button clicked
	If $msg = $installb Then
		;-------------------------------------------------------------------------
		;select value from drop down menu
		$interface = GUICtrlRead($combo)
		DoDebug("selected interface = " & $interface)
		Dim $output = ""
		if (StringInStr($interface, "wireless")) Then
			;---------------------------------------------------------------------------------------------------WIRELESS Capture
			GUICtrlSetData($progressbar1, 0)
			UpdateProgress(10);
			$hClientHandle = _Wlan_OpenHandle()
			If @error Then
				DoDebug("No Wireless Interface Found. Exiting... Error Code = " & @error)
				Exit
			EndIf
			$Enum = _Wlan_EnumInterfaces($hClientHandle)
			If @error Then DoDebug("No Interface Found")
			If (UBound($Enum) == 0) Then
				DoDebug("[setup]Enumeration of wlan adapter" & @error)
				MsgBox(16, "Error", "No Wireless Adapter Found.")
				Exit
			EndIf
			;get profiles from all wireless adapters
			For $alladapters = 0 To UBound($Enum, 1) - 1
				$pGUID = $Enum[$alladapters][0]
				;if adapter is the one selected by the user
				DoDebug($interface & " and " & $Enum[$alladapters][1])
				if (StringInStr($interface, $Enum[$alladapters][1])) Then
					DoDebug("Adapter=" & $Enum[$alladapters][1])
					$profiles = _Wlan_GetProfileList($hClientHandle, $pGUID)
					If (UBound($profiles) == 0) Then
						DoDebug("[setup]No wireless profiles found for adapter")
					Else
						DoDebug("Found " & UBound($profiles) & " profiles")
						For $numprofiles = 0 To UBound($profiles, 1) - 1
							UpdateProgress(10);
							$profile = _Wlan_GetProfileXML($hClientHandle, $pGUID, $profiles[$numprofiles])
							Dim $profile_type[11]
							$profile_type = _Wlan_GetProfile($hClientHandle, $pGUID, $profiles[$numprofiles])
							Dim $authentication = $profile_type[3]
							;$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanGetProfile", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $SSID,"ptr", 0, "wstr*", 0, "ptr*", 0, "ptr*", 0)
							if (@error) Then
								DoDebug("No profile exists!")
								DoDebug("Adapter= " & $Enum[$alladapters][1])
								DoDebug("wlan_getProfileXML result = " & $profile)
								MsgBox(1, "Error", "No profile exists! Exiting...")
								ExitLoop
							EndIf
							if ($DEBUG > 0) Then _ArrayDisplay($profile, "Details of profile captured")
							UpdateProgress(10)
							$output &= SaveXMLProfile($profiles[$numprofiles], $profile, $numprofiles, $authentication) & " "
							UpdateProgress(10)
						Next
					EndIf
				EndIf
			Next
		Else
			;---------------------------------------------------------------------------------------------------WIRED Capture
			GUICtrlSetData($progressbar1, 0)
			UpdateProgress(20);
			$wired_interface = ""
			;get description from interface name
			$objWMIService = ObjGet("winmgmts:{impersonationLevel = impersonate}!\\" & $ip & "\root\cimv2")
			$colItems = $objWMIService.ExecQuery("SELECT * FROM Win32_NetworkAdapter", "WQL", 0x30)
			If IsObj($colItems) Then
				For $objItem In $colItems
					UpdateProgress(10);
					if (StringInStr($interface, $objItem.description)) Then
						$wired_interface = $objItem.netconnectionid
						UpdateProgress(20);
						$output &= SaveWiredXMLProfile($wired_interface) & " "
						UpdateProgress(20);
					EndIf
				Next
			Else
				DoDebug("[setup]No Adapters found!")
				MsgBox(1, "Error", "No Networking adapters found")
			EndIf
		EndIf
		GUICtrlSetData($progressbar1, 100)
		DoDebug("Complete. Exported to " & $output)
		MsgBox(16, "Complete", "Profiles exported to: " & $output & ". Do not forget to rename the profiles and change the config.ini")
		;-------------------------------------------------------------------------
		; All done... report any errors or anything
	EndIf

WEnd
;-------------------------------------------------------------------------
;End of Program when loop ends
;-------------------------------------------------------------------------

Exit