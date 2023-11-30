
#!/bin/bash

set -o allexport

# HOSTS
CONTROL_HOST=192.168.1.17
BENCHMARK_HOST=192.168.1.18
CLIENT1_HOST=192.168.1.19

HTTPD_HOST=192.168.1.10
TOMCAT1_HOST=192.168.10.31
MYSQL1_HOST=192.168.10.32

FRONT_HOST=192.168.1.10
CART_HOST=192.168.1.13
CATALOGUE_HOST=192.168.1.11
USER_HOST=192.168.1.15


# Experiment name on Emulab
EMULAB_EXPERIMENT_NAME=rubbos.elba.cc.gatech.edu
EXPERIMENT_CONFIG=111-xgu-AP150-TP50-DP10
EXPERIMENT_CONFIG_TIERS=3

# Directories from which files are copied
WORK_HOME=/root/SockShop
OUTPUT_HOME=/root/SockShop/output
SOFTWARE_HOME=/home/xgu/rubbos/software

# Output directory for results of RUBBoS benchmark
RUBBOS_RESULTS_HOST=node-7
RUBBOS_RESULTS_DIR_BASE=/root/sockshopResult
RUBBOS_RESULTS_DIR_NAME=2021-03-16T-cloudLab-first-WL1000

# Output directory for results of RUBBoS benchmark on Bonn and SysViz servers
BONN_HOST=node-7
BONN_RUBBOS_RESULTS_DIR_BASE=/root/sockshopResult
BONN_SCRIPTS_BASE=/root/rubbosResult/scripts_limit


SYSVIZ_HOST=qywang@incheon.cc.gt.atl.ga.us
SYSVIZ_RUBBOS_RESULTS_DIR_BASE=/home/qywang/AnaResult-CA





# Target directories
ELBA_TOP=/root/elba
RUBBOS_TOP=$ELBA_TOP/rubbos
TMP_RESULTS_DIR_BASE=/root/elba/rubbos/results
RUBBOS_HOME=/root/elba/rubbos/RUBBoS
SYSSTAT_HOME=/home/xgu/elba/rubbos/sysstat-10.0.2
HTTPD_HOME=/home/xgu/elba/rubbos/apache2
HTTPD_INSTALL_FILES=$RUBBOS_TOP/httpd-2.2.31
MOD_JK_INSTALL_FILES=$RUBBOS_TOP/tomcat-connectors-1.2.46-src
CATALINA_HOME=/home/xgu/elba/rubbos/apache-tomcat-7.0.99
CATALINA_BASE=$CATALINA_HOME
CJDBC_HOME=$RUBBOS_TOP/c-jdbc-2.0.2-bin
MYSQL_HOME=$RUBBOS_TOP/mysql-5.5.54-linux2.6-x86_64
JONAS_ROOT=$RUBBOS_TOP/JONAS_4_6_6

# Java & Ant
JAVA_HOME=/root/elba/rubbos/jdk1.8.0_241
JAVA_OPTS="-Xmx1300m"
J2EE_HOME=/root/elba/rubbos/j2sdkee1.3.1
ANT_HOME=$RUBBOS_TOP/apache-ant-1.6.5

# Tarballs
JAVA_TARBALL=jdk-8u241-linux-x64.tar.gz
J2EE_TARBALL=j2sdkee1.3.1.jar.gz
ANT_TARBALL=apache-ant-1.6.5.tar.gz
SYSSTAT_TARBALL=sysstat-10.0.2.tar.gz
HTTPD_TARBALL=httpd-2.2.31.tar.gz
MOD_JK_TARBALL=tomcat-connectors-1.2.46-src.tar.gz
TOMCAT_TARBALL=apache-tomcat-7.0.99.tar.gz
CJDBC_TARBALL=c-jdbc-2.0.2-bin-modified.tar.gz
MYSQL_TARBALL=mysql-5.5.54-linux2.6-x86_64.tar.gz
RUBBOS_TARBALL=RUBBoS-servlets.tar.gz
RUBBOS_DATA_TARBALL=rubbos_data.tar.gz
RUBBOS_DATA_TEXTFILES_TARBALL=smallDB-rubbos-modified.tgz

# for MySQL
MYSQL_CONNECTOR=mysql-connector-java-5.1.19-bin.jar
MYSQL_PORT=3313
MYSQL_SOCKET=$MYSQL_HOME/mysql.sock
MYSQL_DATA_DIR=$MYSQL_HOME/data
MYSQL_ERR_LOG=$MYSQL_HOME/data/mysql.log
MYSQL_PID_FILE=$MYSQL_HOME/run/mysqld.pid

# for DBs & C-JDBC
ROOT_PASSWORD=lsu2015
ELBA_USER=elba
ELBA_PASSWORD=elba


#CLASSPATH=$CLASSPATH:$JONAS_ROOT/bin/unix/registry:$JAVA_HOME:$JAVA_HOME/lib/tools.jar:$CATALINA_HOME/common/lib/servlet-api.jar:.:$RUBBOS_HOME/Servlet_HTML/WEB-INF/lib/log4j.jar
CLASSPATH=$CLASSPATH:$JONAS_ROOT/bin/unix/registry:$JAVA_HOME:$JAVA_HOME/lib/tools.jar:$CATALINA_HOME/lib/servlet-api.jar:.:$RUBBOS_HOME/Servlet_HTML/WEB-INF/lib/log4j.jar

PATH=$JAVA_HOME/bin:$JONAS_ROOT/bin/unix:$ANT_HOME/bin:$CATALINA_HOME/bin:$PATH
set +o allexport

