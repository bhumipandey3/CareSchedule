const express = require("express");

const {
    addMedicine,
    getMedicines
} = require("../controllers/medicineController");

const authMiddleware = require("../middleware/authMiddleware");

const router = express.Router();

router.post("/", authMiddleware, addMedicine);

router.get("/", authMiddleware, getMedicines);

module.exports = router;