FROM findepi/graalvm:java17-all AS BUILDER
COPY ./ ./
RUN apt install curl -y && \
    curl -O https://dlcdn.apache.org/maven/maven-3/3.9.0/binaries/apache-maven-3.9.0-bin.tar.gz && \
    tar -xf apache-maven-3.9.0-bin.tar.gz && \
    apache-maven-3.9.0/bin/mvn -Pnative -Dagent clean package
#CMD ["target/my-app"]

FROM debian:stable-slim
COPY --from=BUILDER /target/my-app /my-app
COPY --from=BUILDER /src/main/resources/index.html /src/main/resources/index.html
CMD ["/my-app"]


# ==============================================

#FROM debian:stable-slim
#LABEL maintainer="Piotr Findeisen <piotr.findeisen@gmail.com>"
#
#ARG GRAAL_VERSION
#ARG JDK_VERSION
#
#RUN set -xeu && \
#    export DEBIAN_FRONTEND=noninteractive && \
#    apt-get update && \
#    apt-get install -y --no-install-recommends \
#        ca-certificates `# stays, not having this is just not useful` \
#        curl \
#        && \
#    mkdir /graalvm && \
#    curl -fsSL "https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-${GRAAL_VERSION}/graalvm-ce-${JDK_VERSION}-linux-amd64-${GRAAL_VERSION}.tar.gz" \
#        | tar -zxC /graalvm --strip-components 1 && \
#    find /graalvm -name "*src.zip"  -printf "Deleting %p\n" -exec rm {} + && \
#    { test ! -d /graalvm/legal || tar czf /graalvm/legal.tgz /graalvm/legal/; } && \
#    { test ! -d /graalvm/legal || rm -r /graalvm/legal; } && \
#    rm -rf /graalvm/man `# does not exist in java11 package` && \
#    echo Cleaning up... && \
#    apt-get remove -y \
#        curl \
#        && \
#    apt-get autoremove -y && \
#    apt-get clean && rm -r "/var/lib/apt/lists"/* && \
#    echo 'PATH="/graalvm/bin:$PATH"' | install --mode 0644 /dev/stdin /etc/profile.d/graal-on-path.sh && \
#    echo OK
#
## This applies to all container processes. However, `bash -l` will source `/etc/profile` and set $PATH on its own. For this reason, we
## *also* set $PATH in /etc/profile.d/*
#ENV PATH=/graalvm/bin:$PATH
#
## vim:set tw=140:
#
#RUN mvn -Dnative lean package
#
#CMD ["target/my-app"]