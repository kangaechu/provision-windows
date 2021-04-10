$packages = @(
'docker-desktop',
'git',
'GoogleChrome',
'keyhac',
'keypirinha',
'line',
'microsoft-windows-terminal',
'powertoys',
'slack',
'vscode',
'winmerge-jp'
)

function Install-Package-Retryable($package, $errorCount = 0) {
  try {
    Install-Package $package -Force -ProviderName 'ChocolateyGet'
  } catch {
    if ($errorCount -lt 2) {
      Install-Package-Retryable $package ($errorCount + 1)
    } else {
      Write-Error $_.Exception
    }
  }
}

function Install-WSL2-Kernel-Update() {
  Write-Host '-> WSL2 Kernel Update'
  $client = New-Object net.webclient
  $client.DownloadFile('https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi', "$env:temp\wsl_update_x64.msi")
  Invoke-Expression "msiexec /i $env:temp\wsl_update_x64.msi /passive /norestart"
  wsl --set-default-version 2
}

function Install-MagicUtilities() {
  Write-Host '-> Magic Utilities'
  $client = New-Object net.webclient
  $client.DownloadFile('https://magicutilities.net/downloads/MagicUtilities-Setup-3.0.9.6-Win10.exe', "$env:temp\MagicUtilities-Setup-3.0.9.6-Win10.exe")
  # TODO: サイレントインストールにする（コンポーネントの指定が必要）
  Invoke-Expression "$env:temp\MagicUtilities-Setup-3.0.9.6-Win10.exe"
  # Remove-Item $env:temp\MagicUtilities-Setup-3.0.9.6-Win10.exe
}

function Install-Ubuntu() {
  Write-Host '-> Ubuntu'
  choco install -y wsl-ubuntu-2004 --params /InstallRoot:true
  wsl -s Ubuntu-20.04
}

Write-Host 'Installing packages:'
Install-WSL2-Kernel-Update
$packages | % {
  Write-Host "-> $_"
  Install-Package-Retryable $_
}
# Install-MagicUtilities
Install-Ubuntu
Write-Host ''
