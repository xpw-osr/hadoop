# start ssh service
service ssh start

# re-format namenode
yes | hdfs namenode -format

# start dfs daemon
hdfs --daemon start namenode
hdfs --daemon start secondarynamenode
hdfs --daemon start datanode

# change permissions of / folder on dfs
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

# start yarn
yarn --daemon start resourcemanager
yarn --daemon start nodemanager
mapred --daemon start historyserver