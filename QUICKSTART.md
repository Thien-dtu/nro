\# NRO Offline Server - Quick Start Guide



&nbsp;



This guide will get you up and running in under 10 minutes.



&nbsp;



\## 🚀 Automated Deployment (Recommended)



&nbsp;



\### Step 1: Run Tests



&nbsp;



```bash



cd nro-offline



./test-setup.sh



```



&nbsp;



This checks if your system is ready for deployment.



&nbsp;



\### Step 2: Deploy Automatically



&nbsp;



```bash



./deploy.sh



```



&nbsp;



This will:



\- ✅ Create necessary directories



\- ✅ Generate secure MySQL passwords



\- ✅ Build Docker images



\- ✅ Start containers



\- ✅ Configure networking



&nbsp;



\### Step 3: Initial Server Setup



&nbsp;



Once deployed, run the setup menu:



&nbsp;



```bash



cd ~/Desktop/selthost/nro



docker-compose exec nro-server python3 nro\_deobfuscated.py



```



&nbsp;



\*\*Follow the menu:\*\*



&nbsp;



1\. \*\*Choose option 1\*\* → Downloads server files (~5 minutes)



2\. \*\*Choose option 2\*\* → Downloads and imports database



&nbsp;  - When prompted for MySQL credentials:



&nbsp;    - Host: `nro-mysql`



&nbsp;    - User: `nro\_user`



&nbsp;    - Password: (check your .env file or deployment script output)



&nbsp;    - Port: `3306`



3\. \*\*Choose option 3\*\* → Starts the game server



&nbsp;



\### Step 4: Connect and Play



&nbsp;



\*\*Find your local IP:\*\*



```bash



hostname -I | awk '{print $1}'



```



&nbsp;



\*\*Connect from game client:\*\*



\- Server address: `YOUR\_LOCAL\_IP:14445`



\- Example: `192.168.1.100:14445`



&nbsp;



---



&nbsp;



\## 📋 Manual Deployment



&nbsp;



If you prefer manual setup:



&nbsp;



\### 1. Prepare Environment



&nbsp;



```bash



\# Create directory



cd ~/Desktop/selthost



git clone https://github.com/Thien-dtu/nro-offline.git nro



cd nro



&nbsp;



\# Add to .env file



nano ~/Desktop/selthost/.env



```



&nbsp;



Add these lines:



```env



\# NRO Configuration



NRO\_MYSQL\_ROOT\_PASSWORD=your\_secure\_password\_here



NRO\_MYSQL\_PASSWORD=your\_secure\_password\_here



```



&nbsp;



Generate secure passwords:



```bash



openssl rand -base64 32  # Run twice, use for each password



```



&nbsp;



\### 2. Create Network (if needed)



&nbsp;



```bash



docker network create selfnet



```



&nbsp;



\### 3. Build and Start



&nbsp;



```bash



docker-compose build



docker-compose up -d



```



&nbsp;



\### 4. Verify



&nbsp;



```bash



docker-compose ps



docker-compose logs -f nro-mysql



```



&nbsp;



Wait until you see: `ready for connections`



&nbsp;



\### 5. Setup Server (same as automated Step 3 above)



&nbsp;



---



&nbsp;



\## 🔍 Verification Checklist



&nbsp;



After deployment, verify everything is working:



&nbsp;



\- \[ ] Containers are running: `docker-compose ps`



\- \[ ] MySQL is healthy: `docker inspect nro-mysql | grep Health`



\- \[ ] No errors in logs: `docker-compose logs --tail=50`



\- \[ ] Ports are exposed: `docker-compose ps` (should show `0.0.0.0:14445`)



\- \[ ] Network connectivity: `docker network inspect selfnet`



&nbsp;



---



&nbsp;



\## 📊 Monitoring



&nbsp;



\### View Logs



&nbsp;



```bash



\# All logs



docker-compose logs -f



&nbsp;



\# Just server



docker-compose logs -f nro-server



&nbsp;



\# Just MySQL



docker-compose logs -f nro-mysql



```



&nbsp;



\### Check Resource Usage



&nbsp;



```bash



docker stats nro-server nro-mysql



```



&nbsp;



\### Access Container Shell



&nbsp;



```bash



docker-compose exec nro-server bash



```



&nbsp;



---



&nbsp;



\## 🛑 Common Issues \& Fixes



&nbsp;



\### Issue: "network selfnet not found"



&nbsp;



\*\*Fix:\*\*



```bash



docker network create selfnet



docker-compose up -d



```



&nbsp;



\### Issue: "port already in use"



&nbsp;



\*\*Fix:\*\*



```bash



\# Check what's using the port



sudo netstat -tulpn | grep 14445



&nbsp;



\# Either stop that service or change NRO ports in docker-compose.yml



```



&nbsp;



\### Issue: "permission denied" on data directories



&nbsp;



\*\*Fix:\*\*



```bash



sudo chown -R $(id -u):$(id -g) ~/Desktop/selthost/nro/data/



```



&nbsp;



\### Issue: MySQL container keeps restarting



&nbsp;



\*\*Fix:\*\*



```bash



\# Check logs



docker-compose logs nro-mysql



&nbsp;



\# Usually a permission issue - fix ownership



sudo chown -R 1000:1000 ~/Desktop/selthost/nro/data/nro-mysql/



&nbsp;



\# Restart



docker-compose restart nro-mysql



```



&nbsp;



\### Issue: Can't connect from game client



&nbsp;



\*\*Checklist:\*\*



```bash



\# 1. Verify server is running



docker-compose exec nro-server ps aux | grep java



&nbsp;



\# 2. Check if port is listening



docker-compose exec nro-server netstat -tlnp | grep 14445



&nbsp;



\# 3. Test local connectivity



telnet localhost 14445



&nbsp;



\# 4. Verify your local IP



hostname -I



```



&nbsp;



---



&nbsp;



\## 🎮 Client Setup



&nbsp;



\### Android Client



&nbsp;



1\. Download NRO APK (see main README.md)



2\. Install on Android device



3\. Open game



4\. Go to Settings → Server



5\. Enter server IP: `192.168.x.x:14445`



6\. Save and restart game



&nbsp;



\### iOS Client (if available)



&nbsp;



Same steps as Android



&nbsp;



---



&nbsp;



\## 🔐 Security Notes



&nbsp;



\*\*Before running:\*\*



&nbsp;



1\. ⚠️ \*\*Read SECURITY\_ANALYSIS.md\*\* - Understand what you're running



2\. 🔍 \*\*Inspect downloaded files\*\* - After option 1 \& 2, check what was downloaded



3\. 📊 \*\*Monitor logs\*\* - Watch for suspicious activity



4\. 🌐 \*\*Local network only\*\* - Don't expose to internet without proper security



&nbsp;



\*\*Inspect downloaded files:\*\*



```bash



\# After option 1 (Download server)



docker-compose exec nro-server bash



cat NRO-Server/start.sh



ls -la NRO-Server/



&nbsp;



\# After option 2 (Download SQL)



head -100 nro\_offline.sql



grep -i "load\_file\\|into outfile" nro\_offline.sql



```



&nbsp;



---



&nbsp;



\## 🧹 Cleanup \& Reset



&nbsp;



\### Stop Containers



&nbsp;



```bash



docker-compose down



```



&nbsp;



\### Complete Reset



&nbsp;



```bash



docker-compose down



rm -rf ~/Desktop/selthost/nro/data/



docker-compose up -d



\# Then run setup again



```



&nbsp;



\### Remove Everything



&nbsp;



```bash



cd ~/Desktop/selthost



docker-compose down -v



rm -rf nro/



```



&nbsp;



---



&nbsp;



\## 📚 Additional Resources



&nbsp;



\- \*\*Full Documentation:\*\* \[DOCKER.md](DOCKER.md)



\- \*\*Security Analysis:\*\* \[SECURITY\_ANALYSIS.md](SECURITY\_ANALYSIS.md)



\- \*\*Original README:\*\* \[README.md](README.md)



&nbsp;



---



&nbsp;



\## 🆘 Getting Help



&nbsp;



\*\*Check logs first:\*\*



```bash



docker-compose logs --tail=100



```



&nbsp;



\*\*Common log locations:\*\*



\- Container logs: `docker-compose logs`



\- MySQL logs: `docker-compose logs nro-mysql`



\- Server logs: `docker-compose logs nro-server`



&nbsp;



\*\*Gather system info:\*\*



```bash



docker --version



docker-compose --version



docker ps



docker network ls



docker-compose ps



```



&nbsp;



---



&nbsp;



\## ⏭️ Next Steps



&nbsp;



Once your server is running:



&nbsp;



1\. ✅ Test local connectivity



2\. ✅ Create player accounts



3\. ✅ Configure game settings



4\. ✅ Set up regular backups



5\. ✅ (Optional) Configure Cloudflare Tunnel for remote access



6\. ✅ Monitor with Portainer



&nbsp;



\*\*Backup command:\*\*



```bash



tar -czf ~/nro-backup-$(date +%Y%m%d).tar.gz ~/Desktop/selthost/nro/data/



```



&nbsp;



---



&nbsp;



\*\*Happy Gaming! 🎮\*\*



&nbsp;

