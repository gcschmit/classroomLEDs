from flask import Flask
from config import Config

app = Flask(__name__)
app.config.from_object(Config)

from app import routes #import at the bottom to avoid cyclical dependencies