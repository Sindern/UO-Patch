#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseX64=n
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.6.1
 Author:         myName

 Script Function:
  Simple thing that automatically updates a change log file with a specific format for including
    in a webpage via dropbox.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here

#include <GUIConstantsEX.au3>
#include <File.au3>

Global $LogFile = @ScriptDir & "\downloads\minorupdates.txt"

$GUI = GUICreate("InGame Change Update",250,100,-1,-1,0x80020000,0x00000008)
GUISetBkColor(0x000000)
Global $Name = GUICtrlCreateInput("???",203,55,46,18,0x1044)
GUICtrlSetColor($Name,0xAAAAAA)
GUICtrlSetBkColor($Name,0x454545)
Global $Update = GUICtrlCreateButton("Upd8",203,0,46,30)
GUICtrlSetColor($Update,0xAAAAAA)
GUICtrlSetBkColor($Update,0x333333)
Global $Exit = GUICtrlCreateButton("Exit",203,31,46,20)
GUICtrlSetColor($Exit,0xAAAAAA)
GUICtrlSetBkColor($Exit,0x333333)
Global $Input = GUICtrlCreateInput("",1,1,201,97,0x1044)
GUICtrlSetColor($Input,0xAAAAAA)
GUICtrlSetBkColor($Input,0x333333)
Global $Label = GUICtrlCreateLabel("    Drag",203,78,48,22,-1,0x00100000)
GUICtrlSetColor($Label,0xEEEEEE)
GUISetState(@SW_SHOW)

While 1
	$MSG = GUIGetMsg()
	Select
		Case $MSG = -3 Or $MSG = $Exit
			Exit
		Case $MSG = $Update
			UpdateLog()
			Exit
	EndSelect
	Sleep(100)
WEnd


Func UpdateLog()
	FileMove($LogFile, @TempDir & "\oldchangelog.txt",1)
	Local $LogFile2 = @TempDir & "\oldchangelog.txt"
	Local $UpdateFileText = "  -=( " & GetDate() & " )=-       <|" & GUICtrlRead($Name) & "|>" & @CRLF & GUICtrlRead($Input) & @CRLF & @CRLF
	Local $VLogFile = FileOpen($LogFile2)
	Local $FileSize = _FileCountLines($LogFile2)
	$UpdateFileText = $UpdateFileText & FileReadLine($VLogFile,1) & @CRLF
	For $i=2 to $FileSize Step 1
		$UpdateFileText = $UpdateFileText & FileReadLine($VLogFile) & @CRLF
		If @error = 1 Then ExitLoop
	Next
	FileWrite($LogFile,$UpdateFileText)
EndFunc

Func GetDate()
	Local $TempFile = @TempDir & "\IGCU.temp.txt"
	FileWriteLine($TempFile,".")
	Local $Time = FileGetTime($TempFile,0,0)
	Return $Time[0] & "." & $Time[1] & "." & $Time[2] & " @ " & $Time[3] & ":" & $Time[4] & ":" & $Time[5]
EndFunc
