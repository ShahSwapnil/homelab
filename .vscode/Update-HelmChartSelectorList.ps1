# --- Configuration ---
$TasksPath = ".vscode/tasks.json"
$SearchDir = "./helm"  # Change this to the directory you want to scan

# 1. Get the names of subfolders in the target directory
if (-Not (Test-Path $SearchDir)) {
    Write-Error "Target directory '$SearchDir' not found."
    return
}

$FolderNames = Get-ChildItem -Path $SearchDir -Directory | Select-Object -ExpandProperty Name

# output FolderNames to console
Write-Host "Found folders:" -ForegroundColor Green
$FolderNames | ForEach-Object { Write-Host "- $_" -ForegroundColor Green }

# 2. Read the existing tasks.json file
if (-Not (Test-Path $TasksPath)) {
    Write-Error "tasks.json not found at $TasksPath"
    return
}
$JsonContent = Get-Content -Raw -Path $TasksPath | ConvertFrom-Json

# 3. Locate the 'folderSelector' input and update its options
$Found = $false
foreach ($inputVar in $JsonContent.inputs) {
    if ($inputVar.id -eq "HelmChartPicker") {
        $inputVar.options = [string[]]$FolderNames
        $Found = $true
        break
    }
}

if ($Found) {
    # 4. Convert back to JSON and save
    # We use -Depth 100 to ensure the nested structure isn't truncated
    $JsonContent | ConvertTo-Json -Depth 100 -Compress | Out-File -FilePath $TasksPath -Encoding UTF8 
    Write-Host "Successfully updated $TasksPath with $( $FolderNames.Count ) folders." -ForegroundColor Cyan

    npx --yes prettier --write .vscode\tasks.json
} else {
    Write-Warning "Could not find an input with id 'HelmChartSelector' in tasks.json"
}
