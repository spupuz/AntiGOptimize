# OmniState Update & Sync Script
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
} else { "1.5.0" }
$pluginName = "omnistate"
$repoUrl = "https://github.com/spupuz/OmniState.git"

$memoryFiles = @(
    "omnistate.config.json", "antigravity.config.json", "project-summary.md", "tasks-history.json",
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
function Inject-Version($file, $version) {
    if (Test-Path $file) {
        (Get-Content $file -Raw) -replace '\{\{VERSION\}\}', $version | Set-Content $file -Encoding UTF8
    }
}

# Get source directory for a platform (skill format vs workflow format)
function Get-PlatformSource($platform) {
    switch ($platform) {
        "opencode" { return ".opencode\skills" }
        "agents"   { return ".opencode\skills" }
        "claude"   { return ".opencode\skills" }
        "antigravity" { return "dist\workflows" }
        "kilocode" { return "dist\workflows" }
        "roo"      { return "dist\workflows" }
    }
    return ""
}

# Get destination directory for a platform in a project
function Get-PlatformDest($platform) {
    switch ($platform) {
        "opencode" { return ".opencode\skills" }
        "agents"   { return ".agents\skills" }
        "claude"   { return ".agents\skills" }
        "antigravity" { return ".agents\workflows" }
        "kilocode" { return ".kilo\commands" }
        "roo"      { return ".roo\commands" }
    }
    return ""
}

# Detect which platforms a specific project uses
function Get-ProjectPlatforms($target) {
    $platforms = @()

    # opencode
    if ((Test-Path (Join-Path $target "opencode.json")) -Or (Test-Path (Join-Path $target ".opencode"))) {
        $platforms += "opencode"
    }

    # kilocode
    if ((Test-Path (Join-Path $target ".kilo")) -Or (Test-Path (Join-Path $target ".kilo\config.json"))) {
        $platforms += "kilocode"
    }

    # agents (Claude Code, Antigravity)
    if ((Test-Path (Join-Path $target ".agent")) -Or (Test-Path (Join-Path $target ".agents"))) {
        $platforms += "agents"
        # Antigravity usa .agents/workflows
        if (Test-Path (Join-Path $target ".agents\workflows")) {
            $platforms += "antigravity"
        }
    }

    # roo
    if (Test-Path (Join-Path $target ".roo")) {
        $platforms += "roo"
    }

    return $platforms
}

# Install skills for a specific platform with correct format
function Install-ForPlatform($platform, $target) {
    $sourceDir = Get-PlatformSource $platform
    $destDir = Get-PlatformDest $platform

    if (-not $sourceDir -Or -not $destDir) { return }

    $fullSource = Join-Path $scriptDir $sourceDir
    $fullDest = Join-Path $target $destDir

    if (-not (Test-Path $fullSource)) { return }

    if (-not (Test-Path $fullDest)) { New-Item -ItemType Directory -Path $fullDest -Force | Out-Null }

    if ($platform -eq "opencode" -Or $platform -eq "agents" -Or $platform -eq "claude") {
        # Formato skill: copia sottodirectory
        Copy-Item -Path "$fullSource\*" -Destination $fullDest -Recurse -Force
    } else {
        # Formato workflow: copia solo file .md piatti in batch
        if (Test-Path "$fullSource\*.md") {
            Copy-Item -Path "$fullSource\*.md" -Destination $fullDest -Force
        }
    }
}

function Sync-ToProject($target) {
    if (!(Test-Path $target)) { return }

    # Migrate legacy config if present
    $migrateScript = Join-Path $scriptDir "migrate.ps1"
    $legacyConfig = Join-Path $target "antigravity.config.json"
    if ((Test-Path $migrateScript) -and (Test-Path $legacyConfig)) {
        & $migrateScript -Target $target -Silent
    }

    Write-Log "Syncing OmniState to $target ..." "Cyan"

    # Detect platforms from project
    $projectPlatforms = Get-ProjectPlatforms $target

    # Detect global platforms
    $globalPlatforms = Get-DetectedPlatforms

    # Combine (project has priority)
    $allPlatforms = @($projectPlatforms + $globalPlatforms) | Sort-Object -Unique

    # Install skills for each detected platform with correct format
    foreach ($platform in $allPlatforms) {
        Install-ForPlatform $platform $target
    }

    $tplSource = Join-Path $scriptDir "dist\templates"
    if (Test-Path $tplSource) {
        foreach ($dir in @(".agents", ".agent", ".opencode")) {
            $dest = Join-Path $target "$dir\templates"
            if (!(Test-Path $dest)) { New-Item -ItemType Directory -Path $dest -Force | Out-Null }
            Copy-Item -Path "$tplSource\*" -Destination $dest -Force
        }
        # Inject version into templates
        foreach ($dir in @(".agents", ".agent", ".opencode")) {
            $configFile = Join-Path $target "$dir\templates\omnistate.config.json"
            $dashboardFile = Join-Path $target "$dir\templates\dashboard.html"
            if (Test-Path $configFile) { Inject-Version $configFile $version }
            if (Test-Path $dashboardFile) { Inject-Version $dashboardFile $version }
        }
    }

    # Copy omnistate.config.json to project root if not present
    $rootConfig = Join-Path $target "omnistate.config.json"
    $tplConfig = Join-Path $scriptDir "dist\templates\omnistate.config.json"
    if (!(Test-Path $rootConfig) -and (Test-Path $tplConfig)) {
        Copy-Item -Path $tplConfig -Destination $rootConfig -Force
        Inject-Version $rootConfig $version
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
            $sourceDir = Get-PlatformSource $platform
            $dirs = Get-SkillDirs $platform
            foreach ($dir in $dirs) {
                if ($dir -and !(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
                if ($dir) {
                    $fullSource = Join-Path $scriptDir $sourceDir
                    if ($platform -eq "opencode" -Or $platform -eq "agents" -Or $platform -eq "claude") {
                        # Formato skill: copia sottodirectory
                        Copy-Item -Path "$fullSource\*" -Destination $dir -Recurse -Force
                    } else {
                        # Formato workflow: copia solo file .md piatti in batch
                        if (Test-Path "$fullSource\*.md") {
                            Copy-Item -Path "$fullSource\*.md" -Destination $dir -Force
                        }
                    }
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
