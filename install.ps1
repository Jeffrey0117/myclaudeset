# Install myclaudeset — symlink Claude Code config from this repo to ~/.claude/
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ClaudeDir = "$env:USERPROFILE\.claude"

Write-Host "Installing myclaudeset from: $ScriptDir"
Write-Host "Target: $ClaudeDir"

# Backup existing config
$dirs = @("skills", "commands", "rules", "agents")
$hasExisting = $dirs | Where-Object { Test-Path "$ClaudeDir\$_" }

if ($hasExisting -or (Test-Path "$ClaudeDir\settings.json")) {
    $Backup = "$ClaudeDir\backup-$(Get-Date -Format 'yyyyMMddHHmmss')"
    Write-Host "Backing up existing config to: $Backup"
    New-Item -ItemType Directory -Path $Backup -Force | Out-Null
    foreach ($dir in $dirs) {
        if (Test-Path "$ClaudeDir\$dir") {
            Copy-Item -Recurse "$ClaudeDir\$dir" "$Backup\"
        }
    }
    if (Test-Path "$ClaudeDir\settings.json") {
        Copy-Item "$ClaudeDir\settings.json" "$Backup\"
    }
}

New-Item -ItemType Directory -Path $ClaudeDir -Force | Out-Null

# Remove existing and create symlinks (requires admin or developer mode)
foreach ($dir in $dirs) {
    $target = "$ClaudeDir\$dir"
    if (Test-Path $target) { Remove-Item -Recurse -Force $target }
    New-Item -ItemType SymbolicLink -Path $target -Target "$ScriptDir\$dir" | Out-Null
    Write-Host "  Linked: $dir"
}

# Settings file
$settingsTarget = "$ClaudeDir\settings.json"
if (Test-Path $settingsTarget) { Remove-Item -Force $settingsTarget }
New-Item -ItemType SymbolicLink -Path $settingsTarget -Target "$ScriptDir\settings.json" | Out-Null
Write-Host "  Linked: settings.json"

Write-Host ""
Write-Host "Done! Claude Code config is now synced from this repo."
Write-Host "Pull this repo on any machine and run install.ps1 to sync."
