\# NRO Offline Server - Deployment Checklist



&nbsp;



Use this checklist to ensure a successful deployment.



&nbsp;



---



&nbsp;



\## 📋 Pre-Deployment Checklist



&nbsp;



\### System Requirements



&nbsp;



\- \[ ] Zorin OS / Ubuntu / Debian-based Linux



\- \[ ] Docker installed and running



\- \[ ] Docker Compose installed (or Docker Compose plugin)



\- \[ ] Minimum 2GB RAM available



\- \[ ] Minimum 5GB disk space available



\- \[ ] User has docker permissions (in docker group)



&nbsp;



\*\*Test command:\*\*



```bash



./test-setup.sh



```



&nbsp;



---



&nbsp;



\### Environment Setup



&nbsp;



\- \[ ] Selfhost directory exists at `~/Desktop/selthost/`



\- \[ ] `.env` file exists in selfhost directory



\- \[ ] PUID and PGID configured in `.env`



\- \[ ] Timezone (TZ) configured in `.env`



\- \[ ] NRO\_MYSQL\_ROOT\_PASSWORD added to `.env`



\- \[ ] NRO\_MYSQL\_PASSWORD added to `.env`



&nbsp;



\*\*Generate passwords:\*\*



```bash



openssl rand -base64 32



```



&nbsp;



---



&nbsp;



\### Network Configuration



&nbsp;



\- \[ ] `selfnet` Docker network exists



\- \[ ] Ports 14445 and 14444 are available



\- \[ ] No firewall blocking internal Docker traffic



&nbsp;



\*\*Create network:\*\*



```bash



docker network create selfnet



```



&nbsp;



\*\*Check ports:\*\*



```bash



sudo netstat -tulpn | grep -E "14445|14444"



```



&nbsp;



---



&nbsp;



\### Repository Setup



&nbsp;



\- \[ ] Repository cloned to `~/Desktop/selthost/nro/`



\- \[ ] Checked out correct branch



\- \[ ] All required files present (run `./test-setup.sh`)



\- \[ ] Scripts are executable (`chmod +x \*.sh`)



&nbsp;



\*\*Clone command:\*\*



```bash



cd ~/Desktop/selthost



git clone https://github.com/Thien-dtu/nro-offline.git nro



cd nro



git checkout claude/define-project-purpose-018SJAhXmvyN3b5c6Vq1D4Mx



```



&nbsp;



---



&nbsp;



\## 🚀 Deployment Checklist



&nbsp;



\### Phase 1: Build



&nbsp;



\- \[ ] Docker Compose configuration validated



\- \[ ] Docker images built successfully



\- \[ ] No build errors in logs



&nbsp;



\*\*Commands:\*\*



```bash



docker-compose config



docker-compose build



```



&nbsp;



---



&nbsp;



\### Phase 2: Start Containers



&nbsp;



\- \[ ] Containers started without errors



\- \[ ] MySQL container is healthy



\- \[ ] NRO server container is running



\- \[ ] Both containers on `selfnet` network



&nbsp;



\*\*Commands:\*\*



```bash



docker-compose up -d



docker-compose ps



docker inspect nro-mysql | grep Health



```



&nbsp;



\*\*Expected output:\*\*



```



NAME         STATUS                    PORTS



nro-mysql    Up X minutes (healthy)    3306/tcp



nro-server   Up X minutes              0.0.0.0:14444->14444/tcp, 0.0.0.0:14445->14445/tcp



```



&nbsp;



---



&nbsp;



\### Phase 3: Initial Server Setup



&nbsp;



\- \[ ] Accessed NRO setup menu successfully



\- \[ ] Downloaded server files (option 1)



\- \[ ] Extracted NRO-Server directory



\- \[ ] Downloaded SQL file (option 2)



\- \[ ] Imported SQL to MySQL database



\- \[ ] Started game server (option 3)



&nbsp;



\*\*Commands:\*\*



```bash



docker-compose exec nro-server python3 nro\_deobfuscated.py



```



&nbsp;



---



&nbsp;



\### Phase 4: Verification



&nbsp;



\- \[ ] No errors in server logs



\- \[ ] Java process is running



\- \[ ] Ports are listening (14445, 14444)



\- \[ ] MySQL connection is working



\- \[ ] Server files exist in `/app/NRO-Server/`



&nbsp;



\*\*Verification commands:\*\*



```bash



\# Check server process



docker-compose exec nro-server ps aux | grep java



&nbsp;



\# Check listening ports



docker-compose exec nro-server netstat -tlnp



&nbsp;



\# Check logs



docker-compose logs --tail=50 nro-server



&nbsp;



\# Check files



docker-compose exec nro-server ls -la /app/NRO-Server/



```



&nbsp;



---



&nbsp;



\### Phase 5: Network Testing



&nbsp;



\- \[ ] Found local server IP address



\- \[ ] Ports accessible from local network



\- \[ ] Game client can connect



\- \[ ] Can create/login to account



&nbsp;



\*\*Get local IP:\*\*



```bash



hostname -I | awk '{print $1}'



```



&nbsp;



\*\*Test connectivity:\*\*



```bash



telnet YOUR\_LOCAL\_IP 14445



```



&nbsp;



---



&nbsp;



\## 🔐 Security Checklist



&nbsp;



\### Pre-Deployment Security



&nbsp;



\- \[ ] Read `SECURITY\_ANALYSIS.md` completely



\- \[ ] Understand risks of running obfuscated code



\- \[ ] Using deobfuscated version (`nro\_deobfuscated.py`)



\- \[ ] Strong MySQL passwords generated



\- \[ ] Passwords stored securely



&nbsp;



---



&nbsp;



\### Post-Deployment Security



&nbsp;



\- \[ ] Inspected downloaded server files



\- \[ ] Reviewed `start.sh` script



\- \[ ] Checked SQL file for suspicious commands



\- \[ ] No unexpected network connections



\- \[ ] Server logs show normal activity



&nbsp;



\*\*Inspection commands:\*\*



```bash



\# Check start.sh



docker-compose exec nro-server cat NRO-Server/start.sh



&nbsp;



\# Check SQL file



docker-compose exec nro-server head -100 nro\_offline.sql



docker-compose exec nro-server grep -i "load\_file\\|into outfile\\|create function" nro\_offline.sql



&nbsp;



\# Monitor network



docker-compose exec nro-server netstat -tupn



```



&nbsp;



---



&nbsp;



\### Ongoing Security



&nbsp;



\- \[ ] Monitor logs regularly



\- \[ ] Keep containers updated



\- \[ ] Regular backups configured



\- \[ ] Not exposed to internet (local network only)



\- \[ ] Firewall rules configured (if needed)



&nbsp;



---



&nbsp;



\## 📊 Monitoring Checklist



&nbsp;



\### Container Health



&nbsp;



\- \[ ] Both containers show "Up" status



\- \[ ] MySQL shows "(healthy)" status



\- \[ ] No continuous restarts



\- \[ ] Resource usage is normal (<50% allocated)



&nbsp;



\*\*Check commands:\*\*



```bash



docker-compose ps



docker stats nro-server nro-mysql



```



&nbsp;



---



&nbsp;



\### Logs Monitoring



&nbsp;



\- \[ ] No errors in MySQL logs



\- \[ ] No errors in server logs



\- \[ ] No suspicious connection attempts



\- \[ ] Server startup completed successfully



&nbsp;



\*\*Log commands:\*\*



```bash



docker-compose logs --tail=100



docker-compose logs -f nro-server



```



&nbsp;



---



&nbsp;



\### Portainer Integration



&nbsp;



\- \[ ] Can see containers in Portainer



\- \[ ] Container stats visible



\- \[ ] Can access logs via Portainer



\- \[ ] No alerts or warnings



&nbsp;



\*\*Access Portainer:\*\*



Your existing Portainer instance → Containers → Look for `nro-server` and `nro-mysql`



&nbsp;



---



&nbsp;



\## 💾 Backup Checklist



&nbsp;



\### Initial Backup



&nbsp;



\- \[ ] Server files backed up



\- \[ ] MySQL database exported



\- \[ ] Configuration files saved



\- \[ ] Environment variables documented



&nbsp;



\*\*Backup commands:\*\*



```bash



\# Full backup



tar -czf ~/nro-backup-$(date +%Y%m%d).tar.gz ~/Desktop/selthost/nro/data/



&nbsp;



\# Database backup



docker-compose exec nro-mysql mysqldump -u nro\_user -p${NRO\_MYSQL\_PASSWORD} nro > ~/nro-db-backup-$(date +%Y%m%d).sql



```



&nbsp;



---



&nbsp;



\### Backup Schedule



&nbsp;



\- \[ ] Automated backup script created



\- \[ ] Backup location decided



\- \[ ] Backup retention policy set



\- \[ ] Test restore performed



&nbsp;



---



&nbsp;



\## 🎮 Client Configuration Checklist



&nbsp;



\### Game Client Setup



&nbsp;



\- \[ ] NRO APK downloaded



\- \[ ] APK installed on Android device



\- \[ ] Server IP configured in game



\- \[ ] Port configured (14445)



\- \[ ] Connection tested successfully



&nbsp;



---



&nbsp;



\## 📝 Documentation Checklist



&nbsp;



\### Files to Keep



&nbsp;



\- \[ ] Copy of `.env` file (secure location)



\- \[ ] MySQL passwords documented (secure location)



\- \[ ] Server IP address noted



\- \[ ] Backup locations documented



\- \[ ] Contact info for troubleshooting



&nbsp;



---



&nbsp;



\## ✅ Final Verification



&nbsp;



Before marking deployment as complete:



&nbsp;



\- \[ ] Server is accessible from local network



\- \[ ] Game client can connect



\- \[ ] Can create/login accounts



\- \[ ] Game is playable



\- \[ ] No errors in logs



\- \[ ] Backups working



\- \[ ] Monitoring in place



\- \[ ] Security measures implemented



\- \[ ] Documentation complete



&nbsp;



---



&nbsp;



\## 🎉 Post-Deployment



&nbsp;



\### Success Criteria



&nbsp;



✅ All checkboxes above are checked



✅ Server is stable for 24 hours



✅ No unexpected errors in logs



✅ Players can connect and play



✅ Backups are automated



&nbsp;



\### Next Steps



&nbsp;



1\. Configure regular maintenance schedule



2\. Set up monitoring alerts



3\. Plan for updates



4\. Create player documentation



5\. (Optional) Set up Cloudflare Tunnel for remote access



&nbsp;



---



&nbsp;



\## 📞 Troubleshooting Reference



&nbsp;



If any checklist item fails, refer to:



&nbsp;



\- \*\*Quick fixes:\*\* \[QUICKSTART.md](QUICKSTART.md#common-issues--fixes)



\- \*\*Detailed troubleshooting:\*\* \[DOCKER.md](DOCKER.md#troubleshooting)



\- \*\*Security concerns:\*\* \[SECURITY\_ANALYSIS.md](SECURITY\_ANALYSIS.md)



&nbsp;



\*\*Common issues:\*\*



```bash



\# Container won't start



docker-compose logs CONTAINER\_NAME



&nbsp;



\# Network issues



docker network inspect selfnet



&nbsp;



\# Permission errors



sudo chown -R $(id -u):$(id -g) ~/Desktop/selthost/nro/data/



&nbsp;



\# Reset everything



docker-compose down



rm -rf ~/Desktop/selthost/nro/data/



docker-compose up -d



```



&nbsp;



---



&nbsp;



\## 📅 Maintenance Schedule



&nbsp;



\### Daily



\- \[ ] Check container status



\- \[ ] Review logs for errors



&nbsp;



\### Weekly



\- \[ ] Backup database



\- \[ ] Check disk space



\- \[ ] Review resource usage



&nbsp;



\### Monthly



\- \[ ] Update Docker images



\- \[ ] Test backup restore



\- \[ ] Review security logs



&nbsp;



---



&nbsp;



\*\*Deployment Date:\*\* \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_



&nbsp;



\*\*Deployed By:\*\* \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_



&nbsp;



\*\*Server IP:\*\* \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_



&nbsp;



\*\*Notes:\*\* \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_



&nbsp;



\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_



&nbsp;



\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_



&nbsp;

