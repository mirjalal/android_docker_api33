FROM debian
 
RUN apt-get update
RUN yes | apt-get upgrade
RUN yes | apt-get dist-upgrade
RUN yes | apt-get install apt-utils
RUN yes | apt-get install build-essential bridge-utils wget zip unzip
 
ENV UDIDS=""

#=====================
# Install android sdk
#=====================
ARG ANDROID_SDK_VERSION=8512546
ENV ANDROID_SDK_VERSION=$ANDROID_SDK_VERSION
ARG ANDROID_PLATFORM="android-33"
ARG BUILD_TOOLS="32.0.0"
ENV ANDROID_PLATFORM=$ANDROID_PLATFORM
ENV BUILD_TOOLS=$BUILD_TOOLS
 
# install adk
RUN mkdir -p /opt/adk
RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip
RUN unzip commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip -d /opt/adk
RUN rm commandlinetools-linux-${ANDROID_SDK_VERSION}_latest.zip

RUN cd $HOME
RUN wget https://download.java.net/java/GA/jdk11/9/GPL/openjdk-11.0.2_linux-x64_bin.tar.gz
RUN tar -xzf openjdk-11.0.2_linux-x64_bin.tar.gz
ENV JAVA_HOME=$HOME/jdk-11.0.2
ENV JAVA_HOME=$HOME/jdk-11.0.2/bin

ADD pkg.txt /sdk
RUN mkdir -p /root/.android
RUN touch /root/.android/repositories.cfg

RUN wget -q https://dl.google.com/android/repository/platform-tools-latest-linux.zip
RUN unzip platform-tools-latest-linux.zip -d /opt/adk
RUN rm platform-tools-latest-linux.zip
RUN yes | /opt/adk/tools/bin/sdkmanager --licenses
RUN yes | /opt/adk/tools/bin/sdkmanager "build-tools;${BUILD_TOOLS}" "platforms;${ANDROID_PLATFORM}"
RUN mkdir -p ${HOME}/.android/
ENV ANDROID_HOME /opt/adk
 
RUN mkdir -p ${HOME}/repo
RUN git clone https://github.com/mirjalal/Structure.git -b master "structure"
RUN cd structure
RUN chmod +x ./gradlew
RUN ./gradlew kspDebugKotlin
RUN ./gradlew kspReleaseKotlin
RUN ./gradlew check
RUN ./gradlew build
RUN ./gradlew test
