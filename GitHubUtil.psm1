$githubApiBase = 'https://api.github.com'
$githubApiVersion = '2026-03-10'
$defaultGithubHeaders = @{
    'X-GitHub-Api-Version' = $githubApiVersion
}


function Get-DefaultBranch {
    param([Parameter(Mandatory)][string]$Repo)

    $response = Invoke-RestMethod `
        $githubApiBase/repos/$Repo `
        -Headers $defaultGithubHeaders
    $response.default_branch
}

Export-ModuleMember Get-DefaultBranch


function Get-LatestCommitOfBranch {
    param(
        [Parameter(Mandatory)][string]$Repo,
        [Parameter(Mandatory)][string]$Branch
    )

    $response = Invoke-RestMethod `
        $githubApiBase/repos/$Repo/branches/$Branch `
        -Headers $defaultGithubHeaders
    $response.commit.sha
}

Export-ModuleMember Get-LatestCommitOfBranch


function Get-RepoArchive {
    param(
        [Parameter(Mandatory)][string]$Repo,
        [Parameter(Mandatory)][string]$Ref,
        [Parameter(Mandatory)][string]$OutFile
    )

    Invoke-WebRequest $githubApiBase/repos/$Repo/zipball/$Ref `
        -Headers $defaultGithubHeaders `
        -OutFile $OutFile
}

Export-ModuleMember Get-RepoArchive
