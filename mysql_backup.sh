#!/bin/bash
# mysql_backup.sh: backup mysql databases and keep newest 5 days backup.  
#  
# ${db_user} is mysql username  
# ${db_password} is mysql password  
# ${db_host} is mysql host   
# �������������������C  
#/root/mysql_backup.sh
# everyday 3:00 AM execute database backup
# 0 3 * * * /root/mysql_backup.sh
#/etc/cron.daily

db_user="backup"
db_password="8H2QQQBEypp"
db_host="localhost"
# the directory for story your backup file.  #
backup_dir="/home/backup/mysql/"
# Ҫ���ݵ����ݿ��� #
#all_db="$(${mysql} -u ${db_user} -h ${db_host} -p${db_password} -Bse 'show databases')" #
all_db="dbname"

# Ҫ�����ı������� #
backup_day=10

#���ݿⱸ����־�ļ��洢��·��
logfile="/var/log/mysql_backup.log"

###ssh�˿ں�###
ssh_port=1204
###����ssh auto key���ļ�###
id_rsa=/root/auth_key/id_rsa_153.141.rsa
###����ssh auto username###
id_rsa_user=rsync
###����Ҫͬ����Զ�̷�������Ŀ¼·���������Ǿ���·����###
clientPath="/home/backup/mysql"
###����Ҫ����ı����ļ�Ŀ¼·�� Դ�������������Ǿ���·����###
serverPath=${backup_dir}
###��������������ip###
web_ip="192.168.0.2"

# date format for backup file (dd-mm-yyyy)  #
time="$(date +"%Y-%m-%d")"

# mysql, ${mysqldump} and some other bin's path  #
mysql="/usr/local/mysql-5.5.33/bin/mysql"
mysqldump="/usr/local/mysql-5.5.33/bin/mysqldump"

# the directory for story the newest backup  #
test ! -d ${backup_dir} && mkdir -p ${backup_dir}

#�������ݿ⺯��#
mysql_backup()
{
    # ȡ���е����ݿ��� #
    for db in ${all_db}
    do
        backname=${db}.${time}
        dumpfile=${backup_dir}${backname}
        
        #�����ݵ�ʱ�䡢���ݿ���������־
        echo "------"$(date +'%Y-%m-%d %T')" Beginning database "${db}" backup--------" >>${logfile}
        ${mysqldump} -F -u${db_user} -h${db_host} -p${db_password} ${db} > ${dumpfile}.sql 2>>${logfile} 2>&1
        
        #��ʼ��ѹ��������־д��log
        echo $(date +'%Y-%m-%d %T')" Beginning zip ${dumpfile}.sql" >>${logfile}
        #���������ݿ��ļ���ѹ��ZIP�ļ�����ɾ����ǰ��SQL�ļ�. #
        tar -czvf ${backname}.tar.gz ${backname}.sql 2>&1 && rm ${dumpfile}.sql 2>>${logfile} 2>&1 
        
        #��ѹ������ļ���������־��
        echo "backup file name:"${dumpfile}".tar.gz" >>${logfile}
        echo -e "-------"$(date +'%Y-%m-%d %T')" Ending database "${db}" backup-------\n" >>${logfile}    
    done
}

delete_old_backup()
{    
    echo "delete backup file:" >>${logfile}
    # ɾ���ɵı��� ���ҳ���ǰĿ¼������ǰ���ɵ��ļ�������֮ɾ��
    find ${backup_dir} -type f -mtime +${backup_day} | tee delete_list.log | xargs rm -rf
    cat delete_list.log >>${logfile}
}

rsync_mysql_backup()
{
    # rsync ͬ��������Server�� #
    for j in ${web_ip}
    do                
        echo "mysql_backup_rsync to ${j} begin at "$(date +'%Y-%m-%d %T') >>${logfile}
        ### ͬ�� ###
        rsync -avz --progress --delete $serverPath -e "ssh -p "${ssh_port}" -i "${id_rsa} ${id_rsa_user}@${j}:$clientPath >>${logfile} 2>&1 
        echo "mysql_backup_rsync to ${j} done at "$(date +'%Y-%m-%d %T') >>${logfile}
    done
}

#�������ݿⱸ���ļ�Ŀ¼
cd ${backup_dir}

mysql_backup
delete_old_backup
rsync_mysql_backup

echo -e "========================mysql backup && rsync done at "$(date +'%Y-%m-%d %T')"============================\n\n">>${logfile}
cat ${logfile}
