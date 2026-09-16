const express = require('express');
const cors = require('cors');
const app = express();

app.use(cors());

// Mock dealer & pricing data mapped by product ID
const dealerPrices = {
    "p1": [
        { "dealer": "Alpha Tech Supplies", "price": 1200 },
        { "dealer": "ByteSized Electronics", "price": 1150 }
    ],
    "p2": [
        { "dealer": "SoundWave Audio Labs", "price": 299 },
        { "dealer": "Alpha Tech Supplies", "price": 310 },
        { "dealer": "Global Gizmos", "price": 285 }
    ],
    "p3": [
        { "dealer": "ByteSized Electronics", "price": 89 },
        { "dealer": "Global Gizmos", "price": 95 }
    ],
    "p4": [
        { "dealer": "Alpha Tech Supplies", "price": 450 },
        { "dealer": "Global Gizmos", "price": 430 }
    ]
};

app.get('/prices/:productId', (req, res) => {
    const productId = req.params.productId;
    const data = dealerPrices[productId] || [];
    res.json(data);
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Dealer Pricing Service running on port ${PORT}`);
});
