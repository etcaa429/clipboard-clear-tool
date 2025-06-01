# Clipboard Cleaner Tool Flowchart

## Process Logic Analysis
1. Program starts with `[STAThread]` attribute to ensure single-threaded mode
2. Main program uses try-catch structure to handle various exceptions
3. Different error codes are returned to indicate execution status

## Flowchart
```mermaid
flowchart TB
    Start([Program Start]) --> ThreadCheck{Check Thread State}
    ThreadCheck -->|STA Mode| TryClear[Try Clear Clipboard]
    ThreadCheck -->|Non-STA Mode| ThreadError[Return Error Code 3]
    
    TryClear --> Success{Success?}
    Success -->|Yes| Exit0[Return Error Code 0]
    Success -->|No| ErrorCheck{Error Type}
    
    ErrorCheck -->|Clipboard Locked| Exit2[Return Error Code 2]
    ErrorCheck -->|Thread Error| Exit3[Return Error Code 3]
    ErrorCheck -->|Other Error| Exit1[Return Error Code 1]
    
    Exit0 --> End([Program End])
    Exit1 --> End
    Exit2 --> End
    Exit3 --> End
    ThreadError --> End
```

## Error Code Description
| Error Code | Description |
|------------|-------------|
| 0 | Successfully cleared clipboard |
| 1 | Unknown error |
| 2 | Clipboard locked by other program |
| 3 | Thread mode requirement not met |

## Notes
1. Program must run in STA (Single-threaded Apartment) mode
2. Uses Windows Forms Clipboard class for operations
3. Runs in windowless mode, all results returned via error codes