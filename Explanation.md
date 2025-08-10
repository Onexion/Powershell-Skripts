## Powershell Scripts explaination:

1.  Eventlogs-Tampering.ps1: This Tool looks at following eventlogs: 

| Event ID | Description |
|----------|-------------|
| **1102** | Security audit log was cleared. |
| **4663** | Attempted access to a protected file, folder, or object. |
| **4660** | A protected object (file/folder) was deleted. |
| **4656** | Handle request to a protected file or object. |
| **104**  | Application log was cleared. |
| **3079** | Application-specific log cleared (varies by system). |
| **5001** | Windows Defender real-time protection disabled. |
| **5004** | Windows Defender service stopped. |
| **100**  | Virtual Hard Disk attached. |
| **101**  | Virtual Hard Disk detached. |

