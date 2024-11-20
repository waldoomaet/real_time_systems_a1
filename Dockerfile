FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    gnat \
    gdb \
    make \
    git \
    nano \
    && rm -rf /var/lib/apt/lists/*


WORKDIR /workspace
EXPOSE 2345
ENTRYPOINT ["/bin/bash"]