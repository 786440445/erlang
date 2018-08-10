@echo off
for /f "tokens=2 delims=:" %%i in ('ipconfig^|findstr "IPv4 地址"') do set ip=%%i

erl -name %computername%@%ip% -pa ebin/% start main