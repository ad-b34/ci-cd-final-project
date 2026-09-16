from flask import Flask, jsonify
from flask_cors import CORS
import os

app = Flask(__name__)
CORS(app)  # Enables cross-origin requests for the frontend

# Mock database of products
PRODUCTS = [
    {"id": "p1", "name": "Laptop Pro 15"},
    {"id": "p2", "name": "Wireless Noise-Canceling Headphones"},
    {"id": "p3", "name": "Mechanical Keyboard (RGB)"},
    {"id": "p4", "name": "Ultra-Wide Gaming Monitor 34\""}
]

@app.route('/products', methods=['GET'])
def get_products():
    return jsonify(PRODUCTS)

if __name__ == '__main__':
    # Binds to environment port for Code Engine compatibility
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port)
