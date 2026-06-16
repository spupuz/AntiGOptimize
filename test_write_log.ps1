$ErrorActionPreference = "Stop"

$scriptContent = Get-Content -Path "update.ps1" -Raw

# Use AST parser to extract function safely
$tokens = $null
$errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseInput($scriptContent, [ref]$tokens, [ref]$errors)

$functionAst = $ast.Find({
    param($node)
    $node -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $node.Name -eq "Write-Log"
}, $true)

if (-not $functionAst) {
    throw "Could not find Write-Log function."
}

# The Extent.Text property contains the exact text of the function definition
$functionCode = $functionAst.Extent.Text

Invoke-Expression $functionCode

# Test if function is loaded
Write-Host "Function loaded. Type of Write-Log: $((Get-Command Write-Log).CommandType)"

# Mock Write-Host
$global:WriteHostCalls = @()

function Write-Host {
    param (
        [Parameter(Position=0, ValueFromPipeline=$true, ValueFromRemainingArguments=$true)]
        $Object,
        $NoNewline,
        $Separator,
        $ForegroundColor,
        $BackgroundColor
    )
    $callInfo = @{
        Message = $Object
        ForegroundColor = $ForegroundColor
    }
    $global:WriteHostCalls += $callInfo
}

Write-Host "Checking mock..." -ForegroundColor "Blue"
if ($global:WriteHostCalls.Count -eq 1 -and $global:WriteHostCalls[0].Message -eq "Checking mock..." -and $global:WriteHostCalls[0].ForegroundColor -eq "Blue") {
    # It worked, clear it
    $global:WriteHostCalls = @()
} else {
    throw "Mock Write-Host failed."
}

# Test 1: $Silent = $false (default should print)
$Silent = $false
Write-Log "Test Message 1" "Red"

if ($global:WriteHostCalls.Count -eq 1 -and $global:WriteHostCalls[0].Message -eq "Test Message 1" -and $global:WriteHostCalls[0].ForegroundColor -eq "Red") {
    $Host.UI.Write("DarkGreen", $Host.UI.RawUI.BackgroundColor, "PASS: Write-Log prints when `$Silent is `$false`n")
} else {
    throw "FAIL: Write-Log did not call Write-Host correctly when `$Silent is `$false"
}
$global:WriteHostCalls = @() # reset

# Test 2: $Silent = $true (should NOT print)
$Silent = $true
Write-Log "Test Message 2" "Blue"

if ($global:WriteHostCalls.Count -eq 0) {
    $Host.UI.Write("DarkGreen", $Host.UI.RawUI.BackgroundColor, "PASS: Write-Log does NOT print when `$Silent is `$true`n")
} else {
    throw "FAIL: Write-Log called Write-Host when `$Silent was `$true"
}

$Host.UI.Write("DarkGreen", $Host.UI.RawUI.BackgroundColor, "All tests passed successfully!`n")
