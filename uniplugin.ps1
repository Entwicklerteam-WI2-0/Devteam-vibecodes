# -------------------------------------------------------------
# uniplugin.ps1 - Team-OS CLI (Windows). Dispatcher fuer den globalen Befehl 'uniplugin'.
# Wird ueber den PATH-Shim 'uniplugin.cmd' aufgerufen (siehe install-cli.ps1).
# Aufruf:  uniplugin <update|setup|version|help>
# 'update' = git pull + Redeploy (Skills/Commands auffrischen, geloeschte entfernen).
# -------------------------------------------------------------
$ErrorActionPreference = "Stop"

# Repo = Verzeichnis dieser Datei (sie liegt im geklonten Devteam-vibecodes).
$repo = $PSScriptRoot
if (-not $repo -and $MyInvocation.MyCommand.Path) { $repo = Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $repo) { $repo = (Get-Location).Path }

$cmd = if ($args.Count -ge 1) { [string]$args[0] } else { "help" }

switch ($cmd.ToLower()) {
    "update" {
        & powershell -ExecutionPolicy Bypass -File (Join-Path $repo "update.ps1")
    }
    "setup" {
        & powershell -ExecutionPolicy Bypass -File (Join-Path $repo "setup.ps1")
    }
    { $_ -in @("version","-v","--version") } {
        $v = (Get-Content (Join-Path $repo "VERSION") -Raw).Trim()
        Write-Host "uniplugin (Team-OS G2) v$v"
        Write-Host "Repo: $repo"
    }
    default {
        Write-Host "uniplugin - Team-OS G2 CLI"
        Write-Host "  uniplugin update    neuesten Stand holen + Skills/Commands auffrischen (geloeschte entfernen)"
        Write-Host "  uniplugin setup     Einmal-Setup erneut ausfuehren"
        Write-Host "  uniplugin version   installierte Version + Repo-Pfad zeigen"
    }
}
