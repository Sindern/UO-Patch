#cs ----------------------------------------------------------------------------
1) Check to see if timestamp on file is different from the timestamp stored in the ini file.
2) If differnt, updates the file by adding it to filename.mul.zip in the dropbox folder, overwriting the old
3) Keeps a running list of updated files, then adds them all to the Full Package zip file, overwriting the old files within the zip.
**Also will copy files that are different to the UO folder that is set in $UODir

Requirements:
Set paths of the UO, Mul files, and DropBox folder.  Must have trailing \ unless it's a file.
Must have the 7zip command line executable in the System32 folder.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <GUIConstantsEX.au3>
#include <WindowsConstants.au3>
#include <file.au3>
#include <Crypt.au3>

#region Paths & Globals
Global $DropBox = @ScriptDir & "\patcher\"
Global $FullPackage = @ScriptDir & "\patcher\IN_Full_Package.zip"
Global $CurrentINI = $DropBox & "current.ini"
Global $LogFile = $Dropbox & "staticupdates.log"
;Files that are automatically synced to the server with Syncplicity
Global $FilesStatic=@ScriptDir & "\servermuls\"
Global $FileS[32]=["statics0.mul","staidx0.mul","statics1.mul","staidx1.mul","statics2.mul","staidx2.mul","statics3.mul","staidx3.mul","statics4.mul","staidx4.mul","tiledata.mul", _
  "animdata.mul","anim.mul","anim.idx","anim2.mul","anim2.idx","anim2.def","anim3.mul","anim3.idx","anim3.def","anim4.mul","anim4.idx", "anim5.mul","anim5.idx", _
	"gumpart.mul","gumpidx.mul","body.def","hues.mul","art.mul","artidx.mul","mobtypes.txt","bodyconv.def"]
; Misc/Non-Path Globals
Global $FilesTotalS = UBound($FileS)
Global $ChangedFiles  ;things that need to be updated on FullPackage.zip
#endregion

If Not FileExists(@SystemDir & "\7zG.exe") Then
	MsgBox(0,"7zG.exe not found!","You don't have 7zG.exe in the " & @SystemDir & " directory; the static updater needs this file in order to zip up the statics with no errors or false patches...  Update DID NOT complete.")
	Exit
EndIf

FileMove($LogFile,@TempDir & "\LogBak.txt",1)
If FileExists(@TempDir & "\PatcherUpdateTime.txt") Then FileDelete(@TempDir & "\PatcherUpdateTime.txt")
FileWriteLine(@TempDir & "\PatcherUpdateTime.txt","Gives the patcher the updated time.")
Do
	Sleep(100)
Until FileExists(@TempDir & "\PatcherUpdateTime.txt")
Local $UpdateTime = FileGetTime(@TempDir & "\PatcherUpdateTime.txt")  ;check the current time, then write this to the update log.  This is just to create a nice log that can be pasted to the forums.
LogWrite("-=(Update Log for  " & $UpdateTime[0] & "." & $UpdateTime[1] & "." & $UpdateTime[2] & " @ " & $UpdateTime[3] & ":" & $UpdateTime[4] & ":" & $UpdateTime[5] & ")=-" & @CRLF) ;Logging
CheckFiles($FilesStatic,$FileS)						;and update individual files
UpdateFullPackage()									;and the full package
AppendOldLog()
IniWrite($CurrentINI,"Current","tiledata.mul.6","0x390936FD46B653DE2443CEC73E14D882")
MsgBox(0,"Done","All statics are up to date.")

#region BEYOND HERE BE FUNCTIONS
Func CheckFiles($Path,$File)  ;This is the heart and soul of the updater... the thing that checks for changes.
	For $i=0 to UBound($File) - 1 Step 1  ;It's a for loop!  Yay.  Now don't touch it.
		Local $Hash = _Crypt_HashFile($Path & $File[$i],$CALG_MD5)
		Local $TimeStamp = FileGetTime($Path & $File[$i],0,0)  ;It creates $TimeStamp2 as an Array instead of a string so I can create log files.  Dont' mess with this.
		ConsoleWrite(@CRLF & "Testing " & $File[$i] & " : OldTS:" & IniRead($CurrentINI,"Current",$File[$i],"") & " :: NewTS:" & $Hash)
		If $Hash <> IniRead($CurrentINI,"Current",$File[$i],"") Then   ;If the timestamp is different from the time written in the .ini file, then:
			LogWrite($File[$i] & "  (" & Round(FileGetSize($Path & $File[$i]) / 1024,2) & " KB) was modified on " & $TimeStamp[0] & "." & $TimeStamp[1] & "." & $TimeStamp[2] & " @ " & $TimeStamp[3] & ":" & $TimeStamp[4] & ":" & $TimeStamp[5] & @CRLF)  ;Creates a fancy log entry with the time the file was updated.
			ZipUp($Path, $File[$i])  ;Zips the file up.  See the function below.
			IniWrite($CurrentINI,"Current",$File[$i],$Hash)  ;Writes the current $TimeStamp to the .ini file so that it won't update it again till it changes.
			$ChangedFiles = $ChangedFiles & '"' & $Path & $File[$i] & '" ' ;Adds the file to the list of files to be added to the FullPackage.zip
		EndIf
	Next
EndFunc ;==>CheckFiles
Func ZipUp($Path,$FileName) ;This function will zip up the file that is being updated.
	FileDelete($DropBox & "repo\" & $FileName & ".zip")  ;delete the old version of the file
	RunWait("7zg a -tzip " & '"' & $DropBox & "repo\" & $FileName & '.zip" "' & $Path & $FileName & '"') ;Fancy shit that will make 7zip zip the file.  Don't touch.
	ConsoleWrite(@CRLF & "  7zg a -tzip " & '"' & $DropBox & "repo\" & $FileName & '.zip" "' & $Path & $FileName & '"') ;Fancy shit that will make 7zip zip the file.  Don't touch.
EndFunc ;==>ZipUp
Func UpdateFullPackage()
	If Not $ChangedFiles = "" Then  ;If the list of files to update is not blank, then:
		RunWait("7zg a -tzip " & '"' & $FullPackage & '" ' & $ChangedFiles)  ;Sends the huge line to 7zip to have it update all the full package.
		ConsoleWrite(@CRLF & @CRLF & "7zg a -tzip " & '"' & $FullPackage & '" ' & $ChangedFiles)
	Else ;if there were *NO CHANGES*, then restore the old log file to prevent spam.
		FileDelete($LogFile) ;AppendOldLog will restore it.
		ConsoleWrite(@CRLF & @CRLF & "NOTHING TO UPDATE!")
	EndIf
EndFunc ;==>UpdateFullPackage

Func LogWrite($LogData)
	FileWrite($LogFile,$LogData) ;Logging function.  Can be Ignored.
EndFunc

Func AppendOldLog()
	LogWrite(@CRLF)
	Local $OldLogFile = FileOpen(@TempDir & "\LogBak.txt")
	LogWrite(FileReadLine($OldLogFile,1) & @CRLF)
	For $i=2 to _FileCountLines(@TempDir & "\LogBak.txt") Step 1
		LogWrite(FileReadLine($OldLogFile) & @CRLF)
	Next
EndFunc

#endregion ABOVE HERE BE FUNCTIONS
