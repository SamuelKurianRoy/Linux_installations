#To know all the persons connected in a vpu
ss -tn state established sport = :22

#To know the pidof a binary
pidof ImgRcvM

#To grep the pidof a python process
ps aux | grep service_manager.py

#To findout what is running in a particular port
sudo lsof -i :8000

#To see the full starting tree
pstree -sp $PID

#To find who ran a particulat command
cat /proc/$PID/environ | tr '\0' '\n' | grep SSH 
