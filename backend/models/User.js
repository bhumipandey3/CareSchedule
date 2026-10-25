const { ObjectId } = require("mongodb");

function createUser(userData) {
    return {
        _id: new ObjectId(),
        name: userData.name,
        email: userData.email.toLowerCase(),
        password: userData.password,
        createdAt: new Date()
    };
}

module.exports = {
    createUser
};