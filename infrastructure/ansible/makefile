.PHONY: install-full install-k3s run-k3s

install-full:
	sudo apt update
	sudo apt install software-properties-common -y
	sudo add-apt-repository --yes --update ppa:ansible/ansible
	sudo apt install ansible -y

install-k3s:
	mkdir -p /home/alvaro/playbooks/k3s/group_vars
	wget -P  /home/alvaro/playbooks/k3s/ https://raw.githubusercontent.com/AlvaroNieto/homelab/refs/heads/main/infraestructure/ansible/playbooks/k3s/inventory.ini
	wget -P  /home/alvaro/playbooks/k3s/ https://raw.githubusercontent.com/AlvaroNieto/homelab/refs/heads/main/infraestructure/ansible/playbooks/k3s/install-k3s-ha.yml
	wget -P  /home/alvaro/playbooks/k3s/group_vars https://raw.githubusercontent.com/AlvaroNieto/homelab/refs/heads/main/infraestructure/ansible/playbooks/k3s/group_vars/all.yml

run-k3s:
	ansible-playbook -i /home/alvaro/playbooks/k3s/inventory.ini /home/alvaro/playbooks/k3s/install-k3s-ha.yml