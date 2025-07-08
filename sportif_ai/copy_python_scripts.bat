@echo off
echo Copying Python scripts to Android assets directory...

if not exist "android\app\src\main\assets\python_scripts" (
    mkdir "android\app\src\main\assets\python_scripts"
)

copy /Y "python_scripts\drill_analyzer.py" "android\app\src\main\assets\python_scripts\"

echo Done!