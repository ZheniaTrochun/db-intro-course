@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0"
chcp 65001 > nul
echo === Initialization ===

set PYTHON_EXE=
where python >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set PYTHON_EXE=python
)
if "%PYTHON_EXE%"=="" (
    where py >nul 2>nul
    if !ERRORLEVEL! equ 0 (
        set PYTHON_EXE=py
    )
)

if "%PYTHON_EXE%"=="" (
    if exist "%LocalAppData%\Programs\Python\Python312\python.exe" (
        set "PYTHON_EXE=%LocalAppData%\Programs\Python\Python312\python.exe"
    ) else if exist "%LocalAppData%\Programs\Python\Python311\python.exe" (
        set "PYTHON_EXE=%LocalAppData%\Programs\Python\Python311\python.exe"
    )
)

if "%PYTHON_EXE%"=="" (
    echo [ERROR] Python not found in your system!
    echo Please install Python from python.org and ensure it is added to PATH.
    pause
    exit /b
)

set VENV_DIR=tests\venv

IF NOT EXIST "%VENV_DIR%\" (
    echo Creating virtual environment in "%VENV_DIR%"...
    "%PYTHON_EXE%" -m venv %VENV_DIR%
)

echo Activating environment...
call "%VENV_DIR%\Scripts\activate.bat"

IF NOT EXIST "%VENV_DIR%\.installed" (
    echo Installing dependencies from tests\requirements.txt...
    python -m pip install --upgrade pip > nul
    pip install -r tests\requirements.txt
    if !ERRORLEVEL! equ 0 (
        echo. > "%VENV_DIR%\.installed"
    ) else (
        echo [ERROR] Failed to install dependencies.
        pause
        exit /b 1
    )
) ELSE (
    echo Dependencies are already installed.
)

IF NOT EXIST "config.yaml" (
    IF EXIST "tests\config.yaml" (
        echo Copying config.yaml to working directory...
        copy "tests\config.yaml" "config.yaml" > nul
    ) ELSE (
        echo [WARNING] config.yaml not found in root or tests folder!
    )
)

IF NOT EXIST "dumps\" mkdir dumps
IF NOT EXIST "dumps\10k.dump" (
    echo Downloading 10k.dump fixture...
    curl -L --fail -o dumps\10k.dump https://github.com/ZheniaTrochun/db-intro-course/releases/download/exercises-fixture-v1/10k.dump
    if !ERRORLEVEL! neq 0 (
        echo [ERROR] Failed to download 10k.dump
        pause
        exit /b 1
    )
)

echo.
echo === Running pytest ===
set PYTHONUTF8=1
pytest tests\

echo // Testing process completed
pause