.PHONY: install-full install-k3s run

install-full:
	sudo apt update
	sudo apt install software-properties-common -y
	sudo add-apt-repository --yes --update ppa:ansible/ansible
	sudo apt install ansible -y
	

install-k3s:
	mkdir -p /home/alvaro/ansible/k3s-ansible-ha/group_vars

run:
	ansible-playbook -i inventory.ini install-k3s-ha.yml