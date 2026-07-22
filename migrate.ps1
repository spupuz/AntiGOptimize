# OmniState Migration Script
# Migrates antigravity.config.json → omnistate.config.json
# Safe for git projects - backups stored in .omnistate/backups/

param(
    [string]$Target = ".",
    [switch]$Force,
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# ── Configuration ──────────────────────────────────────────────────────────────
$scriptDir = $PSScriptRoot
$version = if (Test-Path (Join-Path $scriptDir "VERSION.txt")) {
    (Get-Content (Join-Path $scriptDir "VERSION.txt") -Raw).Trim()
} else { "1.4.0" }

# ── Logging ────────────────────────────────────────────────────────────────────
function Write-Log($msg, $color = "White") { if (!$Silent) { Write-Host $msg -ForegroundColor $color } }

# ── Migration Logic ────────────────────────────────────────────────────────────
function Move-LegacyConfig($projectRoot) {
    $oldConfig = Join-Path $projectRoot "antigravity.config.json"
    $newConfig = Join-Path $projectRoot "omnistate.config.json"
    $backupDir = Join-Path $projectRoot ".omnistate\backups"

    # Skip if no old config exists
    if (!(Test-Path $oldConfig)) { return }

    Write-Log "Detected legacy config: antigravity.config.json" "Cyan"

    # If new config already exists, ask user
    if (Test-Path $newConfig) {
        Write-Log "omnistate.config.json already exists." "Yellow"
        if (!$Force) {
            $reply = Read-Host "Overwrite existing config? [y/N]"
            if ($reply -ne "y" -and $reply -ne "Y") {
                Write-Log "Skipping migration. Old config preserved." "Yellow"
                return
            }
        }
    }

    # Create backup directory
    if (!(Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir -Force | Out-Null }

    # Create backup with timestamp
    $timestamp = Get-Date -Format "yyyyMMdd-HHmm"
    $backupFile = Join-Path $backupDir "antigravity.config.json.$timestamp.bak"
    Copy-Item -Path $oldConfig -Destination $backupFile -Force
    Write-Log "Backup created: $backupFile" "Green"

    # Migrate schema
    $oldJson = Get-Content $oldConfig -Raw | ConvertFrom-Json

    # Create new config object
    $newJson = [PSCustomObject]@{
        omnistate_version = $version
        project_name = if ($oldJson.project_name) { $oldJson.project_name } else { "" }
        optimization = [PSCustomObject]@{
            archive_threshold_done = $oldJson.optimization.archive_threshold_done
            archive_max_age_days = $oldJson.optimization.archive_max_age_days
            auto_sync_workflows = $oldJson.optimization.auto_sync_workflows
        }
        models = [PSCustomObject]@{
            preferred_lite = ""
            preferred_pro = ""
        }
    }

    # Save new config
    $newJson | ConvertTo-Json -Depth 10 | Set-Content -Path $newConfig -Encoding UTF8

    # Remove old config
    Remove-Item -Path $oldConfig -Force
    Write-Log "Migrated: antigravity.config.json → omnistate.config.json" "Green"

    # Ensure old config is in .gitignore
    $gitignore = Join-Path $projectRoot ".gitignore"
    if (Test-Path $gitignore) {
        $content = Get-Content $gitignore -Raw
        if (-not $content.Contains("antigravity.config.json")) {
            Add-Content -Path $gitignore -Value "antigravity.config.json" -Encoding UTF8
            Write-Log "Added antigravity.config.json to .gitignore" "Green"
        }
    }
}

# ── Main ───────────────────────────────────────────────────────────────────────
$resolvedTarget = (Resolve-Path $Target -ErrorAction SilentlyContinue)
if (!$resolvedTarget) { $resolvedTarget = (Get-Location).Path }

Move-LegacyConfig $resolvedTarget
