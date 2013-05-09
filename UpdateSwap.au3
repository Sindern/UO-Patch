#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_icon=patcher.ico
#AutoIt3Wrapper_outfile=UpdateSwap.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_UseX64=n
#AutoIt3Wrapper_Res_Comment=This assists in updating IN-X Patcher and can be safely deleted.
#AutoIt3Wrapper_Res_Description=IN-X Patcher UpdateSwapper
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=eru@in-x.org
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_UseAnsi=y

Break(0)
While 1
  If ProcessExists("IN Patcher.exe") Then
		Sleep(10)
	Else
		ExitLoop
	EndIf
WEnd
FileCopy(@ScriptDir & "\Temp\IN Patcher.exe", @ScriptDir & "\IN Patcher.exe", 1)
DirRemove(@ScriptDir & "\Temp",1)
ShellExecute(@ScriptDir & "\IN Patcher.exe")
