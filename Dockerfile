FROM bitwalker/alpine-elixir-phoenix:latest

# Probably missing from the original image...
RUN apk --no-cache add erlang-eunit

# Needed for live reload in development
RUN apk --no-cache add inotify-tools

###### CONDA ######
# Copied from https://github.com/CognitiveScale/alpine-miniconda/
RUN apk --update  --repository http://dl-4.alpinelinux.org/alpine/edge/community add \
    bash \
    git \
    curl \
    ca-certificates \
    bzip2 \
    unzip \
    sudo \
    libstdc++ \
    glib \
    libxext \
    libxrender \
    tini \
    && curl -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.23-r1/glibc-2.23-r1.apk" -o /tmp/glibc.apk \
    && curl -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.23-r1/glibc-bin-2.23-r1.apk" -o /tmp/glibc-bin.apk \
    && curl -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.23-r1/glibc-i18n-2.23-r1.apk" -o /tmp/glibc-i18n.apk \
    && apk add --allow-untrusted /tmp/glibc*.apk \
    && /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib \
    && /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8 \
    && rm -rf /tmp/glibc*apk /var/cache/apk/*

# Configure environment
ENV CONDA_DIR=/opt/conda CONDA_VER=4.0.5
ENV PATH=$CONDA_DIR/bin:$PATH SHELL=/bin/bash LANG=C.UTF-8

# Install conda
RUN mkdir -p $CONDA_DIR && \
    echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh && \
    curl https://repo.continuum.io/miniconda/Miniconda3-${CONDA_VER}-Linux-x86_64.sh  -o mconda.sh && \
    /bin/bash mconda.sh -f -b -p $CONDA_DIR && \
    rm mconda.sh && \
    $CONDA_DIR/bin/conda install --yes conda==${CONDA_VER}
###### /CONDA ######

RUN conda install pandas

# Cache elixir deps
ADD mix.exs mix.lock ./
# Always compile into _build/prod
RUN MIX_ENV=prod mix do deps.get, deps.compile

# Add the source code
COPY config ./config
COPY lib ./lib
COPY priv ./priv
COPY python ./python
COPY web ./web

# Compile the krihelinator (again, to _build/prod)
RUN MIX_ENV=prod mix compile

# Finally run the server
CMD mix phoenix.server
