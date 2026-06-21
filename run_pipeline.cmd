@echo off
setlocal
cd /d "%~dp0"

if defined PYTHON_EXE (
    "%PYTHON_EXE%" run_pipeline.py
) else (
    where py >nul 2>nul
    if not errorlevel 1 (
        py run_pipeline.py
    ) else (
        python run_pipeline.py
    )
)

if errorlevel 1 (
    echo.
    echo Pipeline failed. Check the error message above.
    exit /b 1
)

echo.
echo Pipeline completed successfully.
endlocal

