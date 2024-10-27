#!/usr/bin/env bash

# Apache Hadoop Download Mirrors
#   https://downloads.apache.org/hadoop/common              - Global
#   https://mirror-hk.koddos.net/apache/hadoop/common       - HK
#   https://mirrors.bfsu.edu.cn/apache/hadoop/common        - China

# if use buildx (https://github.com/docker/buildx/issues/484)
# following options are used to disable log clipping
#   --driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10485760,env.BUILDKIT_STEP_LOG_MAX_SPEED=100000000
# otherwise, following output will be shown when log size larger than 1MB by default
#   => => # [output clipped, log limit 1MiB reached]

docker buildx create --use --name larger_log \
--driver-opt env.BUILDKIT_STEP_LOG_MAX_SIZE=10485760,env.BUILDKIT_STEP_LOG_MAX_SPEED=100000000

docker buildx build --load -t hadoop . \
--build-arg HADOOP_VERSION=3.2.1 \
--build-arg APAHCHE_HADOOP_REPOSITORY=https://mirror-hk.koddos.net/apache/hadoop/common \
--build-arg APT_SOURCES_LIST_FILE=./sources.list.ustc

docker buildx rm larger_log
