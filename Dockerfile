FROM ubuntu:20.04 as base_with_curl
RUN apt-get update && \
    apt-get install --yes --no-install-recommends \
      curl wget software-properties-common

# ---

FROM base_with_curl as intellij_idea

ARG IDEA_VERSION=2022.2
ARG IDEA_BUILD=2022.2.1
ARG idea_source=https://download.jetbrains.com/idea/ideaIC-${IDEA_BUILD}.tar.gz

WORKDIR /opt/idea

RUN curl -fsSL $idea_source -o /opt/idea/installer.tgz && \
    tar --strip-components=1 -xzvf installer.tgz

# ---

FROM base_with_curl as base_ubuntu

ENV TZ=Europe/London
RUN \
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && \
  apt-get install --no-install-recommends --yes \
    gcc git openssh-client less xz-utils \
    libxtst-dev libxext-dev libxrender-dev libfreetype6-dev \
    libfontconfig1 libgtk2.0-0 libxslt1.1 libxxf86vm1 \
    libgtk-3-0 libcanberra-gtk-module libcanberra-gtk3-module libx11-xcb1 libdbus-glib-1-2 \
    && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/* && \
  useradd -ms /bin/bash developer

# ---

FROM base_with_curl as firefox
ARG FIREFOX_VERSION=104.0.2
ARG FILEFOX_URL=https://download-installer.cdn.mozilla.net/pub/firefox/releases/${FIREFOX_VERSION}/linux-x86_64/en-US/firefox-${FIREFOX_VERSION}.tar.bz2

RUN wget --no-verbose -O /tmp/firefox.tar.bz2 ${FILEFOX_URL} \
  && rm -rf /opt/firefox \
  && tar -C /opt -xjf /tmp/firefox.tar.bz2 \
  && rm /tmp/firefox.tar.bz2 

# ---

FROM base_with_curl as developer_with_nvm
RUN useradd -ms /bin/bash developer
USER developer
ENV HOME /home/developer

RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash && \
  export NVM_DIR=/home/developer/.nvm && . ~/.nvm/nvm.sh && \
  nvm install node && \
  npm install -g pnpm && \
  npm install -g vue-language-server && \
  npm install -g bash-language-server

# ---

FROM base_ubuntu
ARG idea_local_dir=.IdeaIC${IDEA_VERSION}

ENV JAVA_HOME=/opt/java/openjdk
ENV PATH="${JAVA_HOME}/bin:${PATH}"
COPY --from=eclipse-temurin:17 ${JAVA_HOME} ${JAVA_HOME}
COPY --from=intellij_idea /opt/idea /opt/idea
COPY --from=firefox /opt/firefox /opt/firefox
RUN ln -fs /opt/firefox/firefox /usr/bin/firefox

USER developer
ENV HOME /home/developer
COPY --from=developer_with_nvm /home/developer /home/developer
RUN mkdir /home/developer/.Idea && ln -sf /home/developer/.Idea /home/developer/${idea_local_dir}

CMD [ "/opt/idea/bin/idea.sh" ]

