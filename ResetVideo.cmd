schtasks /Run /tn ResetVideo
timeout /T 1 /NOBREAK > nul
:loop
for /f "tokens=2 delims=: " %%f in ('schtasks /query /tn ResetVideo /fo list ^| find "Status:"' ) do (
    if "%%f"=="Running" (
        timeout /T 1 /NOBREAK > nul
        goto loop
    )
)