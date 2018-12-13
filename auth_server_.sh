#!/bin/bash
g_CUR_DIR=$(dirname "$(readlink -f "$0")")
CLIENT_FILE=$1
PASSWORD='OFNDsMTXP4s1Xb'

function install_sshpass() {
    yum -y install epel-release
    yum -y install sshpass
    rpm -q sshpss &> /dev/null || { echo -e "\033[1;31m install sshpass failed.\033[0m" ; exit 2 ; }
}
function secretkey_generation() {
    cd ~ && cp -rf .ssh .ssh.`date +%Y%m%d%H%M%S` && \
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' &> /dev/null
    [ $? -ne 0 ] && { echo -e "\033[1;31m The secret key generation failed.\033[0m" ; exit 3 ; }
}
function add_auth() {
    cd ${g_CUR_DIR}
    local I
    local IP=`cat ${CLIENT_FILE}`
    local AUTH_USER="root"
    local PUBLIC_KEY=`cat ~/.ssh/id_rsa.pub`
    for I in ${IP}; do
        sshpass -p "${PASSWORD}" ssh -o StrictHostKeyChecking=no root@${I} "mkdir -p ~/.ssh" && \
        sshpass -p "${PASSWORD}" ssh -o StrictHostKeyChecking=no root@${I} "echo ${PUBLIC_KEY} >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
        [ $? -eq 0 ] && echo -e "\033[32m ${I} Add mutual trust to success!\033[0m" || echo -e "\033[1;31m ${I} Add trust failed.\033[0m"
    done
}
function Main() {
    [ $# -eq 1 ] || { echo "Usage: $(basename $0) ip.txt" ; exit 1 ; }
    which sshpass &> /dev/null || install_sshpass
    if [ -f '/root/.ssh/id_rsa.pub' ]; then
        add_auth
    else
        secretkey_generation
        add_auth
    fi
}
Main $@
