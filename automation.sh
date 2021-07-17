s3_bucket="avdesh-upgrad"
myname="avdesh"
timestamp=$(date '+%d%m%Y-%H%M%S')

apt update -y
#install awscli if not installed
if [ $(dpkg-query -W -f='${Status}' awscli 2>/dev/null | grep -c "ok installed") -eq 0 ];
  echo "AWS CLI package already installed."
then
  apt-get install awscli -y;
fi

#install apache2 if not installed
if [ $(dpkg-query -W -f='${Status}' apache2 2>/dev/null | grep -c "ok installed") -eq 0 ];
  echo "Apache2 package already installed."
then
  apt-get install apache2 -y;
fi

#Check if apache2 is enabled to run on boot
if [ $(systemctl status httpd >/dev/null | grep -c "enabled") -eq 0 ];
then
  echo "apache service enabled"
else
  systemctl enable apache2
fi

#Run apache2 if not running
if [ $(systemctl status apache2 >/dev/null | grep -c "running") -eq 0 ];
then
  echo "apache2 service running"
else
  systemctl start apache2
fi

# Create inventory.html if does not exist
if [[ ! -e /var/www/html/inventory.html ]]; then
    touch /var/www/html/inventory.html
    #echo "<html><head>Inventory</head><body>"
    #echo "<th><td>Log Type</td><td>Time Created</td><td>Type</td><td>Size</td></th>" >> /var/www/html/inventory.html
    echo "Log Type:Time Created:Type:Size" | tr : '\t\t' > /var/www/html/inventory.html
fi


#Zip and upload log files
tar -czf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log
aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar

#Update Inventory
filename="/tmp/${myname}-httpd-logs-${timestamp}.tar"
filesize=$(stat -c%s "$filename")
#echo $filesize
#echo "<tr><td>httpd-logs</td><td>${timestamp}</td><td>tar</td><td>${filesize}</td></tr>" >> /var/www/html/inventory.html
echo "httpd-logs:${timestamp}:tar:${filesize}" | tr : '\t\t' >> /var/www/html/inventory.html

#Create cron job if does not exist
if [[ ! -e /etc/cron.d/automation ]]; then
    echo "0 0 * * * /root/Automation_Project/automation.sh && rm -rf /var/log/apache2/*.log" > /etc/cron.d/automation
fi
