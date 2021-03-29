ARG BUILDER_HOME=/home/builder
ARG BUILD_OUTPUT_FOLDER=${BUILDER_HOME}/dist

ARG APACHE_HADOOP_REPOSITORY=https://downloads.apache.org/hadoop/common/
ARG APACHE_HADOOP_VERSION=3.2.1
ARG APACHE_HADOOP_CONF_FOLDER=./volumes/hadoop/conf

ARG APACHE_SPARK_REPOSITORY=https://archive.apache.org/dist/spark
ARG APACHE_SPARK_VERSION=3.0.1
ARG APACHE_SPARK_FOR_HADOOP=hadoop3.2

# build container-executor
FROM ubuntu:20.04 AS builder

ARG APACHE_HADOOP_LOCAL_SOURCE_PACKAGE
ARG APACHE_HADOOP_VERSION
ARG APACHE_HADOOP_REPOSITORY

ARG PROTOBUF_LOCAL_SOURCE_PACKAGE

ARG APT_SOURCES_LIST_FILE
ARG APACHE_MAVEN_SETTINGS
ARG LOCAL_M2_FOLDER

ARG BUILDER_HOME
ARG BUILD_OUTPUT_FOLDER

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $PATH:${JAVA_HOME}/bin
ENV WORKSPACE_FOLDER ${BUILDER_HOME}/workspace

######################################################################
# install infrastructure

COPY ${APT_SOURCES_LIST_FILE} /sources.list
RUN if [ "${APT_SOURCES_LIST_FILE}" != "" ]; then \
        # ---------------------------------------------------------
        # solve issue of 'Certificate verification failed during docker build when use apt mirrors #1'
        apt-get update && apt-get install -y ca-certificates; \
        # ---------------------------------------------------------
        mv /etc/apt/sources.list /etc/apt/sources.list.offical; \
        mv /sources.list /etc/apt/sources.list; \
    fi

RUN apt-get update \
    && apt-get -y upgrade \
    && DEBIAN_FRONTEND="noninteractive" TZ="Asia/Shanghai" apt-get install -y build-essential curl git linux-headers-$(uname –r) maven autoconf libtool cmake openjdk-8-jdk \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/*

RUN if [ "${APT_SOURCES_LIST_FILE}" != "" ]; then \
        mv /etc/apt/sources.list.offical /etc/apt/sources.list; \
    fi

######################################################################
# add builder
RUN adduser -S builder -s /bin/bash -h ${BUILDER_HOME}
RUN mkdir -p ${BUILDER_HOME}/.m2 \
    && mkdir -p ${WORKSPACE_FOLDER}
COPY ${APACHE_MAVEN_SETTINGS} "${BUILDER_HOME}/.m2/"

######################################################################
# build

# build protobuf 2.5.0
COPY ${PROTOBUF_LOCAL_SOURCE_PACKAGE} protobuf-2.5.0.tar.gz
RUN if [ ! -f "protobuf-2.5.0.tar.gz" ]; then \
        curl -L https://github.com/protocolbuffers/protobuf/releases/download/v2.5.0/protobuf-2.5.0.tar.gz --output protobuf-2.5.0.tar.gz; \
    fi

RUN tar -xvf protobuf-2.5.0.tar.gz \
    && cd protobuf-2.5.0 \
    && ./autogen.sh \
    && ./configure --prefix=/usr \
    && make \
    && make install

# build container-executor
ENV NODEMANAGER_PROJECT_FOLDER hadoop-yarn-project/hadoop-yarn/hadoop-yarn-server/hadoop-yarn-server-nodemanager

COPY ${APACHE_HADOOP_LOCAL_SOURCE_PACKAGE} hadoop-src.tar.gz
RUN if [ ! -f "hadoop-src.tar.gz" ]; then \
        curl -L ${APACHE_HADOOP_REPOSITORY}/hadoop-${APACHE_HADOOP_VERSION}/hadoop-${APACHE_HADOOP_VERSION}-src.tar.gz --output hadoop-src.tar.gz; \
    fi

# RUN tar -zxvf /hadoop-src.tar.gz -C ${WORKSPACE_FOLDER} --strip-components 1 \
#     && cd "${WORKSPACE_FOLDER}/${NODEMANAGER_PROJECT_FOLDER}" \
#     && if [ "${LOCAL_M2_FOLDER}" != "" ]; then \
#             --mount=type=bind,source=${LOCAL_M2_FOLDER},target=${BUILDER_HOME}/.m2,rw mvn package -Pnative -Dcontainer-executor.conf.dir=/etc/ -DskipTests -Dtar 2>&1; \
#         else \
#             --mount=type=cache,target=${BUILDER_HOME}/.m2 mvn package -Pnative -Dcontainer-executor.conf.dir=/etc/ -DskipTests -Dtar 2>&1; \
#         fi \
#     && mkdir -p "${BUILD_OUTPUT_FOLDER}" \
#     && cp "${WORKSPACE_FOLDER}/${NODEMANAGER_PROJECT_FOLDER}/target/native/target/usr/local/bin"/* "${BUILD_OUTPUT_FOLDER}/"

RUN tar -zxvf /hadoop-src.tar.gz -C ${WORKSPACE_FOLDER} --strip-components 1
WORKDIR ${WORKSPACE_FOLDER}/${NODEMANAGER_PROJECT_FOLDER}

    # && cd "${WORKSPACE_FOLDER}/${NODEMANAGER_PROJECT_FOLDER}" \
RUN --mount=type=cache,target=${BUILDER_HOME}/.m2 mvn package -Pnative -Dcontainer-executor.conf.dir=/etc/ -DskipTests -Dtar 2>&1 \
    && mkdir -p "${BUILD_OUTPUT_FOLDER}" \
    && cp "${WORKSPACE_FOLDER}/${NODEMANAGER_PROJECT_FOLDER}/target/native/target/usr/local/bin"/* "${BUILD_OUTPUT_FOLDER}/"



FROM ubuntu:20.04

ARG APACHE_HADOOP_LOCAL_BINARY_PACKAGE
ARG APACHE_HADOOP_REPOSITORY
ARG APACHE_HADOOP_VERSION
ARG APACHE_HADOOP_CONF_FOLDER

ARG APACHE_SPARK_LOCAL_BINARY_PACKAGE
ARG APACHE_SPARK_REPOSITORY
ARG APACHE_SPARK_VERSION
ARG APACHE_SPARK_FOR_HADOOP

ARG APT_SOURCES_LIST_FILE
ARG BUILD_OUTPUT_FOLDER

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

ENV CA_FOLDER /etc/ca
ENV KEYTABS_FOLDER /opt/keytabs

ENV SPARK_HOME=/opt/spark

ENV USER_SHELL /usr/bin/bash
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
ENV PATH $PATH:${HADOOP_HOME}/bin:${SPARK_HOME}/bin:${JAVA_HOME}/bin

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
    "${MAPRED_HOME}/.ssh", \
    "${CA_FOLDER}", \
    "${KEYTABS_FOLDER}", \
    "${SPARK_HOME}/conf" \
]

RUN echo "export PATH=${PATH}" >> /etc/profile

###############################################################
# install dependencies and tools

COPY ${APT_SOURCES_LIST_FILE} /sources.list
RUN if [ "${APT_SOURCES_LIST_FILE}" != "" ]; then \
        # ---------------------------------------------------------
        # solve issue of 'Certificate verification failed during docker build when use apt mirrors #1'
        apt-get update && apt-get install -y ca-certificates; \
        # ---------------------------------------------------------
        mv /etc/apt/sources.list /etc/apt/sources.list.ori; \
        mv /sources.list /etc/apt/sources.list; \
    fi

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y curl openssh-server openjdk-8-jdk krb5-user \
    && apt-get clean \
    && rm -rf /var/cache/apt/archives/*

RUN if [ "${APT_SOURCES_LIST_FILE}" != "" ]; then \
        mv /etc/apt/sources.list.ori /etc/apt/sources.list; \
    fi

RUN sed -ie 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/g' /etc/ssh/sshd_config \
    && sed -ie 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

###############################################################
# install hadoop

COPY ${APACHE_HADOOP_LOCAL_BINARY_PACKAGE} hadoop.tar.gz
RUN if [ ! -f "hadoop.tar.gz" ]; then \
        curl -L ${APACHE_HADOOP_REPOSITORY}/hadoop-${APACHE_HADOOP_VERSION}/hadoop-${APACHE_HADOOP_VERSION}.tar.gz --output hadoop.tar.gz; \
    fi

RUN mkdir -p ${HADOOP_HOME} \
    && tar -zxvf hadoop.tar.gz -C ${HADOOP_HOME} --strip-components 1 \
    && chown -R root:root ${HADOOP_HOME} \
    && rm -f hadoop.tar.gz

RUN bash -c "mkdir -p ${HADOOP_HOME}/{${HADOOP_TMP_FOLDER_NAME},${HADOOP_PID_FOLDER_NAME},${HADOOP_LOG_FOLDER_NAME}}"

###############################################################
# create group and users

# create hadoop group
RUN addgroup hadoop \
    && usermod -aG hadoop root

# for NameNode
RUN useradd -s ${USER_SHELL} -g hadoop nn \
    && echo "nn:hadoop" | chpasswd

# for Secondary NameNode
RUN useradd -s ${USER_SHELL} -g hadoop sn \
    && echo "sn:hadoop" | chpasswd

# for DataNode
RUN useradd -s ${USER_SHELL} -g hadoop dn \
    && echo "dn:hadoop" | chpasswd

# for Node Manager
RUN useradd -s ${USER_SHELL} -g hadoop nm \
    && echo "nm:hadoop" | chpasswd

# for Resource Manager
RUN useradd -s ${USER_SHELL} -g hadoop rm \
    && echo "rm:hadoop" | chpasswd

# for Timeline
RUN useradd -s ${USER_SHELL} -g hadoop tl \
    && echo "tl:hadoop" | chpasswd

# for Job History
RUN useradd -s ${USER_SHELL} -g hadoop jhs \
    && echo "jhs:hadoop" | chpasswd

# for HTTP
RUN useradd -s ${USER_SHELL} -g hadoop HTTP \
    && echo "HTTP:hadoop" | chpasswd


# for HDFS
RUN adduser --home ${HDFS_HOME} --shell ${USER_SHELL} --ingroup hadoop hdfs \
    && echo "hdfs:hadoop" | chpasswd

RUN mkdir -p ${HDFS_NAMENODE_FOLDER_PATH} \
    && chown hdfs:hadoop ${HDFS_NAMENODE_FOLDER_PATH} \
    && chmod 700 ${HDFS_NAMENODE_FOLDER_PATH}

RUN mkdir -p ${HDFS_NAMENODE_SECONDARY_FOLDER_PATH} \
    && chown sn:hadoop ${HDFS_NAMENODE_SECONDARY_FOLDER_PATH} \
    && chmod 750 ${HDFS_NAMENODE_SECONDARY_FOLDER_PATH}

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


######################################################################
# configure container-executor

# change container-executor permission
COPY --from=builder ${BUILD_OUTPUT_FOLDER}/container-executor ${HADOOP_HOME}/bin/container-executor
RUN chown root:hadoop ${HADOOP_HOME}/bin/container-executor
RUN chmod 6050 ${HADOOP_HOME}/bin/container-executor

# RUN cp -f ${HADOOP_HOME}/etc/hadoop/container-executor.cfg /etc/
COPY ${APACHE_HADOOP_CONF_FOLDER}/container-executor.cfg /etc/
RUN chown root:hadoop /etc/container-executor.cfg
RUN chmod 400 /etc/container-executor.cfg


###############################################################
# install spark
COPY ${APACHE_SPARK_LOCAL_BINARY_PACKAGE} spark.tgz
RUN if [ ! -f "spark.tgz" ]; then \
        curl -L ${APACHE_SPARK_REPOSITORY}/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-${APACHE_SPARK_FOR_HADOOP}.tgz --output spark.tgz; \
    fi

RUN mkdir -p ${SPARK_HOME} \
    && tar -zxvf spark.tgz -C ${SPARK_HOME} --strip-components 1 \
    && rm -f spark.tgz


###############################################################
# copy scripts
COPY ./start-services.sh /usr/local/bin/start-services
RUN chmod 744 /usr/local/bin/start-services

ENTRYPOINT /usr/local/bin/start-services && ${SPARK_HOME}/sbin/start-all.sh && tail -f /dev/null
