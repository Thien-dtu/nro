\# Security Analysis of nro.py



&nbsp;



\*\*Date:\*\* 2025-11-17



\*\*Analyzed File:\*\* nro.py (obfuscated version)



\*\*Deobfuscated Version:\*\* nro\_deobfuscated.py



&nbsp;



---



&nbsp;



\## Executive Summary



&nbsp;



The `nro.py` file uses \*\*heavy obfuscation\*\* (base64 + zlib encoding) which is a \*\*red flag\*\* for security. After deobfuscation, the code appears to be a \*\*legitimate server setup script\*\* with no obvious malicious behavior, but there are \*\*security concerns\*\* you should be aware of.



&nbsp;



\## What the Code Does



&nbsp;



The script provides an interactive menu with 4 options:



&nbsp;



1\. \*\*Download and Install Server\*\* - Downloads a ZIP file from GitHub and extracts it



2\. \*\*Download and Import SQL\*\* - Downloads SQL file and imports it to MySQL database



3\. \*\*Start Server\*\* - Runs the `start.sh` script from extracted files



4\. \*\*Exit\*\* - Exits the program



&nbsp;



\## Deobfuscation Results



&nbsp;



\### Obfuscated URLs Found:



&nbsp;



```python



\# Server files download URL



SERVER\_ZIP\_URL = 'https://github.com/NGUYENTRIEUPHUC/nro-offline/releases/download/SOURCE/NRO.OFFLINE.zip'



&nbsp;



\# SQL database download URL



SQL\_FILE\_URL = 'https://github.com/NGUYENTRIEUPHUC/nro-offline/releases/download/SOURCE/solomon.1.sql'



```



&nbsp;



\### Key Functions:



&nbsp;



\- `download\_file()` - Downloads files from URLs using requests library



\- `extract\_zip()` - Extracts ZIP archives



\- `import\_sql()` - Connects to MySQL and imports SQL statements



\- `start\_server()` - Executes `NRO-Server/start.sh` bash script



\- `show\_menu()` - Interactive menu loop



&nbsp;



\## Security Concerns



&nbsp;



\### 🔴 HIGH RISK



&nbsp;



1\. \*\*Obfuscated Code\*\*



&nbsp;  - Legitimate projects rarely obfuscate code



&nbsp;  - Makes auditing difficult



&nbsp;  - Often used to hide malicious intent



&nbsp;  - \*\*Why was it obfuscated?\*\* Unclear.



&nbsp;



2\. \*\*Downloads and Executes External Code\*\*



&nbsp;  - Downloads ZIP file from GitHub releases



&nbsp;  - Extracts and \*\*executes `start.sh` without validation\*\*



&nbsp;  - No checksum verification



&nbsp;  - No signature verification



&nbsp;  - \*\*Risk:\*\* If the GitHub release is compromised, your server is compromised



&nbsp;



3\. \*\*SQL Execution Without Validation\*\*



&nbsp;  - Downloads SQL file and executes all statements



&nbsp;  - No input validation or sanitization



&nbsp;  - Could execute malicious SQL commands



&nbsp;  - \*\*Risk:\*\* Database compromise, data loss



&nbsp;



\### 🟡 MEDIUM RISK



&nbsp;



4\. \*\*Hardcoded Download URLs\*\*



&nbsp;  - URLs point to specific GitHub repository



&nbsp;  - Not using official/verified sources



&nbsp;  - Repository owner: NGUYENTRIEUPHUC



&nbsp;  - \*\*Risk:\*\* Dependency on third-party repository



&nbsp;



5\. \*\*No Error Handling\*\*



&nbsp;  - Limited error handling in download/extract functions



&nbsp;  - Could leave system in inconsistent state



&nbsp;



6\. \*\*MySQL Credentials in Plain Text\*\*



&nbsp;  - Prompts user for credentials (good)



&nbsp;  - But stores in variables during execution



&nbsp;  - \*\*Risk:\*\* Memory dump could expose credentials



&nbsp;



\## Files Downloaded



&nbsp;



Based on deobfuscation, the script downloads:



&nbsp;



1\. \*\*NRO.OFFLINE.zip\*\* (~size unknown)



&nbsp;  - Contains game server files



&nbsp;  - Includes `start.sh` which gets executed



&nbsp;



2\. \*\*solomon.1.sql\*\* (~size unknown)



&nbsp;  - SQL database dump



&nbsp;  - Gets imported directly to MySQL



&nbsp;



\## Recommendations



&nbsp;



\### ✅ SAFE ALTERNATIVE - Use Deobfuscated Version



&nbsp;



I've created `nro\_deobfuscated.py` which:



\- Does exactly the same thing



\- Is fully readable



\- Can be audited



\- No hidden behavior



&nbsp;



\*\*Recommendation:\*\* Use the deobfuscated version instead!



&nbsp;



\### 🔒 Security Best Practices



&nbsp;



1\. \*\*Verify Downloaded Files\*\*



&nbsp;  ```bash



&nbsp;  # Before running, check what was downloaded:



&nbsp;  unzip -l NRO.zip



&nbsp;  cat NRO-Server/start.sh



&nbsp;  head -n 50 solomon.1.sql



&nbsp;  ```



&nbsp;



2\. \*\*Inspect start.sh Before Running\*\*



&nbsp;  ```bash



&nbsp;  # Check what the startup script does:



&nbsp;  cat NRO-Server/start.sh



&nbsp;  ```



&nbsp;



3\. \*\*Review SQL File\*\*



&nbsp;  ```bash



&nbsp;  # Check SQL file for suspicious commands:



&nbsp;  grep -i "into outfile\\|load\_file\\|create function" solomon.1.sql



&nbsp;  ```



&nbsp;



4\. \*\*Use Dedicated Database\*\*



&nbsp;  - Don't use your main MySQL instance



&nbsp;  - Use the Docker MySQL container (isolated)



&nbsp;  - Use strong passwords from environment variables



&nbsp;



5\. \*\*Network Isolation\*\*



&nbsp;  - Run in Docker on isolated network (you're already doing this ✅)



&nbsp;  - Don't expose to internet until verified safe



&nbsp;



6\. \*\*Monitor Server Activity\*\*



&nbsp;  ```bash



&nbsp;  # Watch what the server does:



&nbsp;  docker-compose logs -f nro-server



&nbsp;



&nbsp;  # Check network connections:



&nbsp;  docker exec nro-server netstat -tupln



&nbsp;  ```



&nbsp;



\## Red Flags to Watch For



&nbsp;



When you run the server, watch for:



&nbsp;



❌ \*\*Outbound connections\*\* to unknown IPs



❌ \*\*File system access\*\* outside /app directory



❌ \*\*Privilege escalation\*\* attempts



❌ \*\*Cryptocurrency mining\*\* (high CPU usage)



❌ \*\*Port scanning\*\* activity



❌ \*\*Suspicious cron jobs\*\* or scheduled tasks



&nbsp;



\## Verification Steps



&nbsp;



Before trusting this code:



&nbsp;



1\. \*\*Check the GitHub repository\*\*



&nbsp;  ```bash



&nbsp;  # Check repository age, commits, issues



&nbsp;  # Look for community feedback



&nbsp;  # Check for security reports



&nbsp;  ```



&nbsp;



2\. \*\*Scan downloaded files\*\*



&nbsp;  ```bash



&nbsp;  # Use VirusTotal or similar



&nbsp;  # Scan the ZIP file



&nbsp;  # Scan extracted files



&nbsp;  ```



&nbsp;



3\. \*\*Test in isolated environment first\*\*



&nbsp;  ```bash



&nbsp;  # Use a test VM or container



&nbsp;  # Monitor all activity



&nbsp;  # Check for suspicious behavior



&nbsp;  ```



&nbsp;



\## Conclusion



&nbsp;



\### Is it Malware?



&nbsp;



\*\*Verdict: Unclear / Suspicious\*\*



&nbsp;



\- ✅ Code functionality appears legitimate



\- ✅ Downloads from public GitHub repository



\- ❌ Heavy obfuscation is suspicious



\- ❌ No explanation for obfuscation



\- ❌ Executes external code without verification



&nbsp;



\### Should You Run It?



&nbsp;



\*\*Recommendation: Proceed with Caution\*\*



&nbsp;



1\. ✅ \*\*USE\*\* the deobfuscated version (`nro\_deobfuscated.py`)



2\. ✅ \*\*RUN\*\* in Docker (isolated environment)



3\. ✅ \*\*MONITOR\*\* all server activity



4\. ✅ \*\*INSPECT\*\* downloaded files before running



5\. ❌ \*\*DON'T\*\* run on production server without verification



6\. ❌ \*\*DON'T\*\* use alongside sensitive data/services



&nbsp;



\### Final Notes



&nbsp;



The obfuscation is the biggest red flag. \*\*Legitimate open-source projects don't hide their code.\*\* While the deobfuscated functionality seems benign, always maintain a healthy skepticism when running untrusted code on your infrastructure.



&nbsp;



\*\*Your instinct to question obfuscated code was 100% correct!\*\* 🎯



&nbsp;



---



&nbsp;



\## Next Steps



&nbsp;



1\. Review `nro\_deobfuscated.py`



2\. Replace `nro.py` with deobfuscated version



3\. Manually download and inspect the files first



4\. Run in isolated Docker environment



5\. Monitor closely for suspicious activity



&nbsp;



\## Questions?



&nbsp;



If you notice anything suspicious during testing:



1\. Stop the containers immediately



2\. Check logs: `docker-compose logs`



3\. Inspect network activity



4\. Review file system changes



&nbsp;

