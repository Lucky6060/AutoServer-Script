# Get the files on to the Server

**Step 1: Use this command to install chocolatey on to the server**

Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

--------------------------------------------------------
**Step 2: install git so you can clone the repo to the server**

choco install git -y

--------------------------------------------------------
**Step 3: Restart server after instal git**

Restart-Computer

--------------------------------------------------------
**Step 4: clone the repo**

git clone https://github.com/Lucky6060/AutoServer-Script.git
