FROM python:3.6
COPY . /app
WORKDIR /app
RUN pip install -r requirements.txt
RUN apt-get update
RUN apt-get -y install stress stress-ng
#ENTRYPOINT ["bash"]
#CMD ["startup.sh"]
ENV PYTHONPATH "${PYTHONPATH}:/app"
ENTRYPOINT ["python",  "app.py"]

