function Write-Step {
    param([Parameter(Mandatory)][string]$Step)
    Write-Host "--- $Step ---" -ForegroundColor Yellow
}

Export-ModuleMember Write-Step


function New-TemporaryDirectory {
    $path = Join-Path ([System.IO.Path]::GetTempPath()) "fabric-example-mod-linear-mirror-$PID-$(Get-Random)"
    New-Item -Path $path -Type Directory > $null
    $path
}

Export-ModuleMember New-TemporaryDirectory


function Format-CommandArgument {
    param([Parameter(Mandatory)][string]$Argument)
    # Formatting for display, doesn't need to be perfect
    if ($Argument.Contains(' ') -or $Argument.Contains("'")) {
        "'$($Argument.Replace("'", "''"))'"
    } else {
        $Argument
    }
}

function Invoke-CheckedCommand {
    param(
        [Parameter(Mandatory)][string]$Executable,
        [Parameter(ValueFromRemainingArguments)][string[]]$Arguments
    )

    $displayCommand = (Format-CommandArgument $Executable) + " " + ($Arguments | ForEach-Object { Format-CommandArgument $_ })

    Write-Host "Running $displayCommand" -ForegroundColor DarkGray
    & $Executable @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to run command $displayCommand, exit code: $LASTEXITCODE"
    }
}

Export-ModuleMember Invoke-CheckedCommand


function Get-SingleChild() {
    param([Parameter(Mandatory)][string]$Path)
    $children = Get-ChildItem $Path
    if ($children.Count -eq 1) {
        $children[0]
    } else {
        throw "Expected '$Path' to have exactly one child but it had $($children.Count)"
    }
}

Export-ModuleMember Get-SingleChild
