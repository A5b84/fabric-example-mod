<#
    .SYNOPSIS
    Updates a mirror by performing a snapshot of the upstream repo at a certain commit.

    .PARAMETER UpstreamBranch
    The branch to snapshot.
    Defaults to the default branch of the upstream repository.
    Ignored if UpstreamCommit is specified.

    .PARAMETER UpstreamCommit
    The commit at which to snapshot the upstream repository.
    Defaults to the latest commit of UpstreamBranch.

    .PARAMETER UpstreamRepo
    The repository to mirror formatted as "<Owner>/<Repo>".

    .PARAMETER MirrorBranch
    The local branch to which to save the snapshot.
#>

[CmdletBinding()]
param(
    [string]$UpstreamBranch,
    [string]$UpstreamCommit,
    [string]$UpstreamRepo = "FabricMC/fabric-example-mod",
    [string]$MirrorBranch = "mirror"
)

$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot Util.psm1)
Import-Module (Join-Path $PSScriptRoot GitHubUtil.psm1)

$repoRoot = $PSScriptRoot

if (-not $UpstreamCommit) {
    if (-not $UpstreamBranch) {
        $UpstreamBranch = Get-DefaultBranch $UpstreamRepo
        Write-Host "Using branch '$UpstreamBranch' (default of repo $UpstreamRepo)"
    }

    $UpstreamCommit = Get-LatestCommitOfBranch $UpstreamRepo $UpstreamBranch
    Write-Host "Using commit $UpstreamCommit (latest of branch $UpstreamBranch)"
}

$temporaryDirectory = New-TemporaryDirectory
$mirrorRepoPath = Join-Path $temporaryDirectory mirror

try {
    Write-Step 'Downloading repo archive'
    $archiveZipPath = Join-Path $temporaryDirectory archive.zip
    Get-RepoArchive $UpstreamRepo $UpstreamCommit $archiveZipPath
    $extractedArchivePath = Join-Path $temporaryDirectory archive
    Expand-Archive $archiveZipPath -DestinationPath $extractedArchivePath
    $archiveContentRoot = Get-SingleChild $extractedArchivePath

    Write-Step 'Updating mirror'
    Invoke-CheckedCommand git clone $repoRoot $mirrorRepoPath --branch $MirrorBranch --single-branch

    Get-ChildItem $mirrorRepoPath -Force -Exclude .git `
        | Remove-Item -Recurse -Force
    Move-Item (Join-Path $archiveContentRoot *) -Destination $mirrorRepoPath

    Invoke-CheckedCommand git -C $mirrorRepoPath config core.autocrlf false # Avoids warning when end of lines are converted
    # Add files before checking for changes in case something somehow modifies the files when adding them (eg EOL conversion)
    Invoke-CheckedCommand git -C $mirrorRepoPath add .

    $changes = (Invoke-CheckedCommand git -C $mirrorRepoPath status --porcelain).Count
    if ($changes -gt 0) {
        Write-Step "Committing $changes changes"
        $message = "Snapshot $($UpstreamBranch ? "branch $UpstreamBranch" : "repo") at commit https://github.com/$UpstreamRepo/commit/$UpstreamCommit"
        Invoke-CheckedCommand git -C $mirrorRepoPath commit -m $message
        Invoke-CheckedCommand git -C $mirrorRepoPath push
    } else {
        Write-Host 'Mirror is already up to date'
    }
} catch {
    Write-Error $_ -ErrorAction Continue
} finally {
    Write-Step 'Cleaning up temporary files'
    Remove-Item $temporaryDirectory -Recurse -Force
}
