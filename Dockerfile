FROM openjdk:8-jdk


# ANDROID_COMPILE_SDK is the version of Android you're compiling with.
# It should match compileSdkVersion.
ENV ANDROID_COMPILE_SDK="28"

# ANDROID_BUILD_TOOLS is the version of the Android build tools you are using.
# It should match buildToolsVersion.
ENV ANDROID_BUILD_TOOLS="27.0.3"

# It's what version of the command line tools we're going to download from the official site.
# Official Site-> https://developer.android.com/studio/index.html
# There, look down below at the cli tools only, sdk tools package is of format:
#        commandlinetools-os_type-ANDROID_SDK_TOOLS_latest.zip
# when the script was last modified for latest compileSdkVersion, it was which is written down below
ENV ANDROID_SDK_TOOLS="6514223"


RUN apt --quiet update --yes
RUN apt --quiet install --yes wget tar unzip lib32stdc++6 lib32z1
RUN apt-get update && apt-get -y install sudo
RUN apt-get update -yqq
RUN curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
RUN apt-get install -y nodejs
RUN npm -v

      # Setup path as android_home for moving/exporting the downloaded sdk into it
ENV ANDROID_HOME="${PWD}/android-home"
      # Create a new directory at specified location
RUN install -d $ANDROID_HOME
      # Here we are installing androidSDK tools from official source,
      # (the key thing here is the url from where you are downloading these sdk tool for command line, so please do note this url pattern there and here as well)
      # after that unzipping those tools and
      # then running a series of SDK manager commands to install necessary android SDK packages that'll allow the app to build
RUN wget --output-document=$ANDROID_HOME/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip
      # move to the archive at ANDROID_HOME
RUN pushd $ANDROID_HOME
RUN unzip -d cmdline-tools cmdline-tools.zip
RUN popd
ENV PATH=$PATH:${ANDROID_HOME}/cmdline-tools/tools/bin/

      # Nothing fancy here, just checking sdkManager version
RUN sdkmanager --version

      # use yes to accept all licenses
RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses || true
RUN sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-${ANDROID_COMPILE_SDK}"
RUN sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools"
RUN sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;${ANDROID_BUILD_TOOLS}"

RUN export ANDROID_SDK_ROOT="$ANDROID_HOME"

RUN sudo apt install zip unzip -y

RUN curl -s "https://get.sdkman.io" | bash
RUN source "$HOME/.sdkman/bin/sdkman-init.sh"
RUN sdk version
RUN sdk install gradle 6.8.3
RUN sudo apt install tree -y

RUN sudo apt install python -y
RUN sudo apt install jq -y

ENV CLOUDSDK_INSTALL_DIR=/home/ubuntu/programs/gcloud
RUN curl -sSL https://sdk.cloud.google.com | bash
RUN if [ -f '/home/ubuntu/programs/gcloud/google-cloud-sdk/path.bash.inc' ]; then . '/home/ubuntu/programs/gcloud/google-cloud-sdk/path.bash.inc'; fi
RUN if [ -f '/home/ubuntu/programs/gcloud/google-cloud-sdk/completion.bash.inc' ]; then . '/home/ubuntu/programs/gcloud/google-cloud-sdk/completion.bash.inc'; fi