sudo yum update
sudo yum install pip docker git -y
sudo pip install ansible
sudo systemctl start docker
sudo systemctl enable docker
sudo git clone https://github.com/nileshmathur/devops-exercise.git
cd devops-exercise/
sudo ansible-playbook playbook.yml
sudo docker-compose up -d
