
open your bashrc

```
vim ~/.bashrc
```

go the last line
```
G
```

then paste this command
```
<NAME>() {
    if echo "<YOUR_NAME> : $1" | nc -q 0 <IP> 9999; then
	    echo "Message sent successfully to user!"
    else
	    echo "Failed to sent messsage. The user might be connected to the Tjio 5g network or their ip has changed!"
    fi
    }
```

replace ```<NAME>``` with the name of the person you want to send
replace ```<YOUR_NAME>``` with your name 
replace ```<IP>``` with the network of the person you want to send to


refresh bashrc

```
source ~/.bashrc
```
