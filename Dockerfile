# import from Docker Hub ---------------------------------------------------- #
# ------ ---- ------ --- ---------------------------------------------------- #
FROM debian:latest
FROM openjdk:11


# Set environmental variables ----------------------------------------------- #
# refer to the table on https://github.com/Hellikandra/ATAK-Dev-Docker        #
# --- ------------- --------- ----------------------------------------------- #
ENV username atakdev

ENV cmake_release_version cmake-3.26.0-linux-x86_64
ENV cmake_release_link https://cmake.org/files/v3.26/${cmake_release_version}.tar.gz

ENV ndk_release_version android-ndk-r12b-linux-x86_64.zip
ENV ndk_release_dl_link https://dl.google.com/android/repository/${ndk_release_version}
ENV ndk_release_folder android-ndk-r12b

# keep an older version of commandlinetools due to Java version issues
# Current version is : commandlinetools-linux-10406996_latest.zip
# Old version is : commandlinetools-linux-9477386_latest.zip
ENV sdk_release_version commandlinetools-linux-9477386_latest.zip
ENV sdk_manager_build_tools "build-tools;30.0.2"
ENV sdk_manager_platforms "platforms;android-30"

ENV atak_release_version atak-civ-sdk-4.6.0.5.zip
ENV atak_extract_foldername atak-civ

# Set root for installation and configuration ------------------------------- #
# --- ---- --- ------------ --- ------------- ------------------------------- # 
USER root
RUN echo "root:pswd" | chpasswd


# install essential --------------------------------------------------------- #
# ------- --------- --------------------------------------------------------- #
RUN dpkg --add-architecture i386
RUN apt-get update -y && apt-get install -yq \
    ant \
    apg \
    autoconf \
    automake \
    bash \
    build-essential \
    cmake \
    curl \
    dos2unix \
    file \
    g++ \
    git \
    git-lfs \
    gnupg \
    libogdi-dev \
    libssl-dev \
    libtool \
    libxml2-dev \
    make \
    nano \
    ninja-build \
    patch \
    python3-pip \
    sqlite3 \
    swig \
    tcl \
    unzip \
    wget \
    zip \
    zlib1g-dev


# add user ------------------------------------------------------------------ #
# --- ---- ------------------------------------------------------------------ #
RUN useradd -rm -d /home/${username} -s /bin/bash -g root -G sudo -u 1001 ${username}
RUN echo "${username}:atakatak" | chpasswd
USER ${username}


# cmake installation -- from : https://cmake.org/files/ --------------------- #
# ----- ------------ -- ---- - ------------------------ --------------------- #
WORKDIR /home/${username}
RUN wget ${cmake_release_link}
RUN tar -xvzf ${cmake_release_version}.tar.gz
RUN mv ${cmake_release_version} cmake
RUN rm ${cmake_release_version}.tar.gz


# Android Studio suite ------------------------------------------------------ #
# ------- ------ ----- ------------------------------------------------------ #
# NDK installation ---------------------------------------------------------- #
WORKDIR /home/${username}/Android
RUN wget ${ndk_release_dl_link}
RUN unzip -q ${ndk_release_version}
RUN mv ${ndk_release_folder} ndk
RUN rm ${ndk_release_version}

# SDK installation ---------------------------------------------------------- #
WORKDIR /home/${username}/Android/sdk
RUN wget https://dl.google.com/android/repository/${sdk_release_version}
RUN unzip -q ${sdk_release_version}
RUN rm ${sdk_release_version}
WORKDIR /home/${username}/Android/sdk/cmdline-tools/bin
RUN yes | ./sdkmanager --sdk_root="/home/${username}/Android/sdk" --licenses
RUN ./sdkmanager --sdk_root="/home/${username}/Android/sdk" ${sdk_manager_build_tools} ${sdk_manager_platforms} "platform-tools"


# ATAK installation --------------------------------------------------------- #
# ---- ------------ --------------------------------------------------------- #
# https://github.com/deptofdefense/AndroidTacticalAssaultKit-CIV/releases --- #
WORKDIR /home/${username}
COPY --chown=${username}:root ${atak_release_version} ./
RUN unzip ${atak_release_version}
#RUN mv ${atak_extract_foldername} atak-civ
RUN rm ${atak_release_version}

# https://tak.gov/products/atak-civ ----------------------------------------- #

# ATAK folder configuration ------------------------------------------------- #
# ---- ------ ------------- ------------------------------------------------- #
WORKDIR /home/${username}/atak-civ
COPY --chown=${username}:root atak-config.sh ./


# define the plugins folder ------------------------------------------------- #
# ------ --- ------- ------ ------------------------------------------------- #
ADD ./plugins ./plugins

USER root
RUN chown -R ${username}:root ./plugins
USER ${username}
# intentionally left blank to ensure that no error appears during the build.
RUN /bin/bash ./atak-config.sh


# start --------------------------------------------------------------------- #
# ----- --------------------------------------------------------------------- #
CMD ["bash"]


# command line -------------------------------------------------------------- #
# ------- ---- -------------------------------------------------------------- #
# docker build -t <name> .
# docker run -ti -v <path_of_plugins_folder>:/home/username/atak-civ/plugins <name> --name <container_name> --bind 127.0.0.1 --port 5555