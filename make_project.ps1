# Create directories
New-Item -ItemType Directory -Force -Path "product_details"
New-Item -ItemType Directory -Force -Path "dealer_pricing"

# 1. Product Details Microservice Files
@'
from flask import Flask, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

PRODUCTS = [
    {"id": "p1", "name": "Laptop Pro 15"},
    {"id": "p2", "name": "Wireless Noise-Canceling Headphones"},
    {"id": "p3", "name": "4K Ultra HD Monitor"},
    {"id": "p4", "name": "Ergonomic Mechanical Keyboard"}
]

@app.route('/products', methods=['GET'])
def get_products():
    return jsonify(PRODUCTS)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
'@ | Out-File -FilePath "product_details\app.py" -Encoding utf8

@'
Flask==3.0.2
Flask-CORS==4.0.0
'@ | Out-File -FilePath "product_details\requirements.txt" -Encoding utf8

@'
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 5000
CMD ["python", "app.py"]
'@ | Out-File -FilePath "product_details\Dockerfile" -Encoding utf8


# 2. Dealer Pricing Microservice Files
@'
const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());

const dealerPrices = {
    "p1": [{ "dealer": "Tech Warehouse", "price": 1200 }, { "dealer": "ElectroStore", "price": 1150 }, { "dealer": "Global Supply", "price": 1210 }],
    "p2": [{ "dealer": "Audio Direct", "price": 250 }, { "dealer": "ElectroStore", "price": 270 }],
    "p3": [{ "dealer": "Tech Warehouse", "price": 400 }, { "dealer": "Global Supply", "price": 385 }],
    "p4": [{ "dealer": "Tech Warehouse", "price": 95 }, { "dealer": "Audio Direct", "price": 110 }, { "dealer": "ElectroStore", "price": 99 }]
};

app.get('/pricing/:productId', (req, res) => {
    const productId = req.params.productId;
    const prices = dealerPrices[productId];
    if (prices) res.json(prices);
    else res.status(404).json({ error: "Product not found" });
});

app.listen(PORT, () => console.log(`Dealer pricing running on port ${PORT}`));
'@ | Out-File -FilePath "dealer_pricing\server.js" -Encoding utf8

@'
{
  "name": "dealer-pricing-microservice",
  "version": "1.0.0",
  "main": "server.js",
  "scripts": { "start": "node server.js" },
  "dependencies": { "cors": "^2.8.5", "express": "^4.19.2" }
}
'@ | Out-File -FilePath "dealer_pricing\package.json" -Encoding utf8

@'
FROM node:18-slim
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
'@ | Out-File -FilePath "dealer_pricing\Dockerfile" -Encoding utf8


# 3. Frontend HTML File
@'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Dealer Evaluation Portal</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f7f6; }
        .container { max-width: 600px; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 20px; }
        label { display: block; margin-bottom: 8px; font-weight: bold; }
        select { width: 100%; padding: 10px; border-radius: 4px; border: 1px solid #ccc; }
        .result-box { margin-top: 20px; padding: 15px; border-left: 5px solid #0066cc; background: #eef5fc; display: none; }
    </style>
</head>
<body>
<div class="container">
    <h2>Dealer Evaluation Dashboard</h2>
    <div class="form-group">
        <label for="productSelect">Select Product:</label>
        <select id="productSelect" onchange="loadDealers()">
            <option value="">-- Loading Products... --</option>
        </select>
    </div>
    <div class="form-group" id="dealerGroup" style="display:none;">
        <label for="dealerSelect">Select Dealer:</label>
        <select id="dealerSelect" onchange="showPrice()">
        </select>
    </div>
    <div id="resultWindow" class="result-box"></div>
</div>
<script>
    const PRODUCT_SERVICE_URL = "http://localhost:5000/products";
    const PRICING_SERVICE_URL = "http://localhost:3000/pricing";
    let pricingData = [];

    document.addEventListener("DOMContentLoaded", async () => {
        const select = document.getElementById("productSelect");
        try {
            const res = await fetch(PRODUCT_SERVICE_URL);
            const data = await res.json();
            select.innerHTML = '<option value="">-- Choose a Product --</option>';
            data.forEach(p => select.innerHTML += `<option value="${p.id}">${p.name}</option>`);
        } catch { select.innerHTML = '<option>Error loading products</option>'; }
    });

    async function loadDealers() {
        const id = document.getElementById("productSelect").value;
        const group = document.getElementById("dealerGroup");
        const select = document.getElementById("dealerSelect");
        if (!id) { group.style.display = "none"; return; }
        
        const res = await fetch(`${PRICING_SERVICE_URL}/${id}`);
        pricingData = await res.json();
        
        select.innerHTML = '<option value="">-- Choose an Option --</option><option value="ALL">All Dealers</option>';
        pricingData.forEach((d, idx) => select.innerHTML += `<option value="${idx}">${d.dealer}</option>`);
        group.style.display = "block";
    }

    function showPrice() {
        const val = document.getElementById("dealerSelect").value;
        const win = document.getElementById("resultWindow");
        if (!val) { win.style.display = "none"; return; }
        win.style.display = "block";
        
        if (val === "ALL") {
            let html = "<h4>All Dealer Offerings:</h4><ul>";
            pricingData.forEach(d => html += `<li><strong>\${d.dealer}:</strong> $\${d.price}</li>`);
            win.innerHTML = html + "</ul>";
        } else {
            const d = pricingData[parseInt(val)];
            win.innerHTML = `<h4>Price Offering:</h4><p><strong>Dealer:</strong> \${d.dealer}</p><p><strong>Price:</strong> $\${d.price}</p>`;
        }
    }
</script>
</body>
</html>
'@ | Out-File -FilePath "index.html" -Encoding utf8


# 4. Docker Compose File
@'
version: '3.8'
services:
  product-details:
    build: ./product_details
    ports:
      - "5000:5000"
  dealer-pricing:
    build: ./dealer_pricing
    ports:
      - "3000:3000"
'@ | Out-File -FilePath "docker-compose.yml" -Encoding utf8

# Zip everything into project.zip
Compress-Archive -Path "product_details", "dealer_pricing", "index.html", "docker-compose.yml" -DestinationPath "project.zip" -Force

Write-Host "📦 Successfully created 'project.zip' and all subfolders!" -ForegroundColor Green
