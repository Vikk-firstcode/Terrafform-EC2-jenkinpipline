#script will install Terraform & Ansible 

sudo apt update

sudo apt install -y wget unzip
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip

sudo mv terraform /usr/local/bin/


terraform -version
sudo apt-add-repository ppa:ansible/ansible
sudo apt install -y ansible
ansible --version

apt install python3-pip
apt install  python3-boto3
apt install  python3-botocore
ansible-playbook orch.yaml
aws
apt update -y
apt  install awscli
apt install awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
apt install unzip
unzip awscliv2.zip
sudo ./aws/install
aws configure
