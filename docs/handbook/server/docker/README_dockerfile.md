FROM ubuntu
MAINTAINER Michael Crosby <michael@crosbymichael.com>
RUN echo "deb http://archive.ubuntu.com/ubuntu precise main universe" > /etc/apt/sources.list
RUN apt-get update
RUN apt-get upgrade -y


====

From centos:6.8
MAINTAINER Jesse <jesse@8ops.cc>
RUN echo "Hello Docker file "
# RUN yum install -y -q vim
RUN yum install -y -q nc
EXPOSE 2222:10000
ENTRYPOINT ["nc -k -l 10000 &"]
CMD [";date"]

docker build -t="xtso520ok/centos:6.8_2016102804" .
docker run -t -i xtso520ok/centos:6.8_2016102804 test_nc_port


docker exec -i -t loving_heisenberg /bin/bash


ADD your.war /usr/local/tomcat/webapps/
CMD ["catalina.sh", "run"]

docker run --rm -it -p 8080:8080 yourName


ADD pom.xml /tmp/build/
RUN cd /tmp/build && mvn -q dependency:resolve

ADD src /tmp/build/src
        #构建应用
RUN cd /tmp/build && mvn -q -DskipTests=true package \
        #拷贝编译结果到指定目录
        && rm -rf $CATALINA_HOME/webapps/* \
        && mv target/*.war $CATALINA_HOME/webapps/ROOT.war \
        #清理编译痕迹
        && cd / && rm -rf /tmp/build

EXPOSE 8080
CMD ["catalina.sh","run"]



docker commit abeabc76a38f xtso520ok/tomcat:6.0.35_1.6.0_27











