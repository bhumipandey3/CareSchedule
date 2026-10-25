const express = require("express");

const {
    addReminder,
    getReminders
} = require("../controllers/reminderController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/", authMiddleware, addReminder);

router.get("/", authMiddleware, getReminders);

module.exports = router;