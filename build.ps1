$TOKEN = "9MIP4bMbdOtYE6f4kR9JClugOr6AST9_KO8qF2_XxV8"
$UPLOAD_URL = "https://dl.shortformfunnels.com/upload"
$APK_PATH = ".\build\app\outputs\flutter-apk\app-release.apk"
$UPLOAD_PATH = "apps/app-release.apk"

Write-Host "=== Building APK ===" -ForegroundColor Cyan
flutter build apk

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed with exit code $LASTEXITCODE" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Build succeeded." -ForegroundColor Green

if (-not (Test-Path $APK_PATH)) {
    Write-Host "APK not found at: $APK_PATH" -ForegroundColor Red
    exit 1
}

$fileInfo = Get-Item $APK_PATH
$sizeMB = [math]::Round($fileInfo.Length / 1MB, 2)
Write-Host "Uploading $sizeMB MB..." -ForegroundColor Cyan

Add-Type -AssemblyName System.Net.Http

$fileStream = [System.IO.File]::OpenRead((Resolve-Path $APK_PATH))

try {
    $multipart = [System.Net.Http.MultipartFormDataContent]::new()

    $fileContent = [System.Net.Http.StreamContent]::new($fileStream)
    $fileContent.Headers.ContentType = [System.Net.Http.Headers.MediaTypeHeaderValue]::Parse("application/octet-stream")
    $multipart.Add($fileContent, "file", $fileInfo.Name)
    $multipart.Add([System.Net.Http.StringContent]::new($UPLOAD_PATH), "path")
    $multipart.Add([System.Net.Http.StringContent]::new("0"), "ttl")

    $client = [System.Net.Http.HttpClient]::new()
    $client.DefaultRequestHeaders.Authorization = `
        [System.Net.Http.Headers.AuthenticationHeaderValue]::new("Bearer", $TOKEN)

    $response = $client.PostAsync("$UPLOAD_URL`?overwrite=true", $multipart).Result
    $body = $response.Content.ReadAsStringAsync().Result

    if ($response.IsSuccessStatusCode) {
        $json = $body | ConvertFrom-Json
        Write-Output $json.url
    } else {
        Write-Host "Upload failed: $($response.StatusCode.value__) $($response.ReasonPhrase)" -ForegroundColor Red
        Write-Host $body -ForegroundColor Red
        exit 1
    }
}
finally {
    $fileStream.Dispose()
    if ($client) { $client.Dispose() }
}