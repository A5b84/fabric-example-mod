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

$oldModId = "modid"
$oldPackage = "example"

$path = "build.gradle"
(Get-Content $path).Replace($oldModId, $modId) | Set-Content $path

$path = "gradle.properties"
(Get-Content $path).Replace($oldModId, $modId) | Set-Content $path


$path = "src/main/java/io/github/a5b84/example/config/ExampleModConfig.java"
(Get-Content $path).Replace(".$oldPackage", ".$package").Replace("ExampleMod", $className) | Set-Content $path
Move-Item $path $path.Replace("ExampleMod", $className)

$path = "src/main/java/io/github/a5b84/example/mixin/ExampleMixin.java"
(Get-Content $path).Replace(".$oldPackage", ".$package") | Set-Content $path
Move-Item $path $path.Replace("ExampleMod", $className)

$path = "src/main/java/io/github/a5b84/example/ExampleMod.java"
(Get-Content $path).Replace(".$oldPackage", ".$package").Replace("ExampleMod", $className).Replace("modid", $modId) | Set-Content $path
Move-Item $path $path.Replace("ExampleMod", $className)

$path = "src/main/java/io/github/a5b84/example"
Move-Item $path $path.Replace("example", $package)

$path = "src/main/resources/assets/modid/lang/en_us.json"
(Get-Content $path).Replace("modid", $modId) | Set-Content $path

$path = "src/main/resources/assets/modid"
Move-Item $path $path.Replace("modid", $modId)

$path = "src/main/resources/fabric.mod.json"
(Get-Content $path).Replace($oldModId, $modId).Replace("Example mod", ".$modId").Replace("fabric-example-mod", $modId).Replace(".$oldPackage", ".$package").Replace("ExampleMod", $className) | Set-Content $path

$path = "src/main/resources/modid.mixins.json"
(Get-Content $path).Replace(".$oldPackage", ".$package") | Set-Content $path
Move-Item $path $path.Replace("modid", $modId)


$path = "src/client/java/io/github/a5b84/example/config/ModMenuIntegration.java"
(Get-Content $path).Replace(".$oldPackage", ".$package").Replace("ExampleMod", $className) | Set-Content $path

$path = "src/client/java/io/github/a5b84/example/mixin/client/ExampleClientMixin.java"
(Get-Content $path).Replace(".$oldPackage", ".$package") | Set-Content $path
Move-Item $path $path.Replace("ExampleMod", $className)

$path = "src/client/java/io/github/a5b84/example/ExampleModClient.java"
(Get-Content $path).Replace(".$oldPackage", ".$package").Replace("ExampleMod", $className) | Set-Content $path
Move-Item $path $path.Replace("ExampleMod", $className)

$path = "src/client/java/io/github/a5b84/example"
Move-Item $path $path.Replace($oldPackage, $package)

$path = "src/client/resources/modid.client.mixins.json"
(Get-Content $path).Replace(".$oldPackage", ".$package") | Set-Content $path
Move-Item $path $path.Replace("modid", $modId)
