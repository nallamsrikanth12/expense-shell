#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter DB password:"
read -s mysql_root_password

VALIDATE(){
   if [ $1 -ne 0 ]
   then
        echo -e "$2...$R FAILURE $N"
        exit 1
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $USERID -ne 0 ]
then
    echo "Please run this script with root access."
    exit 1 # manually exit if error comes.
else
    echo "You are super user."
fi


dnf module disable nodejs -y &>>$LOGFILE
VALIDATE $? "disable the nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE
VALIDATE $? "enable the 20 nodejs version"

dnf install nodejs -y &>>$LOGFILE
VALIDATE $? "installing the nodejs"

id expense 

if [ $? -ne 0 ]
then
    useradd expense
else
    echo -e "expense user already created.. $Y skipping $N"
fi       

mkdir -p /app &>>$LOGFILE
VALIDATE $? "creating app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGFILE
VALIDATE $? "download the backendcode"

cd /app &>>$LOGFILE
npm install &>>$LOGFILE
VALIDATE $? "install denpendencies"

cp /home/ec2-user/expense-shell  /etc/systemd/system/backend.service &>>$LOGFILE
VALIDATE $? "copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon reload"

systemctl start backend &>>$LOGFILE
VALIDATE "start backend"

systemctl enable backend &>>$LOGFILE
VALIDATE "enable backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "install mysql client"

mysql -h db.srikantheswar.online -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "scheme loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "restart backend"