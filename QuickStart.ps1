param (
    [Parameter(Mandatory = $true)] [String] $modId
)

if (!($modId -match "^[a-z][a-z0-9-_]{1,63}$")) {
    # https://github.com/FabricMC/fabric-loader/blob/5dadf857ff5f30f5a681a1033e806794423c91ef/src/main/java/net/fabricmc/loader/impl/metadata/MetadataVerifier.java#L36
    Write-Host "Illegal mod ID: $modId" -ForegroundColor Red
    exit 1
}

$package = $modId -replace "[-_]", ""
$className = (Get-Culture).TextInfo.ToTitleCase($modId) -replace "[-_]", ""

$path = "gradle.properties"
(Get-Content $path).Replace("fabric-example-mod", $modId) | Set-Content $path

$path = "src/main/java/io/github/a5b84/example/config/ExampleModConfig.java"
(Get-Content $path).Replace(".example", ".$package").Replace("ExampleMod", $className) | Set-Content $path
Move-Item $path $path.Replace("ExampleMod", $className)

$path = "src/main/java/io/github/a5b84/example/config/ModMenuIntegration.java"
(Get-Content $path).Replace(".example", ".$package").Replace("ExampleMod", $className) | Set-Content $path

$path = "src/main/java/io/github/a5b84/example/ExampleMod.java"
(Get-Content $path).Replace(".example", ".$package").Replace("ExampleMod", $className).Replace("modid", $modId) | Set-Content $path
Move-Item $path $path.Replace("ExampleMod", $className)

$path = "src/main/java/io/github/a5b84/example"
Move-Item $path $path.Replace("example", $package)

$path = "src/main/resources/assets/modid/lang/en_us.json"
(Get-Content $path).Replace("modid", $modId) | Set-Content $path

$path = "src/main/resources/assets/modid"
Move-Item $path $path.Replace("modid", $modId)

$path = "src/main/resources/fabric.mod.json"
(Get-Content $path).Replace("modid", $modId).Replace("Example Mod", ".$modId").Replace("fabric-example-mod", $modId).Replace(".example", ".$package").Replace("ExampleMod", $className) | Set-Content $path

$path = "src/main/resources/modid.mixins.json"
(Get-Content $path).Replace(".example", ".$package") | Set-Content $path
Move-Item $path $path.Replace("modid", $modId)
