@echo off
setlocal enabledelayedexpansion

echo =============================
echo  U盘病毒修复工具 (Batch/VBS)
echo  作者：安全响应团队
echo =============================
echo.

:: 创建日志
set LOG=%~dp0usb_fix.log
echo [%date% %time%] 工具启动 >> "%LOG%"

:: 步骤1: 枚举所有可移动磁盘（U盘）
echo 正在检测U盘...
set /a drive_count=0
for /f "skip=1 tokens=1,2" %%A in ('wmic logicaldisk where "DriveType=2" get DeviceID^,VolumeName 2^>nul') do (
    if "%%B" neq "" (
        set /a drive_count+=1
        set "drive_!drive_count!=%%A"
        set "label_!drive_count!=%%B"
        echo   [!] 发现U盘: %%A (卷标: %%B)
        echo [%date% %time%] 发现U盘 %%A >> "%LOG%"
    )
)

if %drive_count% equ 0 (
    echo [!] 未检测到U盘。
    echo [%date% %time%] 未检测到U盘 >> "%LOG%"
    pause
    exit /b
)

:: 步骤2: 遍历每个U盘
for /l %%i in (1,1,%drive_count%) do (
    call :fix_drive !drive_%%i! "!label_%%i!"
)

echo.
echo [√] 所有U盘处理完成！
echo [%date% %time%] 修复完成 >> "%LOG%"
pause
exit /b

:: ========================
:: 修复单个U盘子程序
:: ========================
:fix_drive
set DRIVE=%~1
set LABEL=%~2
echo.
echo [处理] %DRIVE% (%LABEL%)

:: (1) 清理根目录 .lnk 文件
for %%f in ("%DRIVE%\*.lnk") do (
    echo   删除快捷方式: %%~nxf
    del /f /q "%%f" 2>nul
    echo [%date% %time%] 删除 %%f >> "%LOG%"
)

:: (2) 删除 sysvolume 目录
if exist "%DRIVE%\sysvolume\" (
    echo   删除恶意目录: sysvolume
    rd /s /q "%DRIVE%\sysvolume" 2>nul
    echo [%date% %time%] 删除 sysvolume >> "%LOG%"
)

:: (3) 查找并还原被隐藏的原始文件目录
set FOUND_DIR=
for /d %%d in ("%DRIVE%\*") do (
    if /i not "%%~nxd"=="System Volume Information" (
        :: 检查是否为隐藏目录
        attrib "%%d" | findstr /i "H S" >nul && (
            :: 调用VBS检查是否包含用户文件
            cscript //nologo "%~dp0unhide.vbs" "%%d" >nul && (
                set "FOUND_DIR=%%d"
                goto :found_dir
            )
        )
    )
)
:found_dir

if defined FOUND_DIR (
    echo   发现伪装目录: %FOUND_DIR%
    echo [%date% %time%] 发现伪装目录 %FOUND_DIR% >> "%LOG%"
    
    :: 还原所有文件（取消隐藏属性）
    cscript //nologo "%~dp0unhide.vbs" "%FOUND_DIR%" "UNHIDE"
    
    :: 移动内容到根目录
    for %%i in ("%FOUND_DIR%\*") do (
        if not exist "%DRIVE%\%%~nxi" (
            echo     还原: %%~nxi
            move "%%i" "%DRIVE%\" >nul
            echo [%date% %time%] 还原 %%i >> "%LOG%"
        )
    )
    
    :: 删除空伪装目录
    rd "%FOUND_DIR%" 2>nul
)

exit /b
