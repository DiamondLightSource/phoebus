# Dockerfile for building Phoebus
FROM ubuntu:24.04 as common

    ENV DEBIAN_FRONTEND=noninteractive

    RUN apt-get update &&  apt-get install -y locales
    RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
        dpkg-reconfigure --frontend=noninteractive locales && \
        update-locale LANG=en_US.UTF-8

    # Updated by CI jobs through build-args
    ARG BRANCH=dls-master

    # Update this to track the version in the pom.xml file
    ENV VERSION=5.0.3-SNAPSHOT
    ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64/
    ENV LANG en_US.UTF-8
    ENV ROOT=/phoebus
    ENV TARGET=${ROOT}/phoebus-product/target
    WORKDIR ${ROOT}

FROM common as build

    RUN apt-get install -y \
        openjdk-17-jdk \
        maven \
        openjfx \
        git

    RUN git clone https://github.com/DiamondLightSource/phoebus.git \
        --branch=${BRANCH} ${ROOT}

    RUN mvn -DskipTests clean install

    RUN ln -s ${TARGET}/product-${VERSION}.jar phoebus.jar

    COPY ./dls/settings /settings

FROM common as runtime

    RUN apt-get install -y \
        openjdk-17-jre \
        openjfx

    COPY --from=build ${TARGET}/product-${VERSION}.jar ${TARGET}/phoebus.jar
    COPY --from=build ${TARGET}/lib ${TARGET}/lib
    COPY --from=build /settings /settings
    RUN ln -s ${TARGET}/phoebus.jar phoebus.jar

    ENTRYPOINT ["java", "-jar", "/phoebus/phoebus.jar"]
    CMD ["-settings=/dls/settings/settings.ini", "-server", "4918", "-add-modules=ALL-SYSTEM"]
