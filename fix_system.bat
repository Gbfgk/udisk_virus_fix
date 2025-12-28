@echo off
setlocal

echo ===============================
echo  系统挖矿木马修复工具 (CMD/VBS)
echo  仅清除报告中确认的恶意文件
echo ===============================
echo.

:: 日志
set LOG=%~dp0system_fix.log
echo [%date% %time%] 启动修复 >> "%LOG%"

:: 步骤1: 清理 Defender 非法排除项（通过注册表）
echo [1/3] 正在清理 Windows Defender 排除项...
reg delete "HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /v "C:\Windows\System32" /f 2>nul && (
    echo   已移除排除项: C:\Windows\System32
    echo [%date% %time%] 移除 Defender 排除项 >> "%LOG%"
)
reg delete "HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /v "%USERPROFILE%\Desktop\sysvolume" /f 2>nul && (
    echo   已移除排除项: Desktop\sysvolume
    echo [%date% %time%] 移除 sysvolume 排除 >> "%LOG%"
)

:: 步骤2: 标记恶意 DLL 为重启删除
echo [2/3] 正在标记恶意文件重启删除...
for %%f in (
    "C:\Windows\System32\u253774.dat"
    "C:\Windows\System32\u377573.dll"
    "C:\Windows\System32\u121373.bat"
    "C:\Windows\System32\u889079.vbs"
) do (
    if exist %%f (
        echo   标记删除: %%~nxf
        cscript //nologo "%~dp0mark_delete.vbs" %%f
        echo [%date% %time%] 标记 %%f >> "%LOG%"
    )
)

:: 步骤3: 运行系统文件检查（建议在重启前执行）
echo [3/3] 建议运行系统文件检查（sfc /scannow）以确保系统完整性
echo        请在重启后以管理员身份运行:
echo        sfc /scannow
echo        DISM /Online /Cleanup-Image /RestoreHealth

echo.
echo [√] 修复操作已完成！
echo     请**重启计算机**以彻底清除恶意文件。
pause
