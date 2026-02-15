# Install myclaudeset — symlink Claude Code config from this repo to ~/.claude/
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = "$env:USERPROFILE\.claude"

Write-Host "Installing myclaudeset from: $ScriptDir"
Write-Host "Target: $ClaudeDir"

New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null

$items = @("skills", "commands", "rules", "agents")

# Check if already installed (symlinks pointing to this repo)
$alreadyLinked = $true
foreach ($dir in $items) {
    $target = "$ClaudeDir\$dir"
    if (Test-Path $target) {
        $item = Get-Item $target -Force
        if ($item.LinkType -eq "SymbolicLink" -and $item.Target -eq "$ScriptDir\$dir") {
            continue
        }
    }
    $alreadyLinked = $false
    break
}

if ($alreadyLinked) {
    Write-Host "Already installed! Symlinks are correct."
    Write-Host "Just use 'git pull' to sync updates - no need to re-install."
    exit 0
}

# Backup existing config (only real dirs, skip symlinks)
$needsBackup = $false
foreach ($dir in $items) {
    $target = "$ClaudeDir\$dir"
    if ((Test-Path $target) -and -not ((Get-Item $target -Force).LinkType -eq "SymbolicLink")) {
        $needsBackup = $true
        break
    }
}

$settingsPath = "$ClaudeDir\settings.json"
$settingsIsReal = (Test-Path $settingsPath) -and -not ((Get-Item $settingsPath -Force).LinkType -eq "SymbolicLink")

if ($needsBackup -or $settingsIsReal) {
    $Backup = "$ClaudeDir\backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
    Write-Host "Backing up existing config to: $Backup"
    New-Item -ItemType Directory -Path $Backup -Force | Out-Null
    foreach ($dir in $items) {
        $target = "$ClaudeDir\$dir"
        if ((Test-Path $target) -and -not ((Get-Item $target -Force).LinkType -eq "SymbolicLink")) {
            Copy-Item -Recurse $target "$Backup\"
        }
    }
    if ($settingsIsReal) {
        Copy-Item $settingsPath "$Backup\"
    }
}

# Remove existing and create symlinks (requires admin or developer mode)
foreach ($dir in $items) {
    $target = "$ClaudeDir\$dir"
    if (Test-Path $target) { Remove-Item -Recurse -Force $target }
    New-Item -ItemType SymbolicLink -Path $target -Target "$ScriptDir\$dir" | Out-Null
    Write-Host "  Linked: $dir"
}

# Settings file
if (Test-Path $settingsPath) { Remove-Item -Force $settingsPath }
New-Item -ItemType SymbolicLink -Path $settingsPath -Target "$ScriptDir\settings.json" | Out-Null
Write-Host "  Linked: settings.json"

Write-Host ""
Write-Host "Done! Claude Code config is now synced from this repo."
Write-Host "After this, just 'git pull' to get updates - no need to re-install."
