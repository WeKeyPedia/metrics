from flask import Flask
from flask import jsonify
from flask import render_template
from flask.ext.cors import CORS

from api import api

app = Flask(__name__)
cors = CORS(app)

if __name__ == "__main__":
  app.register_blueprint(api)
  app.run(debug=True, port=5100)