;SU1X Installer script use with NSIS Installer
;http://su1x.swan.ac.uk
;http://nsis.sourceforge.net

; -------------------------------
; Start
  !define MUI_PRODUCT "SU1X"
  !define MUI_FILE "su1x-setup"
  !define MUI_VERSION ""
  !define MUI_BRANDINGTEXT "SIG Beta Ver. 1.0"
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\images\jrs-header.jpg" ; optional
  CRCCheck On

;--------------------------------
;Include Modern UI
  !include "MUI2.nsh"

;--------------------------------
;General
  Name "SU1X"
  OutFile "su1x-installer.exe"
  ShowInstDetails "nevershow"
  ShowUninstDetails "nevershow"
  !define MUI_ICON "swansea.ico"
  !define MUI_UNICON "swansea.ico"
  ;Request application privileges for Windows Vista
  RequestExecutionLevel user

;--------------------------------
;Folder selection page
  InstallDir "$PROGRAMFILES\${MUI_PRODUCT}"


;--------------------------------
;Pages
;install
  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "${NSISDIR}\license.txt"
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


Section "SU1X custom" su1xFunc

  ;Store installation folder
  ;WriteRegStr HKCU "Software\Modern UI Test" "" $INSTDIR

SectionEnd

  LangString DESC_su1x ${LANG_ENGLISH} "Welcome..."

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${su1xFunc} $(DESC_su1x)
  !insertmacro MUI_FUNCTION_DESCRIPTION_END


;--------------------------------
;Installer Sections
Section "install" Installation info

;Add files
  SetOutPath "$INSTDIR"

  File "${MUI_FILE}.exe"
  File "config.ini"
  File "license.txt"
  SetOutPath "$INSTDIR\images"
  file "images\lis-header.jpg"

;create desktop shortcut
  CreateShortCut "$DESKTOP\${MUI_PRODUCT}.lnk" "$INSTDIR\${MUI_FILE}.exe" ""

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


;--------------------------------
;MessageBox Section


;Function that calls a messagebox when installation finished correctly
Function .onInstSuccess
  MessageBox MB_OK "You have successfully installed ${MUI_PRODUCT}. Use the desktop icon to start the program."
FunctionEnd


Function un.onUninstSuccess
  MessageBox MB_OK "You have successfully uninstalled ${MUI_PRODUCT}."
FunctionEnd


;eof