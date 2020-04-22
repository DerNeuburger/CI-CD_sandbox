FROM python:3.7.3-stretch

# Working Directory
WORKDIR /app

# Copy source code to working directory
COPY . flask/hello_world.py /app/

# Install packages from requirements.txt
RUN pip install --upgrade pip &&\
    pip install --trusted-host pypi.python.org -r requirements/build.txt

# Open Ports
EXPOSE 5000

# Run Flask App
CMD env FLASK_APP=flask/hello_world.py flask run --host=0.0.0.0
