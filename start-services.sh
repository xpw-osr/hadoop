# start ssh service
service ssh start

# do clean
rm -f ${HADOOP_HOME}/${HADOOP_LOG_FOLDER_NAME}/*.log
rm -f ${HADOOP_HOME}/${HADOOP_LOG_FOLDER_NAME}/*.out
rm -f ${HADOOP_HOME}/${HADOOP_LOG_FOLDER_NAME}/*.out.*
rm -f ${HADOOP_HOME}/${HADOOP_LOG_FOLDER_NAME}/SecurityAuth-hdfs.audit
rm -rf ${HADOOP_HOME}/${HADOOP_TMP_FOLDER_NAME}/tmp/nm-local-dir
rm -f ${HADOOP_HOME}/${HADOOP_PID_FOLDER_NAME}/*.pid
rm -rf ${HDFS_NAMENODE_FOLDER_PATH}/current
rm -f ${HDFS_NAMENODE_FOLDER_PATH}/in_use.lock
rm -rf ${HDFS_NAMENODE_SECONDARY_FOLDER_PATH}/current
rm -f ${HDFS_NAMENODE_SECONDARY_FOLDER_PATH}/in_use.lock
rm -rf ${HDFS_DATANODE_FOLDER_PATH}/current
rm -f ${HDFS_DATANODE_FOLDER_PATH}/in_use.lock
rm -rf ${YARN_NM_LOCAL_FOLDER_PATH}/filecache
rm -rf ${YARN_NM_LOCAL_FOLDER_PATH}/nmPrivate
rm -rf ${YARN_NM_LOCAL_FOLDER_PATH}/usercache
rm -rf ${YARN_LOG_FOLDER_PATH}/userlogs
rm -f ${YARN_LOG_FOLDER_PATH}/*.log
rm -f ${YARN_LOG_FOLDER_PATH}/*.out
rm -f ${YARN_LOG_FOLDER_PATH}/*.out.*

# NOTE: following actions MUST be done after the volumes are mounted and container is running. so, add scripts here.
#       or, maybe we can try settings in /etc/fstab later.
# change ownership and permission of 
#   * /opt/hadoop/pids
#   * /opt/hadoop/logs
#   * /opt/hadoop/tmp
# to make following processes can create pid files
#   - following processes run as hdfs user
#       * namenode
#       * secondary namenode
#       * datanode
#   - following processes run as yarn user
#       * resource manager
#       * node manager
chown root:hadoop ${HADOOP_HOME}/${HADOOP_PID_FOLDER_NAME}
chmod 775 ${HADOOP_HOME}/${HADOOP_PID_FOLDER_NAME}
chown root:hadoop ${HADOOP_HOME}/${HADOOP_LOG_FOLDER_NAME}
chmod 775 ${HADOOP_HOME}/${HADOOP_LOG_FOLDER_NAME}
chown root:hadoop ${HADOOP_HOME}/${HADOOP_TMP_FOLDER_NAME}
chmod 775 ${HADOOP_HOME}/${HADOOP_TMP_FOLDER_NAME}
# following folders should belong to special users
chown -R hdfs:hadoop ${HDFS_HOME}
chmod -R 755 ${HDFS_HOME}
chown -R yarn:hadoop ${YARN_HOME}
chmod -R 755 ${YARN_HOME}
chown -R mapred:hadoop ${MAPRED_HOME}
chmod -R 755 ${MAPRED_HOME}

# re-format namenode
yes | hdfs namenode -format

# start hdfs
hdfs --daemon start namenode
hdfs --daemon start secondarynamenode
hdfs --daemon start datanode

# change ownership and permission hdfs folders


if [ "${HADOOP_MODE}" = "secure" ]; then
  kinit -kt /etc/keytabs/master/nn.keytab nn/master
  hdfs dfs -chown hdfs:hadoop /
  hdfs dfs -chmod 755 /
  hdfs dfs -mkdir /tmp
  hdfs dfs -chown hdfs:hadoop /tmp
  hdfs dfs -chmod 777 /tmp
  hdfs dfs -mkdir /user
  hdfs dfs -chown hdfs:hadoop /user
  hdfs dfs -chmod 755 /user
  hdfs dfs -mkdir -p /logs
  hdfs dfs -chown yarn:hadoop /logs
  hdfs dfs -chmod 777 /logs
  hdfs dfs -mkdir -p /mr-history
  hdfs dfs -chown hdfs:hadoop /mr-history
  hdfs dfs -chmod 777 /mr-history
  hdfs dfs -mkdir -p /mr-history/tmp
  hdfs dfs -chown mapred:hadoop /mr-history/tmp
  hdfs dfs -chmod 777 /mr-history/tmp
  hdfs dfs -mkdir -p /mr-history/done
  hdfs dfs -chown mapred:hadoop /mr-history/done
  hdfs dfs -chmod 750 /mr-history/done
  kdestroy
else
  su -c 'hdfs dfs -chown hdfs:hadoop /' - hdfs
  su -c 'hdfs dfs -chmod 755 /' - hdfs
  su -c 'hdfs dfs -mkdir /tmp' - hdfs
  su -c 'hdfs dfs -chown hdfs:hadoop /tmp' - hdfs
  su -c 'hdfs dfs -chmod 777 /tmp' - hdfs
  su -c 'hdfs dfs -mkdir /user' - hdfs
  su -c 'hdfs dfs -chown hdfs:hadoop /user' - hdfs
  su -c 'hdfs dfs -chmod 775 /user' - hdfs
  su -c 'hdfs dfs -mkdir -p /logs' - hdfs
  su -c 'hdfs dfs -chown yarn:hadoop /logs' - hdfs
  su -c 'hdfs dfs -chmod 777 /logs' - hdfs
  su -c 'hdfs dfs -mkdir -p /mr-history/tmp' - hdfs
  su -c 'hdfs dfs -chown mapred:hadoop /mr-history/tmp' - hdfs
  su -c 'hdfs dfs -chmod 777 /mr-history/tmp' - hdfs
  su -c 'hdfs dfs -mkdir -p /mr-history/done' - hdfs
  su -c 'hdfs dfs -chown mapred:hadoop /mr-history/done' - hdfs
  su -c 'hdfs dfs -chmod 750 /mr-history/done' - hdfs
fi

# start yarn
yarn --daemon start resourcemanager
yarn --daemon start nodemanager
mapred --daemon start historyserver