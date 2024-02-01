@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "[System.Net.ServicePointManager]::SecurityProtocol = 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
choco -?
choco upgrade chocolatey
@REM choco install -yes python
python --version
pip --version
winget install --id Microsoft.Powershell --source winget
winget install --id Git.Git -e --source winget
winget install -e --id Kitware.CMake
winget install --id=PuTTY.PuTTY  -e
choco install make
choco install -yes gh
pause