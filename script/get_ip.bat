@echo off
for /f "tokens=4" %%a in ('route print^|findstr 0.0.0.0.*0.0.0.0') do (
 set IP1=%%a
)
echo 你的局域网IP是(方法一)：
echo %IP1%
echo.
for /f "tokens=2 delims=:" %%i in ('ipconfig^|findstr "IPv4 地址"') do (
set ip=%%i
)
echo 你的局域网IP是(方法二)：
echo %ip%
echo.
echo 你的主机名是：
echo %computername%
pause>nul