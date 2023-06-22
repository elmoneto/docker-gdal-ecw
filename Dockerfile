FROM ubuntu

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y wget gnupg2 build-essential make cmake ca-certificates libjpeg-dev libpng-dev unzip expect

RUN apt update && DEBIAN_FRONTEND=noninteractive apt -y install tzdata
COPY ./install-ecw-sdk.exp ./install-ecw-sdk.exp

#I'm using this specific version of ECW JPEG 2000 SDK, but feel free to replace with your own preferred binary version
#Note: The bin must be in the same folder of this dockerfile
COPY ./ECWJP2SDKSetup_5.5.0.2268.bin ./install.bin
RUN chmod +x install.bin 
RUN expect ./install-ecw-sdk.exp

RUN cp -r /root/hexagon/ERDAS-ECW_JPEG_2000_SDK-5.5.0/Desktop_Read-Only /usr/local/hexagon
RUN rm -r /usr/local/hexagon/lib/x64
RUN mv /usr/local/hexagon/lib/cpp11abi/x64 /usr/local/hexagon/lib/x64
RUN cp /usr/local/hexagon/lib/x64/release/libNCSEcw* /usr/local/lib
RUN ldconfig /usr/local/hexagon
RUN apt update
RUN apt upgrade -y
RUN apt install -y proj-bin libproj-dev proj-data libproj22
RUN wget https://github.com/OSGeo/gdal/releases/download/v3.5.3/gdal-3.5.3.tar.gz
RUN tar -xf gdal-3.5.3.tar.gz

WORKDIR ./gdal-3.5.3/
RUN ./configure -with-ecw=/usr/local/hexagon
RUN make
RUN make install

RUN ln -s /usr/lib/libgdal.so /usr/lib/libgdal.so.1
RUN /sbin/ldconfig

WORKDIR ../
RUN rm gdal-3.5.3.tar.gz
RUN rm -r gdal-3.5.3
RUN rm -r /usr/local/hexagon

WORKDIR /home
