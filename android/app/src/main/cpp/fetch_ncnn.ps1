# fetch_ncnn.ps1
# 用途:从 Tencent ncnn 官方 release 下载 android-vulkan 预编译包,只解出 arm64-v8a。
# 触发:首次构建前手动执行一次,或被 Gradle / CI 调用。
# 不需要联网的二次开发可以直接删掉本脚本,CMakeLists.txt 仍会按既有目录结构工作。

[CmdletBinding()]
param(
    [string]$Version = "20260526",
    [string]$Abi = "arm64-v8a"
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = Join-Path $ScriptDir "ncnn\ncnn-${Version}-android-vulkan"
$TargetAbi = Join-Path $TargetDir $Abi

# 已存在则直接退出(幂等)
if (Test-Path $TargetAbi) {
    Write-Host "[fetch_ncnn] 已存在 $TargetAbi,跳过下载。" -ForegroundColor Yellow
    exit 0
}

$Url = "https://github.com/Tencent/ncnn/releases/download/${Version}/ncnn-${Version}-android-vulkan.zip"
$ZipPath = Join-Path $env:TEMP "ncnn-${Version}-android-vulkan.zip"

Write-Host "[fetch_ncnn] 下载 $Url" -ForegroundColor Cyan
Invoke-WebRequest -Uri $Url -OutFile $ZipPath -UseBasicParsing

Write-Host "[fetch_ncnn] 解压并裁剪到 $Abi" -ForegroundColor Cyan
$TempExtract = Join-Path $env:TEMP "ncnn-${Version}-extract"
if (Test-Path $TempExtract) { Remove-Item -Recurse -Force $TempExtract }
Expand-Archive -Path $ZipPath -DestinationPath $TempExtract

# 顶层通常就是 ncnn-<ver>-android-vulkan
$ExtractedRoot = Get-ChildItem -Directory $TempExtract | Select-Object -First 1
$SrcAbi = Join-Path $ExtractedRoot.FullName $Abi
if (-not (Test-Path $SrcAbi)) {
    throw "解压结果中未找到 $Abi 目录,可能 ncnn release 结构调整了。"
}

New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
Move-Item -Path $SrcAbi -Destination $TargetAbi

# 清理:同时把不需要的 ABI 目录全删了(armeabi-v7a / riscv64 / x86 / x86_64)
Get-ChildItem -Directory $ExtractedRoot.FullName | Where-Object { $_.Name -ne $Abi } | ForEach-Object {
    Remove-Item -Recurse -Force $_.FullName
}
# 把 $ExtractedRoot 里的剩余内容(include 共享目录等)挪进 TargetDir
Get-ChildItem -Path $ExtractedRoot.FullName -Force | Where-Object { $_.Name -ne $Abi } | ForEach-Object {
    Move-Item -Path $_.FullName -Destination $TargetDir
}

Remove-Item -Recurse -Force $TempExtract, $ZipPath

Write-Host "[fetch_ncnn] 完成:$TargetAbi" -ForegroundColor Green
