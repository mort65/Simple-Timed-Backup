#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
;#Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#Persistent 
#SingleInstance, ignore 
sPath := ""
sDest := ""
sExt  := "das"
sExts :=""
sBackupt := "Backup is Running!"
sBackupf := "Backup is Stopped!"
iBackupCount := 10
tInterval := 300000 ; 5 min
toggle := 0
sCurrentTime :=""
bIsEDExtsenabled:=-1
bCopyallExts:=false
black:="c0x0"
lightblue:="c0x066dd"
maincolor:="bad8cf" 
red:="c0xe1256b"
blue:="c0x056bed"
lightgrey:="bad8cf"
lightgreen:="d0e970"
if (FileExist("STB_settings.ini"))
{   
	IniRead, sPath, STB_settings.ini, Paths, Files Location 
	IniRead, sDest, STB_settings.ini, Paths, Backups Location 
	IniRead, tInterval, STB_settings.ini, Option, Backup Interval , 300000 
	IniRead, iBackupCount, STB_settings.ini, Option, Backups Count , 10
	IniRead, iBkupNum, STB_settings.ini, History, Next Backup Number, 1
	IniRead, sExts, STB_settings.ini, Option , Extensions, "*;"
}
Else
{
	sExts:= "*;"
	IniWrite, %sPath%, STB_settings.ini, Paths, Files Location
	IniWrite, %sDest%, STB_settings.ini, Paths, Backups Location
	IniWrite, %tInterval%, STB_settings.ini, Option, Backup Interval 
	IniWrite, %iBackupCount%, STB_settings.ini, Option, Backups Count 
	IniWrite, %iBkupNum%, STB_settings.ini, History, Next Backup Number
	IniWrite, %sExts%, STB_settings.ini, Option , Extensions
}
fa := DllCall("LoadKeyboardLayout", "Str", "00000429", "Int", 1)
en := DllCall("LoadKeyboardLayout", "Str", "00000409", "Int", 1)
w := DllCall("GetForegroundWindow")
pid := DllCall("GetWindowThreadProcessId", "UInt", w, "Ptr", 0)
l := DllCall("GetKeyboardLayout", "UInt", pid)
if (l != en) 
{
    PostMessage 0x50, 0, %fa%,, A
}
Hotkey, ^!x, ExitSub
OnExit, ExitSub
Gui, +LastFound
WinSet, Transparent, 254
;Gui, Color, %maincolor%
GUI, -ToolWindow
Gui, +CAPTION
GUI, -MaximizeBox
Gui, Margin, 0, 0
Gui,Font, 
Gui,Add,Edit,x125 y56 w250 h22 %black%  ReadOnly vSLedit,
GuiControl,, SLedit, %sPath%
Gui,Add,Edit,x125 y128 w250 h22 %black% ReadOnly vBLedit,
GuiControl,, BLedit, %sDest%
Gui,Add,Button,x397 y56 w80 h25  vSPvar gSPbtn,Change
Gui,Add,Button,x398 y128 w80 h25 vBPvar gBPbtn,Change
Gui,Font,s9
Gui,Add,Text,x18 y58 w80 h13 %black%  Center,Files to Backup:
Gui,Add,Text,x23 y130 w90 h13 %black%  center ,Backups Location:
Gui,Font,
Gui,Add,Edit,x127 y198 w38 h18 %black% Number ReadOnly vBIedit gBIedit
mInterval := (tInterval/60000)
Gui,Add,UpDown, 0x20 Range1-720 ,%mInterval%,vBIud
Gui,Add,Edit,x126 y250 w38 h18 %black% Number ReadOnly vBCedit gBCedit
Gui,Add,UpDown,x146 y275 w18 h18 0x20 Range1-100,%iBackupCount%,vBCud
Gui,Font,s10 Normal ,tahoma
Gui,Add,Button,x80 y400 w112 h40 vcenter center vACvar gACbtn,Activate
Gui,Add,Button,x308 y400 w112 h40 +Disabled vDEvar gDEbtn,Deactivate 
Gui,Font,s8 Normal ,tahoma
Gui,Add,Text,x44 y200 w70 h13 %black% left ,Backup every:
Gui,Add,Text,x44 y250 w80 h13 %black% left  ,Backups count:
Gui,Add,Text,x170 y200 w40 h25 %black% ,minutes
Gui,Font,Normal s14  Bold ,Segoe UI
Gui,Add,Text,x30 y320 w200 h50 Center %red% vNotetext,%sBackupf%
Gui,Font,Normal s12 %black%,Tahoma
Gui,Add,Edit,x265 y200 w185 h103 %black% r4 1024 Lowercase Multi Border readonly 64 vextsediVar gextsEdit,%sExts%
Gui,Font,Normal s9 %black%
Gui,Add,Text,x268 y175 w140 h20 %black% -Wrap,File extensions to backup:
Gui,Add,Button,x335 y290 w45 h25  vEDbtnvar gextsEDbtn,Edit
Gui,Add,Button,x270 y290 w45 h25 disabled vEDbtnokvar gextsEDokbtn,Ok
Gui,Add,Button,x400 y290 w45 h25 disabled vEDbtncancelvar gextsEDcancelbtn,Cancel
;Gui,Add,Checkbox,x268 y320 w100 h20 %black% vFLCOPYcbxVar gFLCOPYcbx,Checkbox
Gui,Show,x390 y122 w500 h500 ,Simple Timed Backup
Return
extsEDcancelbtn:
{
	GuiControl,,extsediVar, %sExts%
	GuiControl, +ReadOnly, extsediVar
	GuiControl, Disabled, EDbtncancelvar
	GuiControl, Disabled, EDbtnokvar
	GuiControl, Enabled, EDbtnvar
	bIsEDExtsenabled := bIsEDExtsenabled * -1
	Return
}

FLCOPYcbx:
Return

extsEDbtn:
{ 
	if(bIsEDExtsenabled = -1)
	{
		GuiControl, -ReadOnly, extsediVar
		GuiControl, Enabled, EDbtncancelvar
		GuiControl, Enabled, EDbtnokvar
		GuiControl, Disabled, EDbtnvar
		bIsEDExtsenabled := bIsEDExtsenabled * -1
		return
	}
	else
	{
		GuiControl, +ReadOnly, extsediVar
		GuiControl, Disabled, EDbtncancelvar
		GuiControl, Disabled, EDbtnokvar
		GuiControl, Enabled, EDbtnvar
		bIsEDExtsenabled := bIsEDExtsenabled * -1
		return
	}
}
extsEDokbtn:
{
	GuiControlGet, Extstring ,, extsediVar, 
	StringReplace, Extstring,Extstring,`n,,All
	StringReplace, Extstring, Extstring,%A_SPACE%,, All
	StringReplace, Extstring, Extstring,%A_Tab%,, All
	StringReplace, Extstring, Extstring,/,, All
	StringReplace, Extstring, Extstring,\,, All
	StringReplace, Extstring, Extstring,:,, All
	StringReplace, Extstring, Extstring,|,, All
	StringReplace, Extstring, Extstring,",, All
	StringReplace, Extstring, Extstring,<,, All
	StringReplace, Extstring, Extstring,>,, All
	StringReplace, Extstring, Extstring,`,,, All
	sExts := Extstring
	GuiControl,,extsediVar, %sExts%
	GuiControl, +ReadOnly, extsediVar
	GuiControl, Disabled, EDbtncancelvar
	GuiControl, Disabled, EDbtnokvar
	GuiControl, Enabled, EDbtnvar
	bIsEDExtsenabled := bIsEDExtsenabled * -1
	Return
}
SPbtn:
{
	FileSelectFolder,OutputVar1 , , 0
	GuiControl,, SLedit, %OutputVar1%
	sPath := OutputVar1
	IniWrite, %sPath%, STB_settings.ini, Paths, Files Location
	Return
}
BPbtn:
{
	FileSelectFolder,OutputVar2 , , 3
	GuiControl,, BLedit, %OutputVar2%
	sDest := OutputVar2
	IniWrite, %sDest%, STB_settings.ini, Paths, Backups Location
	Return	
}
BIedit:
{
	GuiControlGet , BIedit
	tInterval := BIedit*60000
	IniWrite, %tInterval%, STB_settings.ini, Option, Backup Interval 
	Return
}
BCedit:
{
	GuiControlGet , BCedit
	iBackupCount := BCedit
	IniWrite, %iBackupCount%, STB_settings.ini, Option, Backups Count
	Return
}
BCud:
{
	GuiControlGet , BCud
	iBackupCount := BCud
	IniWrite, %iBackupCount%, STB_settings.ini, Option, Backups Count
	Return
}
BIud:
{
	GuiControlGet , BIud
	tInterval := BIud*60000
	IniWrite, %tInterval%, STB_settings.ini, Option, Backups Interval 
	Return
}
extsEdit:
{
	ExtArr := Object()
	GuiControlGet, Extstring ,, extsediVar, 
	StringReplace,Extstring,Extstring,`n,,All
	StringReplace, Extstring, Extstring,%A_SPACE%,, All
	StringReplace, Extstring, Extstring,%A_Tab%,, All
	StringReplace, Extstring, Extstring,/,, All
	StringReplace, Extstring, Extstring,\,, All
	StringReplace, Extstring, Extstring,:,, All
	StringReplace, Extstring, Extstring,|,, All
	StringReplace, Extstring, Extstring,",, All
	StringReplace, Extstring, Extstring,<,, All
	StringReplace, Extstring, Extstring,>,, All
	StringReplace, Extstring, Extstring,`,,, All
	StringSplit, ExtArr, Extstring ,`;,`n
}
Return
ACbtn:
{
	if(bIsEDExtsenabled := 1)
	{
		GuiControl,,extsediVar, %sExts%
	}	
	Gui, Submit , NoHide
	GuiControlGet, sPath,, SLedit
	GuiControlGet, sDest,, BLedit
	GuiControlGet, tInterVal,, BIedit
	GuiControlGet, iBackupCount,, BCedit
	GuiControlGet, Extstring ,, extsediVar, 
	StringReplace, Extstring,Extstring,`n,,All
	StringReplace, Extstring, Extstring,%A_SPACE%,, All
	StringReplace, Extstring, Extstring,%A_Tab%,, All
	StringReplace, Extstring, Extstring,/,, All
	StringReplace, Extstring, Extstring,\,, All
	StringReplace, Extstring, Extstring,:,, All
	StringReplace, Extstring, Extstring,|,, All
	StringReplace, Extstring, Extstring,",, All
	StringReplace, Extstring, Extstring,<,, All
	StringReplace, Extstring, Extstring,>,, All
	StringReplace, Extstring, Extstring,`,,, All
	sExts := Extstring
	StringSplit, ExtArr, Extstring ,`;,
	PathPattern := spath
	sPVar :=InStr(FileExist(PathPattern),"D")
	if(tInterval="" )
	{
		tInterval := 300000
		GuiControl, , BIud,%tInterval%
	}
	Else If (iBackupCount="")
	{
		iBackupCount := 10
	}
	Else If (sPVar=0)
	{
		msgbox,The foldername you entered could not be found: %sPath%
		return
	}
	Else If tInterval not between 1 and 720
	{
		msgbox,Your Backup Interval is not within the valid range: 1-720
		return
	}
	Else If  iBackupCount not between 1 and 100
	{
		msgbox,Your Backup Count is not within the valid range: 1-100
		return
	}
	Else
	{
		If (sPath=sDest)
		{
			sDest.="\Backups"
			GuiControl,, BLedit, %sDest%
			IniWrite, %sDest%, STB_settings.ini, Paths, Backups Location
		}
		If (sDest="")
		{
			sDest:=sPath
			sDest.="\Backups"
			GuiControl,, BLedit, %sDest%
			IniWrite, %sDest%, STB_settings.ini, Paths, Backups Location
		}
		DestPattern := sDest
		sDVar :=InStr(FileExist(DestPattern),"D")
		If (sDVar=0)
		{
			FileCreateDir, %sDest%
			erl:=ErrorLevel
			if(erl<>0)
			{
				msgbox,The foldername you entered could not be created: %sDest%
				return
			}
		}
		tInterval:=tInterval*60000
		GuiControl,Disable,ACvar
		GuiControl,Enable,DEvar
		GuiControl,Disable,SPvar
		GuiControl,Disable,BPvar
		GuiControl,Disable,BCedit
		GuiControl,Disable,BIedit
		GuiControl,Disable,SLedit
		GuiControl,Disable,BLedit
		GuiControl,Disabled,EDbtnvar
		GuiControl, Disabled, EDbtncancelvar
		GuiControl, Disabled, EDbtnokvar
		GuiControl,,Notetext,%sBackupt%
		Gui,Font,Normal s14 Bold %blue% ,Segoe UI
		GuiControl, Font, Notetext 
		if(iBkupNum="")
		{
			iBkupNum := 1
		}
		else
		{
			if iBkupNum not between 1 and %iBackupCount%
			iBkupNum := 1
		}
		i := iBackupCount
		while (i >= 0 )
		{
			FileCreateDir, %sDest%\Backup_%i%
			i := i-1
		}
		sleep,2000
		sLogfullpath :=sDest
		sLogfullpath.="\stbackup_log.txt"
		bCopyallExts:=false
		loop, %ExtArr0%
		{
			if(ExtArr%A_Index%="*")
			{
				bCopyallExts:=true
				Break
			}
		}
		if(bCopyallExts=false)
		{
			loop, %ExtArr0%
			{
				if(ExtArr%A_Index%<>"")
				{
					tempExt:=ExtArr%A_Index%
					FileCopy, %sPath%\*.%tempExt%, %sDest%\Backup_0\, 1
					ErrorCount := ErrorLevel
					If (ErrorCount = 0)
					{
						FormatTime, sNow, %a_now%, [yyyy-MM-dd%a_space%hh:mm:ss]
						xttemp:=ExtArr%A_Index%
						if FileExist(sLogfullpath)
						{
							FileGetSize, logsizekb, %sLogfullpath%, K
							if(logsizekb>500)
							{
								FileDelete, %sLogfullpath%
								FileAppend ,%sNow% backup started..., %sLogfullpath%
								FileAppend ,`n%sNow% autobackup created `, extension:%xttemp% `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
							}
							else
							{
								FileAppend ,`n%sNow% backup started..., %sLogfullpath%
								FileAppend ,`n%sNow% autobackup created `, extension:%xttemp% `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
							}
						}
						else
						{
							FileAppend ,%sNow% backup started..., %sLogfullpath%
							FileAppend ,`n%sNow% autobackup created `, extension:%xttemp% `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
						}
						FileDelete, %sDest%\Backup_0\log.txt
						FormatTime, sCurrentTime ,  dddd MMMM d yyyy hh:mm:ss tt
						FileAppend ,*.%xttemp% autoBackup Created in %sCurrentTime%,%sDest%\Backup_0\log.txt
					}
					Else
					{
						FormatTime, sNow, %a_now%, [yyyy-MM-dd%a_space%hh:mm:ss]
						xttemp:=ExtArr%A_Index%
						if FileExist(sLogfullpath)
						{
							FileAppend ,`n%sNow% warning! `, extension:%xttemp% `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
							FileAppend ,`n%sNow% can`t copy %ErrorCount% file(s)!
						}
						else
						{
							FileAppend ,%sNow% warning! `, extension:%xttemp% `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
							FileAppend ,`n%sNow% can`t copy %ErrorCount% file(s)!
						}
					}
				}
			}
		}
		Else 
		{
			FileCopy, %sPath%\*.*, %sDest%\Backup_0\, 1
			ErrorCount := ErrorLevel
			If (ErrorCount = 0)
			{

				FileDelete, %sDest%\Backup_0\log.txt
				FormatTime, sNow, %a_now%, [yyyy-MM-dd%a_space%hh:mm:ss]
				FormatTime, sCurrentTime ,  dddd MMMM d yyyy hh:mm:ss tt
				if FileExist(sLogfullpath)
				{
					FileGetSize, logsizekb, %sLogfullpath%, K
					if(logsizekb>500)
					{
						FileDelete, %sLogfullpath%
						FileAppend ,%sNow% backup started..., %sLogfullpath%
						FileAppend ,`n%sNow% autobackup created `, extension:* `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
					}
					else
					{
						FileAppend ,`n%sNow% backup started..., %sLogfullpath%
						FileAppend ,`n%sNow% autobackup created `, extension* `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
					}
				}
				else
				{
					FileAppend ,%sNow% backup started..., %sLogfullpath%
					FileAppend ,`n%sNow% autobackup created `, extension:* `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
				}
				FileAppend ,*.* autoBackup Created in %sCurrentTime%,%sDest%\Backup_0\log.txt
			}
			else
			{
				FormatTime, sNow, %a_now%, [yyyy-MM-dd%a_space%hh:mm:ss]
				if FileExist(sLogfullpath)
				{
					FileAppend ,`n%sNow% warning! `, extension:* `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
					FileAppend ,`n%sNow% can`t copy %ErrorCount% file(s)!
				}
				else 
				{
					FileAppend ,%sNow% warning! `, extension:* `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
					FileAppend ,`n%sNow% can`t copy %ErrorCount% file(s)!
				}
			}
		}
		Gosub, ToggleBackup
	}
	Return
}
DEbtn:
GuiControl,Disable,DEvar
GuiControl,Enable,ACvar
GuiControl,Enable,SPvar
GuiControl,Enable,BPvar
GuiControl,Enable,BCedit
GuiControl,Enable,BIedit
GuiControl,Enable,SLedit
GuiControl,Enable,BLedit
if(bIsEDExtsenabled = -1)
{
	GuiControl,Enable,EDbtnvar
}
else
{
	GuiControl, Enable, EDbtncancelvar
	GuiControl, Enable, EDbtnokvar
}
GuiControl,,Notetext,%sBackupf%
Gui,Font,Normal s14 Bold %red% ,Segoe UI
GuiControl, Font, Notetext 
if(bCopyallExts=false)
{
	loop, %ExtArr0%
	{
		if(ExtArr%A_Index%<>"")
		{
			tempExt:=ExtArr%A_Index%
			FileCopy, %sPath%\*.%tempExt%, %sDest%\Backup_0\, 1
			ErrorCount := ErrorLevel
			If (ErrorCount = 0)
			{
				FormatTime, sNow, %a_now%, [yyyy-MM-dd%a_space%hh:mm:ss]
				xttemp:=ExtArr%A_Index%
				if FileExist(sLogfullpath)
				{
					FileGetSize, logsizekb, %sLogfullpath%, K
					if(logsizekb>500)
					{
						FileDelete, %sLogfullpath%
						FileAppend ,%sNow% backup stopped..., %sLogfullpath%
						FileAppend ,`n%sNow% autobackup created `, extension:%xttemp% `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
					}
					else
					{
						FileAppend ,`n%sNow% backup stopped..., %sLogfullpath%
						FileAppend ,`n%sNow% autobackup created `, extension:%xttemp% `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
					}
				}
				else
				{
					FileAppend ,%sNow% backup stopped..., %sLogfullpath%
					FileAppend ,`n%sNow% autobackup created `, extension:%xttemp% `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
				}
				FileDelete, %sDest%\Backup_0\log.txt
				FormatTime, sCurrentTime ,  dddd MMMM d yyyy hh:mm:ss tt
				FileAppend ,*.%xttemp% autoBackup Created in %sCurrentTime%,%sDest%\Backup_0\log.txt
			}
			else
			{
				FormatTime, sNow, %a_now%, [yyyy-MM-dd%a_space%hh:mm:ss]
				if FileExist(sLogfullpath)
				{
					FileAppend ,`n%sNow% warning! `, extension:%xttemp% `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
					FileAppend ,`n%sNow% can`t copy %ErrorCount% file(s)!
				}
				else 
				{
					FileAppend ,%sNow% warning! `, extension:%xttemp% `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
					FileAppend ,`n%sNow% can`t copy %ErrorCount% file(s)!
				}
			}
		}
	}
}
Else 
{
	FileCopy, %sPath%\*.*, %sDest%\Backup_0\, 1
	ErrorCount := ErrorLevel
	If (ErrorCount = 0)
	{

		FileDelete, %sDest%\Backup_0\log.txt
		FormatTime, sNow, %a_now%, [yyyy-MM-dd%a_space%hh:mm:ss]
		FormatTime, sCurrentTime ,  dddd MMMM d yyyy hh:mm:ss tt
		if FileExist(sLogfullpath)
		{
			FileGetSize, logsizekb, %sLogfullpath%, K
			if(logsizekb>500)
			{
				FileDelete, %sLogfullpath%
				FileAppend ,%sNow% backup stopped..., %sLogfullpath%
				FileAppend ,`n%sNow% autobackup created `, extension:* `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
			}
			else
			{
				FileAppend ,`n%sNow% backup stopped..., %sLogfullpath%
				FileAppend ,`n%sNow% autobackup created `, extension* `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
			}
		}
		else
		{
			FileAppend ,%sNow% backup stopped..., %sLogfullpath%
			FileAppend ,`n%sNow% autobackup created `, extension:* `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
		}
		FileAppend ,*.* autoBackup Created in %sCurrentTime%,%sDest%\Backup_0\log.txt
	}
	else 
	{
		FormatTime, sNow, %a_now%, [yyyy-MM-dd%a_space%hh:mm:ss]
		if FileExist(sLogfullpath)
		{
			FileAppend ,`n%sNow% warning! `, extension:* `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
			FileAppend ,`n%sNow% can`t copy %ErrorCount% file(s)!
		}
		else 
		{
			FileAppend ,%sNow% warning! `, extension:* `, source:%sPath%\ `, destination:%sDest%\Backup_0\, %sLogfullpath%
			FileAppend ,`n%sNow% can`t copy %ErrorCount% file(s)!
		}
	}
}
Gosub, ToggleBackup
return
GuiClose:
Gosub, ExitSub
Return
ToggleBackup:
{
	toggle := !toggle
	if (toggle) 
	{
		if(tInterval < 60000)
		{
			tInterval:=60000
		}
		SetTimer, Backup, %tInterval%
	}
	else
	{
		SetTImer, Backup, Off
	}
	return
}
backup:
{
	if(bCopyallExts = false)
	{
		loop, %ExtArr0%
		{
			if(ExtArr%A_Index% <> "")
			{
				tempExt1:=ExtArr%A_Index%
				FileCopy, %sPath%\*.%tempExt1%, %sDest%\Backup_%iBkupNum%\, 1
				ErrorCount := ErrorLevel
				If (ErrorCount = 0)
				{

					FormatTime, sNow, %a_now%, [yyyy-MM-dd%a_space%hh:mm:ss]
					xttemp:=ExtArr%A_Index%
					if FileExist(sLogfullpath)
					{
						FileGetSize, logsizekb, %sLogfullpath%, K
						if(logsizekb>500)
						{
							FileDelete, %sLogfullpath%
							FileAppend ,%sNow% backup created `, extension:%xttemp% `, source:%sPath%\ `, destination:%sDest%\Backup_%iBkupNum%\, %sLogfullpath%
						}
						else
						{
							FileAppend ,`n%sNow% backup created `, extension:%xttemp% `, source:%sPath%\ `, destination:%sDest%\Backup_%iBkupNum%\, %sLogfullpath%
						}
					}
					else
					{
						FileAppend ,%sNow% backup created `, extension:%xttemp% `, source:%sPath%\ `, destination:%sDest%\Backup_%iBkupNum%\, %sLogfullpath%
					}
					FileDelete, %sDest%\Backup_%iBkupNum%\log.txt
					FormatTime, sCurrentTime ,  dddd MMMM d yyyy hh:mm:ss tt
					FileAppend ,backup from *.%xttemp% Created in %sCurrentTime%,%sDest%\Backup_%iBkupNum%\log.txt
				}
				else
				{
					FormatTime, sNow, %a_now%, [yyyy-MM-dd%a_space%hh:mm:ss]
					xttemp:=ExtArr%A_Index%
					If FileExist(sLogfullpath)
					{
						FileAppend ,`n%sNow% warning! `, extension:%xttemp% `, source:%sPath%\ `, destination:%sDest%\Backup_%iBkupNum%\, %sLogfullpath%
						FileAppend ,`n%sNow% can`t copy %ErrorCount% file(s)!
					}
					else
					{
						FileAppend ,%sNow% warning! `, extension:%xttemp% `, source:%sPath%\ `, destination:%sDest%\Backup_%iBkupNum%\, %sLogfullpath%
						FileAppend ,`n%sNow% can`t copy %ErrorCount% file(s)!
					}
				}
			}
		}
	}
	else If ( bCopyallExts = True)
	{
		FileCopy, %sPath%\*.*, %sDest%\Backup_%iBkupNum%\, 1
		If (ErrorCount = 0)
		{
			FileDelete, %sDest%\Backup_%iBkupNum%\log.txt
			FormatTime, sNow, %a_now%, [yyyy-MM-dd%a_space%hh:mm:ss]
			FormatTime, sCurrentTime ,  dddd MMMM d yyyy hh:mm:ss tt
			if FileExist(sLogfullpath)
			{
				FileGetSize, logsizekb, %sLogfullpath%, K
				if(logsizekb>500)
				{
					FileDelete, %sLogfullpath%
					FileAppend ,%sNow% backup created `, extension:* `, source:%sPath%\ `, destination:%sDest%\Backup_%iBkupNum%\, %sLogfullpath%
				}
				else
				{
					FileAppend ,`n%sNow% backup created `, extension:* `, source:%sPath%\ `, destination:%sDest%\Backup_%iBkupNum%\, %sLogfullpath%
				}
			}
			else
			{
				FileAppend ,%sNow% backup created `, extension:* `, source:%sPath%\ `, destination:%sDest%\Backup_%iBkupNum%\, %sLogfullpath%
			}
			FileAppend ,backup from *.* Created in %sCurrentTime%,%sDest%\Backup_%iBkupNum%\log.txt
		}
		else
		{
			FormatTime, sNow, %a_now%, [yyyy-MM-dd%a_space%hh:mm:ss]
			if FileExist(sLogfullpath)
			{
				FileAppend ,`n%sNow% warning! `, extension:* `, source:%sPath%\ `, destination:%sDest%\Backup_%iBkupNum%\, %sLogfullpath%
				FileAppend ,`n%sNow% can`t copy %ErrorCount% file(s)!
			}
			else
			{
				FileAppend ,%sNow% warning! `, extension:* `, source:%sPath%\ `, destination:%sDest%\Backup_%iBkupNum%\, %sLogfullpath%
				FileAppend ,`n%sNow% can`t copy %ErrorCount% file(s)!
			}
		}
	}
	iBkupNum := iBkupNum + 1
	if (iBkupNum > iBackupCount )
	{
		iBkupNum := 1
	}
	Return
}
ExitSub:
{
	if A_ExitReason not in Logoff,Shutdown  
	{
		SetTImer, Backup, Off
		sleep, 50
		GuiControlGet, Extstring ,, extsediVar, 
		StringReplace, Extstring,Extstring,`n,,All
		StringReplace, Extstring, Extstring,%A_SPACE%,, All
		StringReplace, Extstring, Extstring,%A_Tab%,, All
		StringReplace, Extstring, Extstring,/,, All
		StringReplace, Extstring, Extstring,\,, All
		StringReplace, Extstring, Extstring,:,, All
		StringReplace, Extstring, Extstring,|,, All
		StringReplace, Extstring, Extstring,",, All
		StringReplace, Extstring, Extstring,<,, All
		StringReplace, Extstring, Extstring,>,, All
		StringReplace, Extstring, Extstring,`,,, All
		if(Extstring ="")
		{
			sExts := "*;"
		}
		Else
		{
			sExts := Extstring
		}
		IniWrite, %sPath%, STB_settings.ini, Paths, Files Location
		IniWrite, %sDest%, STB_settings.ini, Paths, Backups Location
		IniWrite, %tInterval%, STB_settings.ini, Option, Backup Interval 
		IniWrite, %iBackupCount%, STB_settings.ini, Option, Backups Count 
		IniWrite, %iBkupNum%, STB_settings.ini, History, Next Backup Number
		IniWrite, %sExts%, STB_settings.ini, Option , Extensions
		FormatTime, sNow, %a_now%, [yyyy-MM-dd%a_space%hh:mm:ss]
		FileAppend ,`n%sNow% exiting program..., %sLogfullpath%
		sleep, 50
	}
	ExitApp
}
