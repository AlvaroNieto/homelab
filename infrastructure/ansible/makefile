# wget -P  /home/alvaro/playbooks/k3s/ https://raw.githubusercontent.com/AlvaroNieto/homelab/refs/heads/main/infrastructure/ansible/makefile

.PHONY: install-full prepare-k3s run-k3s-pre run-k3s-main run-k3s-full config-k3s-pre config-k3s-main config-k3s-full

install-full:
	sudo apt update
	sudo apt install software-properties-common -y
	sudo add-apt-repository --yes --update ppa:ansible/ansible
	sudo apt install ansible -y

prepare-k3s:
	mkdir -p /home/alvaro/playbooks/k3s/group_vars
	wget -P  /home/alvaro/playbooks/k3s/ https://raw.githubusercontent.com/AlvaroNieto/homelab/refs/heads/main/infrastructure/ansible/playbooks/k3s/inventory.ini
	wget -P  /home/alvaro/playbooks/k3s/ https://raw.githubusercontent.com/AlvaroNieto/homelab/refs/heads/main/infrastructure/ansible/playbooks/k3s/install-k3s-main.yml
	wget -P  /home/alvaro/playbooks/k3s/ https://raw.githubusercontent.com/AlvaroNieto/homelab/refs/heads/main/infrastructure/ansible/playbooks/k3s/install-k3s-pre.yml
	wget -P  /home/alvaro/playbooks/k3s/ https://raw.githubusercontent.com/AlvaroNieto/homelab/refs/heads/main/infrastructure/ansible/playbooks/k3s/k3s-main-config.yml
	wget -P  /home/alvaro/playbooks/k3s/ https://raw.githubusercontent.com/AlvaroNieto/homelab/refs/heads/main/infrastructure/ansible/playbooks/k3s/k3s-pre-config.yml
	wget -P  /home/alvaro/playbooks/k3s/group_vars https://raw.githubusercontent.com/AlvaroNieto/homelab/refs/heads/main/infrastructure/ansible/playbooks/k3s/group_vars/all.yml

run-k3s-pre:
	ansible-playbook -i /home/alvaro/playbooks/k3s/inventory.ini /home/alvaro/playbooks/k3s/install-k3s-pre.yml --limit k3s_preprod

run-k3s-main:
	ansible-playbook -i /home/alvaro/playbooks/k3s/inventory.ini /home/alvaro/playbooks/k3s/install-k3s-main.yml --limit k3s_control_plane

run-k3s-full: run-k3s-pre run-k3s-main

config-k3s-pre:
	ansible-playbook -i /home/alvaro/playbooks/k3s/inventory.ini /home/alvaro/playbooks/k3s/k3s-pre-config.yml --limit k3s_preprod
	
config-k3s-main:
	ansible-playbook -i /home/alvaro/playbooks/k3s/inventory.ini /home/alvaro/playbooks/k3s/k3s-main-config.yml --limit k3s_control_plane

config-k3s-full: config-k3s-pre config-k3s-main
