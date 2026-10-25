const { ObjectId } = require("mongodb");

function createReminder(reminderData) {
    return {
        _id: new ObjectId(),
        userId: new ObjectId(reminderData.userId),
        medicineName: reminderData.medicineName,
        reminderTime: reminderData.reminderTime,
        reminderDate: reminderData.reminderDate,
        status: reminderData.status || "Pending",
        createdAt: new Date()
    };
}

module.exports = {
    createReminder
};