FROM debian:buster-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /usr/share/man/man1 /usr/share/man/man2
 
RUN apt-get update
RUN yes | apt-get upgrade
RUN yes | apt-get dist-upgrade
RUN yes | apt-get install apt-utils
RUN yes | apt-get install build-essential bridge-utils wget zip unzip openjdk-11-jdk

RUN java --version

ENV UDIDS=""

# RUN update-alternatives --list java

#=====================
# Install android sdk
#=====================
ARG ANDROID_SDK_VERSION=8512546
ENV ANDROID_SDK_VERSION=$ANDROID_SDK_VERSION
ARG ANDROID_PLATFORM="android-33"
ARG BUILD_TOOLS="32.0.0"
ENV ANDROID_PLATFORM=$ANDROID_PLATFORM
ENV BUILD_TOOLS=$BUILD_TOOLS
 
# RUN cd $HOME
# RUN wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz \
#     && tar -xzf openjdk-11.0.2_linux-x64_bin.tar.gz \
#     && export JAVA_HOME="$(dirname $(dirname $(readlink -f $(which java))))"

ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/
RUN echo $JAVA_HOME
RUN export PATH=$PATH:${JAVA_HOME}/bin

# install android stuff
RUN mkdir -p /opt/adk \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip \
    && unzip commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip -d /opt/adk \
    && rm commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip

ADD pkg.txt /sdk
RUN mkdir -p /root/.android
RUN touch /root/.android/repositories.cfg

RUN cd /opt/adk && mkdir tools && mv cmdline-tools tools && mv tools cmdline-tools && cd cmdline-tools && mv cmdline-tools tools
RUN cd /opt/adk/cmdline-tools/tools/bin && yes | ./sdkmanager --licenses && yes | ./sdkmanager "build-tools;${BUILD_TOOLS}" "platforms;${ANDROID_PLATFORM}"
RUN mkdir -p ${HOME}/.android/
ENV ANDROID_HOME /opt/adk

# RUN mkdir -p ${HOME}/repo/mirjalal
# RUN cd ${HOME}/repo/mirjalal
# RUN git clone https://github.com/mirjalal/Structure.git -b master "structure"
# RUN cd structure
# RUN chmod +x ./gradlew
# RUN ./gradlew kspDebugKotlin
# RUN ./gradlew kspReleaseKotlin
# RUN ./gradlew check
# RUN ./gradlew build
# RUN ./gradlew test
