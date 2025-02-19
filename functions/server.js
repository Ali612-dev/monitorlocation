const express = require("express");
const axios = require("axios");
const cors = require("cors"); // 🔥 Add this
require("dotenv").config();

const app = express();
app.use(cors()); // 🔥 Allow cross-origin requests

const PORT = process.env.PORT || 3000;

app.get("/getDirections", async (req, res) => {
    const { origin, destination } = req.query;
    if (!origin || !destination) {
        return res.status(400).json({ error: "Missing origin or destination" });
    }

    try {
        const url = `https://maps.googleapis.com/maps/api/directions/json?origin=${origin}&destination=${destination}&mode=driving&key=AIzaSyB7mtSHZ5tjIOiYXsnal4WwqZSO4wHv8xw`;
        const response = await axios.get(url);
        res.json(response.data);
    } catch (error) {
        res.status(500).json({ error: "Failed to fetch directions" });
    }
});

app.listen(PORT, () => console.log(`🚀 Server running on http://localhost:${PORT}`));


