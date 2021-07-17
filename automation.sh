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
