;SU1X Installer script use with NSIS Installer
;http://su1x.swan.ac.uk
;http://nsis.sourceforge.net

; -------------------------------
; Start
  !define MUI_PRODUCT "Eduroam Tool"
  !define MUI_FILE "su1x-setup"
  !define MUI_VERSION ""
  !define MUI_BRANDINGTEXT "Eduroam @ Swansea"
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "images\jrs-header.bmp"
  CRCCheck On

;--------------------------------
;Include Modern UI
  !include "MUI2.nsh"

;--------------------------------
;General
  Name "Eduroam @ Swansea"
  OutFile "su1x-installer.exe"
  ShowInstDetails "nevershow"
  ShowUninstDetails "nevershow"
  !define MUI_ICON "swansea.ico"
  !define MUI_UNICON "swansea.ico"
  ;Request application privileges for Windows Vista
  RequestExecutionLevel admin

;--------------------------------
;Folder selection page
  InstallDir "$PROGRAMFILES\${MUI_PRODUCT}"

;--------------------------------
;Pages
;install
  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "license.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  ;uninstall
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

;--------------------------------
;Language
  !insertmacro MUI_LANGUAGE "English"


;--------------------------------
;Installer Sections
Section "Eduroam @ Swansea" install

;Add files
  SetOutPath "$INSTDIR"
  File "${MUI_FILE}.exe"
  File "config.ini"
  File "license.txt"
  File "CertMgr.Exe"
  File "su1x-auth-task.xml"
  File "su1x-setup.exe"
  File "swansea.ico"
  File "CamfordCA.der"
  CreateDirectory "profiles\"
  SetOutPath "$INSTDIR\profiles"
  File "profiles\Wired_Profile.xml"
  File "profiles\eduroam_WPA2_win7_0.xml"
  SetOutPath "$INSTDIR"
  CreateDirectory "images\"
  SetOutPath "$INSTDIR\images"
  File "images\lis-header.jpg"
  File "images\bubble-connected-xp.jpg"
  File "images\connected-7.jpg"
  File "images\connected-vista.jpg"
  File "images\jrs-header.jpg"
  File "images\bubble-vista.jpg"


;create desktop shortcut
  CreateShortCut "$DESKTOP\${MUI_PRODUCT}.lnk" "$INSTDIR\${MUI_FILE}.exe" "$INSTDIR\${MUI_ICON}" ""

;create start-menu items
  CreateDirectory "$SMPROGRAMS\${MUI_PRODUCT}"
  CreateShortCut "$SMPROGRAMS\${MUI_PRODUCT}\Uninstall.lnk" "$INSTDIR\Uninstall.exe" "" "$INSTDIR\Uninstall.exe" 0
  CreateShortCut "$SMPROGRAMS\${MUI_PRODUCT}\${MUI_PRODUCT}.lnk" "$INSTDIR\${MUI_FILE}.exe" "" "$INSTDIR\${MUI_FILE}.exe" 0

;write uninstall information to the registry
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PRODUCT}" "DisplayName" "${MUI_PRODUCT} (remove only)"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PRODUCT}" "UninstallString" "$INSTDIR\Uninstall.exe"

  WriteUninstaller "$INSTDIR\Uninstall.exe"

SectionEnd

;--------------------------------
;Installer Sections
;Section /o "Swansea Web Portal" web
;	Exec '"$INSTDIR\setHomePage.exe"'
;SectionEnd

;--------------------------------
;Uninstaller Section
Section "Uninstall"

;Delete Files
  RMDir /r "$INSTDIR\*.*"

;Remove the installation directory
  RMDir "$INSTDIR"

;Delete Start Menu Shortcuts
  Delete "$DESKTOP\${MUI_PRODUCT}.lnk"
  Delete "$SMPROGRAMS\${MUI_PRODUCT}\*.*"
  RmDir  "$SMPROGRAMS\${MUI_PRODUCT}"

;Delete Uninstaller And Unistall Registry Entries
  DeleteRegKey HKEY_LOCAL_MACHINE "SOFTWARE\${MUI_PRODUCT}"
  DeleteRegKey HKEY_LOCAL_MACHINE "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\${MUI_PRODUCT}"

SectionEnd


LangString DESC_Section1 ${LANG_ENGLISH} "The Eduroam SU1X tool."
;LangString DESC_Section2 ${LANG_ENGLISH} "Set your homepage to the Wireless Portal Page. This page has quick links to Swansea services."

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${install} $(DESC_Section1)
 ; !insertmacro MUI_DESCRIPTION_TEXT ${web} $(DESC_Section2)
!insertmacro MUI_FUNCTION_DESCRIPTION_END



;--------------------------------
;MessageBox Section


;Function that calls a messagebox when installation finished correctly
Function .onInstSuccess
  MessageBox MB_OK "You have successfully installed ${MUI_PRODUCT}. Starting tool..."
  Exec '"$INSTDIR\${MUI_FILE}.exe"'

FunctionEnd

  Function un.onInit
    MessageBox MB_YESNO "This will uninstall ${MUI_PRODUCT} and wireless networks. Continue?" IDYES NoAbort
      Abort ; causes uninstaller to quit.
    NoAbort:	Exec '"$INSTDIR\${MUI_FILE}.exe" remove'
  FunctionEnd

Function un.onUninstSuccess
  MessageBox MB_OK "You have successfully uninstalled ${MUI_PRODUCT}."
FunctionEnd


;eof