@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion
title Local Area Network-bat   LAN-bat v1.0
color 0A

:menu
cls
echo ============================================================
echo                  LAN-bat v1.0
echo ============================================================
echo  1. 扫描局域网存活主机 
echo  2. 路由追踪 (tracert)
echo  3. 查询公网IP
echo  4. Minecraft 扫描 
echo  5. 局域网端口扫描 
echo  6. 公网IP端口自检 
echo  7. 退出
echo ============================================================
echo  提示：按 Enter 默认执行 [1]
set /p choice="请输入数字选择 [1-7]: "
if "%choice%"=="" set choice=1
if "%choice%"=="1" goto :lan_scan
if "%choice%"=="2" goto :tracert
if "%choice%"=="3" goto :public_ip
if "%choice%"=="4" goto :mc_scan_menu
if "%choice%"=="5" goto :port_scan
if "%choice%"=="6" goto :public_self_scan
if "%choice%"=="7" exit /b
echo 无效输入，请重试。
pause
goto :menu

:: ===================== 快速局域网扫描 =====================
:lan_scan
cls
echo ========== 快速局域网扫描  ==========
echo.
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do (
    set "myip=%%a"
    set "myip=!myip: =!"
    goto :got_ip_lan
)
:got_ip_lan
for /f "tokens=1-3 delims=." %%a in ("!myip!") do set "default_prefix=%%a.%%b.%%c"
echo 本机IP: !myip!
set /p "prefix=请输入要扫描的IP前缀 (默认 !default_prefix!): "
if "!prefix!"=="" set "prefix=!default_prefix!"
set "prefix=!prefix: =!"
echo.
echo 正在扫描 !prefix!.1 - !prefix!.254，请稍候...
echo.

:: 
set /a count=0
for /L %%I in (1,1,254) do (
    set /a count+=1
    set /a percent=count*100/254
    powershell -Command "Write-Host -NoNewline \"`r扫描进度: !percent!%%  [正在 ping !prefix!.%%I ...]\""
    ping !prefix!.%%I -n 1 -w 100 >nul 2>&1
)
echo.

echo 扫描完成，正在收集设备信息...
echo.

:: 获取ARP缓存并解析动态条目
set "arp_file=%TEMP%\arp_temp.txt"
arp -a > "%arp_file%"

:: 显示表头
echo ======================================================================
echo IP地址              MAC地址                TTL   系统
echo ======================================================================

:: 将结果同时输出到屏幕和文件
(
    echo ======================================================================
    echo IP地址              MAC地址                TTL   系统
    echo ======================================================================
    for /f "tokens=1-3" %%a in ('findstr /i "dynamic" "%arp_file%"') do (
        set "ip=%%a"
        set "mac=%%b"
        set "type=%%c"
        set "ttl="
        set "os="
        :: 对该IP进行ping获取TTL
        for /f "tokens=2 delims==" %%t in ('ping -n 1 !ip! ^| find "TTL="') do (
            set "ttl=%%t"
        )
        :: 判断系统
        if "!ttl!"=="128" set "os=Windows"
        if "!ttl!"=="64"  set "os=Linux/macOS/Android/iOS"
        if "!ttl!"=="255" set "os=网络设备"
        if "!ttl!"=="32"  set "os=Windows (旧版)"
        if "!ttl!"==""    set "os=未知(无响应)"
        if "!os!"==""     set "os=未知(!ttl!)"
        :: 输出对齐（使用制表符或空格）
        echo !ip!        !mac!        !ttl!        !os!
    )
) > "%USERPROFILE%\Desktop\lan_scan_result.txt"

:: 显示文件内容
type "%USERPROFILE%\Desktop\lan_scan_result.txt"
echo.
echo 详细结果已保存到桌面：lan_scan_result.txt
echo 按任意键返回菜单...
pause >nul
goto :menu

:: ===================== 路由追踪 =====================
:tracert
cls
echo ========== 路由追踪 ==========
set /p "target=请输入目标IP或域名 (如 bilibili.com): "
if "%target%"=="" goto :menu
echo 正在追踪到 %target% 的路由...
tracert -d %target%
echo.
echo 按任意键返回菜单...
pause >nul
goto :menu

:: ===================== 查询公网IP =====================
:public_ip
cls
echo ========== 查询公网IP ==========
echo 正在获取...(cip.cc)
curl -s cip.cc
echo.
echo 按任意键返回菜单...
pause >nul
goto :menu

:: ===================== Minecraft扫描子菜单 =====================
:mc_scan_menu
cls
echo ========== Minecraft 服务器扫描 ==========
echo  1. 自动扫描当前子网 (/24)
echo  2. 自定义IP范围扫描
echo  3. 扫描单个IP
echo  4. 返回主菜单
echo ============================================
echo  提示：直接按 Enter 默认执行 [1]
set /p mc_choice="请选择 [1-4]: "
if "%mc_choice%"=="" set mc_choice=1
if "%mc_choice%"=="1" goto :mc_auto
if "%mc_choice%"=="2" goto :mc_range
if "%mc_choice%"=="3" goto :mc_single
if "%mc_choice%"=="4" goto :menu
echo 无效输入，返回主菜单。
pause
goto :menu

:mc_auto
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr "IPv4"') do (
    set "myip=%%a"
    set "myip=!myip: =!"
    goto :mc_got_ip
)
:mc_got_ip
for /f "tokens=1-3 delims=." %%a in ("!myip!") do set "prefix=%%a.%%b.%%c"
set "start_ip=!prefix!.1"
set "end_ip=!prefix!.254"
echo 自动扫描范围: !start_ip! - !end_ip!
goto :mc_do_scan

:mc_range
set /p "start_ip=请输入起始IP (如 192.168.1.1): "
if "!start_ip!"=="" goto :mc_scan_menu
set /p "end_ip=请输入结束IP (如 192.168.1.254): "
if "!end_ip!"=="" goto :mc_scan_menu
goto :mc_do_scan

:mc_single
set /p "single=请输入要扫描的IP地址: "
if "!single!"=="" goto :mc_scan_menu
set "start_ip=!single!"
set "end_ip=!single!"
goto :mc_do_scan

:mc_do_scan
set "start_ip=!start_ip: =!"
set "end_ip=!end_ip: =!"
if "!start_ip!"=="" goto :mc_scan_menu
if "!end_ip!"=="" goto :mc_scan_menu

echo.
echo 开始 Minecraft 端口扫描 (25565 TCP / 19132 UDP) ...
echo 结果（仅显示开放的端口）:
echo ------------------------------------------------
set total=0
set found=0

for /f "tokens=1-4 delims=." %%a in ("!start_ip!") do set "s1=%%a" & set "s2=%%b" & set "s3=%%c" & set "s4=%%d"
for /f "tokens=1-4 delims=." %%a in ("!end_ip!") do set "e1=%%a" & set "e2=%%b" & set "e3=%%c" & set "e4=%%d"
if "!s4!"=="" goto :mc_scan_menu
if "!e4!"=="" goto :mc_scan_menu

for /l %%i in (!s4!,1,!e4!) do (
    set "target=!s1!.!s2!.!s3!.%%i"
    set /a total+=1
    <nul set /p "正在检查 !target! ... "

    call :mc_check_port !target!
)

echo.
echo ------------------------------------------------
echo 扫描完成！共扫描 !total! 个IP，发现 !found! 个服务。
pause
goto :mc_scan_menu

:mc_check_port
set "ip=%1"
set "has=0"

powershell -Command "$t=New-Object System.Net.Sockets.TcpClient; $r=$t.BeginConnect('%ip%',25565,$null,$null); if($r.AsyncWaitHandle.WaitOne(150,$false)){ $t.EndConnect($r); $t.Close(); exit 0 } else { exit 1 }" >nul 2>&1
if %errorlevel%==0 (
    set "has=1"
    set /a found+=1
    call :get_service_name 25565
    echo [OPEN] 25565 (!svc_name!)
)

powershell -Command "$ErrorActionPreference='SilentlyContinue'; $u=New-Object System.Net.Sockets.UdpClient; $u.Client.ReceiveTimeout=200; $u.Connect('%ip%',19132); $u.Send([byte[]]@(0x01),1) | Out-Null; $ep=New-Object System.Net.IPEndPoint([System.Net.IPAddress]::Any,0); $r=$u.Receive([ref]$ep); $u.Close(); if($r -and $r.Length -gt 0){ exit 0 } else { exit 2 }" >nul 2>&1
if %errorlevel%==0 (
    set "has=1"
    set /a found+=1
    call :get_service_name 19132
    echo [OPEN] 19132 (!svc_name!)
) else if %errorlevel%==2 (
    set "has=1"
    set /a found+=1
    call :get_service_name 19132
    echo [可能开放] 19132 (!svc_name! - UDP无响应)
)

if "!has!"=="0" echo 无端口开放
exit /b

:: ===================== 局域网端口扫描 =====================
:port_scan
cls
echo ========== 局域网端口扫描  ==========
set /p "scan_start=请输入起始IP (如 192.168.1.1): "
if "!scan_start!"=="" goto :menu
set /p "scan_end=请输入结束IP (如 192.168.1.254): "
if "!scan_end!"=="" goto :menu
set "scan_start=!scan_start: =!"
set "scan_end=!scan_end: =!"
if "!scan_start!"=="" goto :menu
if "!scan_end!"=="" goto :menu

echo 支持多个端口，用逗号分隔 (例如: 80,443,3389,8080)
echo 或输入 "common" 扫描常用端口: 21,22,23,25,80,443,3389,8080,25565
set /p "ports_input=请输入端口: "
if "!ports_input!"=="" goto :menu
if /i "!ports_input!"=="common" set "ports_input=21,22,23,25,80,443,3389,8080,25565"
echo 扫描范围: !scan_start! - !scan_end!
echo 端口列表: !ports_input!
echo 开始扫描，请稍候 (每个端口超时150ms)...
echo ------------------------------------------------
set total=0
set found=0

for /f "tokens=1-4 delims=." %%a in ("!scan_start!") do set "s1=%%a" & set "s2=%%b" & set "s3=%%c" & set "s4=%%d"
for /f "tokens=1-4 delims=." %%a in ("!scan_end!") do set "e1=%%a" & set "e2=%%b" & set "e3=%%c" & set "e4=%%d"
if "!s4!"=="" goto :menu
if "!e4!"=="" goto :menu

for /l %%i in (!s4!,1,!e4!) do (
    set "target=!s1!.!s2!.!s3!.%%i"
    set /a total+=1
    <nul set /p "检查 !target! 端口: "
    set "any_open=0"
    for %%p in (!ports_input!) do (
        set "port=%%p"
        powershell -Command "$t=New-Object System.Net.Sockets.TcpClient; $r=$t.BeginConnect('%target%',!port!,$null,$null); if($r.AsyncWaitHandle.WaitOne(150,$false)){ $t.EndConnect($r); $t.Close(); exit 0 } else { exit 1 }" >nul 2>&1
        if !errorlevel!==0 (
            set "any_open=1"
            set /a found+=1
            call :get_service_name !port!
            <nul set /p " [!port! !svc_name!]"
        )
    )
    if !any_open!==0 (
        echo 无开放端口
    ) else (
        echo.
    )
)

echo.
echo ------------------------------------------------
echo 扫描完成！共扫描 !total! 个IP，发现 !found! 个开放端口。
pause
goto :menu

:: ===================== 公网IP端口自检 =====================
:public_self_scan
cls
echo ============================================================
echo                 公网IP端口自检
echo ============================================================
echo ⚠️ 警告：此功能仅允许扫描您自己的公网IP！
echo 未经授权扫描他人IP属于违法行为，运营商将直接封禁。
echo ============================================================
echo.
echo 正在获取您的公网IP...
for /f "tokens=4 delims=: " %%a in ('curl -s cip.cc ^| findstr "IP"') do set "public_ip=%%a"
if "!public_ip!"=="" (
    echo 自动获取失败，请手动输入。
    set /p "public_ip=请输入您的公网IP: "
) else (
    echo 您的公网IP: !public_ip!
    set /p "confirm=扫描此IP吗？(Y/N，默认Y): "
    if /i "!confirm!"=="N" (
        set /p "public_ip=请输入要扫描的公网IP: "
    )
)
if "!public_ip!"=="" goto :menu
set "public_ip=!public_ip: =!"

echo.
echo 将扫描常用端口：80 (HTTP), 443 (HTTPS), 3389 (RDP), 8080 (HTTP-Alt), 25565 (Minecraft Java), 19132 (Bedrock TCP备用)
echo 开始扫描 !public_ip! ，请稍候...
echo ------------------------------------------------
set "ports_list=80,443,3389,8080,25565,19132"
set found=0
for %%p in (!ports_list!) do (
    set "port=%%p"
    <nul set /p "检查端口 !port! ... "
    powershell -Command "$t=New-Object System.Net.Sockets.TcpClient; $r=$t.BeginConnect('%public_ip%',!port!,$null,$null); if($r.AsyncWaitHandle.WaitOne(200,$false)){ $t.EndConnect($r); $t.Close(); exit 0 } else { exit 1 }" >nul 2>&1
    if !errorlevel!==0 (
        set /a found+=1
        call :get_service_name !port!
        echo [开放] !port! (!svc_name!)
    ) else (
        echo [关闭/超时]
    )
)

echo.
if !found!==0 (
    echo 未检测到任何开放端口。
    echo.
    echo 提示：如果您已经在路由器做了端口映射，请检查：
    echo  1. 路由器是否开启了 NAT 环回（部分路由器不支持从内网访问公网IP）
    echo  2. 可以使用手机流量访问 !public_ip! 来二次验证
) else (
    echo 检测到 !found! 个开放端口，端口映射似乎已生效！
)
echo.
echo 按任意键返回菜单...
pause >nul
goto :menu

:: ===================== 端口名称映射表 =====================
:get_service_name
set "svc_name=未知服务"
if "%1"=="21" set "svc_name=FTP"
if "%1"=="22" set "svc_name=SSH"
if "%1"=="23" set "svc_name=Telnet"
if "%1"=="25" set "svc_name=SMTP"
if "%1"=="53" set "svc_name=DNS"
if "%1"=="80" set "svc_name=HTTP"
if "%1"=="110" set "svc_name=POP3"
if "%1"=="143" set "svc_name=IMAP"
if "%1"=="443" set "svc_name=HTTPS"
if "%1"=="445" set "svc_name=SMB"
if "%1"=="465" set "svc_name=SMTPS"
if "%1"=="587" set "svc_name=SMTP TLS"
if "%1"=="993" set "svc_name=IMAPS"
if "%1"=="995" set "svc_name=POP3S"
if "%1"=="1080" set "svc_name=SOCKS"
if "%1"=="1433" set "svc_name=MSSQL"
if "%1"=="1521" set "svc_name=Oracle"
if "%1"=="3306" set "svc_name=MySQL"
if "%1"=="3389" set "svc_name=RDP"
if "%1"=="5432" set "svc_name=PostgreSQL"
if "%1"=="5900" set "svc_name=VNC"
if "%1"=="6379" set "svc_name=Redis"
if "%1"=="8080" set "svc_name=HTTP-Alt"
if "%1"=="8443" set "svc_name=HTTPS-Alt"
if "%1"=="19132" set "svc_name=Minecraft-Bedrock"
if "%1"=="25565" set "svc_name=Minecraft-Java"
exit /b