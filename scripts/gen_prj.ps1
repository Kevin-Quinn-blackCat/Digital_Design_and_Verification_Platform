# 1. 初始化并拷贝基础模板
$sourcePath = "..\..\exp_lib\exp_prj_lib\New_prj"
$tempPath = ".\New_prj"

if (Test-Path $sourcePath) {
    Copy-Item -Path $sourcePath -Destination $tempPath -Recurse -Force
} else {
    Write-Error "源模板目录不存在: $sourcePath"
    pause
    exit
}

# 2. 获取用户输入
$FILE_NAME    = Read-Host "请输入工程名称 (FILE_NAME, 缺省为 new)"
if ([string]::IsNullOrWhiteSpace($FILE_NAME)) { $FILE_NAME = "new" }

$RTL_LANGUAGE = Read-Host "请输入设计语言后缀 (v/sv, 缺省为 v)"
if ([string]::IsNullOrWhiteSpace($RTL_LANGUAGE)) { $RTL_LANGUAGE = "v" }

$TB_LANGUAGE  = Read-Host "请输入仿真语言后缀 (v/sv, 缺省为 sv)"
if ([string]::IsNullOrWhiteSpace($TB_LANGUAGE)) { $TB_LANGUAGE = "sv" }

$RTL_TOOL     = Read-Host "请输入设计工具 (RTL_TOOL, 缺省为 none)"
if ([string]::IsNullOrWhiteSpace($RTL_TOOL)) { $RTL_TOOL = "none" }

$TB_TOOL      = Read-Host "请输入仿真工具 (TB_TOOL, 缺省为 Modelsim)"
if ([string]::IsNullOrWhiteSpace($TB_TOOL)) { $TB_TOOL = "Modelsim" }

$NAME         = Read-Host "请输入署名 (NAME, 缺省为 [空格])"
if ([string]::IsNullOrWhiteSpace($NAME)) { $NAME = " " }

$DATE         = Get-Date -Format "yyyy-MM-dd"

# 3. 根据语言选择删除多余文件
# 处理 RTL 文件
if ($RTL_LANGUAGE -eq "v") {
    $itemToRemove = Join-Path $tempPath "rtl\top.sv"
    if (Test-Path $itemToRemove) { Remove-Item $itemToRemove -Force }
} elseif ($RTL_LANGUAGE -eq "sv") {
    $itemToRemove = Join-Path $tempPath "rtl\top.v"
    if (Test-Path $itemToRemove) { Remove-Item $itemToRemove -Force }
}

# 处理 TB 文件
if ($TB_LANGUAGE -eq "v") {
    $itemToRemove = Join-Path $tempPath "tb\top_tb.sv"
    if (Test-Path $itemToRemove) { Remove-Item $itemToRemove -Force }
} elseif ($TB_LANGUAGE -eq "sv") {
    $itemToRemove = Join-Path $tempPath "tb\top_tb.v"
    if (Test-Path $itemToRemove) { Remove-Item $itemToRemove -Force }
}

# 4. 定义需要处理的文件路径（此时路径已根据语言确定）
$targetFiles = @(
    "$tempPath\rtl\top.$RTL_LANGUAGE",
    "$tempPath\tb\top_tb.$TB_LANGUAGE",
    "$tempPath\sim\workspace\config.mk",
    "$tempPath\sim\workspace\file_list.f"
)

# 替换字典（移除了  和  的替换）
$replacements = @{
    "{{FILE_NAME}}"    = $FILE_NAME
    "{{RTL_TOOL}}"     = $RTL_TOOL
    "{{TB_TOOL}}"      = $TB_TOOL
	"{{RTL_LANGUAGE}}" = $RTL_LANGUAGE
	"{{TB_LANGUAGE}}"  = $TB_LANGUAGE
    "{{NAME}}"         = $NAME
    "{{DATE}}"         = $DATE
}

# 5. 执行文本替换
foreach ($file in $targetFiles) {
    if (Test-Path $file) {
        $content = Get-Content -Path $file -Raw -Encoding UTF8
        foreach ($key in $replacements.Keys) {
            $content = $content.Replace($key, $replacements[$key])
        }
        # 使用 UTF8 无 BOM 编码保存
        [System.IO.File]::WriteAllText((Get-Item $file).FullName, $content)
    } else {
        Write-Warning "未找到文件: $file"
    }
}

# 6. 重命名文件（将 top 更改为项目名）
$oldRtlFile = "$tempPath\rtl\top.$RTL_LANGUAGE"
if (Test-Path $oldRtlFile) {
    Rename-Item -Path $oldRtlFile -NewName "$FILE_NAME.$RTL_LANGUAGE"
}

$oldTbFile = "$tempPath\tb\top_tb.$TB_LANGUAGE"
if (Test-Path $oldTbFile) {
    Rename-Item -Path $oldTbFile -NewName "$FILE_NAME`_tb.$TB_LANGUAGE"
}

# 7. 将 New 文件夹重命名为 {{FILE_NAME}}
Rename-Item -Path $tempPath -NewName $FILE_NAME

Write-Host "`n工程 $FILE_NAME 创建完成！" -ForegroundColor Green
pause