FROM python:3.13-alpine

LABEL "com.github.actions.name"="S3 Sync"
LABEL "com.github.actions.description"="Sync a directory to an AWS S3 repository"
LABEL maintainer="platform@intelerad.com"
ENV AWSCLI_VERSION='1.29.62'

RUN pip install --quiet --no-cache-dir awscli==${AWSCLI_VERSION}

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]