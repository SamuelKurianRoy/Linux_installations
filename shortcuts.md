### Open a remote server path in vs-code directly


open 

```
vim ~/.bashrc
```

then type
```
GG
```
to go to the last part

add these lines in there

```
remote() {
       local host="${1%%:*}"
       local path="${1#*:}"
       code --folder-uri "vscode-remote://ssh-remote+${host}${path}"
   }
```

reload it 

```
source ~/.bashrc
```

open a folder in vscode the same way you do scp

Example usage
```
remote 124:/home/mtx003/img
remote mtx003@192.168.1.1:/home/mtx003/img
```
