const { ObjectId } = require("mongodb");
const { createMedicine } = require("../models/Medicine");
const { getDB } = require("../config/db");

// ADD MEDICINE
async function addMedicine(req, res) {
    try {
       const {
       medicineName,
        dosage,
        timing,
        frequency
} = req.body || {};

        // Check required fields
        if (!medicineName || !dosage || !timing || !frequency) {
            return res.status(400).json({
                message: "Please provide all medicine details"
            });
        }

        // Create medicine
        const medicine = createMedicine({
            userId: req.user.userId,
            medicineName,
            dosage,
            timing,
            frequency
        });

        // Save medicine to MongoDB
        const db = getDB();

        await db.collection("medicines").insertOne(medicine);

        res.status(201).json({
            message: "Medicine added successfully",
            medicine
        });

    } catch (error) {
        console.error("Add medicine error:", error);

        res.status(500).json({
            message: "Server error"
        });
    }
}


// GET USER'S MEDICINES
async function getMedicines(req, res) {
    try {
        const db = getDB();

        const medicines = await db.collection("medicines")
            .find({
         userId: new ObjectId(req.user.userId)
           })  
            .toArray();

        res.status(200).json({
            message: "Medicines fetched successfully",
            medicines
        });

    } catch (error) {
        console.error("Get medicines error:", error);

        res.status(500).json({
            message: "Server error"
        });
    }
}


module.exports = {
    addMedicine,
    getMedicines
};