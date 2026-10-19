param([string]$DesktopDirectory=[Environment]::GetFolderPath('Desktop'))
$ErrorActionPreference='Stop'
$linkPath=Join-Path $DesktopDirectory 'Codex Anime.lnk'
if(Test-Path -LiteralPath $linkPath){
 $shell=New-Object -ComObject WScript.Shell
 $link=$shell.CreateShortcut($linkPath)
 $expected='"'+(Join-Path $PSScriptRoot 'Start.vbs')+'"'
 $hostPath=Join-Path $env:WINDIR 'System32\wscript.exe'
 if($link.TargetPath -ne $hostPath -or $link.Arguments -ne $expected){throw 'This shortcut belongs to another installation; it was left unchanged.'}
 Remove-Item -LiteralPath $linkPath
 Write-Output 'Removed the Codex Anime desktop shortcut.'
}else{Write-Output 'No shortcut from this installation was found.'}
Write-Output 'Codex and your other shortcuts are unchanged. You can now delete this project folder if desired.'
