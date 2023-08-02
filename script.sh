sudo yum update -y
sudo yum install python3 -y
sudo yum install pip -y
sudo pip install ansible -y
sudo yum install git -y
sudo git clone https://github.com/nileshmathur/devops-exercise.git
cd devops-exercise/
sudo ansible-playbook playbook.yml
sudo docker-compose up