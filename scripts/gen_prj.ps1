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
$FILE_NAME    = Read-Host "请输入工程名称 (FILE_NAME)"
$RTL_LANGUAGE = Read-Host "请输入设计语言后缀 (RTL_LANGUAGE, 如 v/sv)"
$TB_LANGUAGE  = Read-Host "请输入仿真语言后缀 (TB_LANGUAGE, 如 v/sv)"

$RTL_TOOL     = Read-Host "请输入设计工具 (RTL_TOOL, 缺省为 none)"
if ([string]::IsNullOrWhiteSpace($RTL_TOOL)) { $RTL_TOOL = "none" }

$TB_TOOL      = Read-Host "请输入仿真工具 (TB_TOOL, 缺省为 Modelsim)"
if ([string]::IsNullOrWhiteSpace($TB_TOOL)) { $TB_TOOL = "Modelsim" }

$NAME         = Read-Host "请输入署名 (NAME)"
$DATE         = Get-Date -Format "yyyy-MM-dd"

# 3. 定义需要处理的文件路径和替换字典
$targetFiles = @(
    "$tempPath\rtl\top.v",
    "$tempPath\tb\top_tb.v",
    "$tempPath\sim\workspace\config.mk",
    "$tempPath\sim\workspace\file_list.f"
)

$replacements = @{
    "{{FILE_NAME}}"    = $FILE_NAME
    "{{RTL_LANGUAGE}}" = $RTL_LANGUAGE
    "{{TB_LANGUAGE}}"  = $TB_LANGUAGE
    "{{RTL_TOOL}}"     = $RTL_TOOL
    "{{TB_TOOL}}"      = $TB_TOOL
    "{{NAME}}"         = $NAME
    "{{DATE}}"         = $DATE
}

# 4. 执行文本替换
foreach ($file in $targetFiles) {
    if (Test-Path $file) {
        $content = Get-Content -Path $file -Raw -Encoding UTF8
        foreach ($key in $replacements.Keys) {
            $content = $content.Replace($key, $replacements[$key])
        }
        # 使用 UTF8 无 BOM 编码保存，通常对 EDA 工具更友好
        [System.IO.File]::WriteAllText((Get-Item $file).FullName, $content)
    } else {
        Write-Warning "未找到文件: $file"
    }
}

# 5. 重命名 top.v 和 top_tb.v
$oldRtlFile = "$tempPath\rtl\top.v"
$newRtlFile = "$tempPath\rtl\$FILE_NAME.$RTL_LANGUAGE"
if (Test-Path $oldRtlFile) {
    Rename-Item -Path $oldRtlFile -NewName "$FILE_NAME.$RTL_LANGUAGE"
}

$oldTbFile = "$tempPath\tb\top_tb.v"
$newTbFile = "$tempPath\tb\$FILE_NAME`_tb.$TB_LANGUAGE"
if (Test-Path $oldTbFile) {
    Rename-Item -Path $oldTbFile -NewName "$FILE_NAME`_tb.$TB_LANGUAGE"
}

# 6. 将 New 文件夹重命名为 {{FILE_NAME}}
Rename-Item -Path $tempPath -NewName $FILE_NAME

Write-Host "`n工程 $FILE_NAME 创建完成！" -ForegroundColor Green
pause