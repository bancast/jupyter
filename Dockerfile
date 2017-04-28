FROM alpine:3.5
MAINTAINER Jack Stephenson <docker@bancast.net>

RUN mkdir -p /app
WORKDIR /app

ONBUILD COPY requirements.txt requirements.txt

ONBUILD RUN apk add --no-cache --virtual .build-deps \
  build-base python3 libffi-dev \
    && pip install -r requirements.txt \
    && find /usr/local \
        \( -type d -a -name test -o -name tests \) \
        -o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
        -exec rm -rf '{}' + \
    && runDeps="$( \
        scanelf --needed --nobanner --recursive /usr/local \
                | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                | sort -u \
                | xargs -r apk info --installed \
                | sort -u \
    )" \
    && apk add --virtual .rundeps $runDeps \
    && apk del .build-deps

ONBUILD COPY examples examples

CMD ["jupyter", "notebook"]
