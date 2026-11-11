# Red Teaming Payload

Personal red team repo — USB drop simulation, file exfiltration via webhook, and ransomware PoC with decryptor. Built for security research and awareness demonstrations.

> **For authorized security testing and research only. Do not use on systems without explicit written permission.**

---

## Attack Chain

```
[USB Drop]
Malicious pendrive inserted
  └─ autorun.inf triggers Autorun.bat
       └─ Collection.ps1 executes silently
            └─ Exfiltrates files via webhook

[Ransomware]
Encryption payload executed
  └─ Encrypts files on target Desktop
       └─ Decryption payload restores files
```

---

## Files

| File | Description |
|---|---|
| `Pendrive.inf` | Autorun config — triggers the bat on USB insertion when AutoPlay is enabled |
| `Pendrive_Autorun.bat` | Silently launches the collection script from the pendrive |
| `Collection.ps1` | Collects and exfiltrates files to a webhook endpoint |
| `Encryption.ps1` | Encrypts files on the Desktop — ransomware simulation |
| `Encryption.exe` | Compiled version of the encryption script |
| `Decryption.ps1` | Restores all files encrypted by the payload |
| `Decryption.exe` | Compiled version of the decryption script |

---

## Setup

1. Update `Collection.ps1` — replace `YOUR_WEBHOOK_URL` with your controlled endpoint
2. Load pendrive files onto a USB drive for the drop scenario
3. Execute `Encryption.ps1` or `.exe` on the target machine
4. Run `Decryption.ps1` or `.exe` to restore files

---

## Disclaimer

Published for educational and authorized security testing purposes only. I'm not responsible for any misuse.

---

## License

MIT — see `LICENSE`.
