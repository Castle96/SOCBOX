#!/bin/bash

# Define Variables
WAZUH_VERSION="4.6"
ELK_VERSION="7.x"

# Update System 
echo "[+] Updating system..."
sudo apt update && sudo apt upgrade -y

# Install Required Dependencies 
echo "[+] Installing dependencies..."
sudo apt install -y curl wget gnupg unzip apt-transport-https software-properties-common

# Install Wazuh Manager
echo "[+] Installing Wazuh Manager..."
curl -sO https://packages.wazuh.com/${WAZUH_VERSION}/wazuh-install.sh
bash wazuh-install.sh --manager 
sudo systemctl enable --now wazuh_manager

# Install Wazuh Manager (Self-Monitoring)
echo "[+] Installing Wazuh Agent..."
bash wazuh-install.sh --agent 
sudo systemctl enable --now wazuh-agent 

# Configuring Wazuh Agent 
echo "[+] Configuring Wazuh Agent..."
sudo sed -i 's/<ADDRESS>/192.168.x.x/' /var/ossec/etc/ossec.conf 
sudo systemctl restart wazuh-agent

# Install Elasticsearch
echo "[+] Installing Elasticsearch..."
wget -qO- https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/${ELK_VERSION}/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-${ELK_VERSION}.list 
sudo apt update 
sudo apt install -y elasticsearch 
sudo systemctl enable --now elasticsearch

# Optimize Elasticsearch for Low RAM
echo "[+] Configuring Elasticsearch for Raspberry Pi..."
sudo sed -i 's/-Xms1g/-Xms512m/' /etc/elasticsearch/jvm.options
sudo sed -i 's/-Xmx1g/-Xmx512m/' /etc/elasticsearch/jvm.options 
sudo systemctl restart elasticsearch

# Install Logstash
echo "[+] Installing Logstash..."
sudo apt install -y logstash 
sudo systemctl enable --now logstash 

# Install Kibana
echo "[+] Installing Kibana..."
sudo apt install -y kibana 
sudo systemctl enable --now kibana

# Install Wazuh Plugin for Kibana
echo "[+] Installing Wazuh Plugin for Kibana..."
sudo /usr/share/kibana/bin/kibana-plugin install https://packages.wazuh.com/${WAZUH_VERSION}/wazuhapp.zip
sudo systemctl restart kibana

# Install Grafana
echo "[+] Installing Grafana..."
sudo apt install -y grafana 
sudo systemctl enable --now grafana

# Display Access Information
echo "[+] SOC in a Box setup complete!"
echo "-------------------------------------------------------------"
echo "Kibana: http://$(hostname -I | awk '{print $1}'):5601"
echo "Grafana: http://$(hostname -I | awk '{print $1}'):3000"
echo "Elasticsearch: http://$(hostname -I | awk '{print $1}'):9200"
echo "--------------------------------------------------------------"
echo "Default Grafana login: admin / admin"


