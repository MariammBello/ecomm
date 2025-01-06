from flask import Flask, jsonify, request
from flask_pymongo import PyMongo
import os

app = Flask(__name__)
app.config["MONGO_URI"] = os.getenv("MONGO_URI", "mongodb://mongodb:27017/ecomm")
mongo = PyMongo(app)

@app.route("/health")
def health():
    return jsonify({"status": "healthy"})

@app.route("/api/products", methods=["GET"])
def get_products():
    products = list(mongo.db.products.find({}, {"_id": 0}))
    return jsonify(products)

@app.route("/api/products", methods=["POST"])
def add_product():
    product = request.json
    mongo.db.products.insert_one(product)
    return jsonify({"message": "Product added"}), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
