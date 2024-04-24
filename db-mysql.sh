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

systemctl enable mysqld 
VALIDATE $? "enable the mysqld" &>>$LOGFILE

systemctl start mysqld 
VALIDATE $? "start the mysqld" &>>$LOGFILE

#mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
#ALIDATE $? "setting the root password"

#below code will be useful for idempotent nature

mysql -h db.srikantheswar.online -uroot -pExpenseApp@1 -e 'show databases;'

if [ $? -ne 0 ]
then
    mysql_secure_installation --set-root-pass ExpenseApp@1
    VALIDATE $? "settingup password"
else
    echo -e "mysql root password is already setup ..$P skipping $N"    
fi