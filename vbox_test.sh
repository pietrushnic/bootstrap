#!/bin/bash
#TODO: write documentation and disclaimer about vm usage
#TODO: make sure that $1 exist - use vboxmanage list
SCANCODES=$HOME/src/scancodes/scancodes
pub_key=$(cat $HOME/.ssh/id_rsa.pub)
pkey_scancodes=$(echo -en $pub_key|$SCANCODES)

sc_send () {
    for (( i=0; i<${#2}; i++ )); do
        echo ">${2:$i:1}<"
        c=$(echo -en "${2:$i:1}"|$SCANCODES)
        echo "$1: send ${c}"
        vboxmanage controlvm $1 keyboardputscancode $c
        if [[ $i -eq $(expr ${#2} - 1) ]]; then
            c=$(echo -en "\n"|$SCANCODES)
            echo "$1: send ${c}"
            vboxmanage controlvm $1 keyboardputscancode $c
        fi
    done
}

startvm() {
    echo "startvm $1"
    vboxmanage startvm $1 # -type headless
}

ssh_cmd () {
    echo "ssh_cmd: $1"
    ssh -oStrictHostKeyChecking=no user@localhost -p 2222 $1
}

scp_cmd () {
    echo "scp_cmd: $1 $2"
    scp -P 2222 -oStrictHostKeyChecking=no $1 user@localhost:$2
}

bash_cmd () {
    st="bash -l -c '"
    nd="$1"
    rd="'"
    echo "bash_cmd: $st$nd$rd"
    ssh_cmd "$st$nd$rd"
}

no_pass_ssh () {
    startvm $1
    sleep 3
    vboxmanage controlvm $1 keyboardputscancode 1C 9C
    sleep 60
    # cat host pub key to guest .ssh/authorized_keys
    sc_send $1 'mkdir -p $HOME/.ssh'
    st_pt=' > $HOME/.ssh/authorized_keys'
    nd_pt="echo $pub_key"
    echo "$nd_pt$st_pt"
    sc_send $1 "$nd_pt$st_pt"
}

init_custom () {
    no_pass_ssh $1
    scp_cmd $2 /home/user
    home_v='$HOME'
    nd_pt="/${2##*/}"
    bash_cmd "$home_v$nd_pt"
}

eval "$@"
