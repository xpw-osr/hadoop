# start ssh service
service ssh start

# clean hadoop log folder
rm -f ${HADOOP_HOME}/${HADOOP_LOG_FOLDER_NAME}/*.log
rm -f ${HADOOP_HOME}/${HADOOP_LOG_FOLDER_NAME}/*.out
rm -f ${HADOOP_HOME}/${HADOOP_LOG_FOLDER_NAME}/*.out.*
rm -f ${HADOOP_HOME}/${HADOOP_LOG_FOLDER_NAME}/SecurityAuth-hdfs.audit

# clean hadoop tmp folder
rm -rf ${HADOOP_HOME}/${HADOOP_TMP_FOLDER_NAME}/tmp/nm-local-dir

# clean hadoop pid folder
rm -f ${HADOOP_HOME}/${HADOOP_PID_FOLDER_NAME}/*.pid

# clean hdfs
rm -rf ${HDFS_NAMENODE_FOLDER_PATH}/current
rm -f ${HDFS_NAMENODE_FOLDER_PATH}/in_use.lock

rm -rf ${HDFS_NAMENODE_SECONDARY_FOLDER_PATH}/current
rm -f ${HDFS_NAMENODE_SECONDARY_FOLDER_PATH}/in_use.lock

rm -rf ${HDFS_DATANODE_FOLDER_PATH}/current
rm -f ${HDFS_DATANODE_FOLDER_PATH}/in_use.lock

# clean yarn home
rm -rf ${YARN_NM_LOCAL_FOLDER_PATH}/filecache
rm -rf ${YARN_NM_LOCAL_FOLDER_PATH}/nmPrivate
rm -rf ${YARN_NM_LOCAL_FOLDER_PATH}/usercache

rm -rf ${YARN_LOG_FOLDER_PATH}/userlogs
rm -f ${YARN_LOG_FOLDER_PATH}/*.log
rm -f ${YARN_LOG_FOLDER_PATH}/*.out
rm -f ${YARN_LOG_FOLDER_PATH}/*.out.*

# re-format namenode
yes | hdfs namenode -format

# start dfs daemon
hdfs --daemon start namenode
hdfs --daemon start secondarynamenode
hdfs --daemon start datanode

# change permissions of / folder on dfs
su -c 'hdfs dfs -chown hdfs:hadoop /' - hdfs
su -c 'hdfs dfs -chmod 755 /' - hdfs

su -c 'hdfs dfs -mkdir /tmp' - hdfs
su -c 'hdfs dfs -chown hdfs:hadoop /tmp' - hdfs
su -c 'hdfs dfs -chmod 777 /tmp' - hdfs

su -c 'hdfs dfs -mkdir /user' - hdfs
su -c 'hdfs dfs -chown hdfs:hadoop /user' - hdfs
su -c 'hdfs dfs -chmod 755 /user' - hdfs

su -c 'hdfs dfs -mkdir -p /logs' - hdfs
su -c 'hdfs dfs -chown yarn:hadoop /logs' - hdfs
su -c 'hdfs dfs -chmod 777 /logs' - hdfs

su -c 'hdfs dfs -mkdir -p /mr-history/tmp' - hdfs
su -c 'hdfs dfs -chown mapred:hadoop /mr-history/tmp' - hdfs
su -c 'hdfs dfs -chmod 777 /mr-history/tmp' - hdfs

su -c 'hdfs dfs -mkdir -p /mr-history/done' - hdfs
su -c 'hdfs dfs -chown mapred:hadoop /mr-history/done' - hdfs
su -c 'hdfs dfs -chmod 750 /mr-history/done' - hdfs

# start yarn
yarn --daemon start resourcemanager
yarn --daemon start nodemanager
mapred --daemon start historyserver