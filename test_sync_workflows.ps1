param()

$ErrorActionPreference = "Stop"

# Setup Output Colors for assertions
function Assert-True($condition, $message) {
    if ($condition) {
        Write-Host "✅ PASS: $message" -ForegroundColor Green
    } else {
        Write-Host "❌ FAIL: $message" -ForegroundColor Red
        throw "Assertion failed: $message"
    }
}

function Assert-False($condition, $message) {
    Assert-True -condition (!$condition) -message $message
}

function Assert-Equal($expected, $actual, $message) {
    if ($expected -eq $actual) {
        Write-Host "✅ PASS: $message" -ForegroundColor Green
    } else {
        Write-Host "❌ FAIL: $message - Expected: '$expected', Actual: '$actual'" -ForegroundColor Red
        throw "Assertion failed: $message"
    }
}

$testDir = Join-Path $PWD "temp_test_sync_workflows"
if (Test-Path $testDir) { Remove-Item $testDir -Recurse -Force }
New-Item -ItemType Directory -Path $testDir | Out-Null

try {
    Write-Host "--- Setup Mock Environment ---" -ForegroundColor Cyan

    # We will dot-source update.ps1 with -SyncOnly to load the functions, but we need to override the globals.
    . ./update.ps1 -SyncOnly

    # Override globals used by Sync-Workflows
    $global:scriptDir = Join-Path $testDir "scriptDir"
    $global:targetPluginPath = Join-Path $testDir "targetPluginPath"
    $global:protectedPatterns = @("test-pattern/", "other-pattern.txt")
    $global:Silent = $true

    # Create mock paths
    New-Item -ItemType Directory -Path $global:scriptDir | Out-Null
    New-Item -ItemType Directory -Path $global:targetPluginPath | Out-Null

    $targetProject = Join-Path $testDir "targetProject"
    New-Item -ItemType Directory -Path $targetProject | Out-Null

    # Test Case 1: Primary path exists ($targetPluginPath)
    Write-Host "`n--- Test Case 1: Primary Path Exists ---" -ForegroundColor Cyan
    $sourceWf = Join-Path $global:targetPluginPath "dist\workflows"
    $sourceTemplates = Join-Path $global:targetPluginPath "dist\templates"
    New-Item -ItemType Directory -Path $sourceWf -Force | Out-Null
    New-Item -ItemType Directory -Path $sourceTemplates -Force | Out-Null

    # Create some dummy files to copy
    Set-Content -Path (Join-Path $sourceWf "wf1.txt") -Value "workflow_content_1"
    Set-Content -Path (Join-Path $sourceTemplates "tmpl1.txt") -Value "template_content_1"

    # Create gitignore with one existing pattern
    $gitignorePath = Join-Path $targetProject ".gitignore"
    Set-Content -Path $gitignorePath -Value "test-pattern/" -Encoding UTF8

    # Run Function
    Sync-Workflows -targetProject $targetProject

    # Assertions
    $agentWf = Join-Path $targetProject ".agent\workflows\wf1.txt"
    $agentsWf = Join-Path $targetProject ".agents\workflows\wf1.txt"
    $agentTmpl = Join-Path $targetProject ".agent\templates\tmpl1.txt"
    $agentsTmpl = Join-Path $targetProject ".agents\templates\tmpl1.txt"

    Assert-True (Test-Path $agentWf) "File wf1.txt synced to .agent/workflows"
    Assert-True (Test-Path $agentsWf) "File wf1.txt synced to .agents/workflows"
    Assert-True (Test-Path $agentTmpl) "File tmpl1.txt synced to .agent/templates"
    Assert-True (Test-Path $agentsTmpl) "File tmpl1.txt synced to .agents/templates"

    # Check .gitignore
    $gitignoreContent = Get-Content $gitignorePath -Raw
    Assert-True ($gitignoreContent -match "other-pattern\.txt") "other-pattern.txt added to .gitignore"
    Assert-True ($gitignoreContent -match "\.agent/") ".agent/ added to .gitignore"
    Assert-True ($gitignoreContent -match "\.agents/") ".agents/ added to .gitignore"

    # Check no duplication
    $testPatternMatches = [regex]::Matches($gitignoreContent, "test-pattern/").Count
    Assert-Equal 1 $testPatternMatches "test-pattern/ should only appear once (no duplication)"

    # Test Case 2: Fallback path exists ($scriptDir)
    Write-Host "`n--- Test Case 2: Fallback Path Exists ---" -ForegroundColor Cyan
    $targetProject2 = Join-Path $testDir "targetProject2"
    New-Item -ItemType Directory -Path $targetProject2 | Out-Null

    # Remove primary path folders to trigger fallback
    Remove-Item $sourceWf -Recurse -Force
    Remove-Item $sourceTemplates -Recurse -Force

    $fallbackWf = Join-Path $global:scriptDir "dist\workflows"
    $fallbackTemplates = Join-Path $global:scriptDir "dist\templates"
    New-Item -ItemType Directory -Path $fallbackWf -Force | Out-Null
    New-Item -ItemType Directory -Path $fallbackTemplates -Force | Out-Null

    # Create some dummy files in fallback
    Set-Content -Path (Join-Path $fallbackWf "wf2.txt") -Value "workflow_content_2"
    Set-Content -Path (Join-Path $fallbackTemplates "tmpl2.txt") -Value "template_content_2"

    # Run Function
    Sync-Workflows -targetProject $targetProject2

    # Assertions
    $agentWf2 = Join-Path $targetProject2 ".agent\workflows\wf2.txt"
    $agentsWf2 = Join-Path $targetProject2 ".agents\workflows\wf2.txt"
    $agentTmpl2 = Join-Path $targetProject2 ".agent\templates\tmpl2.txt"
    $agentsTmpl2 = Join-Path $targetProject2 ".agents\templates\tmpl2.txt"

    Assert-True (Test-Path $agentWf2) "File wf2.txt synced to .agent/workflows via fallback path"
    Assert-True (Test-Path $agentsWf2) "File wf2.txt synced to .agents/workflows via fallback path"
    Assert-True (Test-Path $agentTmpl2) "File tmpl2.txt synced to .agent/templates via fallback path"
    Assert-True (Test-Path $agentsTmpl2) "File tmpl2.txt synced to .agents/templates via fallback path"

    Write-Host "`nAll tests passed successfully! 🎉" -ForegroundColor Green
}
finally {
    # Cleanup
    Write-Host "`n--- Cleanup Mock Environment ---" -ForegroundColor Cyan
    if (Test-Path $testDir) { Remove-Item $testDir -Recurse -Force }
}
