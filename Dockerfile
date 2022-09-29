FROM openjdk/openjdk11@sha256:3262629245da5917039afcbb98dc0c84c6a6e319c1dc9c87f03656505e168a19
 
RUN apt-get update -qqy && apt-get upgrade && apt-get -qqy install libglu1 build-essential virtinst bridge-utils
 
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
RUN mkdir -p /opt/adk \
    && wget -q https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_VERSION}.zip \
    && unzip sdk-tools-linux-${ANDROID_SDK_VERSION}.zip -d /opt/adk \
    && rm sdk-tools-linux-${ANDROID_SDK_VERSION}.zip

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
