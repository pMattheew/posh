$manifestPath = ".\..\pwsh.psd1"
$commitRegex = '^(?<type>\w+)(\((?<scope>[^\)]+)\))?(?<bc>!)?:\s+(?<description>.+)$'
$commit = [string](git log -1 --pretty=%B)

function Get-CommitType {
    param (
        [Parameter(Mandatory)]
        [string] $message
    )
    if ($message -match $commitRegex) {
        if ($matches['bc']) {
            return 'major'
        }
        elseif ($matches['type'] -eq 'fix') {
            return 'patch'
        }
        else {
            return 'minor'
        }
    }
    else {
        throw "Invalid commit message. Check if it is following Conventional Commits convention."
    }
}

function Get-ManifestVersion {
    $currentVersion = Get-Content $manifestPath | Select-String -Pattern 'ModuleVersion\s+=\s+["''](.+)["'']'
    $currentVersion = $currentVersion.Matches.Groups[1].Value
    return $currentVersion.Split('.')
}

function Set-ManifestVersion {
    param (
        [Parameter(Mandatory)]
        [array] $versionParts
    )
    $newVersion = $versionParts -join '.'
    $content = Get-Content -Path $manifestPath -Encoding utf8
    $newContent = $content -replace "(?<=ModuleVersion\s*=\s*\').*?(?=\'\s*)", "$newVersion"
    Set-Content -Path $manifestPath -Value $newContent -Encoding utf8
}

function Publish-ModuleVersion {
    $versionParts = Get-ManifestVersion
    $type = Get-CommitType $commit
    switch ($type) {
        'major' { $versionParts[0] = "$([int]$versionParts[0] + 1)" }
        'minor' { $versionParts[1] = "$([int]$versionParts[1] + 1)" }
        'patch' { $versionParts[2] = "$([int]$versionParts[2] + 1)" }
    }
    Set-ManifestVersion $versionParts
}

Publish-ModuleVersion
