#/bin/bash
#可在mysql配置文件中修改默认保存binlog的天数
#expire_logs_days=7
db_user="root"
db_password="root"
mysqladmin="/usr/local/mysql/bin/mysqladmin"
#定义二进制日志文件目录
binlog_dir="/usr/local/mysql/data/"
#定义二进制索引文件
binlog_index="/usr/local/mysql/data/mysql-bin.index"
#定义备份目录
binlog_bak="/mysql/binlog/"
#定义增量备份的日志文件
logfile="/mysql/binlog_backup.log"
#定义日志保留天数
backup_day=10
#定义日期格式
#dateformat="$(date +'$Y-%m-%d')"
#测试目录是否存在，如果不存在则创建
[ ! -d ${binlog_bak} ] && mkdir -p ${binlog_bak}
#定义备份函数
binlog_backup(){
	echo "------mysql_binlog_backup at "$(date +'%Y-%m-%d %T')"------" >>${logfile}
	#刷新二进制日志
	${mysqladamin} -u${db_user} -p${db_password} flush-logs >/dev/null 2>&1
	count=`wc -l ${binlog_index} |awk '{print $1}'`
	for file in `cat ${binlog_index} |head -n ${count}`
	do
		#这里用basename取出二进制日志名
		f=`basename $file`
		chmod +x ${binlog_dir}$f
		cp ${binlog_dir}$f ${binlog_bak}$f
	done
	
}
binlog_backup
echo -e "===========mysql binlog backup done at "$(date +'%Y-%m-%d %T')"===========\n\n" >>${logfile}
