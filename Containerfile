ARG java_image_tag=17-jammy
ARG unity_version="0.2.0-SNAPSHOT"
ARG unity_uid=185

FROM eclipse-temurin:${java_image_tag} AS packages

ARG sbt_args="-J-Xmx2G"
#ARG mysql_uri=https://dev.mysql.com/get/Downloads/Connector-J
ARG mysql_uri=http://10.10.10.65/pub/mysql
ARG mysql_cj_version=8.4.0
ARG unity_version

RUN set -ex && \
    apt-get update && \
    ln -s /lib /lib64 && \
    apt install -y bash git

#RUN curl -L https://github.com/unitycatalog/unitycatalog/archive/refs/tags/v${unity_version}.tar.gz | \
RUN curl -L http://10.10.10.65/pub/unitycatalog/unitycatalog-${unity_version}.tar.gz | \
    tar xvz -C /opt/ && \
    ln -s /opt/unitycatalog-${unity_version} /opt/unitycatalog

WORKDIR /opt/unitycatalog

RUN build/sbt ${sbt_args} server/package
RUN ./docker/copy_jars_from_classpath.sh server/target/jars

RUN curl -L ${mysql_uri}/mysql-connector-j-${mysql_cj_version}.tar.gz \
	| tar xvz -C /opt/ \
	&& mv /opt/mysql-connector-j-${mysql_cj_version}/mysql-connector-j-${mysql_cj_version}.jar server/target/jars/

# --------------------------------------------

FROM eclipse-temurin:${java_image_tag} AS uc
ARG unity_uid
ARG unity_version

ENV UNITY_HOME "/opt/unitycatalog"
EXPOSE 8080 8081

RUN set -ex && \
    apt-get update && \
    ln -s /lib /lib64 && \
    apt install -y bash coreutils curl libc6 libpam-modules libnss3 procps net-tools tini && \
    rm /bin/sh && \
    ln -sv /bin/bash /bin/sh && \
    useradd -u ${unity_uid} -d /opt/unitycatalog unity && \
    echo "auth required pam_wheel.so use_uid" >> /etc/pam.d/su && \
    chgrp root /etc/passwd && chmod ug+rw /etc/passwd && \
    rm -rf /var/cache/apt/* && rm -rf /var/lib/apt/lists/* 

COPY --from=packages /opt/unitycatalog /opt/unitycatalog
COPY entrypoint.sh /opt/

WORKDIR /opt/unitycatalog

RUN chown -R unity:unity /opt/unitycatalog && \
    chmod a+x /opt/entrypoint.sh && \
    ln -s server/target/jars ./jars && \
    cp server/target/unitycatalog-server-${unity_version}.jar ./jars/ 

ENTRYPOINT [ "/opt/entrypoint.sh" ]

USER ${unity_uid}
 