USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log
R="\e[31m"
G="\e[32m"
N="\e[0m"
P="\e[34m"

VALIDATE(){
if [ $1 -ne 0 ]
then
  echo -e "$2 $R failure $N"
else
  echo -e "$2  $G success $N" 
fi 
}

if [ $USERID -ne 0 ]
then 
  echo "you are not a super user"

else
  echo "you are super user"
fi

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "installing mysql sever"

systemctl enable mysqld -y 
VALIDATE $? "enable the mysqld" &>>$LOGFILE

systemctl start mysqld -y
VALIDATE $? "start the mysqld" &>>$LOGFILE

mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
VALIDATE $? "setting the root password"