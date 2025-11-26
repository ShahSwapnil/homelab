# -----------------------------------------------------------------------------
# PowerShell Script to Generate a Kubernetes TLS Secret Manifest
# -----------------------------------------------------------------------------

# --- CONFIGURATION ---
# IMPORTANT: Update these paths to point to your actual certificate files.
$CertFilePath = "D:\code\certs\ca\intermediate\ca.crt"
$KeyFilePath  = "D:\code\certs\ca\intermediate\ca.key"

# The desired output file path for the Kubernetes Secret YAML
$OutputFilePath = "D:\code\homelab\helm\cert-manager\manifest\secret.yaml"

# The name of the Secret to be created in Kubernetes
$SecretName = "k8s-cm-ca-key-pair"
# The namespace where this Secret should reside
$SecretNamespace = "default" 

# --- FUNCTIONS ---

# Function to read a file and Base64 encode its content.
# -NoNewline is crucial to prevent extra line breaks in the Base64 output.
function Get-Base64EncodedContent {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Path
    )
    if (-not (Test-Path $Path)) {
        Write-Error "File not found: $Path"
        exit 1
    }
    # Read the file content as raw bytes and convert to Base64 string
    $ContentBytes = [System.IO.File]::ReadAllBytes($Path)
    $Base64String = [System.Convert]::ToBase64String($ContentBytes)
    return $Base64String
}

# --- EXECUTION ---

Write-Host "Starting TLS Secret generation..."

# 1. Read and encode the files
Write-Host "Encoding certificate file: $CertFilePath"
$EncodedCert = Get-Base64EncodedContent -Path $CertFilePath

Write-Host "Encoding private key file: $KeyFilePath"
$EncodedKey = Get-Base64EncodedContent -Path $KeyFilePath

if (-not $EncodedCert -or -not $EncodedKey) {
    Write-Error "Encoding failed. Check file paths and content."
    exit 1
}

# 2. Construct the YAML content
$YamlContent = @"
apiVersion: v1
kind: Secret
metadata:
  name: $SecretName
  namespace: $SecretNamespace
data:
  # The Base64 encoded certificate content goes under 'tls.crt'
  tls.crt: $EncodedCert
  # The Base64 encoded private key content goes under 'tls.key'
  tls.key: $EncodedKey
type: kubernetes.io/tls
"@

# 3. Write the YAML content to the output file
$YamlContent | Out-File -FilePath $OutputFilePath -Encoding UTF8

Write-Host "--------------------------------------------------------"
Write-Host "✅ Success! Kubernetes Secret YAML saved to: $OutputFilePath"
Write-Host "To apply this secret to your cluster, run:"
Write-Host "kubectl apply -f $($OutputFilePath)"
Write-Host "--------------------------------------------------------"
