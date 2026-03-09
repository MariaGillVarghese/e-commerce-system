# Jasypt Encryption Helper Script for Windows PowerShell
# Usage: .\encrypt-credentials.ps1 -Value "postgres" -Key "MySecretPassword123"

param(
    [Parameter(Mandatory=$false)]
    [string]$Value,
    
    [Parameter(Mandatory=$false)]
    [string]$Key
)

function Show-Usage {
    Write-Host "Jasypt Encryption Helper" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Usage Examples:" -ForegroundColor Yellow
    Write-Host "  `$> .\encrypt-credentials.ps1 -Value 'postgres' -Key 'MySecretPassword123'"
    Write-Host "  `$> .\encrypt-credentials.ps1 -Value 'SecurePassword123!' -Key 'MySecretPassword123'"
    Write-Host ""
}

function Generate-EncryptionKey {
    Write-Host "Generating secure random encryption key (256-bit)..." -ForegroundColor Green
    $bytes = New-Object byte[] 32
    $rng = [System.Security.Cryptography.RNGCryptoServiceProvider]::new()
    $rng.GetBytes($bytes)
    $key = [Convert]::ToBase64String($bytes)
    Write-Host "Generated Key: $key" -ForegroundColor Green
    return $key
}

# If no parameters provided, show usage
if ([string]::IsNullOrEmpty($Value) -and [string]::IsNullOrEmpty($Key)) {
    Show-Usage
    Write-Host "Do you want to:" -ForegroundColor Cyan
    Write-Host "1. Generate a new encryption key"
    Write-Host "2. Encrypt a value (interactive)"
    Write-Host "3. Exit"
    
    $choice = Read-Host "Enter your choice (1/2/3)"
    
    switch ($choice) {
        "1" {
            Generate-EncryptionKey
            exit 0
        }
        "2" {
            $Value = Read-Host "Enter value to encrypt"
            $Key = Read-Host "Enter encryption key" -AsSecureString
            $Key = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($Key))
        }
        default {
            exit 0
        }
    }
}

if ([string]::IsNullOrEmpty($Value) -or [string]::IsNullOrEmpty($Key)) {
    Write-Host "ERROR: Both -Value and -Key parameters are required" -ForegroundColor Red
    Show-Usage
    exit 1
}

Write-Host ""
Write-Host "Encrypting credentials using Jasypt..." -ForegroundColor Green
Write-Host "Value: $Value" -ForegroundColor Yellow

# Try to use Jasypt CLI if installed
$jasyptPath = (Get-Command jasypt -ErrorAction SilentlyContinue).Source

if ($jasyptPath) {
    Write-Host "Using Jasypt from: $jasyptPath" -ForegroundColor Green
    try {
        $encrypted = & jasypt encrypt input="$Value" password="$Key" algorithm=PBEWITHHMACSHA512ANDAES_256 2>&1
        
        Write-Host ""
        Write-Host "✓ Encryption successful!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Use this in your application.properties:" -ForegroundColor Cyan
        Write-Host "spring.datasource.password=ENC($encrypted)" -ForegroundColor Green
        Write-Host ""
        Write-Host "Then run application with encryption key:" -ForegroundColor Cyan
        Write-Host "`$env:JASYPT_ENCRYPTOR_PASSWORD = '$Key'" -ForegroundColor Green
        Write-Host "java -jar service-1.0.0.jar" -ForegroundColor Green
        Write-Host ""
        Write-Host "For Docker Compose (add to services):" -ForegroundColor Cyan
        Write-Host "environment:" -ForegroundColor Green
        Write-Host "  JASYPT_ENCRYPTOR_PASSWORD: '$Key'" -ForegroundColor Green
        Write-Host "  SPRING_DATASOURCE_PASSWORD: ENC($encrypted)" -ForegroundColor Green
        exit 0
    }
    catch {
        Write-Host "ERROR: Failed to encrypt with Jasypt" -ForegroundColor Red
        Write-Host "Details: $_" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "WARNING: Jasypt CLI not found in PATH" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install Jasypt:" -ForegroundColor Cyan
    Write-Host "  1. Download from: https://github.com/ulisesbocchio/jasypt-spring-boot/releases"
    Write-Host "  2. Extract to a directory"
    Write-Host "  3. Add to PATH: C:\path\to\jasypt\bin"
    Write-Host ""
    Write-Host "Or use Maven directly:" -ForegroundColor Cyan
    Write-Host "  mvn test-compile exec:java -Dexec.mainClass='org.jasypt.zcrypt.ZeroableChar' -Dfrom.password=MyKey -Dto.password='value'" -ForegroundColor Green
    Write-Host ""
    Write-Host "Alternative: Use online tool (TESTING ONLY):" -ForegroundColor Yellow
    Write-Host "  https://www.devglan.com/online-tools/jasypt-online-encryption-decryption" -ForegroundColor Cyan
    exit 1
}
