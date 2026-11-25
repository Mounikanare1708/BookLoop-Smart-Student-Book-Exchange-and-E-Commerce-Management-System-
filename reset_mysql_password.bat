@echo off
title MySQL Root Password Reset - BookLoop
echo ===============================================================================
echo               MySQL Root Password Reset Tool for BookLoop
echo ===============================================================================
echo.
echo This tool will reset your MySQL 'root' password to: root
echo and automatically set up the 'bookloop_db' database.
echo.
echo [IMPORTANT] Please make sure you ran this file by:
echo             RIGHT-CLICKING on it and choosing "Run as administrator".
echo.
pause

echo.
echo [1/5] Stopping MySQL service...
net stop MySQL80 >nul 2>nul
net stop MySQL >nul 2>nul

echo [2/5] Creating reset command file...
echo ALTER USER 'root'@'localhost' IDENTIFIED BY 'root'; > "%TEMP%\mysql_init.txt"
echo FLUSH PRIVILEGES; >> "%TEMP%\mysql_init.txt"

echo [3/5] Applying new password 'root' to MySQL Server...
start "" /b "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysqld.exe" --defaults-file="C:\ProgramData\MySQL\MySQL Server 8.0\my.ini" --init-file="%TEMP%\mysql_init.txt"
timeout /t 5 /nobreak >nul
taskkill /f /im mysqld.exe >nul 2>nul
del "%TEMP%\mysql_init.txt" >nul 2>nul

echo [4/5] Starting MySQL service...
net start MySQL80
if %ERRORLEVEL% NEQ 0 (
    net start MySQL
)

echo [5/5] Creating 'bookloop_db' and importing seed data...
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -proot -e "CREATE DATABASE IF NOT EXISTS bookloop_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -proot bookloop_db < "%~dp0bookloop\database\schema.sql"
"C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" -u root -proot bookloop_db < "%~dp0bookloop\database\seed_data.sql"

echo.
echo Updating db.properties with password 'root'...
(
echo #BookLoop Database Configuration
echo db.username=root
echo db.password=root
echo db.pool.size=10
echo db.url=jdbc:mysql://localhost:3306/bookloop_db?useSSL=false^&serverTimezone=UTC^&allowPublicKeyRetrieval=true
) > "%~dp0db.properties"

echo.
echo ===============================================================================
echo   SUCCESS! Your MySQL root password is now: root
echo   Database 'bookloop_db' has been imported with all demo accounts!
echo.
echo   You can now launch BookLoop by double-clicking: run_bookloop.bat
echo ===============================================================================
echo.
pause
