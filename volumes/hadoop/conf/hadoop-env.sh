export HADOOP_OS_TYPE=${HADOOP_OS_TYPE:-$(uname -s)}
export HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
export HADOOP_PID_DIR=/opt/hadoop/pids
export HADOOP_LOG_DIR=/opt/hadoop/logs

export HDFS_NAMENODE_USER=hdfs
export HDFS_DATANODE_USER=hdfs
export HDFS_SECONDARYNAMENODE_USER=hdfs

export YARN_RESOURCEMANAGER_USER=yarn
export YARN_NODEMANAGER_USER=yarn

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64