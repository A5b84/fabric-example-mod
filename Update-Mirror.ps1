<#
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

if (-not $UpstreamCommit) {
    if (-not $UpstreamBranch) {
        $UpstreamBranch = Get-DefaultBranch $UpstreamRepo
        Write-Host "Using branch '$UpstreamBranch' (default of repo $UpstreamRepo)"
    }

    $UpstreamCommit = Get-LatestCommitOfBranch $UpstreamRepo $UpstreamBranch
    Write-Host "Using commit $UpstreamCommit (latest of branch $UpstreamBranch)"
}

$temporaryDirectory = New-TemporaryDirectory
$mirrorWorktreePath = Join-Path $temporaryDirectory mirror

try {
    Write-Host 'Downloading repo archive'
    $archiveZipPath = Join-Path $temporaryDirectory archive.zip
    Get-RepoArchive $UpstreamRepo $UpstreamCommit $archiveZipPath
    $extractedArchivePath = Join-Path $temporaryDirectory archive
    Expand-Archive $archiveZipPath -DestinationPath $extractedArchivePath
    $archiveContentRoot = Get-SingleChild $extractedArchivePath

    Write-Host 'Creating worktree'
    Invoke-CheckedCommand git worktree add $mirrorWorktreePath $MirrorBranch
    $createdWorkTree = $true

    Remove-Item $mirrorWorktreePath -Recurse -Force -Exclude .git
    Move-Item (Join-Path $archiveContentRoot *) -Destination $mirrorWorktreePath

    $changes = (Invoke-CheckedCommand git -C $mirrorWorktreePath status --porcelain).Count
    if ($changes -gt 0) {
        Write-Host "Committing $changes changes"
        Invoke-CheckedCommand git -C $mirrorWorktreePath add $mirrorWorktreePath

        $message = "Snapshot $($UpstreamBranch ? "branch $UpstreamBranch" : "repo") at commit https://github.com/$UpstreamRepo/commit/$UpstreamCommit"
        Invoke-CheckedCommand git -C $mirrorWorktreePath commit -m $message
    } else {
        Write-Output 'Mirror is already up to date'
    }
} catch {
    Write-Error $_ -ErrorAction Continue
} finally {
    if ($createdWorkTree) {
        Write-Host 'Removing worktree'
        git worktree remove $mirrorWorktreePath --force
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to remove worktree, exit code: $LASTEXITCODE" -ErrorAction Continue
        }
    }

    Remove-Item $temporaryDirectory -Recurse -Force
}
