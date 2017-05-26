FROM python:2-alpine
MAINTAINER Hank Preston <hank.preston@gmail.com>
EXPOSE 5000

# Install Bot Library 
RUN pip install ciscosparkbot

# Create bot directory and add code
RUN mkdir /bot
WORKDIR /bot
ADD ./mybot.py /bot

# Run Bot
CMD [ "python", "mybot.py" ]
