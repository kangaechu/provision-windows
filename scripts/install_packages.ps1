$packages = @(
'7zip.install',
'docker-desktop',
'github-desktop',
'GoogleChrome',
'intellijidea-ultimate',
'keyhac',
'keypirinha',
'Kindle',
'line',
'microsoft-windows-terminal',
'postman',
'registrychangesview',
'rufus',
'slack',
'wsl-ubuntu-2004',
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

function Install-AtokPassport() {
  Write-Host '-> AtokPassport'
  $client = New-Object net.webclient
  $client.DownloadFile('https://sevenzip.osdn.jp/howto/9.20/7z.exe', "$env:temp\7z.exe")
  $client.DownloadFile('https://sevenzip.osdn.jp/howto/9.20/7z.dll', "$env:temp\7z.dll")
  $client.DownloadFile('https://gate.justsystems.com/download/atok/ut/win/at31try4.exe', "$env:temp\at31try4.exe")
  Invoke-Expression "$env:temp\7z x $env:temp\at31try4.exe -o$env:temp"
  Invoke-Expression "$env:temp\at31try4\ATOK\SETUP.EXE /s"
  Remove-Item $env:temp\7z.exe
  Remove-Item $env:temp\7z.dll
  Remove-Item $env:temp\at31try4.exe
  # TODO: ウェイトを入れてtry-catchを咬ませつつ消す
  # Remove-Item $env:temp\at31try4 -Force -Recurse
}

function Install-HackGen() {
  Write-Host '-> HackGen'
  $client = New-Object net.webclient
  # TODO: バージョンを可変にする
  $client.DownloadFile('https://github.com/yuru7/HackGen/releases/download/v2.1.1/HackGen_v2.1.1.zip', "$env:temp\HackGen_v2.1.1.zip")
  Expand-Archive -Path $env:temp\HackGen_v2.1.1.zip -DestinationPath $env:temp
  Copy-Item $env:temp\HackGen_v2.1.1\HackGen-Regular.ttf C:\Windows\Fonts
  Remove-Item $env:temp\HackGen_v2.1.1.zip
  Remove-Item $env:temp\HackGen_v2.1.1 -Force -Recurse
}

function Install-TablePlus() {
  Write-Host '-> TablePlus'
  $client = New-Object net.webclient
  $client.DownloadFile('https://tableplus.com/release/windows/tableplus_latest', "$env:temp\TablePlusSetup.exe")
  Invoke-Expression "$env:temp\TablePlusSetup.exe /SILENT"
  # Remove-Item $env:temp\TablePlusSetup.exe
}

Write-Host 'Installing packages:'
Install-WSL2-Kernel-Update
$packages | % {
  Write-Host "-> $_"
  Install-Package-Retryable $_
}
Install-AtokPassport
Install-HackGen
Install-TablePlus
Write-Host ''

Write-Host 'Converting Ubuntu to WSL2...'
Write-Host ''
