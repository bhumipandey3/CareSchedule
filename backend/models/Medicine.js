const { ObjectId } = require("mongodb");

function createMedicine(medicineData) {
    return {
        _id: new ObjectId(),
        userId: new ObjectId(medicineData.userId),
        medicineName: medicineData.medicineName,
        dosage: medicineData.dosage,
        timing: medicineData.timing,
        frequency: medicineData.frequency,
        createdAt: new Date()
    };
}

module.exports = {
    createMedicine
};