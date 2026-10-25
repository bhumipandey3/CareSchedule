const { createReminder } = require("../models/Reminder");
const { getDB } = require("../config/db");
const { ObjectId } = require("mongodb");

// ADD REMINDER
async function addReminder(req, res) {
    try {
        const {
            medicineName,
            reminderTime,
            reminderDate
        } = req.body || {};

        // Check required fields
        if (!medicineName || !reminderTime || !reminderDate) {
            return res.status(400).json({
                message: "Please provide all reminder details"
            });
        }

        // Create reminder
        const reminder = createReminder({
            userId: req.user.userId,
            medicineName,
            reminderTime,
            reminderDate
        });

        // Save reminder to MongoDB
        const db = getDB();

        await db.collection("reminders").insertOne(reminder);

        res.status(201).json({
            message: "Reminder added successfully",
            reminder
        });

    } catch (error) {
        console.error("Add reminder error:", error);

        res.status(500).json({
            message: "Server error"
        });
    }
}


// GET USER'S REMINDERS
async function getReminders(req, res) {
    try {
        const db = getDB();

        const reminders = await db.collection("reminders")
            .find({
                userId: new ObjectId(req.user.userId)
            })
            .toArray();

        res.status(200).json({
            message: "Reminders fetched successfully",
            reminders
        });

    } catch (error) {
        console.error("Get reminders error:", error);

        res.status(500).json({
            message: "Server error"
        });
    }
}


module.exports = {
    addReminder,
    getReminders
};