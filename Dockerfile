FROM ubuntu:jammy
ARG GDAL_VERSION=3.8.5

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y wget gnupg2 build-essential make cmake ca-certificates libjpeg-dev libpng-dev unzip expect

RUN apt update && DEBIAN_FRONTEND=noninteractive apt -y install tzdata
COPY ./install-ecw-sdk.exp ./install-ecw-sdk.exp

# I'm using this specific version of ECW JPEG 2000 SDK, but feel free to replace it with your own preferred binary version
# Note: The bin must be in the same folder of this dockerfile
COPY ./ECWJP2SDKSetup_5.5.0.2268.bin ./install.bin
RUN chmod +x install.bin 
RUN expect ./install-ecw-sdk.exp

RUN cp -r /root/hexagon/ERDAS-ECW_JPEG_2000_SDK-5.5.0/Desktop_Read-Only /usr/local/hexagon
RUN rm -r /usr/local/hexagon/lib/x64

# Inspect the hexagon folder generated by the bin execution, your /usr/local/hexagon/lib/ can have newabi folder instead of cpp11abi
RUN mv /usr/local/hexagon/lib/cpp11abi/x64 /usr/local/hexagon/lib/x64
RUN cp /usr/local/hexagon/lib/x64/release/libNCSEcw* /usr/local/lib
RUN ldconfig /usr/local/hexagon
RUN apt update
RUN apt upgrade -y
RUN apt install -y proj-bin libproj-dev proj-data libproj22
RUN wget https://github.com/OSGeo/gdal/releases/download/v${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz
RUN tar -xf gdal-${GDAL_VERSION}.tar.gz
RUN mkdir ./gdal-${GDAL_VERSION}/build

WORKDIR ./gdal-${GDAL_VERSION}/build
RUN cmake -DCMAKE_BUILD_TYPE=Release -DECW_ROOT=/usr/local/hexagon ..
RUN make
RUN make install

RUN ln -s /usr/lib/libgdal.so /usr/lib/libgdal.so.1
RUN /sbin/ldconfig

WORKDIR ../../
RUN rm gdal-${GDAL_VERSION}.tar.gz
RUN rm -r gdal-${GDAL_VERSION}
RUN rm -r /usr/local/hexagon

WORKDIR /home
