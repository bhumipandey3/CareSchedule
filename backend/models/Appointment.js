
const { ObjectId } = require("mongodb");

function createAppointment(appointmentData) {
    return {
        _id: new ObjectId(),
        userId: new ObjectId(appointmentData.userId),
        doctorName: appointmentData.doctorName,
        specialty: appointmentData.specialty,
        hospitalName: appointmentData.hospitalName || "",
        appointmentDate: appointmentData.appointmentDate,
        appointmentTime: appointmentData.appointmentTime,
        reason: appointmentData.reason,
        createdAt: new Date()
    };
}

module.exports = {
    createAppointment
};
