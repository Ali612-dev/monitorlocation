const express = require("express");
const axios = require("axios");
require("dotenv").config();

const app = express();

// ✅ Middleware to Force CORS Headers
app.use((req, res, next) => {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "Content-Type");
    next();
});

// ✅ Handle Preflight Requests
app.options("*", (req, res) => {
    res.sendStatus(200);
});

// ✅ Route for Getting Directions
app.get("/api/getDirections", async (req, res) => {
    const { origin, destination } = req.query;

    if (!origin || !destination) {
        return res.status(400).json({ success: false, error: "Missing origin or destination" });
    }

    try {
        const apiKey = process.env.GOOGLE_MAPS_API_KEY;
        if (!apiKey) {
            throw new Error("Google Maps API key is missing");
        }

        const url = `https://maps.googleapis.com/maps/api/directions/json?origin=${encodeURIComponent(origin)}&destination=${encodeURIComponent(destination)}&mode=driving&key=${apiKey}`;
        const response = await axios.get(url);

        if (response.data.status !== "OK") {
            return res.status(400).json({ success: false, error: response.data.error_message || "Invalid request" });
        }

        // ✅ Force CORS Headers on Response
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
        res.setHeader("Access-Control-Allow-Headers", "Content-Type");

        res.json({ success: true, directions: response.data });
    } catch (error) {
        console.error("Error fetching directions:", error.message);
        res.status(500).json({ success: false, error: "Failed to fetch directions" });
    }
});

// ✅ Export App for Vercel
module.exports = app;
