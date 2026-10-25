const { MongoClient } = require("mongodb");

const client = new MongoClient(process.env.MONGODB_URI);

let db;

async function connectDB() {
    await client.connect();
    db = client.db("CareSchedule");
    console.log("MongoDB connected successfully!");
}

function getDB() {
    return db;
}

module.exports = {
    connectDB,
    getDB
};