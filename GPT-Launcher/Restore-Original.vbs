Set shell = CreateObject("WScript.Shell")
Set fso = CreateObject("Scripting.FileSystemObject")
backup = fso.BuildPath(fso.GetParentFolderName(WScript.ScriptFullName), "Original-ChatGPT.lnk")
target = fso.BuildPath(shell.SpecialFolders("Desktop"), "ChatGPT.lnk")
fso.CopyFile backup, target, True
MsgBox "Original ChatGPT shortcut restored.", 64, "GPT"
