param(
 [string]$AppId,
 [string]$DesktopDirectory = [Environment]::GetFolderPath('Desktop')
)
$ErrorActionPreference='Stop'
if(-not $AppId){
 $match=Get-StartApps | Where-Object { $_.AppID -like 'OpenAI.Codex*!App' -or $_.Name -eq 'Codex' } | Select-Object -First 1
 if(-not $match){throw 'Codex was not found. Install Codex first, or run Install.ps1 -AppId YOUR_APP_ID. Use Get-StartApps to find the ID.'}
 $AppId=$match.AppID
}
if(-not (Test-Path -LiteralPath $DesktopDirectory -PathType Container)){throw 'The desktop folder does not exist.'}
$entry=Join-Path $PSScriptRoot 'Start.vbs'
$linkPath=Join-Path $DesktopDirectory 'Codex Anime.lnk'
$hostPath=Join-Path $env:WINDIR 'System32\wscript.exe'
$arguments='"'+$entry+'"'
$shell=New-Object -ComObject WScript.Shell
if(Test-Path -LiteralPath $linkPath){
 $existing=$shell.CreateShortcut($linkPath)
 if($existing.TargetPath -ne $hostPath -or $existing.Arguments -ne $arguments){throw 'A different Codex Anime shortcut already exists. Rename it before installing.'}
}
foreach($asset in @('luffy-ace.png','zoro-three-sword.png','startup-sfx.wav')){
 if(-not (Test-Path -LiteralPath (Join-Path $PSScriptRoot ('assets\'+$asset)))){throw "Missing asset: $asset"}
}
@{AppId=$AppId} | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'launcher.local.json') -Encoding UTF8
$link=$shell.CreateShortcut($linkPath)
$link.TargetPath=$hostPath
$link.Arguments=$arguments
$link.WorkingDirectory=$PSScriptRoot
$link.Description='Codex anime startup - Luffy, Ace and Zoro'
$link.IconLocation=(Join-Path $env:WINDIR 'System32\shell32.dll')+',112'
$link.Save()
Write-Output ('Installed: '+$linkPath)
Write-Output 'Keep this folder in place. Run Uninstall.ps1 before moving it.'
