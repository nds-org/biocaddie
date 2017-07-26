FROM ndslabs/indri

RUN apt-get -qq update && \
    apt-get -qq install --no-install-recommends \
      redis-tools \
      python \
      python-pip && \
    pip install redis && \
    apt-get -qq autoremove && \
    apt-get -qq autoclean && \
    apt-get -qq clean all && \
    rm -rf /var/cache/apk/*

ADD https://kubernetes.io/docs/tasks/job/fine-parallel-processing-work-queue/rediswq.py?raw=true ./rediswq.py
COPY worker.py ./worker.py
COPY queries /queries

CMD [ "./worker.py" ]
