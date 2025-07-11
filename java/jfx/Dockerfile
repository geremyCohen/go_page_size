FROM ubuntu:22.04
RUN apt-get update \
     && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
          openjdk-17-jdk \
          maven \
          git \
          cmake \
          build-essential \
          python3 \
          python3-pip \
          python3-dev \
          wget \
          libgtk-3-dev \
          libgl1-mesa-dev \
          gradle \
          libx11-dev libxext-dev libxrender-dev \
          libxtst-dev libxi-dev libxrandr-dev libxcursor-dev \
libxss-dev libxinerama-dev libfreetype6-dev libfontconfig1-dev  \
    libasound2-dev \
     && rm -rf /var/lib/apt/lists/* \
     && rm -rf /root/.gradle

WORKDIR /workspace
COPY install.sh /workspace/install.sh
RUN chmod +x /workspace/install.sh

CMD ["/workspace/install.sh"]
COPY install.sh /workspace/install.sh
RUN chmod +x /workspace/install.sh

CMD ["/workspace/install.sh"]