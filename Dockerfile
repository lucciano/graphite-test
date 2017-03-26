FROM debian:8
RUN apt-get update && apt-get install -yq git python wget
RUN wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py

# Install Graphite-web
RUN git clone https://github.com/graphite-project/graphite-web.git /opt/graphite-web

# Install Carbon
RUN git clone https://github.com/graphite-project/carbon.git /opt/carbon

# Install Whisper 
RUN git clone https://github.com/graphite-project/whisper.git /opt/whisper

# Install Ceres
RUN git clone https://github.com/graphite-project/ceres.git /opt/ceres

# Install Graphite-web
RUN apt-get install -yq build-essential
RUN apt-get install -yq python-dev
RUN apt-get install -yq libffi-dev
RUN cd /opt/graphite-web && python setup.py install && pip install -r requirements.txt 

# Install Carbon
RUN cd /opt/carbon && python setup.py install

# Install Whisper 
RUN cd /opt/whisper && python setup.py install

# Install Ceres
RUN cd /opt/ceres && python setup.py install

ENV GRAPHITE_ROOT	/opt/graphite
ENV PYTHONPATH 		/opt/graphite/webapp

RUN apt-get install -yq python-cairo-dev


RUN pip install gunicorn

RUN cd /opt/graphite && cp conf/graphite.wsgi.example conf/graphite.wsgi
RUN cd /opt/graphite && cp webapp/graphite/local_settings.py.example webapp/graphite/local_settings.py

RUN cd /opt/graphite-web && django-admin.py migrate --settings=graphite.settings --run-syncdb
EXPOSE 80

RUN cd /opt/graphite/conf && cp carbon.conf.example carbon.conf
RUN cd /opt/graphite/conf && cp storage-schemas.conf.example storage-schemas.conf

CMD cd /opt/graphite/conf && gunicorn graphite.wsgi -b 0.0.0.0:80
