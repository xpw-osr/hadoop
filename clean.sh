VOLUMES_FOLDER=./volumes
HADOOP_TMP_FOLDER_NAME=tmp
HADOOP_PID_FOLDER_NAME=pids
HADOOP_LOG_FOLDER_NAME=logs

HDFS_HOME=${VOLUMES_FOLDER}/home/hdfs
HDFS_NAMENODE_FOLDER=${HDFS_HOME}/namenode
HDFS_NAMENODE_SECONDARY_FOLDER=${HDFS_HOME}/namesecondary
HDFS_DATANODE_FOLDER=${HDFS_HOME}/datanode
HDFS_LOG_FOLDER=${HDFS_HOME}/log

YARN_HOME=${VOLUMES_FOLDER}/home/yarn
YARN_LOG_FOLDER=${YARN_HOME}/yarn_log
YARN_NM_LOG_FOLDER=${YARN_HOME}/log
YARN_NM_LOCAL_FOLDER=${YARN_HOME}/local

MAPRED_HOME=${VOLUMES_FOLDER}/home/mapred
MAPRED_JH_TMP_FOLDER=${MAPRED_HOME}/tmp
MAPRED_JH_DONE_FOLDER=${MAPRED_HOME}/done

KERBEROS_FOLDER=${VOLUMES_FOLDER}/kerberos
KERBEROS_KEYTAB_FOLDER=${KERBEROS_FOLDER}/keytabs
KERBEROS_LOGS_FOLDER=${KERBEROS_FOLDER}/logs

# clean hadoop log folder
rm -f ${VOLUMES_FOLDER}/hadoop/${HADOOP_LOG_FOLDER_NAME}/*.log
rm -f ${VOLUMES_FOLDER}/hadoop/${HADOOP_LOG_FOLDER_NAME}/*.out
rm -f ${VOLUMES_FOLDER}/hadoop/${HADOOP_LOG_FOLDER_NAME}/*.out.*
rm -f ${VOLUMES_FOLDER}/hadoop/${HADOOP_LOG_FOLDER_NAME}/SecurityAuth-hdfs.audit

# clean hadoop tmp folder
rm -rf ${VOLUMES_FOLDER}/hadoop/${HADOOP_TMP_FOLDER_NAME}/nm-local-dir
rm -rf ${VOLUMES_FOLDER}/hadoop/${HADOOP_TMP_FOLDER_NAME}/dfs

# clean hadoop pid folder
rm -f ${VOLUMES_FOLDER}/hadoop/${HADOOP_PID_FOLDER_NAME}/*.pid

# clean hdfs
rm -rf ${HDFS_NAMENODE_FOLDER}/current
rm -f ${HDFS_NAMENODE_FOLDER}/in_use.lock

rm -rf ${HDFS_NAMENODE_SECONDARY_FOLDER}/current
rm -f ${HDFS_NAMENODE_SECONDARY_FOLDER}/in_use.lock

rm -rf ${HDFS_DATANODE_FOLDER}/current
rm -f ${HDFS_DATANODE_FOLDER}/in_use.lock

# clean yarn home
rm -rf ${YARN_NM_LOCAL_FOLDER}/filecache
rm -rf ${YARN_NM_LOCAL_FOLDER}/nmPrivate
rm -rf ${YARN_NM_LOCAL_FOLDER}/usercache

rm -rf ${YARN_LOG_FOLDER}/userlogs
rm -f ${YARN_LOG_FOLDER}/*.log
rm -f ${YARN_LOG_FOLDER}/*.out
rm -f ${YARN_LOG_FOLDER}/*.out.*

# clean kerberos keytabs
ls ${KERBEROS_KEYTAB_FOLDER} | while read item; do
    if [ -d "${KERBEROS_KEYTAB_FOLDER}/${item}" ]; then
        rm -rf "${KERBEROS_KEYTAB_FOLDER}/${item}"
    fi

    if [[ ${item} =~ .*\.keytab$ ]]; then
        rm -f "${KERBEROS_KEYTAB_FOLDER}/${item}"
    fi
done

# clean kerberos logs
rm -f ${KERBEROS_LOGS_FOLDER}/*.log