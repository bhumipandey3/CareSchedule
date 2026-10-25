const express = require("express");

const {
    addAppointment,
    getAppointments
} = require("../controllers/appointmentController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/", authMiddleware, addAppointment);

router.get("/", authMiddleware, getAppointments);

module.exports = router;