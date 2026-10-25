
const { createAppointment } = require("../models/Appointment");
const { getDB } = require("../config/db");
const { ObjectId } = require("mongodb");

// ADD APPOINTMENT
async function addAppointment(req, res) {
    try {
        const {
            doctorName,
            specialty,
            hospitalName = "Not specified",
            appointmentDate,
            appointmentTime,
            reason
        } = req.body || {};

        const requiredFields = {
            doctorName,
            appointmentDate,
            appointmentTime,
            reason
        };

        const missingFields = Object.entries(requiredFields)
            .filter(([key, value]) =>
                typeof value !== "string" || !value.trim()
            )
            .map(([key]) => key);

        if (missingFields.length > 0) {
            return res.status(400).json({
                message: "Please provide all appointment details",
                missingFields
            });
        }

        const appointment = createAppointment({
            userId: req.user.userId,
            doctorName: doctorName.trim(),
            specialty: typeof specialty === "string"
                ? specialty.trim()
                : "",
            hospitalName: typeof hospitalName === "string"
                ? hospitalName.trim() || "Not specified"
                : "Not specified",
            appointmentDate: appointmentDate.trim(),
            appointmentTime: appointmentTime.trim(),
            reason: reason.trim()
        });

        const db = getDB();

        await db.collection("appointments").insertOne(appointment);

        return res.status(201).json({
            message: "Appointment added successfully",
            appointment
        });
    } catch (error) {
        console.error("Add appointment error:", error);

        return res.status(500).json({
            message: "Server error"
        });
    }
}

// GET USER'S APPOINTMENTS
async function getAppointments(req, res) {
    try {
        const db = getDB();

        const appointments = await db.collection("appointments")
            .find({
                userId: new ObjectId(req.user.userId)
            })
            .toArray();

        return res.status(200).json({
            message: "Appointments fetched successfully",
            appointments
        });
    } catch (error) {
        console.error("Get appointments error:", error);

        return res.status(500).json({
            message: "Server error"
        });
    }
}

module.exports = {
    addAppointment,
    getAppointments
};
