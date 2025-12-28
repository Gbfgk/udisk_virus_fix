' mark_delete.vbs
' 使用 MoveFileEx 标记文件在重启时删除
' 参数: 文件完整路径

If WScript.Arguments.Count < 1 Then WScript.Quit(1)

filePath = WScript.Arguments(0)
Set fso = CreateObject("Scripting.FileSystemObject")
If Not fso.FileExists(filePath) Then WScript.Quit(1)

' 使用 \\?\ 长路径格式
longPath = "\\?\" & fso.GetAbsolutePathName(filePath)

' 调用 Windows API MoveFileEx
Set objShell = CreateObject("WScript.Shell")
' 通过 rundll32 调用 kernel32.MoveFileExW
cmd = "rundll32.exe kernel32.dll,MoveFileExW """ & longPath & """,,""4"""
objShell.Run cmd, 0, True
