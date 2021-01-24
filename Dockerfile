FROM ubuntu:20.04

ARG HADOOP_VERSION
ARG APAHCHE_HADOOP_REPOSITORY
ARG APT_SOURCES_LIST_FILE

ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_TMP_FOLDER_NAME tmp
ENV HADOOP_PID_FOLDER_NAME pids
ENV HADOOP_LOG_FOLDER_NAME logs

ENV HDFS_HOME /home/hdfs
ENV HDFS_NAMENODE_FOLDER_PATH ${HDFS_HOME}/namenode
ENV HDFS_NAMENODE_SECONDARY_FOLDER_PATH ${HDFS_HOME}/namesecondary
ENV HDFS_DATANODE_FOLDER_PATH ${HDFS_HOME}/datanode
ENV HDFS_LOG_FOLDER_PATH ${HDFS_HOME}/log

ENV YARN_HOME /home/yarn
ENV YARN_LOG_FOLDER_PATH ${YARN_HOME}/yarn_log
ENV YARN_NM_LOG_FOLDER_PATH ${YARN_HOME}/log
ENV YARN_NM_LOCAL_FOLDER_PATH ${YARN_HOME}/local

ENV MAPRED_HOME /home/mapred
ENV MAPRED_JH_TMP_FOLDER_PATH ${MAPRED_HOME}/tmp
ENV MAPRED_JH_DONE_FOLDER_PATH ${MAPRED_HOME}/done

ENV USER_SHELL /usr/bin/bash
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $PATH:${HADOOP_HOME}/bin:${HADOOP_HOME}/sbin:${JAVA_HOME}/bin

VOLUME [ \
    "${HADOOP_HOME}/etc/hadoop", \
    "${HADOOP_HOME}/tmp", \
    "${HADOOP_HOME}/pids", \
    "${HADOOP_HOME}/logs", \
    "/root/.ssh", \
    "${HDFS_HOME}/.ssh", \
    "${HDFS_NAMENODE_FOLDER_PATH}", \
    "${HDFS_NAMENODE_SECONDARY_FOLDER_PATH}", \
    "${HDFS_DATANODE_FOLDER_PATH}", \
    "${HDFS_LOG_FOLDER_PATH}", \
    "${YARN_HOME}/.ssh", \
    "${YARN_LOG_FOLDER_PATH}", \
    "${YARN_NM_LOCAL_FOLDER_PATH}", \
    "${YARN_NM_LOG_FOLDER_PATH}", \
    "${MAPRED_HOME}/.ssh" \
]

RUN echo "export PATH=${PATH}" >> /etc/profile

###############################################################
# install dependencies and tools

COPY ${APT_SOURCES_LIST_FILE} /sources.list
RUN if [ "${APT_SOURCES_LIST_FILE}" != "" ]; then \
        mv /etc/apt/sources.list /etc/apt/sources.list.offical; \
        mv /sources.list /etc/apt/sources.list; \
    fi

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y curl iputils-ping openssh-server openjdk-8-jdk \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/*

RUN if [ "${APT_SOURCES_LIST_FILE}" != "" ]; then \
        mv /etc/apt/sources.list.offical /etc/apt/sources.list; \
    fi

RUN sed -ie 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config \
    && sed -ie 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

###############################################################
# install hadoop

RUN curl ${APAHCHE_HADOOP_REPOSITORY}/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz --output /hadoop.tar.gz \
    && mkdir -p ${HADOOP_HOME} \
    && tar -zxvf /hadoop.tar.gz -C ${HADOOP_HOME} --strip-components 1 \
    && chown -R root:root ${HADOOP_HOME} \
    && rm -f /hadoop.tar.gz

RUN bash -c "mkdir -p ${HADOOP_HOME}/{${HADOOP_TMP_FOLDER_NAME},${HADOOP_PID_FOLDER_NAME},${HADOOP_LOG_FOLDER_NAME}}"

###############################################################
# create group and users

# create hadoop group
RUN addgroup hadoop \
    && usermod -aG hadoop root

# for HDFS
RUN adduser --home ${HDFS_HOME} --shell ${USER_SHELL} --ingroup hadoop hdfs \
    && echo "hdfs:hadoop" | chpasswd

RUN mkdir -p ${HDFS_NAMENODE_FOLDER_PATH} \
    && chown hdfs:hadoop ${HDFS_NAMENODE_FOLDER_PATH} \
    && chmod 700 ${HDFS_NAMENODE_FOLDER_PATH}

RUN mkdir -p ${HDFS_NAMENODE_SECONDARY_FOLDER_PATH} \
    && chown hdfs:hadoop ${HDFS_NAMENODE_SECONDARY_FOLDER_PATH} \
    && chmod 700 ${HDFS_NAMENODE_SECONDARY_FOLDER_PATH}

RUN mkdir -p ${HDFS_DATANODE_FOLDER_PATH} \
    && chown hdfs:hadoop ${HDFS_DATANODE_FOLDER_PATH} \
    && chmod 700 ${HDFS_DATANODE_FOLDER_PATH}

RUN mkdir -p ${HDFS_LOG_FOLDER_PATH} \
    && chown hdfs:hadoop ${HDFS_LOG_FOLDER_PATH} \
    && chmod 755 ${HDFS_LOG_FOLDER_PATH}

# for Yarn
RUN adduser --home ${YARN_HOME} --shell ${USER_SHELL} --ingroup hadoop yarn \
    && echo "yarn:hadoop" | chpasswd

RUN mkdir -p ${YARN_LOG_FOLDER_PATH} \
    && chown yarn:hadoop ${YARN_LOG_FOLDER_PATH} \
    && chmod 775 ${YARN_LOG_FOLDER_PATH}

RUN mkdir -p ${YARN_NM_LOCAL_FOLDER_PATH} \
    && chown yarn:hadoop ${YARN_NM_LOCAL_FOLDER_PATH} \
    && chmod 755 ${YARN_NM_LOCAL_FOLDER_PATH}

RUN mkdir -p ${YARN_NM_LOG_FOLDER_PATH} \
    && chown yarn:hadoop ${YARN_NM_LOG_FOLDER_PATH} \
    && chmod 755 ${YARN_NM_LOG_FOLDER_PATH}

# for MapRed
RUN adduser --home ${MAPRED_HOME} --shell ${USER_SHELL} --ingroup hadoop mapred \
    && echo "mapred:hadoop" | chpasswd

RUN mkdir -p ${MAPRED_JH_TMP_FOLDER_PATH} \
    && chown mapred:hadoop ${MAPRED_JH_TMP_FOLDER_PATH} \
    && chmod 755 ${MAPRED_JH_TMP_FOLDER_PATH}

RUN mkdir -p ${MAPRED_JH_DONE_FOLDER_PATH} \
    && chown mapred:hadoop ${MAPRED_JH_DONE_FOLDER_PATH} \
    && chmod 755 ${MAPRED_JH_DONE_FOLDER_PATH}

###############################################################
# copy scripts

COPY ./launch.sh /usr/local/bin/start-services
RUN chmod 744 /usr/local/bin/start-services

# ENTRYPOINT service ssh start && tail -f /dev/null
ENTRYPOINT /usr/local/bin/start-services && tail -f /dev/null