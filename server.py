import os

from flask import Flask
from flask import jsonify
from flask import render_template
from flask import url_for

from flask.ext.cors import CORS

from flask_cake import Cake
from flask.ext.scss import Scss

from api import api
from front import front

app = Flask(__name__)
cors = CORS(app)
# scss = Scss(app, static_dir='static', asset_dir='assets')
cake = Cake(app)

@app.route('/favicon.ico')
def favicon():
  pass

if __name__ == "__main__":
  port = os.environ.setdefault("PORT", "5000")

  app.register_blueprint(front)
  app.register_blueprint(api)

  app.run(debug=True, port=int(port))
