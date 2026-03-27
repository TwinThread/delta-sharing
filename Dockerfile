# Build amd64 image of delta-sharing-server from source
# Usage:
#   docker buildx build --platform linux/amd64 -t <your-registry>/delta-sharing-server:<version> --load .
#   docker push <your-registry>/delta-sharing-server:<version>

FROM eclipse-temurin:8-jdk AS build

RUN apt-get update && apt-get install -y --no-install-recommends curl && rm -rf /var/lib/apt/lists/*

# Install sbt
RUN curl -fsSL "https://github.com/sbt/sbt/releases/download/v1.9.9/sbt-1.9.9.tgz" | tar xz -C /opt && \
    ln -s /opt/sbt/bin/sbt /usr/local/bin/sbt

WORKDIR /build

# Cache dependency resolution
COPY project/build.properties project/plugins.sbt project/
COPY build.sbt version.sbt ./
RUN sbt update

# Copy source and build the server universal package
COPY . .
RUN sbt server/Universal/packageZipTarball

# Runtime image
FROM eclipse-temurin:8-jre

RUN groupadd -r sharing && useradd -r -g sharing -u 1001 sharing

COPY --from=build /build/server/target/universal/delta-sharing-server-*.tgz /tmp/delta-sharing-server.tgz
RUN mkdir -p /opt/docker && \
    tar xzf /tmp/delta-sharing-server.tgz --strip-components=1 -C /opt/docker && \
    rm /tmp/delta-sharing-server.tgz && \
    chown -R sharing:sharing /opt/docker

USER 1001
WORKDIR /opt/docker

EXPOSE 8080

ENTRYPOINT ["bin/delta-sharing-server"]
