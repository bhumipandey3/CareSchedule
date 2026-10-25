
const { createHealthProfile } = require("../models/HealthProfile");
const { getDB } = require("../config/db");
const { ObjectId } = require("mongodb");

// CREATE OR UPDATE HEALTH PROFILE
async function createProfile(req, res) {
    try {
        const {
            dateOfBirth,
            gender,
            bloodGroup,
            height,
            weight,
            allergies,
            existingConditions
        } = req.body || {};

        const requiredFields = {
            dateOfBirth,
            gender,
            bloodGroup,
            height,
            weight
        };

        const missingFields = Object.entries(requiredFields)
            .filter(([key, value]) =>
                value === undefined ||
                value === null ||
                String(value).trim() === ""
            )
            .map(([key]) => key);

        if (missingFields.length > 0) {
            return res.status(400).json({
                message: "Please provide all required health details",
                missingFields
            });
        }

        const db = getDB();
        const userId = new ObjectId(req.user.userId);

        const profileData = {
            userId,
            dateOfBirth: String(dateOfBirth).trim(),
            gender: String(gender).trim(),
            bloodGroup: String(bloodGroup).trim(),
            height: String(height).trim(),
            weight: String(weight).trim(),
            allergies: allergies ? String(allergies).trim() : "None",
            existingConditions: existingConditions
                ? String(existingConditions).trim()
                : "None"
        };

        const existingProfile = await db.collection("healthProfiles")
            .findOne({ userId });

        if (existingProfile) {
            await db.collection("healthProfiles").updateOne(
                { userId },
                {
                    $set: {
                        dateOfBirth: profileData.dateOfBirth,
                        gender: profileData.gender,
                        bloodGroup: profileData.bloodGroup,
                        height: profileData.height,
                        weight: profileData.weight,
                        allergies: profileData.allergies,
                        existingConditions: profileData.existingConditions,
                        updatedAt: new Date()
                    }
                }
            );

            const updatedProfile = await db.collection("healthProfiles")
                .findOne({ userId });

            return res.status(200).json({
                message: "Health profile updated successfully",
                profile: updatedProfile
            });
        }

        const profile = createHealthProfile(profileData);

        await db.collection("healthProfiles").insertOne(profile);

        return res.status(201).json({
            message: "Health profile created successfully",
            profile
        });

    } catch (error) {
        console.error("Save health profile error:", error);

        return res.status(500).json({
            message: "Server error"
        });
    }
}

// GET HEALTH PROFILE
async function getProfile(req, res) {
    try {
        const db = getDB();
        const userId = new ObjectId(req.user.userId);

        const profile = await db.collection("healthProfiles")
            .findOne({ userId });

        if (!profile) {
            return res.status(404).json({
                message: "Health profile not found"
            });
        }

        return res.status(200).json({
            message: "Health profile fetched successfully",
            profile
        });

    } catch (error) {
        console.error("Get health profile error:", error);

        return res.status(500).json({
            message: "Server error"
        });
    }
}

module.exports = {
    createProfile,
    getProfile
};
