# hadoop

## TODO
- [x] deploy hadoop with non-secure mode
- [x] deploy hadoop with secure mode (with Kerberos)
- [ ] deploy Spark
- [ ] deploy HBase
- [ ] deploy Hive

## Build
```bash
$ docker build -t hadoop . --build-arg HADOOP_VERSION=3.2.1 --build-arg APAHCHE_HADOOP_REPOSITORY=https://downloads.apache.org/hadoop/common
```

## Example Configurations
### Principals
|Service|Component|Mandatory Principal Name|Mandatory Keytab File Name|Domain Folder Name|
|---|---|---|---|---|
|HDFS|NameNode|nn/master@WEIJILAB\.COM|nn.keytab|service|
|HDFS|NameNode HTTP|HTTP/master@WEIJILAB\.COM|HTTP.keytab|service|
|HDFS|SecondaryNameNode|sn/master@WEIJILAB\.COM|sn.keytab|service|
|HDFS|SecondaryNameNode HTTP|HTTP/master@WEIJILAB\.COM|HTTP.keytab|service|
|HDFS|DataNode|dn/master@WEIJILAB\.COM|dn.keytab|service|
|MR2|History Server|jhs/master@WEIJILAB\.COM|jhs.keytab|service|
|MR2|History Server HTTP|HTTP/master@WEIJILAB\.COM|HTTP.keytab|service|
|YARN|ResourceManager|rm/master@WEIJILAB\.COM|rm.keytab|service|
|YARN|NodeManager|nm/master@WEIJILAB\.COM|nm.keytab|service|
|YARN|Timeline Server|tl/master@WEIJILAB\.COM|tl.keytab|service|


### Port Settings
Following are port settings in hadoop config xmls, you can change them with your want.

|Config File|Field|Port|
|---|---|---|
|core-site.xml|fs.defaultFS|9000|
|hdfs-site.xml|dfs.namenode.http-address|5080|
||dfs.namenode.secondary.http-address|5088|
||dfs.datanode.address|6060|
||dfs.datanode.http.address|6088|
|yarn-site.xml|yarn.resourcemanager.webapp.address|7088|
|mapred-site.xml|mapreduce.jobhistory.address|9020|
||mapreduce.jobhistory.webapp.address|9088|

### Web Pages
Following Page URLs are based on above port settings

* [Hadoop NameNode](http://localhost:5080)
* [Hadoop Secondary Namenode](http://localhost:5088)
* [Hadoop DataNode](http://localhost:6088)
* [Hadoop Jobs](http://localhost:7088)
* [Hadoop Job History](http://localhost:9088)

## Job Example
### Submit MapReduce Job
```bash
hdfs $ export YARN_EXAMPLES=/opt/hadoop/share/hadoop/mapreduce
hdfs $ yarn jar ${YARN_EXAMPLES}/hadoop-mapreduce-examples-3.2.1.jar pi 16 100000
```