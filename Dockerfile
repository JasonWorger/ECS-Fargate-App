FROM python:3.10-alpine3.18

# WORKDIR /app

COPY . .

# Install using setup.py:
RUN python setup.py install

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Set environment variables
ENV FLASK_APP=hello

# Run the application
CMD ["flask", "run", "--host=0.0.0.0"]