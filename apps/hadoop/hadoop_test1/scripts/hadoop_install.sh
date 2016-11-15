#!/bin/bash

. ${APP_ROOT}/toolset/setup/basic_cmd.sh

######################################################################################
# Notes:
#  To install Hadoop
#
#####################################################################################
BUILD_DIR="./"$(tool_get_build_dir $1)
SERVER_FILENAME=$1
INSTALL_DIR="/home/hadoop"
TARGET_DIR=$(tool_get_first_dirname ${INSTALL_DIR})

#######################################################################################
if [ ! "$(tool_check_exists ${INSTALL_DIR}/${TARGET_DIR}/bin/hadoop)"  == 0 ]; then
      echo "Hadoop has been install successfully"
      exit 0
fi

####################################################################################
# Prepare for install
####################################################################################
${tool_add_sudo} useradd hadoop
${tool_add_sudo} passwd hadoop hadooptest
${tool_add_sudo} mkdir -p ${INSTALL_DIR}
${tool_add_sudo} chown hadoop.$(whoami) ${INSTALL_DIR}

tar -zxvf ${SERVER_FILENAME} -C ${INSTALL_DIR}
TARGET_DIR=$(tool_get_first_dirname ${BUILD_DIR})
source /etc/profile
echo "Finish install preparation......"

######################################################################################
# Install Hadoop
######################################################################################

if [ -z "$(grep HADOOP_INSTALL /etc/profile)" ] ; then
    echo "export HADOOP_INSTALL=${INSTALL_DIR}/${TARGET_DIR}" >> /etc/profile
    echo 'export PATH=${HADOOP_INSTALL}/bin:${HADOOP_INSTALL}/sbin:${PATH}' >> /etc/profile
    echo 'export HADOOP_MAPRED_HOME=${HADOOP_INSTALL}' >> /etc/profile
    echo 'export HADOOP_COMMON_HOME=${HADOOP_INSTALL}' >> /etc/profile
    echo 'export HADOOP_HDFS_HOME=${HADOOP_INSTALL}' >> /etc/profile
    echo 'export YARN_HOME=${HADOOP_INSTALL}' >> /etc/profile
    echo 'export HADOOP_COMMON_LIB_NATIVE_DIR=${HADOOP_INSTALL}/lib/native' >> /etc/profile
    echo 'export HADOOP_OPTS="-Djava.library.path=${HADDOP_INSTALL}/lib:${HADOOP_INSTALL}/lib/native"' >> /etc/profile
fi
source /etc/profile

#######################################################################################
#Update configuration

$(tool_add_sudo) mkdir -p /home/hadoop/tmp/dfs/data
$(tool_add_sudo) mkdir -p /home/hadoop/tmp/dfs/name

${HADOOP_INSTALL}/bin/hdfs namenode -format
${HADOOP_INSTALL}/sbin/start-all.sh

##########################################################################################
