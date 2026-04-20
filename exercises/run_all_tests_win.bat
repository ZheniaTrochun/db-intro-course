@echo off
chcp 65001 > nul
echo === Initialization ===

set PYTHON_EXE=
where py >nul 2>nul
if %ERRORLEVEL% equ 0 (
    set PYTHON_EXE=python
) else (
    where python >nul 2>nul
    if %ERRORLEVEL% equ 0 (
        set PYTHON_EXE=python
    )
)

if "%PYTHON_EXE%"=="" (
    if exist "%LocalAppData%\Programs\Python\Python312\python.exe" (
        set PYTHON_EXE="%LocalAppData%\Programs\Python\Python312\python.exe"
    ) else if exist "%LocalAppData%\Programs\Python\Python311\python.exe" (
        set PYTHON_EXE="%LocalAppData%\Programs\Python\Python311\python.exe"
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
    %PYTHON_EXE% -m venv %VENV_DIR%
)

echo Activating environment...
call "%VENV_DIR%\Scripts\activate.bat"

IF NOT EXIST "%VENV_DIR%\.installed" (
    echo Installing dependencies from tests\requirements.txt...
    python -m pip install --upgrade pip > nul
    pip install -r tests\requirements.txt
    
    echo. > "%VENV_DIR%\.installed"
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

echo.
echo === Running pytest ===
set PYTHONUTF8=1
pytest tests\

echo // Testing process completed 
pause