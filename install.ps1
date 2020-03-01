Set-ExecutionPolicy RemoteSigned -Force

Set-Location -Path C:\Windows\Temp
Invoke-WebRequest -Uri https://github.com/aikawame/provision-windows/archive/master.zip -OutFile provision-windows-master.zip
Expand-Archive -Path .\provision-windows-master.zip -DestinationPath .\ -Force
Set-Location -Path .\provision-windows-master

.\scripts\remove_appx_packages.ps1
.\scripts\disable_windows_optional_features.ps1
.\scripts\enable_windows_optional_features.ps1
.\scripts\install_package_providers.ps1
.\scripts\install_packages.ps1

Reg import .\registrations\settings.reg
Reg import .\registrations\control_panel.reg
Reg import .\registrations\sounds.reg
Reg import .\registrations\others.reg

wsl DEBIAN_FRONTEND=noninteractive apt install -y ansible
wsl ansible-playbook -i local local.yml

Set-Location -Path C:\Windows\Temp
Remove-Item .\provision-windows-master.zip
Remove-Item .\provision-windows-master -Recurse
