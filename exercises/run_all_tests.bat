@REM Дякую Кулікову Максиму, що підготував цей скрипт

@echo off
setlocal EnableDelayedExpansion
cd /d "%~dp0.."
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

set VENV_DIR=exercises\tests\venv

IF NOT EXIST "%VENV_DIR%\" (
    echo Creating virtual environment in "%VENV_DIR%"...
    "%PYTHON_EXE%" -m venv %VENV_DIR%
)

echo Activating environment...
call "%VENV_DIR%\Scripts\activate.bat"

    rem Check whether a representative package is installed in the venv; skip install if present
echo Checking venv packages...
python -m pip show polars > nul 2> nul
if !ERRORLEVEL! equ 0 (
    echo Dependencies already installed in venv.
) else (
    echo Installing dependencies from exercises\tests\requirements.txt...
    python -m pip install --upgrade pip > nul
    pip install -r exercises\tests\requirements.txt
    if !ERRORLEVEL! equ 0 (
        echo Dependencies installed successfully.
    ) else (
        echo [ERROR] Failed to install dependencies.
        pause
        exit /b 1
    )
)

IF NOT EXIST "config.yaml" (
    IF EXIST "exercises\tests\config.yaml" (
        echo Copying config.yaml to working directory...
        copy "exercises\tests\config.yaml" "config.yaml" > nul
    ) ELSE (
        echo [WARNING] config.yaml not found in exercises/tests folder!
    )
)

echo.
echo === Running pytest ===
set PYTHONUTF8=1

cd exercises\tests || exit /b

pytest --html=test_results/report_base.html --json-report --json-report-file=test_results/report_base.json --snapshot base --no-header -v
pytest --html=test_results/report_10k.html --json-report --json-report-file=test_results/report_10k.json --snapshot 10k --no-header -v

echo // Testing process completed
pause