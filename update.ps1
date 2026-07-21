# OmniState Update & Sync Script (v1.3.0)
# Universal installer for opencode, Antigravity, Kilocode, and any AI coding tool
# Auto-detects installed platforms and syncs skills to all of them

param(
    [string]$ProjectRoot = "",
    [switch]$SyncOnly,
    [switch]$Auto,
    [switch]$Check,
    [switch]$Silent
)

$ErrorActionPreference = "Stop"

# ── Configuration ──────────────────────────────────────────────────────────────
$scriptDir = $PSScriptRoot
$version = if (Test-Path (Join-Path $scriptDir "VERSION.txt")) {
    (Get-Content (Join-Path $scriptDir "VERSION.txt") -Raw).Trim()
} else { "1.3.0" }
$pluginName = "omnistate"
$repoUrl = "https://github.com/spupuz/OmniState.git"

$memoryFiles = @(
    "omnistate.config.json", "project-summary.md", "tasks-history.json",
    "tasks-archive.json", "AGENTS.md", "AI_POLICY.md", "CONTEXT.md",
    "omnistate-dashboard.html", "/omnistate-dashboard.html", "chunks/"
)
$ideDirs = @(".opencode/", ".kilo/", ".agents/", ".omnistate/", ".roo/")

# ── Logging ────────────────────────────────────────────────────────────────────
function Write-Log($msg, $color = "White") { if (!$Silent) { Write-Host $msg -ForegroundColor $color } }

# ── Platform Detection ─────────────────────────────────────────────────────────
function Get-DetectedPlatforms {
    $platforms = @()
    if (Test-Path (Join-Path $HOME ".config\opencode")) { $platforms += "opencode" }
    if (Test-Path (Join-Path $HOME ".gemini\antigravity")) { $platforms += "antigravity" }
    if (Test-Path (Join-Path $HOME ".kilo") -Or Test-Path (Join-Path $HOME ".kilocode")) { $platforms += "kilocode" }
    if (Test-Path (Join-Path $HOME ".roo")) { $platforms += "roo" }
    if (Test-Path (Join-Path $HOME ".claude") -Or Test-Path (Join-Path $HOME ".agents")) { $platforms += "agents" }
    return $platforms
}

function Get-SkillDirs($platform) {
    switch ($platform) {
        "opencode"     { return @((Join-Path $HOME ".agents\skills"), (Join-Path $HOME ".config\opencode\skills")) }
        "antigravity"  { return @((Join-Path $HOME ".gemini\antigravity\plugins\$pluginName\dist\skills")) }
        "kilocode"     { return @((Join-Path $HOME ".kilo\commands")) }
        "roo"          { return @((Join-Path $HOME ".roo\commands")) }
        "agents"       { return @((Join-Path $HOME ".agents\skills"), (Join-Path $HOME ".claude\skills")) }
    }
    return @()
}

# ── Helpers ────────────────────────────────────────────────────────────────────
function Sync-ToProject($target) {
    if (!(Test-Path $target)) { return }

    Write-Log "Syncing OmniState to $target ..." "Cyan"

    $skillsSource = Join-Path $scriptDir ".opencode\skills"
    if (Test-Path $skillsSource) {
        $dest = Join-Path $target ".opencode\skills"
        if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }
        Copy-Item -Path "$skillsSource\*" -Destination $dest -Recurse -Force
    }

    $wfSource = Join-Path $scriptDir "dist\workflows"
    if (Test-Path $wfSource) {
        foreach ($dir in @(".agents", ".agent")) {
            $dest = Join-Path $target "$dir\workflows"
            if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }
            Copy-Item -Path "$wfSource\*" -Destination $dest -Force
        }
    }

    $tplSource = Join-Path $scriptDir "dist\templates"
    if (Test-Path $tplSource) {
        foreach ($dir in @(".agents", ".agent", ".opencode")) {
            $dest = Join-Path $target "$dir\templates"
            if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }
            Copy-Item -Path "$tplSource\*" -Destination $dest -Force
        }
    }

    $opencodeConfig = Join-Path $target "opencode.json"
    if (!(Test-Path $opencodeConfig) -and (Test-Path (Join-Path $scriptDir "opencode.json"))) {
        Copy-Item -Path (Join-Path $scriptDir "opencode.json") -Destination $opencodeConfig -Force
    }

    $gitignore = Join-Path $target ".gitignore"
    if (Test-Path $gitignore) {
        $content = Get-Content $gitignore -Raw
        $additions = @()
        $allPatterns = $memoryFiles + $ideDirs
        foreach ($pattern in $allPatterns) {
            if (-not $content.Contains($pattern)) { $additions += $pattern }
        }
        if ($additions.Count -gt 0) { Add-Content -Path $gitignore -Value $additions -Encoding UTF8 }
    }

    Write-Log "Synced to $target" "Green"
}

function Auto-Update {
    $stateDir = Join-Path $scriptDir ".omnistate"
    if (!(Test-Path $stateDir)) { New-Item -ItemType Directory -Path $stateDir -Force | Out-Null }
    $checkFile = Join-Path $stateDir ".last_update_check"
    $now = [DateTimeOffset]::Now.ToUnixTimeSeconds()
    $lastCheck = if (Test-Path $checkFile) { (Get-Content $checkFile -Raw).Trim() } else { "0" }
    if ($lastCheck -notmatch '^\d+$') { $lastCheck = "0" }

    if ($now - [int]$lastCheck -gt 86400) {
        Write-Log "Checking for OmniState updates ..." "Yellow"
        if ((Test-Path (Join-Path $scriptDir ".git")) -and (Get-Command git -ErrorAction SilentlyContinue)) {
            Set-Location $scriptDir
            $remoteHash = (git ls-remote origin -h refs/heads/main 2>$null).Split("`t")[0]
            $localHash = git rev-parse HEAD 2>$null
            if ($remoteHash -and $remoteHash -ne $localHash) {
                Write-Log "New version available! Updating ..." "Cyan"
                git pull origin main --quiet
                Write-Log "Updated to v$version" "Green"
            }
        }
        Set-Content -Path $checkFile -Value $now
    }
}

function Install-Global {
    Write-Log "Installing OmniState v$version ..." "Cyan"

    Auto-Update

    $platforms = Get-DetectedPlatforms
    if ($platforms.Count -eq 0) {
        Write-Log "No supported AI coding tools detected." "Yellow"
        Write-Log "Skills available locally in: $scriptDir\.opencode\skills\" "Yellow"
    } else {
        foreach ($platform in $platforms) {
            Write-Log "Installing for $platform ..." "Cyan"
            $dirs = Get-SkillDirs $platform
            foreach ($dir in $dirs) {
                if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
                if ($dir) {
                    Copy-Item -Path (Join-Path $scriptDir ".opencode\skills\*") -Destination $dir -Recurse -Force
                    Write-Log "  -> $dir" "Green"
                }
            }
        }
    }

    # Ensure local .opencode/skills is populated from dist/skills
    $localSkills = Join-Path $scriptDir ".opencode\skills"
    if (!(Test-Path $localSkills)) { New-Item -ItemType Directory -Path $localSkills -Force | Out-Null }
    $distSkills = Join-Path $scriptDir "dist\skills"
    if (Test-Path $distSkills) {
        foreach ($skillDir in (Get-ChildItem $distSkills -Directory)) {
            $dest = Join-Path $localSkills $skillDir.Name
            if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }
            Copy-Item -Path "$($skillDir.FullName)\*" -Destination $dest -Force
        }
    }

    Write-Log "OmniState v$version installed successfully!" "Green"
    Write-Host ""
    Write-Host "  Skills installed to: ~/.agents/skills/" -ForegroundColor Cyan
    Write-Host "  To use in a project: .\update.ps1 <project-path>" -ForegroundColor Cyan
    Write-Host ""
}

# ── Main ───────────────────────────────────────────────────────────────────────
if ($Check) {
    if (Test-Path (Join-Path $scriptDir ".git")) {
        Set-Location $scriptDir
        $remoteHash = (git ls-remote origin -h refs/heads/main 2>$null).Split("`t")[0]
        $localHash = git rev-parse HEAD 2>$null
        if ($remoteHash -and $remoteHash -ne $localHash) { exit 1 }
    }
    exit 0
}

if ($Auto) {
    Auto-Update
    if ($ProjectRoot) { Sync-ToProject $ProjectRoot }
    exit 0
}

if ($SyncOnly) {
    if ($ProjectRoot) { Sync-ToProject $ProjectRoot }
    exit 0
}

Install-Global
if ($ProjectRoot) { Sync-ToProject $ProjectRoot }
