import os
from ciscosparkbot import SparkBot

# Get Bot Identity from Environment Variables
bot_email = os.getenv("SPARK_BOT_EMAIL")
spark_token = os.getenv("SPARK_BOT_TOKEN")
bot_url = os.getenv("SPARK_BOT_URL")
bot_app_name = os.getenv("SPARK_BOT_APP_NAME")

# Create New Bot Object
bot = SparkBot(bot_app_name, 
               spark_bot_token=spark_token,
               spark_bot_url=bot_url, 
               spark_bot_email=bot_email)

# Start Your Bot
bot.run(host='0.0.0.0', port=5000)

