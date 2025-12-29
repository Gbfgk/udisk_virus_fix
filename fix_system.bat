@echo off
setlocal enabledelayedexpansion

echo ===============================
echo  挖矿病毒修复工具 (svctrl64 + u######)
echo ===============================

:: 日志
set LOG=%~dp0system_fix.log
echo [%date% %time%] 启动修复 >> "%LOG%"

:: 必须管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] 错误：需要管理员权限！
    echo      请右键选择“以管理员身份运行”。
    pause
    exit /b
)

:: 步骤1: 清理 Defender 排除项（注册表）
echo [1/4] 清理 Defender 排除项...
reg delete "HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /v "C:\Windows\System32" /f >nul 2>&1 && (
    echo   已移除: C:\Windows\System32
)
reg delete "HKLM\SOFTWARE\Microsoft\Windows Defender\Exclusions\Paths" /f >nul 2>&1

:: 步骤2: 定位所有待删除文件
set "TARGETS="
:: 固定主载荷
if exist "C:\Windows\System32\svctrl64.exe" set TARGETS=!TARGETS! "C:\Windows\System32\svctrl64.exe"

:: 随机 u###### 文件（遍历所有匹配）
for %%f in (
    "C:\Windows\System32\u*.dll"
    "C:\Windows\System32\u*.dat"
    "C:\Windows\System32\u*.bat"
    "C:\Windows\System32\u*.vbs"
) do (
    set "name=%%~nf"
    set "ext=%%~xf"
    call :is_u6digit "!name!"
    if !is_match! equ 1 (
        set TARGETS=!TARGETS! "%%f"
    )
)

:: 步骤3: 标记所有文件重启删除
echo [2/4] 标记恶意文件重启删除...
if defined TARGETS (
    for %%f in (!TARGETS!) do (
        echo   标记: %%~nxf
        cscript //nologo "%~dp0mark_delete.vbs" %%f
        echo [%date% %time%] 标记 %%f >> "%LOG%"
    )
) else (
    echo   未发现恶意文件。
)

:: 步骤4: 清理持久化（计划任务、启动项）
echo [3/4] 清理计划任务...
schtasks /delete /tn "\Microsoft\svctrl" /f >nul 2>&1 && echo   已删除计划任务: svctrl

echo [4/4] 建议操作:
echo        - 重启计算机
echo        - 重启后运行: sfc /scannow
echo        - 检查任务管理器是否仍有 svctrl64.exe

pause
exit /b

:: ========================
:: 判断是否为 u + 6 位数字
:: ========================
:is_u6digit
set "fname=%~1"
set "is_match=0"
if "!fname:~0,1!" neq "u" exit /b
set "num=!fname:~1!"
if "!num!" equ "" exit /b
:: 检查是否为6位纯数字
for /f "delims=0123456789" %%i in ("!num!") do (
    exit /b  :: 包含非数字字符
)
if "!num:~6,1!" equ "" if not "!num!" equ "" (
    if "!num:~0,6!" equ "!num!" set "is_match=1"
)
exit /b
