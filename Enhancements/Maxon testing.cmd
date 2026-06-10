@echo off
REM ============================================================
REM  MAXON DEMO TEMPLATE
REM  Project  : My-Demo-Project
REM  Author   : slolla-ai
REM  Date     : 2026-06-10
REM  Purpose  : Demo template for Maxon testing scenarios
REM ============================================================

setlocal enabledelayedexpansion

:: ── Configuration ────────────────────────────────────────────
set DEVICE_NAME=Maxon Controller
set FIRMWARE_VERSION=1.0.0
set LOG_FILE=maxon_test_log.txt
set PASS_COUNT=0
set FAIL_COUNT=0

:: ── Header ───────────────────────────────────────────────────
echo.
echo ============================================================
echo   %DEVICE_NAME% - Demo Test Suite
echo   Firmware: %FIRMWARE_VERSION%
echo   Date    : %DATE%  Time: %TIME%
echo ============================================================
echo.

call :log "===== Maxon Test Session Started ====="

:: ── Main Menu ────────────────────────────────────────────────
:MENU
echo Select a test to run:
echo   [1]  Connection Test
echo   [2]  Motor Initialization Test
echo   [3]  Speed Control Test
echo   [4]  Position Control Test
echo   [5]  Error Handling Test
echo   [6]  Run All Tests
echo   [0]  Exit
echo.
set /p CHOICE="Enter choice: "

if "%CHOICE%"=="1" call :TEST_CONNECTION
if "%CHOICE%"=="2" call :TEST_MOTOR_INIT
if "%CHOICE%"=="3" call :TEST_SPEED_CONTROL
if "%CHOICE%"=="4" call :TEST_POSITION_CONTROL
if "%CHOICE%"=="5" call :TEST_ERROR_HANDLING
if "%CHOICE%"=="6" call :RUN_ALL
if "%CHOICE%"=="0" goto :SUMMARY
goto :MENU

:: ── Test: Connection ─────────────────────────────────────────
:TEST_CONNECTION
echo.
echo [TEST 1] Connection Test
echo ----------------------------------------------------------
call :log "[TEST 1] Connection Test - START"
echo   Checking device connection...
timeout /t 1 /nobreak >nul
echo   RESULT: PASS - Device "%DEVICE_NAME%" connected successfully.
call :PASS "Connection Test"
goto :eof

:: ── Test: Motor Initialization ───────────────────────────────
:TEST_MOTOR_INIT
echo.
echo [TEST 2] Motor Initialization Test
echo ----------------------------------------------------------
call :log "[TEST 2] Motor Initialization - START"
echo   Sending initialization command...
timeout /t 1 /nobreak >nul
echo   Verifying motor state...
timeout /t 1 /nobreak >nul
echo   RESULT: PASS - Motor initialized and ready.
call :PASS "Motor Initialization Test"
goto :eof

:: ── Test: Speed Control ──────────────────────────────────────
:TEST_SPEED_CONTROL
echo.
echo [TEST 3] Speed Control Test
echo ----------------------------------------------------------
call :log "[TEST 3] Speed Control Test - START"
echo   Setting target speed: 1500 RPM...
timeout /t 1 /nobreak >nul
echo   Reading actual speed: 1498 RPM...
timeout /t 1 /nobreak >nul
echo   Tolerance check: within +/- 10 RPM
echo   RESULT: PASS - Speed within acceptable range.
call :PASS "Speed Control Test"
goto :eof

:: ── Test: Position Control ───────────────────────────────────
:TEST_POSITION_CONTROL
echo.
echo [TEST 4] Position Control Test
echo ----------------------------------------------------------
call :log "[TEST 4] Position Control Test - START"
echo   Setting target position: 3600 counts...
timeout /t 1 /nobreak >nul
echo   Reading actual position: 3601 counts...
timeout /t 1 /nobreak >nul
echo   Tolerance check: within +/- 5 counts
echo   RESULT: PASS - Position within acceptable range.
call :PASS "Position Control Test"
goto :eof

:: ── Test: Error Handling ─────────────────────────────────────
:TEST_ERROR_HANDLING
echo.
echo [TEST 5] Error Handling Test
echo ----------------------------------------------------------
call :log "[TEST 5] Error Handling Test - START"
echo   Simulating fault condition...
timeout /t 1 /nobreak >nul
echo   Triggering fault clear command...
timeout /t 1 /nobreak >nul
echo   Verifying fault register cleared...
timeout /t 1 /nobreak >nul
echo   RESULT: PASS - Error handling verified.
call :PASS "Error Handling Test"
goto :eof

:: ── Run All Tests ────────────────────────────────────────────
:RUN_ALL
call :log "[RUN ALL] Executing full test suite"
call :TEST_CONNECTION
call :TEST_MOTOR_INIT
call :TEST_SPEED_CONTROL
call :TEST_POSITION_CONTROL
call :TEST_ERROR_HANDLING
goto :eof

:: ── Helpers ──────────────────────────────────────────────────
:PASS
set /a PASS_COUNT+=1
call :log "  PASS: %~1"
goto :eof

:FAIL
set /a FAIL_COUNT+=1
call :log "  FAIL: %~1"
goto :eof

:log
echo [%DATE% %TIME%] %~1 >> %LOG_FILE%
goto :eof

:: ── Summary ──────────────────────────────────────────────────
:SUMMARY
echo.
echo ============================================================
echo   TEST SUMMARY
echo ============================================================
echo   Passed : %PASS_COUNT%
echo   Failed : %FAIL_COUNT%
echo   Log    : %LOG_FILE%
echo ============================================================
call :log "===== Session End | PASS: %PASS_COUNT% | FAIL: %FAIL_COUNT% ====="
echo.
endlocal
exit /b 0
