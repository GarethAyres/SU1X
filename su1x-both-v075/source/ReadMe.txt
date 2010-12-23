SU1X Readme file by Gareth Ayres.

Works with: XP SP2, SP3, VISTA (All SPs). Will hopefully work with 7 soon.

There are two exe's that make up this package:

1. su1x-setup.exe
This exe sets up Windows XP and Vista clients for use on a wireless network as defined in the XML file.
The config.ini file defines the location of the XML files.

2. getprofile.exe
This file is needed to create the XML file containing the wireless configuration information.
Manually set up a wireless computer for use on your wireless network, make sure the ssid value in the config.ini 
is correct (eduroam by default) and then run the getprofile tool. This will then save a xml file with the 
configuration information in it called Profile.xml. You will then need to make sure the xmlfile value in 
config.ini points to this file. You can then place it in the bin folder and distribute it.


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