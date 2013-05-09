#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=patcher.ico
#AutoIt3Wrapper_outfile=IN Patcher.exe
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=Please report any bugs to Admin Eru at http://www.in-uo.net/forums
#AutoIt3Wrapper_Res_Description=File Patcher for Imagine Nation
#AutoIt3Wrapper_Res_Fileversion=2.1.0.17
#AutoIt3Wrapper_Res_Fileversion_AutoIncrement=y
#AutoIt3Wrapper_Res_LegalCopyright=Admin Eru of Imagine Nation
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#region - Includes and Globals
#include <GUIConstantsEX.au3>
#include <WindowsConstants.au3>
#include <File.au3>
#include <Date.au3>
#include <Crypt.au3>
#include <user/Zip.au3>


Global $PathToSource = "C:\Users\Eremite\Dropbox\Imagine Nation\source\"   ;This actually doesn't do a damn thing, apparently.  Just edit where it appears in the two "FileInstall()" functions.

;Globals
Global $INIFile = @ScriptDir & "\Patcher.ini"
Global $ClientLocation=IniRead($INIFile,"Options","ClientLocation",""), $CLS
Global $ClientVersion=IniRead($IniFile,"Options","ClientVersion",-1), $OptChangeClientVersion
Global $LaunchFile=IniRead($INIFile,"Options","LaunchFile","\Razor.exe"), $LFS
If Not FileExists($INIFile) Or $ClientLocation = "" Or $LaunchFile = "\Razor.exe" Then CreateINI() ;Create .ini file if not there, then/else read the next settings:
Global $HostLocation = IniRead($INIFile,"Options","HostLocation","https://dl.dropbox.com/s/jatqbeluepdlfpb")


;Files to Update
Global $File[32]=["statics0.mul","staidx0.mul","statics1.mul","staidx1.mul","statics2.mul","staidx2.mul","statics3.mul","staidx3.mul","statics4.mul","staidx4.mul","tiledata.mul", _
  "animdata.mul","anim.mul","anim.idx","anim2.mul","anim2.idx","anim2.def","anim3.mul","anim3.idx","anim3.def","anim4.mul","anim4.idx", "anim5.mul","anim5.idx", _
	"gumpart.mul","gumpidx.mul","body.def","hues.mul","art.mul","artidx.mul","mobtypes.txt","bodyconv.def"] ;List of all files to be checked.
Global $TotalFiles = Ubound($File),$CheckedFiles=0

;Random-Ass Globals that cause the compiler to throw errors if not declared.
Global $Update, $OptChangeClientPath,$Cliloclabel2, $ProgressText, $Launch, $OptChangeLauncherPath, $LaunchFileLocLabel2, $UseClient6, $UseClient7, $ProgressBar, $ToolInjection, $Go, $ActionComboBox, $FilesComboBox, $ToolRazorMacros, $CliLocFix
Global $GoToForums, $GoToWebPage, $GoToChangeLog,$UpdateBox, $OptAutoLaunch, $OptAutoPatch, $GoToCartographerDownload, $GoToUOInstallerDownload, $GoToRazorDownload, $GoToPatcherHelp, $ForcedUpdate=False
Global $Progress = 0, $ProgressTextData = (@CRLF & "     /_  _ _ '  _ /| )__/'" & @CRLF & "    (//)(/(///)(-/ |/(///()/)" & @CRLF & "         _/" & @CRLF & "                         [Esc]=Exit")
#endregion - Includes and Globals

CreateGUI()
SelfUpdate()
If IniRead($INIFile,"Options","AutoPatch","No") = "Yes" Then Update()
StartupPrep()
While 1
	GUI()
	Sleep(15)
WEnd
Func GUI()
	$Msg = GUIGetMsg()
	Select
		Case $Msg = $GUI_Event_Close
			DirRemove(@ScriptDir & "\Temp")
			Exit
		Case $Msg = $Update
			Global $DetectedProcesses = ""
			If ProcessExists("Client.exe") Then $DetectedProcesses = $DetectedProcesses & "Client.exe" & @CRLF
			If ProcessExists("Pandora.exe") Then $DetectedProcesses = $DetectedProcesses & "Pandora.exe" & @CRLF
			If $DetectedProcesses <> "" Then
				ClearProgress()
				ProgressUpdate("WARNING: Patching with these processes open may damage UO: " & @CRLF & $DetectedProcesses)
			Else
				Update()
			EndIf
		Case $Msg = $OptChangeClientPath
			$CLS = FileSelectFolder("Select the folder that contains 'Client.exe'","")
			If $CLS <> "" Then
				$ClientLocation = $CLS
				GUICtrlSetData($CliLocLabel2,$ClientLocation)
				IniWrite($INIFile,"Options","ClientLocation",$ClientLocation)
			EndIf
		Case $Msg = $OptChangeClientVersion
			If MsgBox(4,"Which Client Do You Use?","Are you using Client 7?  Press 'Yes' to patch for Client 7, or press 'No' to patch for Client 6 or below.") = 6 Then
				SetClientVersion(7)
			Else
				SetClientVersion(6)
			EndIf
			If MsgBox(4,"Update now?","Would you like to forcefully update all client-specific files now?") = 6 Then
				ClearProgress()
				GetFile("tiledata.mul",1)
				ClearProgress()
				GetFile("multi.mul",1)
				ClearProgress()
				GetFile("multi.idx",1)
			EndIf
		Case $Msg = $UseClient6
			ChangeClient(6)
		Case $Msg = $UseClient7
			ChangeClient(7)
		Case $Msg = $Launch
			If FileExists($LaunchFile) Then
				ShellExecute($LaunchFile)
				DirRemove(@ScriptDir & "\Temp")
				Exit
			Else
				ClearProgress()
				ProgressUpdate("ERROR: Launcher not found." & @CRLF & @CRLF & "You may need to set its location by clicking 'Change Default Launcher' in the 'IN Patcher' menu.")
			EndIf
		Case $Msg = $OptChangeLauncherPath
			$LFS = FileOpenDialog("Select your launching program.","C:\","All (*.*)",1)
			If $LFS <> "" Then
				$LaunchFile = $LFS
				GUICtrlSetData($LaunchFileLocLabel2,$LaunchFile)
				IniWrite($INIFile,"Options","LaunchFile",$LaunchFile)
			EndIf
		Case $Msg = $OptAutoPatch
			If IniRead($INIFile,"Options","AutoPatch","No") = "Yes" Then
				IniWrite($INIFile,"Options","AutoPatch","No")
			Else
				IniWrite($INIFile,"Options","AutoPatch","Yes")
			EndIf
			MenuTogglesUpdate()
		Case $Msg = $OptAutoLaunch
			If IniRead($INIFile,"Options","AutoLaunch","No") = "Yes" Then
				IniWrite($INIFile,"Options","AutoLaunch","No")
			Else
				IniWrite($INIFile,"Options","AutoLaunch","Yes")
			EndIf
			MenuTogglesUpdate()
		Case $Msg = $Go
			GoButton()
		Case $Msg = $GoToWebPage
			ShellExecute("http://in-uo.net")
		Case $Msg = $GoToForums
			ShellExecute("http://www.in-uo.net/forums")
		Case $Msg = $GoToChangeLog
			ShellExecute("http://www.in-uo.net/forums/showthread.php?28-%28Change-Log%29")
		Case $Msg = $GoToUOInstallerDownload
			ShellExecute("http://www.uo.com/uoml/downloads.shtml")
		Case $Msg = $GoToRazorDownload
			ShellExecute("http://www.runuo.com/razor/download.php")
		Case $Msg = $GoToCartographerDownload
			ShellExecute("http://www.uocartographer.com/")
		Case $Msg = $GoToPatcherHelp
			ShellExecute("http://www.in-uo.net/forums/showthread.php?9-Setting-up-UO-with-the-IN-Patcher&p=18&viewfull=1#post18")
		Case $Msg = $ToolInjection
			InjectionSetup()
		Case $Msg = $ToolRazorMacros
			InstallMacros()
		Case $Msg = $CliLocFix
			CliLocFix()
	EndSelect
EndFunc

;###########################################################################
;===============================Functions===================================
;###########################################################################
Func CreateGUI()
	$GUI=GUICreate("Imagine Nation  -=(Patcher)=-",365,230,-1,-1,BitOr($WS_POPUP,$WS_MINIMIZEBOX))
	GUISetIcon(@Scriptdir & "\patcher.ico")
	TraySetIcon(@Scriptdir & "\patcher.ico")
	GUISetBkColor(0x000000,$GUI)
	FileInstall("C:\Users\Eremite\Dropbox\Imagine Nation\source\title.jpg",@TempDir & "\title.jpg",1)
	GUICtrlCreatePic(@TempDir & "\title.jpg",0,0,365,88,-1,0x00100000)
	Global $ProgressText = GUICtrlCreateEdit($ProgressTextData,0,88,235,60,0x200844)
	GUICtrlSetBkColor($ProgressText,0x222222)
	GUICtrlSetColor($ProgressText,0xFFFFFF)
	GUICtrlSetFont($ProgressText,8,1,0,"Lucida Console")
	Global $Update = GUICtrlCreateButton("Patch IN",235,88,80,59,0x0001)
	GUICtrlSetBkColor($Update,0x191919)
	GUICtrlSetColor($Update,0xFFFFFF)
	Global $Launch = GUICtrlCreateButton("Launch",315,88,50,59,0x001)
	GUICtrlSetBkColor($Launch,0x191919)
	GUICtrlSetColor($Launch,0xFFFFFF)
	;Client/Patcher Locations Labels
	$CLiLocLabel = GUICtrlCreateLabel("C:",1,149,10,16)
	GUICtrlSetColor($CLiLocLabel,0xFFFFFF)
	Global $CliLocLabel2 = GUICtrlCreateLabel($ClientLocation,11,149,225,16)
	GUICtrlSetColor($CliLocLabel2,0xFFFFFF)
	GUICtrlSetBkColor($CliLocLabel2,0x191919)
	$LaunchFileLocLabel = GUICtrlCreateLabel("L:",1,167,10,16)
	GUICtrlSetColor($LaunchFileLocLabel,0xFFFFFF)
	$LaunchFileLocLabel2 = GUICtrlCreateLabel($LaunchFile,11,167,225,16)
	GUICtrlSetBkColor($LaunchFileLocLabel2,0x191919)
	GUICtrlSetColor($LaunchFileLocLabel2,0xFFFFFF)
	;Combo Box for Forced Updates
	Global $ActionComboBox = GUICtrlCreateCombo("",236,146,100,25)
	GUICtrlSetData($ActionComboBox,"Force Update|Restore Backup")
	GUICtrlSetColor($ActionComboBox,0xFFFFFF)
	GUICtrlSetBkColor($ActionComboBox,0x191919)
	Global $FilesComboBox = GUICtrlCreateCombo("",236,163,100,25)
	GUICtrlSetData($FilesComboBox,"ALL FILES" & ComboList())
	GUICtrlSetColor($FilesComboBox,0xFFFFFF)
	GUICtrlSetBkColor($FilesComboBox,0x191919)
	Global $Go = GUICtrlCreateButton("Go",336,146,27,38)
	GUICtrlSetColor($Go,0xFFFFFF)
	GUICtrlSetBkColor($Go,0x191919)
	;Prograss Bar/Label
	Global $ProgressBar = GUICtrlCreateProgress(0,184,364,25,0x01)
	GUICtrlSetBkColor($ProgressBar,0x191919)
	GUICtrlSetColor($ProgressBar,0x252525)
	Global $Progress = GUICtrlCreateLabel("",501,325,50,25)
	GUICtrlSetColor($Progress,0xFFFFFF)
	GUISetState(@SW_SHOW)
	;===============Menu Items
	Global $Options = GUICtrlCreateMenu("Patcher")
	Global $OptAutoPatch = GUICtrlCreateMenuItem("Auto Patch On Startup",$Options,1,1)  ;Unchecked = Returns 68 // Checked = Returns 65
		If IniRead($INIFile,"Options","AutoPatch","No") = "Yes" Then GUICtrlSetState($OptAutoPatch, $GUI_CHECKED)
	Global $OptAutoLaunch = GUICtrlCreateMenuItem("Auto Launch UO After Patching",$Options,2,1)
		If IniRead($INIFile,"Options","AutoLaunch","No") = "Yes" Then GUICtrlSetState($OptAutoLaunch, $GUI_CHECKED)
	GUICtrlCreateMenuItem("",$Options,3,0)
	Global $OptChangeClientPath = GUICtrlCreateMenuItem("Change Default Client Path",$Options,4,0)
	Global $OptChangeLauncherPath = GUICtrlCreateMenuItem("Change Default Launcher",$Options,5,0)
	Global $OptChangeClientVersion = GUICtrlCreateMenuItem("Toggle Client Version" & "(" & $ClientVersion & ")",$Options,6,0)
	Global $Tools = GUICtrlCreateMenu("Tools")
	Global $UseClient6 = GUICtrlCreateMenuItem("Use Client 6.x",$Tools,1,0)
	Global $UseClient7 = GUICtrlCreateMenuItem("Use Client 7.x",$Tools,2,0)
	Global $CliLocFix = GUICtrlCreateMenuItem("Fix Razor's 'cliloc' error",$Tools,3,0)
	Global $ToolInjection = GUICtrlCreateMenuItem("Auto-Install Injection",$Tools,4,0)
	Global $ToolRazorMacros = GUICtrlCreateMenuItem("Install Sample Razor Macros",$Tools,5,0)
	Global $GoTo = GUICtrlCreateMenu("GoTo")
	Global $GoToWebPage = GUICtrlCreateMenuItem("Website",$GoTo,1,0)
	Global $GoToForums = GUICtrlCreateMenuItem("Forums",$GoTo,2,0)
	Global $GoToChangeLog = GUICtrlCreateMenuItem("Change Log",$GoTo,3,0)
	Global $GoToPatcherHelp = GUICtrlCreateMenuItem("Patcher Help",$GoTo,4,0)
	GUICtrlCreateMenuItem("",$GoTo,10,0)
	Global $GoToUOInstallerDownload = GUICtrlCreateMenuItem("Download UO Installer",$GoTo,11,0)
	Global $GoToRazorDownload = GUICtrlCreateMenuItem("Download Razor",$GoTo,12,0)
	Global $GoToCartographerDownload = GUICtrlCreateMenuItem("Download Cartographer",$GoTo,13,0)
EndFunc
Func SelfUpdate()
	If InetGetSize($HostLocation & "/IN Patcher.exe",1) <> FileGetSize(@ScriptDir & "\IN Patcher.exe") Then
		MsgBox(0,"New Version of IN Patcher","There is a newer version of IN Patcher." & @CRLF & "The patcher will now update.",5)
		DirCreate(@ScriptDir&"\Temp")
		Local $DownloadSize = InetGetSize($HostLocation & "/IN Patcher.exe",1)
		Local $Download = InetGet($HostLocation & "/IN Patcher.exe", @ScriptDir & "\Temp\IN Patcher.exe",3,1)
		ClearProgress()
		ProgressUpdate(@CRLF & @CRLF & "Downloading Latest IN Patcher (" & Round(($DownloadSize/1024),2) & "KB)")
		Do
			GUI()
			GUICtrlSetData($ProgressBar,(InetGetInfo($Download,0)/$DownloadSize)*100)
			Sleep(100)
		Until InetGetInfo($Download, 2)
		$DownloadSize = InetGetSize($HostLocation & "/UpdateSwap.exe",1)
		$Download = InetGet($HostLocation & "/UpdateSwap.exe",@ScriptDir & "\UpdateSwap.exe",3,1)
		ProgressUpdate(@CRLF & @CRLF & "Preparing Update.")
		Do
			GUI()
			GUICtrlSetData($ProgressBar,(InetGetInfo($Download,0)/$DownloadSize)*100)
			Sleep(100)
		Until InetGetInfo($Download, 2)
		ShellExecute(@ScriptDir & "\UpdateSwap.exe")
		Exit
	ElseIf FileExists(@ScriptDir & "\UpdateSwap.exe") Then
		FileDelete(@ScriptDir & "\UpdateSwap.exe")
	EndIf
EndFunc
Func StartupPrep()
	DirRemove(@ScriptDir&"\Temp",1)
	DirCreate(@ScriptDir&"\Temp")
	DirCreate(@ScriptDir&"\Backup")
EndFunc

#region GUI-Called Functions
Func Update()
	If $ClientVersion < 1 Then SetClientVersion(-1)
	$CheckedFiles=0
	GUICtrlSetData($Progress,"Checked: " & $CheckedFiles & "/" & $TotalFiles)
	DirCreate(@ScriptDir&"\Backup")
	DirCreate(@ScriptDir&"\Temp")
	InetGet($HostLocation & "/current.ini",@ScriptDir & "\Temp\current.ini",1)
	Local $CurrentINI = @ScriptDir & "\Temp\current.ini"
	GUICtrlSetData($Progress,"Checked: " & $CheckedFiles & "/" & $TotalFiles)
	Local $TextProgressBar = "", $Hash
	For $i=0 To UBound($File)-1 Step 1
		$TextProgressBar = $TextProgressBar & "#"
		ClearProgress()
		ProgressUpdate("Chk:" & $TextProgressBar & @CRLF & @CRLF)
		Local $FNF = 6
		If Not FileExists($ClientLocation & "\" & $File[$i]) Then
			$FNF = MsgBox(3,"File Not Found","The " & $File[$i] & " file was not found." & @CRLF & @CRLF & "Do you want to create it?")
		EndIf
		If $FNF = 2 Then ExitLoop
		$Hash = _Crypt_HashFile($ClientLocation & "\" & $File[$i],$CALG_MD5)
		ConsoleWrite(@CRLF & "File = " & $File[$i] & @TAB & @TAB & $Hash & "  --  RemoteHash: " & IniRead($CurrentINI,"Current",$File[$i],""))
		If $File[$i] = "tiledata.mul" And $ClientVersion = 6 And $FNF=6 Or $ForcedUpdate = True Then
			If $Hash <> IniRead($CurrentINI,"Current",$File[$i]& ".6","") Then
				ConsoleWrite(@CRLF & @CRLF &  "Hash = " & $Hash & "  ---   " & "INI: " & IniRead($CurrentINI,"Current",$File[$i]& ".6","") & @CRLF)
				GetFile($File[$i],1) ;Had to add this because the server is writing the MD5 for Client Version 7 only.
			EndIf
		ElseIf ($Hash <> IniRead($CurrentINI,"Current",$File[$i],"") And $FNF=6) Or $ForcedUpdate = True Then
			GetFile($File[$i],1)
		ElseIf $FNF <> 6 Then
			ProgressUpdate("Did not update " & $File[$i] & @CRLF)
			$CheckedFiles=$CheckedFiles+1
		Else
			ProgressUpdate("No newer version of " & $File[$i] & @CRLF)
			$CheckedFiles=$CheckedFiles+1
		EndIf
		GUICtrlSetData($Progress,"Checked: " & $CheckedFiles & "/" & $TotalFiles)
	Next
	FileInstall("C:\Users\Eremite\Dropbox\Imagine Nation\source\login.cfg",$ClientLocation & "\login.cfg",1)
	GUICtrlSetData($Progress, "Done Patching! " )
	Sleep(250)
	ClearProgress()
	ProgressUpdate(@CRLF & "         Patching completed!" & @CRLF & @CRLF &  "        You're ready to play!")
	DirRemove(@ScriptDir & "\Temp",1)
	If IniRead($INIFile,"Options","AutoLaunch","No") = "Yes" Then
		If FileExists($LaunchFile) Then
			ShellExecute($LaunchFile)
			Exit
		Else
			ClearProgress()
			ProgressUpdate(@CRLF & "The launcher path does not point to anything." & @CRLF & "  Please update it by pressing the [Set] button.")
		EndIf
	EndIf
EndFunc
Func GoButton()  ;$FilesComboBox $ActionComboBox
	If GUICtrlRead($ActionComboBox) = "Force Update" Then
		Local $ForceFile = GUICtrlRead($FilesComboBox)
		Local $DownloadSize =  InetGetSize($HostLocation & "/repo/" & $ForceFile & ".zip")
		If $ForceFile = "ALL FILES" Then
			$ForcedUpdate=True
			Update()
			$ForcedUpdate=False
		ElseIf $DownloadSize > 0 Then
			ClearProgress()
			ProgressUpdate("Forced ")
			GetFile($ForceFile,1)
		Else
			ClearProgress()
			ProgressUpdate("   File not found" & @CRLF )
		EndIf
	#cs
	ElseIf GUICtrlRead($ActionComboBox = "Restore Backup") Then
		Local $RestoreFile = GUICtrlRead($FilesComboBox)
		If FileExists(@ScriptDir & "\Backup\" & $RestoreFile) Then
			FileMove(@ScriptDir & "\Backup\" & $RestoreFile,$ClientLocation & "\" & $RestoreFile,1)
			ClearProgress()
			ProgressUpdate("Restored a backup of " & $RestoreFile & @CRLF & @CRLF & "You will need to force update this file to get the latest version.")
		Else
			ClearProgress()
			ProgressUpdate("--=Backup NOT FOUND=--" & @CRLF & "If you've never patched, deleted the backup folder, or already restored, the backup file will not exist.")
		EndIf
	#ce
	Else ;Catchall = Turn button red briefly to show no command was triggered
		GUICtrlSetBkColor($Go,0xAA0000)
		Sleep(350)
		GUICtrlSetBkColor($Go,0x191919)
	EndIf
EndFunc
Func GetFile($GetFile,$Repo)
	If $GetFile="tiledata.mul" Or $GetFile="multi.mul" Or $GetFile = "multi.idx" Then
		If $ClientVersion < 1 Then SetClientVersion(-1)
		Local $DownloadSize = InetGetSize($HostLocation & "/repo/" & $ClientVersion & "/" & $GetFile & ".zip",1)
	ElseIf $Repo=1 Then
		Local $DownloadSize = InetGetSize($HostLocation & "/repo/" & $GetFile & ".zip",1)
	Else
		Local $DownloadSize = InetGetSize($HostLocation & "/" & $GetFile & ".zip",1)
	EndIf
	ProgressUpdate("Updating " & $GetFile & " (" & Round((($DownloadSize/1024)/1024),2) & "MB) ")
	If $GetFile = "tiledata.mul" Or $GetFile="multi.mul" Or $GetFile = "multi.idx" Then
		Local $Download = InetGet($HostLocation & "/repo/" & $ClientVersion & "/" & $GetFile & ".zip",@ScriptDir & "\Temp\" & $GetFile & ".zip",3,1)
		ConsoleWrite(@CRLF & $HostLocation & "/repo/" & $ClientVersion & "/" & $GetFile & ".zip")
	ElseIf $Repo=1 Then
		Local $Download = InetGet($HostLocation & "/repo/" & $GetFile & ".zip",@ScriptDir & "\Temp\" & $GetFile & ".zip",3,1)
	Else
		Local $Download = InetGet($HostLocation & "/" & $GetFile & ".zip",@ScriptDir & "\Temp\" & $GetFile & ".zip",3,1)
	EndIf
	Do
		GUI()
		GUICtrlSetData($ProgressBar,(InetGetInfo($Download,0)/$DownloadSize)*100)
		Sleep(100)
	Until InetGetInfo($Download, 2)
	GUICtrlSetData($ProgressBar,100)
	FileCopy($ClientLocation & "\" & $GetFile,@ScriptDir & "\Backup\" & $GetFile,1)
	_ExtractZip(@ScriptDir & "\Temp\" & $GetFile & ".zip", "", $GetFile, @ScriptDir & "\Temp")
	FileCopy(@ScriptDir & "\Temp\" & $GetFile,$ClientLocation & "\" & $GetFile,1)
	ProgressUpdate("Patched!" & @CRLF)
	$CheckedFiles=$CheckedFiles+1
EndFunc
Func InstallMacros()
	DirCreate(@ScriptDir & "\Temp")
	Local $RazorDir = @AppDataDir & "\Razor\Macros\"
	ClearProgress()
	Local $DownloadSize = InetGetSize($HostLocation & "/INMacros.zip",1)
	ProgressUpdate("Downloading Macros Package (" & Round((($DownloadSize/1024)/1024),2) & "MB) ")
	Local $Download = InetGet($HostLocation & "/INMacros.zip",@ScriptDir & "\Temp\INMacros.zip",3,1)
	Do
		GUI()
		GUICtrlSetData($ProgressBar,(InetGetInfo($Download,0)/$DownloadSize)*100)
		Sleep(500)
	Until InetGetInfo($Download, 2)
	GUICtrlSetData($ProgressBar,100)
	_Zip_UnzipAll(@ScriptDir & "\Temp\INMacros.zip",$RazorDir)
	ProgressUpdate(@CRLF & "Installed Razor Sample Macros!" & @CRLF & @CRLF & "They'll be in the Razor 'Macros' tab next time you launch UO with Razor.")
EndFunc
Func CliLocFix()
	Local $RegFile = @TempDir & "\reg.reg"
	FileDelete($RegFile)
	Local $RegCliLoc = StringReplace($ClientLocation,"\","\\")
	FileWriteLine($RegFile,"Windows Registry Editor Version 5.00")
	FileWriteLine($RegFile,"[HKEY_LOCAL_MACHINE\SOFTWARE\Origin Worlds Online\Ultima Online]")
	FileWriteLine($RegFile,"[HKEY_LOCAL_MACHINE\SOFTWARE\Origin Worlds Online\Ultima Online\1.0]")
	FileWriteLine($RegFile,'"ExePath"="' & $RegCliLoc & '\\client.exe"')
	FileWriteLine($RegFile,'"InstCDPath"="' & $RegCliLoc & '"')
	FileWriteLine($RegFile,'"PatchExePath"="' & $RegCliLoc & '\\uopatch.exe"')
	FileWriteLine($RegFile,'"StartExePath"="' & $RegCliLoc & '\\uo.exe"')
	FileWriteLine($RegFile,'"Upgraded"="Yes"')
	FileWriteLine($RegFile,'')
	FileWriteLine($RegFile,"[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Origin Worlds Online\Ultima Online]")
	FileWriteLine($RegFile,"[HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Origin Worlds Online\Ultima Online\1.0]")
	FileWriteLine($RegFile,'"ExePath"="' & $RegCliLoc & '\\client.exe"')
	FileWriteLine($RegFile,'"InstCDPath"="' & $RegCliLoc & '"')
	FileWriteLine($RegFile,'"PatchExePath"="' & $RegCliLoc & '\\uopatch.exe"')
	FileWriteLine($RegFile,'"StartExePath"="' & $RegCliLoc & '\\uo.exe"')
	FileWriteLine($RegFile,'"Upgraded"="Yes"')
	ShellExecute($RegFile)
EndFunc
Func SetClientVersion($Ver)
	If $Ver = -1 Then
		Local $TDV = FileGetSize($ClientLocation & "\tiledata.mul")
		If $TDV > 10485760 Then
			$ClientVersion = 6
		Else
			$ClientVersion = 7
		EndIf
	Else
		$ClientVersion = $Ver
	EndIf
	IniWrite($INIFile,"Options","ClientVersion",$ClientVersion)
EndFunc
Func ChangeClient($Ver)
	DirCreate(@ScriptDir & "\Temp")
	SetClientVersion($Ver)
	ClearProgress()
	GetFile("tiledata.mul",1)
	ClearProgress()
	GetFile("multi.mul",1)
	ClearProgress()
	GetFile("multi.idx",1)
	ClearProgress()
	ProgressUpdate("Downloading the recommended client version...  " )
	Local $DownloadSize = InetGetSize($HostLocation & "/repo/" & $Ver & "/Client.exe.zip",1)
	Local $Download = InetGet($HostLocation & "/repo/" & $Ver & "/Client.exe.zip", @ScriptDir & "\Temp\Client.exe.zip",3,1)
	Do
		GUI()
		GUICtrlSetData($ProgressBar,(InetGetInfo($Download,0)/$DownloadSize)*100)
		Sleep(100)
	Until InetGetInfo($Download, 2)
	GUICtrlSetData($ProgressBar,100)
	FileMove($ClientLocation & "/Client.exe",$ClientLocation & "/Client.exe.oldclient",0)
	_ExtractZip(@ScriptDir & "\Temp\Client.exe.zip", "","Client.exe", @ScriptDir & "\Temp\")
	FileMove(@ScriptDir & "\Temp\Client.exe",$ClientLocation & "\Client.exe",1)
	DirRemove(@ScriptDir & "\Temp",1)
	ProgressUpdate("Client Patched" & @CRLF & @CRLF & "Your old client has been renamed to " & @CRLF & "         Client.exe.oldclient")
EndFunc
#endregion
#region Startup, Function-Called and Specific Functions
Func MenuTogglesUpdate()
	If IniRead($INIFile,"Options","AutoPatch","No") = "Yes" Then
		GUICtrlSetState($OptAutoPatch,$GUI_CHECKED)
	Else
		GUICtrlSetState($OptAutoPatch,$GUI_UNCHECKED)
	EndIf
	If IniRead($INIFile,"Options","AutoLaunch","No") = "Yes" Then
		GUICtrlSetState($OptAutoLaunch,$GUI_CHECKED)
	Else
		GUICtrlSetState($OptAutoLaunch,$GUI_UNCHECKED)
	EndIf
EndFunc
Func ProgressUpdate($NewLine)
	$ProgressTextData = $ProgressTextData & $NewLine
	GUICtrlSetData($ProgressText,$ProgressTextData)
EndFunc
Func ClearProgress()
	$ProgressTextData = ""
	GUICtrlSetData($ProgressText,$ProgressTextData)
EndFunc
Func ComboList()
	Local $CLGen = ""
	For $i = 0 to UBound($File) - 1 Step 1
		$CLGen = $CLGen & "|" & $File[$i]
	Next
	Return $CLGen
EndFunc
Func CreateINI()
	$ClientLocation = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Origin Worlds Online\Ultima Online\1.0","InstCDPath")
	If $ClientLocation = "" Then $ClientLocation = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Origin Worlds Online\Ultima Online\1.0","InstCDPath")
	If $ClientLocation = "" Then
		Local $CLS = FileSelectFolder("Please select the folder that contains 'Client.exe'","")
			If $CLS <> "" Then
				$ClientLocation = $CLS
				IniWrite($INIFile,"Options","ClientLocation",$ClientLocation)
			EndIf
	EndIf
	IniWrite($INIFile,"Options","ClientLocation",$ClientLocation)
	$LaunchFile = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Razor","InstallDir") & "\Razor.exe"
	If $LaunchFile = "\Razor.exe" Then $LaunchFile = RegRead("HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Razor","InstallDir") & "\Razor.exe"
	If $LaunchFile = "\Razor.exe" Then
		$LFS = FileOpenDialog("Please select your launching program.","C:\","All (*.*)",1)
			If $LFS <> "" Then
				$LaunchFile = $LFS
				IniWrite($INIFile,"Options","LaunchFile",$LaunchFile)
			EndIf
	EndIf
	IniWrite($INIFile,"Options","LaunchFile",$LaunchFile)
	IniWrite($INIFile,"Options","DLSource","http://dl.dropbox.com/s/dc14xgq51tv44uv")
EndFunc
; #FUNCTION# ;===============================================================================
; Name...........: _ExtractZip
; Description ...: Extracts file/folder from ZIP compressed file
; Syntax.........: _ExtractZip($sZipFile, $sFolderStructure, $sFile, $sDestinationFolder)
; Parameters ....: $sZipFile - full path to the ZIP file to process
;                  $sFolderStructure - 'path' to the file/folder to extract inside ZIP file
;                  $sFile - file/folder to extract
;                  $sDestinationFolder - folder to extract to. Must exist.
; Return values .: Success - Returns 1
;                          - Sets @error to 0
;                  Failure - Returns 0 sets @error:
;                  |1 - Shell Object creation failure
;                  |2 - Destination folder is unavailable
;                  |3 - Structure within ZIP file is wrong
;                  |4 - Specified file/folder to extract not existing
; Author ........: trancexx
;==========================================================================================
Func _ExtractZip($sZipFile, $sFolderStructure, $sFile, $sDestinationFolder)
    Local $i
    Do
        $i += 1
        $sTempZipFolder = @TempDir & "\Temporary Directory " & $i & " for " & StringRegExpReplace($sZipFile, ".*\\", "")
    Until Not FileExists($sTempZipFolder) ; this folder will be created during extraction
    Local $oShell = ObjCreate("Shell.Application")
    If Not IsObj($oShell) Then
        Return SetError(1, 0, 0) ; highly unlikely but could happen
    EndIf
    Local $oDestinationFolder = $oShell.NameSpace($sDestinationFolder)
    If Not IsObj($oDestinationFolder) Then
        Return SetError(2, 0, 0) ; unavailable destionation location
    EndIf
    Local $oOriginFolder = $oShell.NameSpace($sZipFile & "\" & $sFolderStructure) ; FolderStructure is overstatement because of the available depth
    If Not IsObj($oOriginFolder) Then
        Return SetError(3, 0, 0) ; unavailable location
    EndIf
    ;Local $oOriginFile = $oOriginFolder.Items.Item($sFile)
    Local $oOriginFile = $oOriginFolder.ParseName($sFile)
    If Not IsObj($oOriginFile) Then
        Return SetError(4, 0, 0) ; no such file in ZIP file
    EndIf
    ; copy content of origin to destination
    $oDestinationFolder.CopyHere($oOriginFile, 4) ; 4 means "do not display a progress dialog box", but apparently doesn't work
    DirRemove($sTempZipFolder, 1) ; clean temp dir
    Return 1 ; All OK!
EndFunc
#endregion
#Region-INJECTION SETUP
Func InjectionSetup()
	Local $InjectionPath = $ClientLocation & "\Injection"
	Local $InjectionZip = @ScriptDir & "\Temp\Injection.zip"
	DirCreate($InjectionPath)
	ClearProgress()
	ProgressUpdate("Writing to ilaunch.xml...")
	WriteInjectionXML()
	ProgressUpdate("done!" & @CRLF & "Getting Package (" & Round((InetGetSize($HostLocation & "/Injection.zip",1)/1024)/1024,2) & " MB)...")
	Local $DownloadSize = InetGetSize($HostLocation & "/Injection.zip",1)
	DirCreate(@ScriptDir & "\Temp")
	Local $Download = InetGet($HostLocation & "/Injection.zip",@ScriptDir & "\Temp\Injection.zip",3,1)
	Do
		GUI()
		GUICtrlSetData($ProgressBar,(InetGetInfo($Download,0)/$DownloadSize)*100)
		Sleep(100)
	Until InetGetInfo($Download, 2)
	GUICtrlSetData($ProgressBar,100)
	ProgressUpdate("done!" & @CRLF & "Unpacking files")
	Local $InjectionFiles[14]= ["5.0.1h m.exe", "Igrping.dll","autoload.sc", "expat.dll", "Ignition.cfg", "ilaunch.exe", "ilpatch.cfg", "Info.txt", _
		"Injection.dll","injection.xml","injection_log.txt", "libexpat.dll", "script.dll", "UOKeys.cfg"]
	For $i=0 to UBound($InjectionFiles) - 1 Step 1
		_ExtractZip($InjectionZip, "", $InjectionFiles[$i], @ScriptDir & "\Temp")
		FileMove(@ScriptDir & "\Temp\" & $InjectionFiles[$i],$InjectionPath & "\" & $InjectionFiles[$i],1)
		ProgressUpdate(".")
	Next
	FileMove($InjectionPath & "\5.0.1h m.exe",$ClientLocation & "\5.0.1h m.exe",1)
	FileMove($InjectionPath & "\Igrping.dll",$ClientLocation & "\Igrping.dll",1)
	ProgressUpdate("done!" & @CRLF & "Removing temporary files...")
	DirRemove(@ScriptDir & "\Temp",1)
	ProgressUpdate("done!")
	Sleep(500)
	ClearProgress()
	ProgressUpdate("Injection installed to \Injection folder in default UO directory." & @CRLF & ">>> ilaunch.exe starts Injection" & _
	@CRLF & @CRLF & "            Enjoy!")
EndFunc
Func WriteInjectionXML()
	Local $InjectionXMLFile = $ClientLocation & "\Injection\ilaunch.xml"
	If FileExists($InjectionXMLFile) Then FileDelete($InjectionXMLFile)
	FileWriteLine($InjectionXMLFile,"<?xml version='1.0'?>")
	FileWriteLine($InjectionXMLFile,@CRLF)
	FileWriteLine($InjectionXMLFile,"<config")
	FileWriteLine($InjectionXMLFile,'		last_server="0"')
	FileWriteLine($InjectionXMLFile,'		last_client="0"')
	FileWriteLine($InjectionXMLFile,'		client_dir="' & $ClientLocation & '"')
	FileWriteLine($InjectionXMLFile,'		ignition_cfg="' & $ClientLocation & '\Injection\Ignition.cfg"')
	FileWriteLine($InjectionXMLFile,'		use_injection="true"')
	FileWriteLine($InjectionXMLFile,'		close="true"')
	FileWriteLine($InjectionXMLFile,'		>')
	FileWriteLine($InjectionXMLFile,@CRLF)
	FileWriteLine($InjectionXMLFile,'	<server name="Imagine Nation" address="game.in-uo.net,2593" username="" password=""/>')
	FileWriteLine($InjectionXMLFile,'	<client name="5.0.1" path="' & $ClientLocation & '\5.0.1h m.exe"/>')
	FileWriteLine($InjectionXMLFile,'</config>')
EndFunc
#endregion-INJECTION SETUP
