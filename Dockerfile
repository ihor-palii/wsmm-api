FROM openjdk:8-jdk-slim


ENV MULE_HOME=/opt/mule \
    MULE_VERSION=4.4.0 \
    MULE_EE_SHA_256=6b546dbb1cd319a6c5df07b88814d2f0c39f1efb7204f47faa5c898d359fd289 \
    TZ=America/Phoenix \
    MULE_USER=mule

# SSL Cert for downloading mule zip
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y ca-certificates openssl tzdata unzip wget gettext libgettextpo-dev procps && \
    update-ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Project dependency
ENV MAVEN_VERSION 3.5.4
ENV MAVEN_HOME /usr/lib/mvn
ENV PATH $MAVEN_HOME/bin:$PATH
RUN wget http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
  tar -zxvf apache-maven-$MAVEN_VERSION-bin.tar.gz && \
  rm apache-maven-$MAVEN_VERSION-bin.tar.gz && \
  mv apache-maven-$MAVEN_VERSION /usr/lib/mvn

# RUN adduser -D -g "" ${MULE_USER} ${MULE_USER}
RUN useradd -m -U ${MULE_USER}

RUN mkdir ${MULE_HOME} && \
    mkdir ${MULE_HOME}/source && \
    chown ${MULE_USER}:${MULE_USER} -R /opt/mule*

RUN echo ${TZ} > /etc/timezone
USER ${MULE_USER}

# Copy and Install Mule Runtime Environment
COPY mule-ee-distribution-standalone-4.4.0-20230822.zip /home/mule
RUN cd ~ && echo "${MULE_EE_SHA_256}  mule-ee-distribution-standalone-4.4.0-20230822.zip" | sha256sum -c && \
    unzip mule-ee-distribution-standalone-4.4.0-20230822.zip && \
    mv -v ~/mule-enterprise-standalone-4.4.0-20230822/* ${MULE_HOME} && \
    rm ~/mule-ee-distribution-standalone-4.4.0-20230822.zip && \
    rm -r ~/mule-enterprise-standalone-4.4.0-20230822

# Copy and Build WSMM Mule Project
COPY . ${MULE_HOME}/source
RUN cd ${MULE_HOME}/source && \ 
    mvn clean package -DattachMuleSources && \
    mv ${MULE_HOME}/source/target/wsmm-1.0.0-SNAPSHOT-mule-application.jar ${MULE_HOME}/apps/

# Define working directory.
WORKDIR ${MULE_HOME}

CMD [ "/opt/mule/bin/mule"]
# CMD ["tail", "-f", "/dev/null"]

# Default http port
EXPOSE 8081
