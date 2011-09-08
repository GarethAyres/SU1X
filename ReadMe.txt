SU1X Readme file by Gareth Ayres.
http://su1x.swan.ac.uk

Works with: XP SP3, VISTA (All SPs) and 7.

Features now include:
-Intercept wireless reauths, reloading tool
-Support features including web API for checks and problem reporting
-Fallback SSID contorl for use with web checks
-Fixed bug with PCA compatabillity warning in win7. see src/manifest.txt
-Wired 802.1x capture and install
-NSIS installer for easy distribution
-More debugging
-Automation of configuration of a PEAP wireless connection on XP(SP3),Vita and Win 7
-Can set EAP credentials without additional user interaction (avoids tooltip bubble)
-Installation of a certificate (silent)
-Checks for WPA2 compatibility and falls back to a WPA profile
-Third party supplicant check
-SSID removal and priority setting
-Support tab: (checks: adapter, wzc service, profile presence, IP)
-Outputs check results to user with tooltip and/or to file
-Printer tab to add/remove networked printer


There are two exe's that make up this package:

1. su1x-setup.exe
This exe sets up Windows XP, Vista and Win7 clients for use on a wireless network as defined in the XML files.
The config.ini file defines the location of the XML files along with other settings to customise the tool to your sites needs.
Read the config.ini and check the settings, its all self explanatory.

2. getprofile.exe
This file is needed to create the XML file containing the wireless configuration information.
Manually set up a computer for use on your wireless network with the wireless profiles you want to deploy to users configured on it. Run the getprofile tool and select the wireless adapter you want to capture profiles from. All profiles found on that adapter will then be saved to file names that contain the profile name, OS and profile priority. You will then need to make sure the xmlfile values in config.ini points to the appropriate files. After customising the config.ini for your site, you can then package and distribute su1x.


***************************
Deployment
***************************
The su1x-installer.nsi file can be modified and recompiled into a installer application using the NSIS software.
NSIS - http://nsis.sourceforge.net



; Written by Gareth Ayres of Swansea University (g.j.ayres@swansea.ac.uk)
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