#region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=SETUP07.ICO
#AutoIt3Wrapper_Outfile=setEAPCred.exe
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_UseUpx=n
#AutoIt3Wrapper_Res_Comment=Swansea Eduroam Tool
#AutoIt3Wrapper_Res_Description=Swansea Eduroam Tool
#AutoIt3Wrapper_Res_Fileversion=0.0.0.10
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=p
#AutoIt3Wrapper_Res_ProductVersion=0.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Gareth Ayres - Swansea University
#AutoIt3Wrapper_AU3Check_Stop_OnWarning=y
#AutoIt3Wrapper_Run_Tidy=y
#endregion ;**** Directives created by AutoIt3Wrapper_GUI ****

;-------------------------------------------------------------------------
; AutoIt script to automate setEAPCredentials for EduroamCAT
;
; Written by Gareth Ayres of Swansea University (g.j.ayres@swansea.ac.uk)
;***************************************************************************
;* This project is distributed under the GEANT Standard Open Source Software Outward Licence.
;*
;***************************************************************************
;
;
; Gareth Ayres (g.j.ayres@swan.ac.uk)
; To save time, makes use of wirelss API interface by MattyD (http://www.autoitscript.com/forum/index.php?showtopic=91018&st=0)
;


#include "../src/Native_Wifi_Func_V3_3b.au3"
#include <String.au3>


;-------------------------------------------------------------------------
; Global variables and stuff
$WZCSVCStarted = 0

;------------------------------------------------------------------------------------------------------------
;---------Variable Initialisation
;------------------------------------------------------------------------------------------------------------
Dim $username
Dim $password
Dim $thessid
Dim $eaptype
Dim $os
Dim $WZCSVCStarted
Dim $num_arguments = 0
Dim $DEBUG = 0
Dim $debugResult

Global $hClientHandle = 0
Global $pGUID = 0
Global $Enum

;------------------------------------------------------------------------------------------------
;Set up Debugging
;------------------------------------------------------------------------------------------------
If ($DEBUG > 0) Then
	$filename = "su1x-dump-" & @YEAR & @MON & @MDAY & @HOUR & @MIN & @SEC & ".txt"
	$file = FileOpen($filename, 1)
	; Check if file opened for reading OK
	If ($file == -1) Then
		;MsgBox(16, "DEBUG", "Unable to open debug dump file.:" & $file)
	EndIf
Else
	FileClose($file)
EndIf
;------------------------------------------------------------------------------------------------

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

;Function to check a service is running
Func CheckService($ServiceName)
	If IsServiceRunning($ServiceName) == 0 Then
		DoDebug("[CheckService]" & $ServiceName & " not running")
		Run("sc config " & $ServiceName & " start= auto", "", @SW_HIDE)
		RunWait("net start " & $ServiceName, "", @SW_HIDE)
		_Wlan_SetInterface($hClientHandle, $pGUID, 0, "Auto Config Enabled")
		If IsServiceRunning($ServiceName) == 0 Then
			DoDebug("[CheckService]" & $ServiceName & " start failure")
			Return 0
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
			DoDebug("[WLANConnect]WLANAPI DLL Open Error:" & @extended & $interfaceWifi)
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
		DoDebug("[WLANClose]WLANAPI DLL Close Error:")
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
			DoDebug("[WLANCheck]WLANAPI DLL Open Error:")
			Return 0
		ElseIf (UBound($Enum) == 0) Then
			DoDebug("[WLANCheck]WLAN Adapter not found")
			Return 0
		Else
			Return 1
		EndIf
	Else
		Return 1
	EndIf
	Return 1
EndFunc   ;==>WlanAPICheck


;Checks if a specified service is running.
;Returns 1 if running.  Otherwise returns 0.
;sc query appears to work in vist and xp
Func IsServiceRunning($ServiceName)
	Dim $pid = Run('sc query ' & $ServiceName, '', @SW_HIDE, 2)
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

;sets the priority of a ssid profile
Func SetPriority($hClientHandle, $pGUID, $thessid, $priority)
	Dim $setpriority = DllCall($WLANAPIDLL, "dword", "WlanSetProfilePosition", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $thessid, "dword", $priority, "ptr", 0)
	DoDebug("[SetPriority] ssid=" & $thessid & " and priority=" & $priority)
	If ($setpriority[0] > 0) Then
		If $setpriority[0] Then DoDebug("[SetWirelessPriority]Error Msg=" & _Wlan_GetErrorMessage($setpriority[0]))
		Return 0
	EndIf
	DoDebug("[SetPriority] Success ssid=" & $thessid & " and priority=" & $priority)
	Return 1
EndFunc   ;==>SetPriority

;-------------------------------------------------------------------------
; Does all the prodding required to set the proxy settings in IE and FireFox

Func SetEAPCred($thessid, $username, $password, $eaptype)
	;*****************************SET  profile EAP credentials
	Local $credentials[4]
	$credentials[0] = $eaptype ; EAP method
	$credentials[1] = "" ;domain
	$credentials[2] = $username ; username
	$credentials[3] = $password ; password
	DoDebug("[EAPCred]_Wlan_SetProfileUserData:" & $hClientHandle & "|" & $pGUID & "|" & $thessid & "|" & $credentials[2])
	$setCredentials = _Wlan_SetProfileUserData($hClientHandle, $pGUID, $thessid, $credentials)
	If @error Then
		DoDebug("[EAPCred]Set credential error:" & @ScriptLineNumber & @error & @extended & $setCredentials & $thessid)
		Return 0
	EndIf

	Return 1
EndFunc   ;==>SetEAPCred

;------------------------------------------------------------------------------------------------------------
;---------Startup code
;------------------------------------------------------------------------------------------------------------
DoDebug("***Starting SU1X***")
;CheckAdmin()
$num_arguments = $CmdLine[0] ;is number of parameters
If ($num_arguments > 2 And $num_arguments < 5) Then
	$username = $CmdLine[1]
	$password = $CmdLine[2]
	$thessid = $CmdLine[3]
	If ($num_arguments == 4) Then
		$eaptype = $CmdLine[4]
	Else
		$eaptype = "PEAP-MSCHAP"
	EndIf

	DoDebug("Got arguments:" & $username & "|" & $password & "|" & $thessid)
Else
	DoDebug("Wrong numnber of argumented")
EndIf


;-----------------------------------------------------------
;Set EAP Credentials
;-----------------------------------------------------------

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
		DoDebug("wifi API problem")
		Exit (2)
	EndIf
EndIf

Dim $success = 0

If (StringLen($thessid) > 0) Then
	If (SetEAPCred($thessid, $username, $password, $eaptype)) Then
		DoDebug("[EAPCred]Success for " & $thessid)
		$success = 0
	Else
		DoDebug("[EAPCred]Failure for " & $thessid)
		$success = 4
	EndIf
Else
	DoDebug("The ssid argument is missing, so doing nothing...")
	Exit (1)
EndIf


WlanAPIClose()
DoDebug("***Exiting SU1X***")
Exit ($success)
;-------------------------------------------------------------------------
;End of Program
;-------------------------------------------------------------------------

