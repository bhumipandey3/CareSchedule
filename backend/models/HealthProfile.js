const { ObjectId } = require("mongodb");

function createHealthProfile(profileData) {
    return {
        _id: new ObjectId(),
        userId: new ObjectId(profileData.userId),
        dateOfBirth: profileData.dateOfBirth,
        gender: profileData.gender,
        bloodGroup: profileData.bloodGroup,
        height: profileData.height,
        weight: profileData.weight,
        allergies: profileData.allergies,
        existingConditions: profileData.existingConditions,
        createdAt: new Date()
    };
}

module.exports = {
    createHealthProfile
};