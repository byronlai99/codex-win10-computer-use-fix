# Windows 10 Computer Use Screenshot Timeout Fix

A reconstructed binary patch for the `codex-computer-use.exe` helper that may resolve the Windows 10 screenshot error:

```text
FrameArrived timed out: timed out waiting on channel
```

Successfully tested on **Windows 10 IoT Enterprise LTSC 2021 (21H2, build 19044.5737)** with ChatGPT Desktop **26.1007.2314.0** and `@oai/sky` **0.7.6**. After patching, capturing the correct Notepad window and clicking its editor worked.

## Usage

Back up the original helper first. In PowerShell, run:

```powershell
.\reproduce_cua_patch.ps1 -OriginalExe '.\codex-computer-use.exe.original' -OutputExe '.\codex-computer-use.exe.patched'
```

The script checks the original hash and expected bytes, applies 33 binary patch entries to a new output file, then verifies its SHA-256. It **does not install** the output or modify the running ChatGPT application.

| File | SHA-256 |
| --- | --- |
| Original EXE | `58FFF5E2359AA09528F48EF37651B9013B204F99E2FD381F0D3D980CF9D2E88D` |
| Patched EXE | `A7EF05E4DABAD5E9ED22709C3A7928A21D40689DB274276206EF25E87456670C` |

## Important notes

- **Unofficial and version-specific.** Do not apply to an EXE with a different original SHA-256.
- This is a **reconstructed binary delta**, not the original MTA-worker implementation source, and it does not independently establish the patch's internal behavior or safety.
- Modifying the EXE invalidates its original Authenticode signature. Review the script and keep an original backup.
- The corrected script was successfully run in **PowerShell 7** on Windows.

Related issue: [openai/codex#52965](https://github.com/openai/codex/issues/52965).
