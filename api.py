import os
import codecs
import json

from flask import Blueprint
from flask import jsonify

api = Blueprint('api', __name__)

datasets_dir = "../datasets"

def info(page, domain):
  r = {
    "title": page,
    "domain": domain
  }

  return r

def metrics(page, domain):
  excludes = [ "reading_maps", "graphs" ]

  r = []

  for root, dirs, files in os.walk("/".join([datasets_dir, domain])):
    if len(dirs) > 0:
      r.extend(dirs)

  r = [ d for d in r if d not in excludes ]

  return r

def dataset(page, metric, domain):
  filename = "/".join([datasets_dir, domain, metric, page+".json"])

  with codecs.open(filename,"r", encoding="utf-8-sig") as f:
    r = json.load(f)

  return r

@api.route("/<page>")
@api.route("/<page>/in-<domain>/")
def get_page_list(page, domain=None):
  r = {
    "info": info(page, domain),
    "metrics": metrics(page, domain)
  }

  return jsonify(r)

@api.route("/<page>/<metric>")
@api.route("/<page>/in-<domain>/<metric>")
def get_page_metric(page, metric, domain=None):
  r = {
    "info": info(page, domain),
    "data": dataset(page, metric, domain)
  }

  return jsonify(r)

@api.route("/<page>/graph:<graph>")
@api.route("/<page>/in-<domain>/graph:<graph>")
def get_page_graph(page, graph, domain=None):
  return "graph"
