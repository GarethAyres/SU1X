#include-once

Global	$a_iCall, $ErrorMessage, $WLANAPIDLL = DllOpen("wlanapi.dll"), $GLOBAL_hClientHandle, $GLOBAL_pGUID, $PTR_INFOLIST = 0, _
		$CallbackDisconnectCount = 0, $CallbackConnectCount = 0, $CallbackSSID, $ExtraGUIDs[1]

Global Const _ ;Enumerations
$DOT11_AUTH_ALGORITHM						= 0, _
	$DOT11_AUTH_ALGO_80211_OPEN					= 1, _
	$DOT11_AUTH_ALGO_80211_SHARED_KEY			= 2, _
	$DOT11_AUTH_ALGO_WPA						= 3, _
	$DOT11_AUTH_ALGO_WPA_PSK					= 4, _
	$DOT11_AUTH_ALGO_WPA_NONE					= 5, _
	$DOT11_AUTH_ALGO_RSNA						= 6, _
	$DOT11_AUTH_ALGO_RSNA_PSK					= 7, _
$DOT11_BSS_TYPE								= 1, _
	$dot11_BSS_type_infrastructure				= 1, _
	$dot11_BSS_type_independent					= 2, _
	$dot11_BSS_type_any							= 3, _
$DOT11_CIPHER_ALGORITHM						= 2, _
	$DOT11_CIPHER_ALGO_NONE						= 0x00, _
	$DOT11_CIPHER_ALGO_WEP40					= 0x01, _
	$DOT11_CIPHER_ALGO_TKIP						= 0x02, _
	$DOT11_CIPHER_ALGO_CCMP						= 0x04, _
	$DOT11_CIPHER_ALGO_WEP104					= 0x05, _
	$DOT11_CIPHER_ALGO_WEP						= 0x101, _
$WLAN_CONNECTION_MODE						= 3, _
	$wlan_connection_mode_profile				= 0, _
$WLAN_INTERFACE_STATE						= 4, _
	$wlan_interface_state_connected				= 1, _
	$wlan_interface_state_disconnected			= 4, _
	$wlan_interface_state_authenticating		= 7, _
$WLAN_INTF_OPCODE							= 5, _
	$wlan_intf_opcode_autoconf_enabled			= 1, _
	$wlan_intf_opcode_bss_type					= 5, _
	$wlan_intf_opcode_interface_state			= 6, _
	$wlan_intf_opcode_current_connection		= 7, _
$WLAN_OPCODE_VALUE_TYPE						= 6, _
	$wlan_opcode_value_type_query_only			= 0, _
	$wlan_opcode_value_type_set_by_group_policy	= 1, _
	$wlan_opcode_value_type_set_by_user			= 2, _
	$wlan_opcode_value_type_invalid				= 3

Global Const _ ;Struct Strings
$GUID_STRUCT						= "ulong GUIDFIRST; ushort GUIDSECOND; ushort GUIDTHIRD; ubyte GUIDFOURTH[8]", _
$DOT11_MAC_ADDRESS					= "byte DOT11MACADDRESS[6]", _
$DOT11_SSID							= "ulong uSSIDLength; char ucSSID[32]", _
$WLAN_ASSOCIATION_ATTRIBUTES		= $DOT11_SSID & "; dword DOT11BSSTYPE; " & $DOT11_MAC_ADDRESS & "; dword DOT11PHYTYPE; ulong uDot11PhyIndex; ulong WLANSIGNALQUALITY; ulong ulRxRate; ulong ulTxRate", _
$WLAN_AVAILABLE_NETWORK				= "wchar strProfileName[256]; " & $DOT11_SSID & "; dword DOT11BSSTYPE; ulong uNumberOfBssids; int bNetworkConnectable; dword WLANREASONCODE; ulong uNumberOfPhyTypes; dword DOT11PHYTYPE[8]; int bMorePhyTypes; ulong WLANSIGNALQUALITY; int bSecurityEnabled; dword DOT11AUTHALGORITHM; dword DOT11CIPHERALGORITHM; dword dwFlags; dword dwReserved", _
$WLAN_AVAILABLE_NETWORK_LIST 		= "dword dwNumberOfItems; dword dwIndex", _
$WLAN_SECURITY_ATTRIBUTES			= "int bSecurityEnabled; int bOneXEnabled; dword DOT11AUTHALGORITHM; dword DOT11CIPHERALGORITHM", _
$WLAN_CONNECTION_ATTRIBUTES			= "dword WLANINTERFACESTATE; dword WLANCONNECTIONMODE; wchar strProfileName[256]; " & $WLAN_ASSOCIATION_ATTRIBUTES & "; " & $WLAN_SECURITY_ATTRIBUTES, _
$WLAN_CONNECTION_NOTIFICATION_DATA	= "dword WLANCONNECTIONMODE; wchar strProfileName[256]; " & $DOT11_SSID & "; dword DOT11BSSTYPE; int bSecurityEnabled; dword WLANREASONCODE; wchar strProfileXml[4096]", _
$WLAN_CONNECTION_PARAMETERS			= "dword WLANCONNECTIONMODE; ptr strProfile; ptr PDOT11SSID; ptr PDOT11BSSIDLIST; dword DOT11BSSTYPE; dword dwFlags", _
$WLAN_INTERFACE_INFO				= $GUID_STRUCT & "; wchar strInterfaceDescription[256]; dword WLANINTERFACESTATE", _
$WLAN_INTERFACE_INFO_LIST			= "dword dwNumberOfItems; dword dwIndex", _
$WLAN_NOTIFICATION_DATA				= "dword NotificationSource; dword NotificationCode; " & $GUID_STRUCT & "; dword dwDataSize; ptr pData", _
$WLAN_PROFILE_INFO					= "wchar strProfileName[256]; dword dwFlags", _
$WLAN_PROFILE_INFO_LIST				= "dword dwNumberOfItems; dword dwIndex"

Global Const $Elements_Base_Start = 'WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1"+|name|SSIDConfig+|SSID+|name|-|-|' & _ ;XML Elements
'connectionType|connectionMode|MSM+|security+|authEncryption+|authentication|encryption|useOneX|-|sharedKey+|keyType|protected|keyMaterial|-|keyIndex|'
Global Const $Elements_OneX_Start = 'OneX xmlns="http://www.microsoft.com/networking/OneX/v1"+|EAPConfig+|' & _
'EapHostConfig xmlns="http://www.microsoft.com/provisioning/EapHostConfig"' & @CRLF & 'xmlns:eapCommon="http://www.microsoft.com/provisioning/EapCommon"' & @CRLF & _
'xmlns:baseEap="http://www.microsoft.com/provisioning/BaseEapMethodConfig"+|EapMethod+|eapCommon:Type|eapCommon:AuthorId|-|Config ' & _
'xmlns:baseEap="http://www.microsoft.com/provisioning/BaseEapConnectionPropertiesV1"' & @CRLF & _
'xmlns:msPeap="http://www.microsoft.com/provisioning/MsPeapConnectionPropertiesV1"' & @CRLF & _
'xmlns:eapTls="http://www.microsoft.com/provisioning/EapTlsConnectionPropertiesV1"' & @CRLF & _
'xmlns:msChapV2="http://www.microsoft.com/provisioning/MsChapV2ConnectionPropertiesV1"+|'
Global Const $Elements_PEAP_Start = 'baseEap:Eap+|baseEap:Type|msPeap:EapType+|msPeap:ServerValidation+|msPeap:DisableUserPromptForServerValidation|' & _
'msPeap:ServerNames|msPeap:TrustedRootCA|-|msPeap:FastReconnect|msPeap:InnerEapOptional|'
Global Const $Elements_TLS = 'baseEap:Eap+|baseEap:Type|eapTls:EapType+|eapTls:CredentialsSource+|eapTls:SmartCard|eapTls:CertificateStore+|' & _
'eapTls:SimpleCertSelection|-|-|eapTls:ServerValidation+|eapTls:DisableUserPromptForServerValidation|eapTls:ServerNames|eapTls:TrustedRootCA|' & _
'-|eapTls:DifferentUsername|-|-|'
Global Const $Elements_MSCHAP = 'baseEap:Eap+|baseEap:Type|msChapV2:EapType+|msChapV2:UseWinLogonCredentials|-|-|'
Global Const $Elements_PEAP_End = 'msPeap:EnableQuarantineChecks|msPeap:RequireCryptoBinding|-|-|'
Global Const $Elements_OneX_End = '-|ConfigBlob|-|-|-|'
Global Const $Elements_Base_End = '-|-|-'

Global Const $Elements_Creds_Base_Start = 'EapHostUserCredentials xmlns="http://www.microsoft.com/provisioning/EapHostUserCredentials"' & @CRLF & _
'xmlns:eapCommon="http://www.microsoft.com/provisioning/EapCommon"' & @CRLF & _
'xmlns:baseEap="http://www.microsoft.com/provisioning/BaseEapMethodUserCredentials"+|EapMethod+|eapCommon:Type|eapCommon:AuthorId|-|' & _
'Credentials xmlns:eapUser="http://www.microsoft.com/provisioning/EapUserPropertiesV1"' & @CRLF & _
'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' & @CRLF & _
'xmlns:baseEap="http://www.microsoft.com/provisioning/BaseEapUserPropertiesV1"' & @CRLF & _
'xmlns:msPeap="http://www.microsoft.com/provisioning/MsPeapUserPropertiesV1"' & @CRLF & _
'xmlns:eapTls="http://www.microsoft.com/provisioning/EapTlsUserPropertiesV1"' & @CRLF & _
'xmlns:msChapV2="http://www.microsoft.com/provisioning/MsChapV2UserPropertiesV1"+|'
Global Const $Elements_Creds_PEAP_Start = 'baseEap:Eap+|baseEap:Type|msPeap:EapType+|msPeap:RoutingIdentity|'
Global Const $Elements_Creds_TLS = 'baseEap:Eap+|baseEap:Type|eapTls:EapType+|eapTls:Username|eapTls:UserCert|-|-|'
Global Const $Elements_Creds_MSCHAP = 'baseEap:Eap+|baseEap:Type|msChapV2:EapType+|msChapV2:Username|msChapV2:Password|msChapV2:LogonDomain|-|-|'
Global Const $Elements_Creds_PEAP_End = '-|-|'
Global Const $Elements_Creds_Base_End = '-|-'


Func _Wlan_OpenHandle()
	Local $iVesion = 1
	If @OSBuild == "WIN_VISTA" Or @OSBuild == "WIN_2008" Or @OSBuild == "WIN_7" Then $iVesion = 2
	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanOpenHandle", "dword", $iVesion, "ptr", 0, "dword*", 0, "hwnd*", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
	Return $a_iCall[4]
EndFunc

Func _Wlan_CloseHandle($hClientHandle = $GLOBAL_hClientHandle)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanCloseHandle", "ptr", $hClientHandle, "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
EndFunc

Func _Wlan_EnumInterfaces($hClientHandle = $GLOBAL_hClientHandle)
    Local $pInfoList, $INFO_LIST, $NumberOfItems, $StructString, $index
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle

	If $PTR_INFOLIST <> 0 Then _Wlan_FreeMemory($PTR_INFOLIST)

    $a_iCall = DllCall($WLANAPIDLL, "dword", "WlanEnumInterfaces", "hwnd", $hClientHandle, "ptr", 0, "ptr*", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))

	$pInfoList = $a_iCall[3]
	$PTR_INFOLIST = $a_iCall[3]
	$INFO_LIST = DllStructCreate($WLAN_INTERFACE_INFO_LIST, $pInfoList)
	$NumberOfItems = DllStructGetData($INFO_LIST, "dwNumberOfItems")

	If Not $NumberOfItems Then Return SetError(2, 0, 0)

	$StructString = _Wlan_BuildListStructString($WLAN_INTERFACE_INFO_LIST, $WLAN_INTERFACE_INFO, $NumberOfItems)
	$INFO_LIST = DllStructCreate($StructString, $pInfoList)

	Dim $InterfaceArray[$NumberOfItems][3]

	For $i = 0 To $NumberOfItems - 1
		$InterfaceArray[$i][0] = $pInfoList + $i * 532 + 8
		$InterfaceArray[$i][1] = StringRegExpReplace(DllStructGetData($INFO_LIST, "strInterfaceDescription" & $index), " - Packet Scheduler Miniport", "")
		$InterfaceArray[$i][2] = DllStructGetData($INFO_LIST, "WLANINTERFACESTATE" & $index)
		If $InterfaceArray[$i][2] = $wlan_interface_state_connected Then $InterfaceArray[$i][2] = "Connected"
		If $InterfaceArray[$i][2] = $wlan_interface_state_disconnected Then $InterfaceArray[$i][2] = "Disconnected"
		If $InterfaceArray[$i][2] = $wlan_interface_state_authenticating Then $InterfaceArray[$i][2] = "Authenticating"
		$index += 1
	Next
   Return($InterfaceArray)
EndFunc

Func _Wlan_GenerateXMLUserData($UserData)
	Local $XMLElements_Start = $Elements_Creds_Base_Start, $XMLElements_End = $Elements_Creds_Base_End, _
	$XMLUserData = '<?xml version="1.0" ?>' & @CRLF, $XMLStack[1] = [-1], $XMLElements
	If UBound($UserData) < 4 Then Return SetError(3, 0, 0)

	If StringInStr($UserData[0], "PEAP") Then
		$XMLElements_Start &= $Elements_Creds_PEAP_Start
		$XMLElements_End = $Elements_Creds_PEAP_End & $XMLElements_End
	EndIf
	If StringInStr($UserData[0], "TLS") Then $XMLElements_Start &= $Elements_Creds_TLS
	If StringInStr($UserData[0], "MSCHAP") Then $XMLElements_Start &= $Elements_Creds_MSCHAP

	$XMLElements = StringSplit($XMLElements_Start & $XMLElements_End, "|")
	For $i = 1 To UBound($XMLElements) - 1
		If StringInStr($XMLElements[$i], @CRLF) Then
			For $j = 0 To $XMLStack[0]
				$XMLElements[$i] = StringReplace($XMLElements[$i], @CRLF, @CRLF & @TAB)
			Next
		EndIf
		If StringInStr($XMLElements[$i], "+") Then
			$XMLUserData &= "<" & StringReplace($XMLElements[$i], "+", "") & ">" & @CRLF
			Redim $XMLStack[Ubound($XMLStack) + 1]
			$XMLStack[Ubound($XMLStack) - 1] = StringReplace($XMLElements[$i], "+", "")
			$XMLStack[0] += 1
		ElseIf $XMLElements[$i] == "-" Then
			$XMLUserData &= "</" & StringRegExpReplace($XMLStack[Ubound($XMLStack) - 1], " [^>]{0,}", "") & ">" & @CRLF
			Redim $XMLStack[Ubound($XMLStack) - 1]
		Else
			$XMLUserData &= "<" & $XMLElements[$i] & "></" & StringRegExpReplace($XMLElements[$i], " [^>]{0,}", "") & ">" & @CRLF
		EndIf
		If $i < UBound($XMLElements) - 1 And $XMLElements[$i + 1] == "-" Then $XMLStack[0] -= 1
		For $j = 0 To $XMLStack[0]
			$XMLUserData &= "	"
		Next
	Next

	$XMLUserData = StringReplace($XMLUserData, "AuthorId><", "AuthorId>0<", 1)
	If StringInStr($UserData[0], "PEAP") Then
		$XMLUserData = StringReplace($XMLUserData, "Type><", "Type>25<", 2)
		$XMLUserData = StringReplace($XMLUserData, "RoutingIdentity><", "RoutingIdentity>" & $UserData[2] & "<", 1)
	EndIf
	If StringInStr($UserData[0], "TLS") Then
		$XMLUserData = StringReplace($XMLUserData, "Type><", "Type>13<")
		If $UserData[1] Then
			$XMLUserData = StringReplace($XMLUserData, "Username><", "Username>" & $UserData[1] & "\" & $UserData[2] & "<", 1)
		Else
			$XMLUserData = StringReplace($XMLUserData, "Username><", "Username>" & $UserData[2] & "<", 1)
		EndIf
		$XMLUserData = StringReplace($XMLUserData, "UserCert><", "UserCert>" & $UserData[3] & "<", 1)
	EndIf
	If StringInStr($UserData[0], "MSCHAP") Then
		$XMLUserData = StringReplace($XMLUserData, "Type><", "Type>26<", 1)
		$XMLUserData = StringReplace($XMLUserData, "Username><", "Username>" & $UserData[2] & "<", 1)
		$UserData[3] = StringReplace($UserData[3],"&","&#038;")
		$UserData[3] = StringReplace($UserData[3],"<","&#060;")
		$UserData[3] = StringReplace($UserData[3],">","&#062;")
		$XMLUserData = StringReplace($XMLUserData, "Password><", "Password>" & $UserData[3] & "<", 1)
		$XMLUserData = StringReplace($XMLUserData, "LogonDomain><", "LogonDomain>" & $UserData[1] & "<", 1)
	EndIf
	Return StringRegExpReplace($XMLUserData, "(\n[^>]{0,})><[^\r]{0,}\r", "\1 />")
EndFunc

Func _Wlan_SetProfileUserData($hClientHandle, $pGUID, $SSID, $UserData)
	Local $a_iCall, $Return
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	$Return = _Wlan_GenerateXMLUserData($UserData)
	If @error Then Return SetError(@error, @extended, $Return)
	$Return = _Wlan_SetProfileUserDataXML($hClientHandle, $pGUID, $SSID, $Return)
	Return SetError(@error, @extended, $Return)
EndFunc

Func _Wlan_SetProfileUserDataXML($hClientHandle, $pGUID, $SSID, $UserData)
	Local $a_iCall
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetProfileEapXmlUserData", "hwnd", $hClientHandle, "ptr", $pGUID, "wstr", $SSID, "dword", 0, "wstr", $UserData, "ptr", 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
EndFunc

Func _Wlan_QueryInterface($hClientHandle, $pGUID, $dwFlag)
	Local $pData, $Output, $AutoConfigState, $BssType, $DOT11BSSTYPE, $ConnectionAttributes
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID

	Switch $dwFlag
		Case 0
			$dwFlag = $wlan_intf_opcode_autoconf_enabled
		Case 1
			$dwFlag = $wlan_intf_opcode_bss_type
		Case 2
			$dwFlag = $wlan_intf_opcode_interface_state
		Case 3
			$dwFlag = $wlan_intf_opcode_current_connection
	EndSwitch

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanQueryInterface", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", $dwFlag, "ptr", 0, "dword*", 0, "ptr*", 0, "dword*", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))

	$pData = $a_iCall[6]

	If $dwFlag == $wlan_intf_opcode_autoconf_enabled Then
		$AutoConfigState = DllStructCreate("int bool", $pData)
		$Output = DllStructGetData($AutoConfigState, "bool")
		If $Output == 1 Then $Output = "Auto Config Enabled"
		If $Output == 0 Then $Output = "Auto Config Disabled"
	ElseIf $dwFlag == $wlan_intf_opcode_bss_type Then
		$BssType = DllStructCreate("dword DOT11BSSTYPE", $pData)
		$DOT11BSSTYPE = DllStructGetData($BssType, "DOT11BSSTYPE")
		If $DOT11BSSTYPE == $dot11_BSS_type_infrastructure	Then $Output = "Infrastructure Only"
		If $DOT11BSSTYPE == $dot11_BSS_type_independent		Then $Output = "Ad Hoc Only"
		If $DOT11BSSTYPE == $dot11_BSS_type_any				Then $Output = "Any Available Network"
	ElseIf $dwFlag == $wlan_intf_opcode_interface_state Then
		$InterfaceState = DllStructCreate("dword WLANINTERFACESTATE", $pData)
		$WLANINTERFACESTATE = DllStructGetData($InterfaceState, "WLANINTERFACESTATE")
		If $WLANINTERFACESTATE == $wlan_interface_state_connected		Then $Output = "Connected"
		If $WLANINTERFACESTATE == $wlan_interface_state_disconnected	Then $Output = "Disconnected"
		If $WLANINTERFACESTATE == $wlan_interface_state_authenticating	Then $Output = "Authenticating"
	ElseIf $dwFlag == $wlan_intf_opcode_Current_Connection Then
		$ConnectionAttributes = DllStructCreate($WLAN_CONNECTION_ATTRIBUTES, $pData)
		Dim $Output[8]
		$Output[0] = DllStructGetData($ConnectionAttributes, "WLANINTERFACESTATE")
			If $Output[0] == $wlan_interface_state_connected		Then $Output[0] = "Connected"
			If $Output[0] == $wlan_interface_state_disconnected		Then $Output[0] = "Disconnected"
			If $Output[0] == $wlan_interface_state_authenticating	Then $Output[0] = "Authenticating"
		$Output[1] = DllStructGetData($ConnectionAttributes, "strProfileName")
		$Output[2] = DllStructGetData($ConnectionAttributes, "DOT11MACADDRESS")
			$Output[2] = StringReplace($Output[2], "0x", "")
			$Output[2] = StringRegExpReplace($Output[2], "[[:xdigit:]]{2}", "\0-", 5)
		$Output[3] = DllStructGetData($ConnectionAttributes, "WLANSIGNALQUALITY")
		$Output[4] = DllStructGetData($ConnectionAttributes, "bSecurityEnabled")
			If $Output[4] == 1	Then $Output[4] = "Security Enabled"
			If $Output[4] == 0	Then $Output[4] = "Security Disabled"
		$Output[5] = DllStructGetData($ConnectionAttributes, "bOneXEnabled")
			If $Output[5] == 1	Then $Output[5] = "802.1x Enabled"
			If $Output[5] == 0	Then $Output[5] = "802.1x Disabled"
		$Output[6] = _Wlan_GetStrAuth(DllStructGetData($ConnectionAttributes, "DOT11AUTHALGORITHM"))
		$Output[7] = _Wlan_GetStrEncr(DllStructGetData($ConnectionAttributes, "DOT11CIPHERALGORITHM"))
		EndIf

		_Wlan_FreeMemory($pData)

	Return $Output
EndFunc

Func _Wlan_SetInterface($hClientHandle, $pGUID, $dwFlag, $strData)
	Local $Input, $Struct
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID

	If $dwFlag == 0 Then
		$dwFlag = $wlan_intf_opcode_autoconf_enabled
	ElseIf $dwFlag == 1 Then
		$dwFlag = $wlan_intf_opcode_bss_type
	EndIf

	$AutoConfigState = DllStructCreate("int bool")
	If $dwFlag == $wlan_intf_opcode_autoconf_enabled Then
		$Struct = DllStructCreate("int bool")
		If $strData = "Auto Config Enabled"	Then $Input = 1
		If $strData = "Auto Config Disabled"	Then $Input = 0
		DllStructSetData($Struct, "bool", $Input)
	ElseIf $dwFlag = $wlan_intf_opcode_bss_type Then
		$Struct = DllStructCreate("dword DOT11BSSTYPE")
		If $strData = "Infrastructure Only"	Then $Input = $dot11_BSS_type_infrastructure
		If $strData = "Ad Hoc Only"			Then $Input = $dot11_BSS_type_independent
		If $strData = "Any Available Network"	Then $Input = $dot11_BSS_type_any
		DllStructSetData($Struct, "DOT11BSSTYPE", $Input)
	EndIf

	$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanSetInterface", "hwnd", $hClientHandle, "ptr", $pGUID, "dword", $dwFlag, "dword", 4, "ptr", DllStructGetPtr($Struct), "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
EndFunc

;----Tools----;

Func _Wlan_StartSession()
	Local $Error, $Extended, $hClientHandle, $InterfaceArray
	$hClientHandle = _Wlan_OpenHandle()
	If @error Then Return SetError(@error, @extended, $hClientHandle)

	$InterfaceArray = _Wlan_EnumInterfaces($hClientHandle)
	If @error Then
		$Error = @error
		$Extended = @extended
		_Wlan_CloseHandle($hClientHandle)
		Return SetError($Error, $Extended, $InterfaceArray)
	EndIf

	_Wlan_SetGlobalConstants($hClientHandle, $InterfaceArray[0][0])

	SetExtended($hClientHandle)
	Return $InterfaceArray
EndFunc

Func _Wlan_EndSession($hClientHandle)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	_Wlan_CloseHandle($hClientHandle)
	SetError(@error, @extended, 0)
	DllClose($WLANAPIDLL)
EndFunc

Func _Wlan_SetGlobalConstants($hClientHandle, $pGUID)
	If $hClientHandle == -1 Or $hClientHandle == Default Then $hClientHandle = $GLOBAL_hClientHandle
	If $pGUID == -1 Or $pGUID == Default Then $pGUID = $GLOBAL_pGUID
	If $hClientHandle Then Global $GLOBAL_hClientHandle = $hClientHandle
	If $pGUID Then Global $GLOBAL_pGUID = $pGUID
EndFunc

Func _Wlan_StringTopGuid($strGUID)
	Local $aGUID
	$strGUID = StringRegExpReplace($strGUID, "[}{]", "")
	$aGUID = StringSplit($strGUID, "-")
	If UBound($aGUID) < 6 Then Return SetError(3, 0, 0)

	$ExtraGUIDs[UBound($ExtraGUIDs) - 1] = DllStructCreate($GUID_STRUCT)
	ReDim $ExtraGUIDs[UBound($ExtraGUIDs) + 1]
	DllStructSetData($ExtraGUIDs[UBound($ExtraGUIDs) - 2], "GUIDFIRST", "0x" & $aGUID[1])
	DllStructSetData($ExtraGUIDs[UBound($ExtraGUIDs) - 2], "GUIDSECOND", "0x" & $aGUID[2])
	DllStructSetData($ExtraGUIDs[UBound($ExtraGUIDs) - 2], "GUIDTHIRD", "0x" & $aGUID[3])
	DllStructSetData($ExtraGUIDs[UBound($ExtraGUIDs) - 2], "GUIDFOURTH", "0x" & $aGUID[4] & $aGUID[5])
	Return DllStructGetPtr($ExtraGUIDs[UBound($ExtraGUIDs) - 2])
EndFunc

Func _Wlan_pGuidToString($pGUID)
	Local $GUIDstruct2, $strGUID = "{"
	Dim $aGUID[5]
	$GUIDstruct2 = DllStructCreate($GUID_STRUCT, $pGUID)

	$aGUID[0] = Hex(DllStructGetData($GUIDstruct2, "GUIDFIRST"))
	$aGUID[1] = Hex(DllStructGetData($GUIDstruct2, "GUIDSECOND"), 4)
	$aGUID[2] = Hex(DllStructGetData($GUIDstruct2, "GUIDTHIRD"), 4)
	$aGUID[3] = Hex(StringTrimRight(DllStructGetData($GUIDstruct2, "GUIDFOURTH"), 12), 4)
	$aGUID[4] = StringTrimLeft(DllStructGetData($GUIDstruct2, "GUIDFOURTH"), 6)

	For $i = 0 To UBound($aGUID) - 2
		$strGUID &= $aGUID[$i] & "-"
	Next

	$strGUID &= $aGUID[4] & "}"

	Return $strGUID
EndFunc

;----Function Dependencies---;

Func _Wlan_ReasonCodeToString($ReasonCode)
	Local $BUFFER

	$BUFFER = DllStructCreate("wchar BUFFER[512]")
	DllCall($WLANAPIDLL, "dword", "WlanReasonCodeToString", "dword", $ReasonCode, "dword", 512, "ptr", DllStructGetPtr($BUFFER), "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	Return(DllStructGetData($BUFFER, "BUFFER"))
EndFunc

Func _Wlan_GetStrAuth($iCode)
	Switch $iCode
		Case $DOT11_AUTH_ALGO_80211_OPEN
			Return "Open"
		Case $DOT11_AUTH_ALGO_80211_SHARED_KEY
			Return "Shared Key"
		Case $DOT11_AUTH_ALGO_WPA
			Return "WPA"
		Case $DOT11_AUTH_ALGO_WPA_PSK
			Return "WPA-PSK"
		Case $DOT11_AUTH_ALGO_WPA_NONE
			Return "WPA-None"
		Case $DOT11_AUTH_ALGO_RSNA
			Return "WPA2"
		Case $DOT11_AUTH_ALGO_RSNA_PSK
			Return "WPA2-PSK"
		Case Else
			Return "Unknown Authentication"
	EndSwitch
EndFunc

Func _Wlan_GetStrEncr($iCode)
	Switch $iCode
		Case $DOT11_CIPHER_ALGO_NONE
			Return "Unencrypted"
		Case $DOT11_CIPHER_ALGO_WEP40
			Return "WEP (40-bit key)"
		Case $DOT11_CIPHER_ALGO_TKIP
			Return "TKIP"
		Case $DOT11_CIPHER_ALGO_CCMP
			Return "AES"
		Case $DOT11_CIPHER_ALGO_WEP104
			Return "WEP (104-bit key)"
		Case $DOT11_CIPHER_ALGO_WEP
			Return "WEP"
		Case Else
			Return "Unknown Encryption"
	EndSwitch
EndFunc

Func _Wlan_GetKeyType($sAuthentication, $sEncryption, $sMaterial)
	Local $KeyLength = StringLen($sMaterial)
	If $sEncryption = "WEP" Or $sAuthentication = "Shared Key" Then
		Switch $KeyLength
			Case 5
				If StringRegExp($sMaterial, "[[:ascii:]]{5}") Then Return "Network Key"
			Case 13
				If StringRegExp($sMaterial, "[[:ascii:]]{13}") Then Return "Network Key"
			Case 10
				If StringRegExp($sMaterial, "[[:xdigit:]]{10}") Then Return "Network Key"
			Case 26
				If StringRegExp($sMaterial, "[[:xdigit:]]{26}") Then Return "Network Key"
		EndSwitch
	ElseIf StringInStr($sAuthentication, "PSK") Then
		If $KeyLength >= 8 And $KeyLength <= 63 Then
			If StringRegExp($sMaterial, "([[:ascii:]]){8,63}") Then Return "Pass Phrase"
		ElseIf $KeyLength == 64 Then
			If StringRegExp($sMaterial, "[[:xdigit:]]{64}") Then Return "Network Key"
		EndIf
	EndIf
	Return "No Key Material"
EndFunc

Func _Wlan_BuildListStructString($Header, $Data, $NumberOfItems)
	Local $StructString, $StructElements, $StructElements2, $Buffer

	$StructString = $Header

	For $i = 0 To $NumberOfItems - 1
		$StructString = $StructString & "; " & $Data
	Next

	$StructElements = StringSplit($StructString, ";")
	$StructElements2 = $StructElements
	$StructString = ""
	Dim $ElementCount[UBound($StructElements)], $Buffer[UBound($StructElements)]

	For $i = 1 To Ubound($StructElements) -1
		For $j = $i To Ubound($StructElements2) -1
			If $i <> $j And $StructElements[$i] == $StructElements2[$j] Then
				If StringInStr($StructElements[$i], "[") <> 0 Then
					$Buffer[$j] = StringRegExpReplace($StructElements[$i], "[^[]{0,1024}", "", 1)
					$StructElements2[$j] = StringRegExpReplace($StructElements2[$j], "[[][[:digit:]]{0,9}[]]", "", 1)
				Else
					$Buffer[$j] = ""
				EndIf

				$ElementCount[$i] += 1

				$StructElements2[$j] &= $ElementCount[$i] & $Buffer[$j]
			EndIf
		Next
	Next

	For $i = 1 To Ubound($StructElements2) -1
		$StructString &= $StructElements2[$i]
		If $i <> Ubound($StructElements2) -1 Then $StructString &= ";"
	Next

	Return $StructString
EndFunc

Func _Wlan_GetErrorMessage($Error)
	Local $BUFFER = DllStructCreate("char BUFFER[4096]")
	DllCall("Kernel32.dll", "int", "FormatMessageA", "int", 0x1000, "hwnd", 0, "int", $Error, "int", 0, "ptr", DllStructGetPtr($BUFFER), "int", 4096, "ptr", 0)
	If @error Then Return SetError(4, 0, 0)
	Return DllStructGetData($BUFFER, "BUFFER")
EndFunc

Func _Wlan_FreeMemory($ptr)
	DllCall($WLANAPIDLL, "dword", "WlanFreeMemory", "ptr", $ptr)
	If @error Then Return SetError(4, 0, 0)
EndFunc

Func _Wlan_RegisterNotification($hClientHandle, $Flag)
	Local $WLAN_NOTIFICATION_CALLBACK
	If $Flag = 1 Then
		$WLAN_NOTIFICATION_CALLBACK = DllCallbackRegister("_WLAN_NOTIFICATION_CALLBACK", "none", "ptr;ptr")
		$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanRegisterNotification", "hwnd", $hClientHandle, "dword", 0X08, "int", 0, "ptr", DllCallbackGetPtr($WLAN_NOTIFICATION_CALLBACK), "ptr", 0, "ptr", 0, "ptr*", 0)
	Else
		$a_iCall = DllCall($WLANAPIDLL, "dword", "WlanRegisterNotification", "hwnd", $hClientHandle, "dword", 0, "int", 0, "ptr", 0, "ptr", 0, "ptr", 0, "ptr*", 0)
	EndIf
	If @error Then Return SetError(4, 0, 0)
	If $a_iCall[0] Then Return SetError(1, $a_iCall[0], _Wlan_GetErrorMessage($a_iCall[0]))
EndFunc

Func _WLAN_NOTIFICATION_CALLBACK($PTR1, $PTR2)
	Local $NOTIFICATION, $pData, $Data, $iCode
	$CallbackSSID = ""
	$NOTIFICATION = DllStructCreate($WLAN_NOTIFICATION_DATA, $PTR1)
	$pData = DllStructGetData($NOTIFICATION, "pData")
	$Data = DllStructCreate($WLAN_CONNECTION_NOTIFICATION_DATA, $pData)
	$iCode = DllStructGetData($NOTIFICATION, "NotificationCode")

	If $GLOBAL_pGUID Then
		If _Wlan_pGUIDToString($PTR1 + 8) = _Wlan_pGUIDToString($GLOBAL_pGUID) Then
			If $iCode == 10 Then $CallbackConnectCount += 1
			If $iCode == 21 Then $CallbackDisconnectCount += 1
		EndIf
	Else
		If $iCode == 10 Then $CallbackConnectCount += 1
		If $iCode == 21 Then $CallbackDisconnectCount += 1
	EndIf
	If $CallbackConnectCount = 3 Then $CallbackSSID = DllStructGetData($Data, "ucSSID")
EndFunc
