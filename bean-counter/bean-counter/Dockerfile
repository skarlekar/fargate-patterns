FROM ubuntu:16.04

MAINTAINER Srini Karlekar <skarlekar@yahoo.com>

RUN apt-get -y update
RUN apt-get -y install ipython python-opencv python-scipy python-numpy python-setuptools python-pip python-pygame
RUN apt-get -y install libjpeg-dev
RUN apt-get -y install libjpeg8-dev
RUN pip install https://github.com/sightmachine/SimpleCV/zipball/master
RUN pip install svgwrite
RUN pip install flask
RUN pip install --no-cache-dir -I Pillow==2.1.0

WORKDIR /app
COPY app/app.py /app

EXPOSE 8080

ENTRYPOINT ["python"]
CMD ["app.py"]
