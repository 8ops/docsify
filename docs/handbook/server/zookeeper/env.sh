export JAVA_HOME=/usr/local/jdk1.6
export JRE_HOME=$JAVA_HOME/jre
export M2_HOME=/usr/local/maven
export TOMCAT_HOME=/usr/local/tomcat6
export CATALINA_HOME=$TOMCAT_HOME
export CLASSPATH=.:$JAVA_HOME/lib:%JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar:$JRE_HOME/lib:$M2_HOME
export ZOOKEEPER_HOME=/usr/local/zookeeper-3.4.6/
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$M2_HOME/bin:${ZOOKEEPER_HOME}/conf:${ZOOKEEPER_HOME}/bin:$PATH

