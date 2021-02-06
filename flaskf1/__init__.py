from flask import Flask
import os

app = Flask(__name__, static_url_path='/f1database/flaskf1/static')
app.config['SECRET_KEY'] = "somekey"

from flaskf1 import routes