SU1X Readme file by Gareth Ayres.

Works with: XP SP3, VISTA (All SPs) and 7.

Features now include:
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
This exe sets up Windows XP, Vista and Win7 clients for use on a wireless network as defined in the XML file.
The config.ini file defines the location of the XML files.
Read the config.ini and check the settings, its all self explanatory.

2. getprofile.exe
This file is needed to create the XML file containing the wireless configuration information.
Manually set up a wireless computer for use on your wireless network, make sure the ssid value in the config.ini 
is correct (eduroam by default) and then run the getprofile tool. This will then save a xml file with the 
configuration information in it called Profile.xml. You will then need to make sure the xmlfile value in 
config.ini points to this file. You can then place it in the bin folder and package and distribute it.


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