' unhide.vbs
' 参数1: 目录路径
' 参数2 (可选): "UNHIDE" 表示还原属性，否则仅检测是否含用户文件

Set fso = CreateObject("Scripting.FileSystemObject")
Set args = WScript.Arguments

If args.Count < 1 Then WScript.Quit(1)

path = args(0)
If Not fso.FolderExists(path) Then WScript.Quit(1)

' 用户文件扩展名列表
userExts = Array(".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx", _
                 ".pdf", ".txt", ".jpg", ".jpeg", ".png", ".mp4", ".mp3")

Set folder = fso.GetFolder(path)

' 模式1: 仅检测（无第二参数）
If args.Count = 1 Then
    If ContainsUserFiles(folder, userExts) Then
        WScript.Quit(0) ' 找到用户文件
    Else
        WScript.Quit(1)
    End If
End If

' 模式2: 还原属性（第二参数为 UNHIDE）
If UCase(args(1)) = "UNHIDE" Then
    UnhideFolder folder
    WScript.Quit(0)
End If

Function ContainsUserFiles(fld, exts)
    ContainsUserFiles = False
    For Each f In fld.Files
        For Each e In exts
            If LCase(fso.GetExtensionName(f.Name)) = LCase(Replace(e, ".", "")) Then
                ContainsUserFiles = True
                Exit Function
            End If
        Next
    Next
    For Each subFld In fld.SubFolders
        If ContainsUserFiles(subFld, exts) Then
            ContainsUserFiles = True
            Exit Function
        End If
    Next
End Function

Sub UnhideFolder(fld)
    ' 清除隐藏和系统属性
    fld.Attributes = fld.Attributes And Not 2 ' Not Hidden
    fld.Attributes = fld.Attributes And Not 4 ' Not System
    For Each f In fld.Files
        f.Attributes = f.Attributes And Not 2
        f.Attributes = f.Attributes And Not 4
    Next
    For Each subFld In fld.SubFolders
        UnhideFolder subFld
    Next
End Sub
