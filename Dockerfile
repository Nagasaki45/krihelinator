FROM bitwalker/alpine-elixir-phoenix:1.4.0

RUN apk add --no-cache bash

###### GLIBC ######
# Necessary for conda / python
# Based on https://github.com/frol/docker-alpine-glibc
RUN BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    VERSION="2.23-r3" && \
    apk add --no-cache --virtual=.build-dependencies ca-certificates && \
    wget --quiet \
        "https://raw.githubusercontent.com/andyshinn/alpine-pkg-glibc/master/sgerrand.rsa.pub" \
        -O "/etc/apk/keys/sgerrand.rsa.pub" && \
    wget --quiet \
        "$BASE_URL/$VERSION/glibc-$VERSION.apk" \
        "$BASE_URL/$VERSION/glibc-bin-$VERSION.apk" \
        "$BASE_URL/$VERSION/glibc-i18n-$VERSION.apk" && \
    apk add --no-cache ./glibc*.apk && \
    rm "/etc/apk/keys/sgerrand.rsa.pub" && \
    /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 C.UTF-8 || true && \
    echo "export LANG=C.UTF-8" > /etc/profile.d/locale.sh && \
    apk del glibc-i18n && \
    apk del .build-dependencies && \
    rm glibc*.apk

ENV LANG=C.UTF-8
###### /GLIBC ######

###### CONDA ######
ENV CONDA_DIR=/opt/conda
ENV PATH=$CONDA_DIR/bin:$PATH

RUN mkdir -p $CONDA_DIR && \
    wget --quiet "https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh" -O mconda.sh && \
    bash mconda.sh -f -b -p $CONDA_DIR && \
    rm mconda.sh
###### /CONDA ######

###### KRIHELINATOR ######
RUN conda install \
        pandas=0.19.2

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
