#/bin/bash
db_user="zabbix"
db_password="zabbix"
#定义备份目录
bakdir="/mysql/data/"
#定义备份日志
logfile="/mysql/mysql_backup.log"
db_name="zabbix"
#定义要保留的天数
backup_day=7
#定义日期格式
dateformat="$(date +'%Y-%m-%d')"
mysql="/usr/local/mysql/bin/mysql"
mysqldump="/usr/local/mysql/bin/mysqldump"
[ ! -d ${bakdir} ] && mkdir -p ${bakdir}
#定义备份函数
mysql_backup(){
	backname=${db_name}.${dateformat}
        dumpfile=${bakdir}${backname}
	#将备份数据库和日期写入备份日志
	echo "------"$(date +'%Y-%m-%d %T')" Beginning database ${db_name} backup------">>${logfile}
	${mysqldump} -F -u${db_user} -p${db_password} --single-transaction --master-data=2 ${db_name} > ${dumpfile}.sql 2>>${logfile} 2>&1
	echo -e "------"$(date +'%Y-%m-%d %T')" Ending database "${db_name}" backup---------\n" >>${logfile}
	
}
#定义删除函数
delete_old_backup(){
	echo "delete backup file: " >>${logfile}
	#删除七天以前的备份
	find ${bakdir} -type f -mtime +${backup_day} |tee delete_backup.log |xargs rm -rf
	cat delete_backup.log >>${logfile}
}
mysql_backup
delete_old_backup
echo -e "=============mysql backup done at "$(date +'%Y-%m-%d %T')"=============\n\n" >>${logfile}
