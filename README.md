# hadoop

## TODO
- [x] deploy hadoop with non-secure mode
- [ ] deploy hadoop with secure mode (with Kerberos)
- [ ] deploy Spark
- [ ] deploy HBase
- [ ] deploy Hive

## Build
```bash
$ docker build -t hadoop . --build-arg HADOOP_VERSION=3.2.1 --build-arg APAHCHE_HADOOP_REPOSITORY=https://downloads.apache.org/hadoop/common
```

## Port Settings
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

## Web Pages
Following Page URLs are based on above port settings

* [Hadoop NameNode](http://localhost:5080/dfshealth.html#tab-overview)
* [Hadoop Secondary Namenode](http://localhost:5088/status.html)
* [Hadoop DataNode](http://localhost:6088/datanode.html)
* [Hadoop Jobs](http://localhost:7088/cluster)
* [Hadoop Job History](http://localhost:9088/jobhistory)

## Job Example
### Submit MapReduce Job
```bash
hdfs $ export YARN_EXAMPLES=/opt/hadoop/share/hadoop/mapreduce
hdfs $ yarn jar ${YARN_EXAMPLES}/hadoop-mapreduce-examples-3.2.1.jar pi 16 100000
```