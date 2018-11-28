FROM python:3.6
MAINTAINER Hank Preston <hank.preston@gmail.com>

# install common tools
RUN apt-get update \
 && apt-get install -y telnet \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Bot port
EXPOSE 5000

# Create bot directory and add Python Requirements
RUN mkdir /bot
WORKDIR /bot
ADD ./requirements.txt /bot

# Install Bot Requirements
RUN pip3 install -r requirements.txt

# Add Bot Code Files
ADD pyats-testbed*.yaml /bot/
COPY ./library/*.py /bot/library/
ADD ./chatbot_example.py /bot

# Run Bot
CMD [ "python", "chatbot_example.py" ]
