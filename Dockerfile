FROM centos:7

MAINTAINER tuteng <eguangning@gmail.com>

# root password
RUN echo 'root:helloworld' | chpasswd

# 为解决Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY问题
RUN rpm --import /etc/pki/rpm-gpg/RPM*

RUN \
    yum -y install \
        openssh openssh-server openssh-clients \
        sudo passwd wget &&\
        yum clean all

# 设置sshd
RUN sshd-keygen
RUN sed -i "s/#UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
RUN sed -i "s/UsePAM.*/UsePAM no/g" /etc/ssh/sshd_config

ADD jdk-8u201-linux-x64.tar.gz /usr/local/

RUN mv /usr/local/jdk1.8.0_201 /usr/local/jdk1.8

ENV JAVA_HOME /usr/local/jdk1.8
ENV PATH $JAVA_HOME/bin:$PATH

RUN mkdir /var/run/sshd

RUN yum -y install which && yum clean all

#下载Hadoop
ADD hadoop-2.9.2.tar.gz /opt/
RUN mv /opt/hadoop-2.9.2 /usr/local/hadoop-2.9.2
RUN cd /usr/local && ln -s ./hadoop-2.9.2 hadoop

ENV HADOOP_HOME /usr/local/hadoop
ENV HADOOP_PREFIX /usr/local/hadoop
ENV HADOOP_COMMON_HOME /usr/local/hadoop
ENV HADOOP_HDFS_HOME /usr/local/hadoop
ENV HADOOP_MAPRED_HOME /usr/local/hadoop
ENV HADOOP_YARN_HOME /usr/local/hadoop
ENV HADOOP_CONF_DIR /usr/local/hadoop/etc/hadoop
ENV YARN_CONF_DIR $HADOOP_PREFIX/etc/hadoop

ENV PATH $HADOOP_HOME/bin:$PATH

RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

ENV HIVE_HOME=/usr/local/hive

#下载安装hive
RUN wget http://mirror.bit.edu.cn/apache/hive/hive-1.2.2/apache-hive-1.2.2-bin.tar.gz && \
     tar -zvxf apache-hive-1.2.2-bin.tar.gz -C /usr/local/ && \
     mv /usr/local/apache-hive-1.2.2-bin /usr/local/hive && \
     rm apache-hive-1.2.2-bin.tar.gz

#下载mysql依赖包
RUN wget http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.39.tar.gz && \
    tar -zvxf mysql-connector-java-5.1.39.tar.gz -C /usr/local/ && \
    mv /usr/local/mysql-connector-java-5.1.39/mysql-connector-java-5.1.39-bin.jar $HIVE_HOME/lib/ && \
    rm -rf /usr/local/mysql-connector-java-5.1.39

RUN mkdir -p /usr/hive/warehouse && mkdir -p /usr/hive/log

ENV PATH=$PATH:$HIVE_HOME/bin:.

CMD ["/usr/sbin/sshd", "-D"]
