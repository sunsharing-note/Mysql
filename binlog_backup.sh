#!/bin/bash
# mysql_backup.sh: backup mysql databases and keep newest 5 days backup.  
#  
# ${db_user} is mysql username  
# ${db_password} is mysql password  
# ${db_host} is mysql host   
# �������������������C  
#/root/mysql_backup.sh
# every 30 minute AM execute database backup
# */30 * * * * /root/mysql_backup.sh
#/etc/cron.daily
#��÷��ڴӿ���ȥ���ݣ����Է�ֹ�����ڱ���ʱ������

# the directory for story your backup file.  #
backup_dir="/var/log/mysql/binlog/"

# Ҫ�����ı������� #
backup_day=10

#���ݿⱸ����־�ļ��洢��·��
logfile="/var/log/binlog_backup.log"

###ssh�˿ں�###
ssh_port=1204
###����ssh auto key���ļ�###
id_rsa=/root/auth_key/id_rsa_153.141.rsa
###����ssh auto username###
id_rsa_user=rsync
###����Ҫͬ����Զ�̷�������Ŀ¼·���������Ǿ���·����###
clientPath="/home/backup/mysqlbinlog"
###����Ҫ����ı����ļ�Ŀ¼·�� Դ�������������Ǿ���·����###
serverPath=${backup_dir}
###��������������ip###
web_ip="192.168.0.2"

# date format for backup file (dd-mm-yyyy)  #
time="$(date +"%Y-%m-%d")"

# the directory for story the newest backup  #
test ! -d ${backup_dir} && mkdir -p ${backup_dir}

delete_old_backup()
{    
    echo "delete old binlog file:" >>${logfile}
    # ɾ���ɵı��� ���ҳ���ǰĿ¼������ǰ���ɵ��ļ�������֮ɾ��
    find ${backup_dir} -type f -mtime +${backup_day} | tee delete_binlog_list.log | xargs rm -rf
    cat delete_binlog_list.log >>${logfile}
}

rsync_mysql_binlog()
{
    # rsync ͬ��������Server�� #
    for j in ${web_ip}
    do                
        echo "mysql_binlog_rsync to ${j} begin at "$(date +'%Y-%m-%d %T') >>${logfile}
        ### ͬ�� ###
        rsync -avz --progress --delete --include="mysql-bin.*" --exclude="*" $serverPath -e "ssh -p "${ssh_port}" -i "${id_rsa} ${id_rsa_user}@${j}:$clientPath >>${logfile} 2>&1 
        echo "mysql_binlog_rsync to ${j} done at "$(date +'%Y-%m-%d %T') >>${logfile}
    done
}

#�������ݿⱸ���ļ�Ŀ¼
cd ${backup_dir}

#delete_old_backup
rsync_mysql_binlog

echo -e "========================mysql binlog backup && rsync done at "$(date +'%Y-%m-%d %T')"============================\n\n">>${logfile}
cat ${logfile}


