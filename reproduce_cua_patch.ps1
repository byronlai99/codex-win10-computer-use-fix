# Reconstructed binary-delta patch, not original MTA-worker source code.
# Requires Windows PowerShell 5.1 or PowerShell 7. Does not modify installed helper.
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)][string]$OriginalExe,
    [Parameter(Mandatory=$true, Position=1)][string]$OutputExe
)
$ErrorActionPreference = 'Stop'
$expectedOriginal = '58FFF5E2359AA09528F48EF37651B9013B204F99E2FD381F0D3D980CF9D2E88D'
$expectedPatched = 'A7EF05E4DABAD5E9ED22709C3A7928A21D40689DB274276206EF25E87456670C'

# FileOffset, ExpectedOriginalHex, ReplacementHex
$patches = @(
    ,@('0x86', '0a', '0b')
    ,@('0x9D', '68', '6a')
    ,@('0xD1', 'e0', 'f0')
    ,@('0xD8', 'f20618', '000000')
    ,@('0x124', 'd8', 'f0')
    ,@('0x129', '6e17', '0000')
    ,@('0x12C', '303d', '0000')
    ,@('0x208', 'd8', 'f0')
    ,@('0x318', '000000000000', '2e6375773130')
    ,@('0x320', '00', 'd0')
    ,@('0x325', '0000', 'e017')
    ,@('0x329', '00', '02')
    ,@('0x32D', '0000', '6e17')
    ,@('0x33C', '00', '20')
    ,@('0x33F', '00', '60')
    ,@('0x418C0', '5b', '3d')
    ,@('0x418CF', '74', 'eb')
    ,@('0x12C8C8', '892404', '00e017')
    ,@('0x1574D9', '0000', 'e017')
    ,@('0x1574DC', '000000', '72e017')
    ,@('0x1574E0', '000000', 'c0e017')
    ,@('0x1574E4', '000000', '80e017')
    ,@('0x1574E8', '000000', 'b2e017')
    ,@('0x1574EC', '000000', 'c8e017')
    ,@('0x176E00', '303d00000002020030823d2006092a864886f70d010702a0823d1130823d0d020101310f300d06096086480165030402010500305c060a2b060104018237020104a04e304c3017060a2b06010401823702010f', '534883ec304889cb488b5108f00fba6a1008723a488b01ff500831c931d24c8d055b0000004989d948c74424200000000048c744242800000000ff15d88fffff4885c074114889c1ff158a8fffff31c04883c4')
    ,@('0x176E54', '09030100a004a20280', '5bc3488b4308c64011')
    ,@('0x176E5E', '3031300d0609608648016503040201050004202e73e380a0244388cf33d9bc22a4ca3d2f0437ace43600862a5e5aca1fb88979a0822200308205cc308203b4a00302010202105498d2d1d45b1995', '4889d9488b01ff5010b8054000804883c4305bc3cccccccccccccccccccccccccccc534883ec204889cbb901000000ff159d8effff4889d9e8ee43ecffff15978effff4889d9488b01ff501031c0')
    ,@('0x176EAD', '1379c811c08799300d06092a864886f70d01010c', '83c4205bc3cccccccccccccccccccccccccccc01')
    ,@('0x176EC2', '003077310b', '0200055201')
    ,@('0x176EC8', '09060355040613025553311e301c060355040a13154d6963726f736f667420436f72706f726174696f6e314830460603550403133f4d6963726f736f6674204964656e7469747920566572696669636174696f6e20526f6f7420436572746966696361746520417574686f726974792032303230301e170d3230303431363138333631365a170d3435303431363138343434305a3077310b3009060355040613025553311e301c060355040a13154d6963726f736f667420436f72706f726174696f6e314830460603550403133f4d6963726f736f6674204964656e7469747920566572696669636174696f6e20526f6f7420436572746966696361746520417574686f72697479203230323030820222300d06092a864886f70d01010105', '0105020005320130000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000')
    ,@('0x176FE8', '0382020f', '00000000')
    ,@('0x176FED', '3082020a02820201', '0000000000000000')
    ,@('0x176FF6', 'b3912a07830667fd9e9d', '00000000000000000000')
)

function Get-Sha256([byte[]]$bytes) {
    $sha = [System.Security.Cryptography.SHA256]::Create()
    try { return ([BitConverter]::ToString($sha.ComputeHash($bytes))).Replace('-', '') }
    finally { $sha.Dispose() }
}
function Convert-Hex([string]$hex) {
    if (($hex.Length % 2) -ne 0) { throw "Odd hex length" }
    $b = New-Object byte[] ($hex.Length / 2)
    for ($i = 0; $i -lt $b.Length; $i++) { $b[$i] = [Convert]::ToByte($hex.Substring($i * 2, 2), 16) }
    return ,$b
}

$inputPath = [IO.Path]::GetFullPath($OriginalExe)
$outputPath = [IO.Path]::GetFullPath($OutputExe)
if ([string]::Equals($inputPath, $outputPath, [StringComparison]::OrdinalIgnoreCase)) { throw 'Input and output paths must differ.' }
if (!(Test-Path -LiteralPath $inputPath -PathType Leaf)) { throw "Original file not found: $inputPath" }
if (Test-Path -LiteralPath $outputPath) { throw "Refusing to overwrite existing output: $outputPath" }
$data = [IO.File]::ReadAllBytes($inputPath)
$originalHash = Get-Sha256 $data
if ($originalHash -ne $expectedOriginal) { throw "Original hash mismatch: $originalHash" }

foreach ($patch in $patches) {
    $offset = [Convert]::ToInt64($patch[0].Substring(2), 16)
    [byte[]]$before = Convert-Hex $patch[1]
    [byte[]]$after = Convert-Hex $patch[2]
    if ($before.Length -ne $after.Length) { throw "Patch length mismatch at $($patch[0])" }
    if ($offset -lt 0 -or $offset + $before.Length -gt $data.Length) { throw "Patch outside file at $($patch[0])" }
    for ($i = 0; $i -lt $before.Length; $i++) {
        if ($data[$offset + $i] -ne $before[$i]) { throw "Original bytes mismatch at $($patch[0]) + $i" }
    }
    [Array]::Copy($after, 0, $data, $offset, $after.Length)
}

$patchedHash = Get-Sha256 $data
if ($patchedHash -ne $expectedPatched) { throw "Patched hash mismatch: $patchedHash" }
[IO.File]::WriteAllBytes($outputPath, $data)
Write-Host "Verified patched SHA-256: $patchedHash" -ForegroundColor Green
Write-Host "Wrote: $outputPath"
Write-Warning 'Modifying an executable invalidates its original Authenticode signature. Use only after independent review.'