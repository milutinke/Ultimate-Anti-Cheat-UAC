============================================================================================================
				ByM Ultimate Anti Cheat Pack
					Version: 1.6
============================================================================================================

READ IN FULL-SCREEN MODE FOR BETTER EXPERIENCE!!!!
Authors and Credits down bellow.

Description:
	About the project:
		This is community project which has been started by Milutinke (ByM) in early 2018 based on Ilham Sakura's anti cheat.
		The goal of the project was to extend the life of Counter-Strike 1.6 game by providing
		the server owners/community with means to get rid of the cheaters.
		I will not provide any support or updated to the project anymore, I am leaving it to your hands
		as the community.
		I hope that someone will improve it in the future.

	About the pack itself:
		This Anti Cheat Pack aims to help the server owners/communities to get rid of the cheaters in most server 
		friendly way and to protect the server from various exploits and malicious attacks.
		This Anti Cheat Pack consists of multiple plugins and modules listed below, providing layered protection
		form cheats and exploits.
		This may not be able to filter all cheaters 100% but it will filter at least 99% of them.
		There will always be that 1% percent, but in end, that 1% percent cannot make too much bad of experience
		for other players as 99% can.
		This pack has been tested and has worked well on Legendary Community and Heavy Team servers.
		Few add-ons are added after the test have been completed, they are located at Optional - Not tested folder,
		use them at your own risk.

	NOTE: Use ReAimDetector instead of default AIM detection (Default AIM Detection is limited and not good and it is disabled by default).
	NOTE: You might be requiered to tweak the settings depending on your server version

	Main Anit Cheat Parts (You should use them as minimal protection):
		1. ByM Ultimate Anti Cheat (Blocks various types of cheats (AIM, AIMBOT (SHAKE), SPINBOT, RAPID, SPEEDHACK, FASTNAME, BHOP, etc...), 
		fake player detection and protection, Cheat toggle detection (Milf AntiCheat)
			> Files:
				- AMXX: ByM Ultimate Anti Cheat/cstrike/addons/amxmodx/plugins/ByM_UltimateAntiCheat.amxx
				- INC for API: ByM Ultimate Anti Cheat/cstrike/addons/amxmodx/scripting/bym_uac.ini
				- Configs folder: ByM Ultimate Anti Cheat/cstrike/addons/amxmodx/configs/UltimateAntiCheat
				- Language file: ByM Ultimate Anti Cheat/cstrike/addons/amxmodx/data/lang/UltimateAntiCheat.txt
				> Source: ByM Ultimate Anti Cheat/cstrike/addons/amxmodx/scripting

		2. ReChecker with a list of cheats (Detects and punishes players with client-side cheat detected in their counter strike)
			> Files (ByM Ultimate Anti Cheat/cstrike/addons/rechecker/):
				> Module Part:
					- Linux: rechecker_mm_i386.so (Windows: rechecker_mm.dll)
					- resources.ini
					- Folder: logs
					> Source not avaliable (Closed source)
				> Plugin part: 
					- AMXX: ByM Ultimate Anti Cheat/cstrike/addons/amxmodx/plugins/ReCheckerLogger.amxx
					- SMA (Source): ByM Ultimate Anti Cheat/cstrike/addons/amxmodx/scripting/ReCheckerLogger.sma
					- Folder: ByM Ultimate Anti Cheat/cstrike/addons/amxmodx/logs/ReChecker_Logs/

		3. Wh Blocker (Blocks all known WH, Radar and ESP cheats)
			> Files (ByM Ultimate Anti Cheat/cstrike/addons/whblocker_newest/):
				- whblocker_mm_i386.so (Windows: whblocker_mm.dll)
				- config.ini
				- Folder: logs
				> Source not avaliable (Closed source)

	Recommended optional plugins/modules/addons:
		1. Plugins:
			1. MDB Ban by Desikac (Excelent good ban system).
				> Files:
					- AMXX: ByM Ultimate Anti Cheat/cstrike/addons/amxmodx/plugins/mdbBansEN.amxx
					> Source not avaliable (Closed source project)

			2. MILF AntiReklama (Stops advertising in chat and name):
				> Files:
					- AMXX: ByM Ultimate Anti Cheat/cstrike/addons/amxmodx/plugins/milf_antireklama.amxx
					> Source not avaliable (Closed source project)

	Requirements to be able to use it:
		- ReHLDS: https://github.com/dreamstalker/rehlds
		- ReUnion: https://dev-cs.ru/threads/135/#post-396
		- Metamod-R: https://github.com/theAsmodai/metamod-r
		- ReGameDLL: https://github.com/s1lentq/ReGameDLL_CS

	 	NOTE: You are advised to install the latest stable version.

	Recommended MetaMod Plugins:
		- ReAuthCheker: https://c-s.net.ua/forum/topic84615.html

	Future plans:
		- No future plans, you as the community can take over the project.

============================================================================================================
					Instalation
============================================================================================================
	====================================================
			>>> IMPORATANT!!!! <<<
	====================================================
	 * If you are updating from 1.3 (or older version), please delete old folder cstrike/addons/amxmodx/configs/UltimateAntiCheat/
	 * If you skip this step Anti-Cheat is not going to work!
	====================================================

	====================================================
	STEP BY STEP TUTORIAL (I recommend to you to follow it):
	====================================================

	====================================================
	1. ReHLDS (Requiered):
	====================================================
		1. Connect to the server via FTP
		2. Rename next files on the server:
			If you are using Linux:
				- core.so to core.so.old
				- demoplayer.so to demoplayer.so.old
				- engine_i486.so to engine_i486.so.old
				- filesystem_stdio.so to filesystem_stdio.so.old
				- hlds_linux to old_hlds_linux
				- hltv to old_hltv
				- proxy.so to proxy.so.old
				- If you have file called director.so in valve/dlls/ , rename it to director.so.old
				- Go to the cstrike/addons/metamod/ and rename metamod.so to the metamod.so.old
				- Go to the cstrike/addons/metamod/dlls and rename metamod.so to the metamod.so.old
			If you are using Windows:
				- core.dll to core.dll.old
				- demoplayer.dll to demoplayer.dll.old
				- engine_i486.dll to engine_i486.dll.old
				- filesystem_stdio.dll to filesystem_stdio.dll.old
				- hlds.exe to hlds.exe.old
				- hltv.exe to hltv.exe.old
				- proxy.dll to proxy.dll.old
				- If you have file called director.dll in valve/dlls/ , rename it to director.dll.old
				- Go to the cstrike/addons/metamod/ and rename metamod.so to the metamod.dll.old
				- Go to the cstrike/addons/metamod/dlls and rename metamod.so to the metamod.dll.old

		3. Go to https://github.com/dreamstalker/rehlds and download the build version
		4. Open the archive that you have downloaded
		5. Go to: bin folder in the archive
		6. 
			> If you are using Windows on the server go to win32 folder
			> if you are using Linux on the server go to linux32 folder
		7. Upload all files from folder mentioned above to your root/main folder of the server and replace all files if it asks you to do
		8. Set Permissions:
			> If you are using Linux on server: 
				- Set permissions of the file: hlds_linux to 777
			> If you are using Windows on the server:
				- Set permissions of the file: hlds.exe to 777
	====================================================
	
	====================================================
	2. MetaMod-P & ReGameDLL (Requiered):
	====================================================
		1. Connect to the server via FTP
		2. Go to https://github.com/theAsmodai/metamod-r and download the built version
		3. Open the Meta Mod R archive that you have downloaded
		4. Upload files to the cstrike/addons/metamod/:
			> If you are using Windows on the server:
				- Upload metamod.dll to the cstrike/addons/metamod/ from the archive folder on to the server.
			> if you are using Linux on the server:
				- Upload metamod.so to the cstrike/addons/metamod/ from the archive folder on to the server.

		5. Upload files to the cstrike/addons/metamod/dlls:
			> If you are using Windows on the server:
				- Upload metamod.dll to the cstrike/addons/metamod/dlls from the archive folder on to the server.
			> if you are using Linux on the server:
				- Upload metamod.so to the cstrike/addons/metamod/dlls from the archive folder on to the server.
		6. Go to the cstrike/ folder on the server
		7. Go to https://github.com/s1lentq/ReGameDLL_CS and download the built version
		8. Open the archive that you have downloaded
		9. Upload game.cfg to the cstrike/ folder on the server
		10. Go to the cstrike/addons/metamod/dlls folder on the server
		11. Open bin/bugfixed/ folder in the archive
		12. Upload files to the cstrike/addons/metamod/dlls:
			> If you are using Windows on the server:
				- Upload mp.dll to the cstrike/addons/metamod/dlls/ from the archive folder on to the server.
			> if you are using Linux on the server:
				- Upload cs.so to the cstrike/addons/metamod/dlls/ from the archive folder on to the server.
		13. Go to the cstrike/addons/metamod folder on the server
		14. If you do not have file Config.ini create it, if you have it, open it
		15. Open Config.ini
		16. Delte file contents if it is not empty
		17. Add next 2 lines:
			> If you are using Windows on the server add:
				gamedll dlls/mp.dll
				clientmeta no
			> if you are using Linux on the server add:
				gamedll dlls/cs.so
				clientmeta no
		18. Save the file
	====================================================

	====================================================
	3. ReUnion (Requiered):
	====================================================
		1. Connect to the server via FTP
		2. Go to the cstrike/addons/ folder on the server and create folder called: reunion
		3. Go to the cstrike/ folder on the server
		4. Go to the ByM Ultimate Anti Cheat Pack v1.6/Dependencies folder on your computer
		5. Go to https://dev-cs.ru/threads/135/#post-396 and download the latest version
		6. Upload reunion.cfg from the archive to the cstrike/ on the server
		7. Go to the bin/ folder in the reunion_0.1.92.zip
		8. 
			> If you are using Windows on the server go to the Windows folder in the archive
			> if you are using Linux on the server go to the Linux folder in the archive
		9. Upload:
			> If you are using Windows on the server:
				- Upload reunion_mm.dll to the addons/reunion/ from the archive folder on to the server.
			> if you are using Linux on the server:
				- Upload reunion_mm.so to the addons/reunion/ from the archive folder on to the server.
		10. Go to cstrike/addons/metamod on the server
		11. Open plugins.ini file
		12. Add following line to the end of file:
			If you are using Linux on the server:
				linux addons/rechecker/reunion_mm.so
			If you are using Windows on server:
				win32 addons/rechecker/reunion_mm.dll
		13. Save the file
	====================================================
	
	====================================================
	4. Removing Dproto (Requiered):
	====================================================
		1. Connect to the server via FTP
		2. Go to cstrike/addons/metamod/ on the server
		3. Open plugins.ini
		4. Find next line and delte it:
			> If you are using Linux on the server:
				linux addons/dproto/dproto_i386.so
			> If you are using Windows on server:
				linux addons/dproto/dproto_i386.dll
		5. Save the file
	====================================================
	
	====================================================
	5. Main Plugin, Re Checker Logger, WH Blocker & ReChecker (Requiered):
	====================================================
		1. Connect to the server via FTP
		2. Go to the ByM Ultimate Anti Cheat Pack v1.6/ folder on your PC
		3. Go to the ByM Ultimate Anti Cheat/cstrike/ folder on your PC
		4. Upload addons/ folder from your PC to the cstrike/ folder on the server
		5. Go to cstrike/addons/metamod/ on the server
		6. Open plugins.ini
		7. Add following 2 lines to the end of file:
			> If you are using Linux on server:
				linux addons/rechecker/rechecker_mm_i386.so
				linux addons/whblocker_newest/whblocker_mm_i386.so
			> If you are using Windows on server:
				win32 addons/rechecker/rechecker_mm.dll
				win32 addons/whblocker_newest/whblocker_mm.dll
	====================================================

	====================================================
	Additional (Optional plugins - Recommended):
	====================================================
		MDB Bans:
			1. Go to cstrike/addons/amxmodx/configs and open plugins.ini
			2. Add mdbBansEN.amxx to the beggining of the file, at first line (It must be first on the list, to be able to work propperly, it is important, do not skip!!!).
		MILF Anti Reklama:
			1. Go to cstrike/addons/amxmodx/configs and open plugins.ini
			2. Add milf_antireklama.amxx at the second line line (It must be second on the list, to be able to work propperly, it is important, do not skip!!!).

	====================================================
	After you have done everyting, restart the server and enjoy.
	====================================================

============================================================================================================
				AUTHORS AND CONTRIBUTORS
============================================================================================================
Authors:
	Anti Cheat Core:
		- Ilham Sakura	
		- Milutinke (ByM)
 		- Rul4

	Other plugins/modules:
		- Desikac (MDB Ban System)
		- Turshija (Milf Anti Reklama)
		- dreamstalker (ReHLDS and Re modules)
		- s1lent (ReHLDS, ReUnion and Re modules)
		- Proffi (HNS Anti cheat)
		- Adidasman (ReAimDetector)
		- Crock (ReUnion)
		- Asmodai (ReUnion)

Contributors:
	- fr0zen (ReChecker list suggestions)
	- alber.soomro (ReChecker suggestions and some more suggestions for improvements)
	- pheel (ReChecker list - The big part of it)
	- Semir Jasarevic (Sent Cheats)
	- Milan Slavkovic (Sent Cheats)
	- Milos Ristic (Tester)
	- And few more which I have forgotten ( Sorry :'( ) or want to stay anonymous.

	Thank you all for your time and efforts.
	- milutinke (15:18 10.04.2018).

============================================================================================================
				Contribution
============================================================================================================
You can do whatever you want with this project. 
Please leave the authors and credits if you decide to use it or change it.