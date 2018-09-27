参考：[传送](https://blog.csdn.net/fuzhongfaya/article/details/80984608 "原文链接")

+ **1、导出某个表的数据**

`mysqldump -u userName -p  dabaseName tableName > fileName.sql`

+ **2.导出某个表的结构**

`mysqldump -u userName -p  -d dabaseName tableName > fileName.sql`

+ **3、导出某个库的数据**

`mysqldump -u userName -p  dabaseName  > fileName.sql`

+ **4、导出某个库的表结构**

`mysqldump -u userName -p  -d dabaseName > fileName.sql`

+ **5、导入方法1**

`mysql -u root -p` 登录之后,选择需要导入的数据库，

`source fileName.sql` 注：fileName.sql要有路径

+ **6、导入方法2**

`mysql -u root -p databasename < fileName.sql fileName.sql` 要有完整路径

+ **7、备份并压缩**

`mysqldump -u db_user -pInsecurePassword my_database | gzip > backup.tar.gz`

+ **8、备份全库**

`mysqldump -u root -p --single-transaction -A --master-data=2 >/data/dump.sql`

+ **9、恢复单库**

`mysql -u root -p test --one-database </data/dump.sql`


+ **10、恢复单表**

   + **1、找出表结构**
 
   sed -e'/./{H;$!d;}' -e 'x;/CREATE TABLE `test`/!d;q' /data/dump.sql

  或者

   cat /data/dump.sql |grep '^CREATE TABLE `test`' -C 10
  
   + **2、找出数据**
  
   grep 'INSERT INTO `test`' /data/dump.sql
