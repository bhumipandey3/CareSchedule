

const express = require("express");

const cors = require("cors");

require("dotenv").config();





const { connectDB } = require("./config/db");

const authRoutes = require("./routes/authRoutes");

const medicineRoutes = require("./routes/medicineRoutes");

const appointmentRoutes = require("./routes/appointmentRoutes");

const healthProfileRoutes = require("./routes/healthProfileRoutes");

const reminderRoutes = require("./routes/reminderRoutes");



const app = express();



app.use(cors());

app.use(express.json({ limit: "12mb" }));



// Existing CareSchedule routes

app.use("/api/auth", authRoutes);

app.use("/api/medicines", medicineRoutes);

app.use("/api/appointments", appointmentRoutes);

app.use("/api/health-profile", healthProfileRoutes);

app.use("/api/reminders", reminderRoutes);



// DailyMed medicine-name search

app.get("/api/dailymed/drugnames", async (req, res) => {

    const drugName =

        typeof req.query.drug_name === "string"

            ? req.query.drug_name.trim()

            : "";



    const requestedPageSize = Number.parseInt(req.query.pagesize, 10);

    const pageSize = Number.isFinite(requestedPageSize)

        ? Math.min(Math.max(requestedPageSize, 1), 20)

        : 5;



    if (!drugName) {

        return res.status(400).json({

            message: "Please provide a medicine name.",

        });

    }



    if (drugName.length > 120) {

        return res.status(400).json({

            message: "Medicine name must be 120 characters or fewer.",

        });

    }



    try {

        const url = new URL(

            "https://dailymed.nlm.nih.gov/dailymed/services/v2/drugnames.json"

        );



        url.searchParams.set("drug_name", drugName);

        url.searchParams.set("pagesize", String(pageSize));



        const response = await fetch(url, {

            headers: { Accept: "application/json" },

            signal: AbortSignal.timeout(12000),

        });



        if (!response.ok) {

            return res.status(502).json({

                message: "DailyMed is temporarily unavailable.",

            });

        }



        return res.json(await response.json());

    } catch (error) {

        console.error("DailyMed lookup error:", error.message);



        return res.status(502).json({

            message: "Could not connect to DailyMed. Please try again.",

        });

    }

});



// Official FDA medicine-label information.

// This is NOT a complete medicine-interaction checker.

app.get("/api/medicine-info", async (req, res) => {
    const drugName = String(req.query.name || req.query.drug_name || "").trim();
    if (!drugName) return res.status(400).json({ message: "Please provide a medicine name." });
    if (drugName.length > 120) return res.status(400).json({ message: "Medicine name is too long." });

    const labelUrl = "https://dailymed.nlm.nih.gov/dailymed/search.cfm?query=" + encodeURIComponent(drugName);
    const normalized = drugName.toLowerCase().replace(/\s+/g, " ").trim();

    // Basic educational information keeps the feature useful even when official label APIs
    // do not contain an Indian brand name. It is not a substitute for an interaction check.
    const basic = {
        paracetamol: {
            name: "Paracetamol (acetaminophen)",
            uses: "Commonly used to relieve pain and reduce fever.",
            warnings: "Too much can cause serious liver damage. Check other cold/flu products for paracetamol too. Ask a clinician/pharmacist about suitability, especially with liver disease or heavy alcohol use.",
        },
        acetaminophen: {
            name: "Acetaminophen (paracetamol)",
            uses: "Commonly used to relieve pain and reduce fever.",
            warnings: "Too much can cause serious liver damage. Check other cold/flu products for acetaminophen too.",
        },
        "crocin": {
            name: "Crocin (brand; many variants contain paracetamol)",
            uses: "Crocin is a brand with different product variants; many common Crocin pain/fever products contain paracetamol and are used for pain and fever relief.",
            warnings: "Check the exact pack/strength and active ingredient. Do not combine with another paracetamol-containing medicine unless a healthcare professional confirms it is appropriate.",
        },
        "crocin advance": {
            name: "Crocin Advance (brand of paracetamol)",
            uses: "Crocin Advance commonly contains paracetamol and is used for relief of pain and fever.",
            warnings: "Check the package for the exact strength and ingredients. Avoid duplicate paracetamol products; excess paracetamol can damage the liver.",
        },
        ibuprofen: {
            name: "Ibuprofen",
            uses: "An anti-inflammatory pain reliever used for pain, fever, and inflammation.",
            warnings: "May not be suitable for people with stomach ulcers/bleeding, kidney disease, some heart conditions, pregnancy, or those taking certain blood thinners. Ask a pharmacist/clinician.",
        },
        cetirizine: {
            name: "Cetirizine",
            uses: "An antihistamine commonly used for allergy symptoms such as sneezing and itching.",
            warnings: "Can cause drowsiness in some people. Check the label and ask a pharmacist if unsure.",
        },
        amoxicillin: {
            name: "Amoxicillin",
            uses: "A prescription antibiotic used for certain bacterial infections.",
            warnings: "Use only when prescribed; it does not treat viral infections. Seek urgent help for signs of a severe allergic reaction.",
        },
    };

    let known = basic[normalized];
    if (!known && normalized.includes("paracetamol")) known = basic.paracetamol;
    if (!known && normalized.includes("crocin") && normalized.includes("advance")) known = basic["crocin advance"];
    if (!known && normalized === "crocin 650") known = basic.crocin;

    let officialUses = "";
    let officialWarnings = "";
    let officialName = "";
    try {
        const searchTerm = normalized.includes("paracetamol") || normalized.includes("crocin")
            ? "acetaminophen"
            : normalized.replace(/["\\]/g, "");
        const url = new URL("https://api.fda.gov/drug/label.json");
        url.searchParams.set("search", `openfda.brand_name:"${searchTerm}" OR openfda.generic_name:"${searchTerm}" OR openfda.substance_name:"${searchTerm}"`);
        url.searchParams.set("limit", "1");
        const response = await fetch(url, { headers: { Accept: "application/json" }, signal: AbortSignal.timeout(8000) });
        if (response.ok) {
            const payload = await response.json();
            const record = payload.results?.[0];
            if (record) {
                officialName = (record.openfda?.brand_name?.[0] || record.openfda?.generic_name?.[0] || "").toString();
                officialUses = [record.purpose, record.indications_and_usage, record.uses].flatMap(v => Array.isArray(v) ? v : (typeof v === "string" ? [v] : [])).slice(0, 2).join("\n");
                officialWarnings = [record.warnings, record.do_not_use, record.ask_doctor].flatMap(v => Array.isArray(v) ? v : (typeof v === "string" ? [v] : [])).slice(0, 2).join("\n");
            }
        }
    } catch (error) {
        console.warn("Official medicine label lookup unavailable:", error.message);
    }

    const matched = Boolean(known || officialName);
    return res.json({
        matched,
        medicineName: officialName || known?.name || drugName,
        uses: officialUses || known?.uses || "I couldn't confirm reliable basic information for this exact name. Check the active ingredient on the package or ask a pharmacist.",
        warnings: officialWarnings || known?.warnings || "The exact product and strength are not confirmed. Do not use this lookup to decide a dose or whether a combination is safe.",
        interactions: "This feature provides basic medicine information, not a complete interaction check. No interaction result here does NOT mean the combination is safe. Ask a pharmacist/doctor to check both exact products.",
        message: matched ? "Basic medicine information found. Confirm the active ingredient and strength on the package." : "No reliable match found for this exact name; check spelling and active ingredient.",
        labelUrl,
        source: officialName ? "Basic information plus U.S. FDA label where available" : "Basic medicine education; official label lookup where available",
    });
});

// Prescription handwriting analysis.

// Suggestions must be reviewed and corrected before being saved.

app.post("/api/prescription-ocr", async (req, res) => {
    const imageBase64 = typeof req.body?.imageBase64 === "string" ? req.body.imageBase64 : "";
    if (!imageBase64 || imageBase64.length > 10_000_000) {
        return res.status(400).json({ message: "Please upload a clear prescription image smaller than about 7 MB." });
    }
    if (!process.env.GEMINI_API_KEY) {
        return res.status(503).json({ message: "Image analysis needs a Gemini API key in backend .env. A free-tier key can be used subject to Google's limits." });
    }
    try {
        const mimeType = String(req.body?.mimeType || "image/jpeg");
        const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${process.env.GEMINI_MODEL || "gemini-2.5-flash-lite"}:generateContent?key=${encodeURIComponent(process.env.GEMINI_API_KEY)}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            signal: AbortSignal.timeout(45000),
            body: JSON.stringify({
                systemInstruction: { parts: [{ text: "You are a cautious prescription handwriting transcription helper. Read only text visibly present. Never invent a medicine, strength, or dosage. Preserve uncertainty. Return JSON only." }] },
                contents: [{ parts: [
                    { text: 'Transcribe visible medicine names and any clearly legible strength only. Return JSON: {"medicines":[{"name":"...","confidence":"low|medium|high"}],"note":"..."} . If uncertain, say so. Do not give medical advice or infer illegible dosage.' },
                    { inline_data: { mime_type: mimeType, data: imageBase64 } }
                ] }],
                generationConfig: { responseMimeType: "application/json", temperature: 0.1 }
            })
        });
        const payload = await response.json();
        if (!response.ok) {
            console.error("Gemini prescription error:", payload?.error?.message || response.status);
            return res.status(response.status === 429 ? 429 : 502).json({ message: "Image analysis service is unavailable or its free quota is temporarily used up. You can still type medicine names manually." });
        }
        const raw = payload.candidates?.[0]?.content?.parts?.map(p => p.text || "").join("").trim();
        if (!raw) return res.status(502).json({ message: "No readable text was returned. Try a clearer, well-lit photo." });
        const parsed = JSON.parse(raw.replace(/^```json\s*/i, "").replace(/```$/i, ""));
        return res.json({ medicines: Array.isArray(parsed.medicines) ? parsed.medicines : [], note: parsed.note || "Check every suggested name against the original prescription with a pharmacist." });
    } catch (error) {
        console.error("Prescription image analysis error:", error.message);
        return res.status(502).json({ message: "Could not analyse this image. Try a sharper, well-lit photo or type the medicine name manually." });
    }
});

// Care AI chat endpoint.

// Requires an API key and available API usage.

app.post("/api/ai-chat", async (req, res) => {
    const messages = req.body?.messages;
    if (!Array.isArray(messages) || messages.length === 0) {
        return res.status(400).json({ message: "Please send a question." });
    }
    const conversation = messages
        .filter(m => m && ["user", "assistant"].includes(m.role) && typeof m.text === "string" && m.text.trim())
        .slice(-12);
    if (!conversation.length || conversation[conversation.length - 1].role !== "user") {
        return res.status(400).json({ message: "Please send a valid question." });
    }
    if (!process.env.GEMINI_API_KEY) {
        return res.status(503).json({ message: "Care AI needs a Gemini API key in backend .env. A free-tier key is available subject to rate limits." });
    }
    try {
        const contents = conversation.map(m => ({
            role: m.role === "assistant" ? "model" : "user",
            parts: [{ text: m.text.slice(0, 3000) }]
        }));
        const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/${process.env.GEMINI_MODEL || "gemini-2.5-flash-lite"}:generateContent?key=${encodeURIComponent(process.env.GEMINI_API_KEY)}`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            signal: AbortSignal.timeout(25000),
            body: JSON.stringify({
                systemInstruction: { parts: [{ text: "You are Care AI, a friendly health education assistant. Give useful, direct answers in simple language, including basic information about common medicines and conditions. Explain general uses and common precautions but do not diagnose, prescribe doses, or tell users to start/stop medicines. State uncertainty. For urgent or emergency symptoms, direct them to local emergency care. You are not a substitute for a clinician." }] },
                contents,
                generationConfig: { temperature: 0.4, maxOutputTokens: 800 }
            })
        });
        const payload = await response.json();
        if (!response.ok) {
            console.error("Gemini Care AI error:", payload?.error?.message || response.status);
            return res.status(response.status === 429 ? 429 : 502).json({ message: "Care AI is temporarily unavailable or its free quota is used up. Please retry shortly." });
        }
        const reply = payload.candidates?.[0]?.content?.parts?.map(p => p.text || "").join("").trim();
        if (!reply) return res.status(502).json({ message: "Care AI did not return an answer. Please try again." });
        return res.json({ reply });
    } catch (error) {
        console.error("Care AI error:", error.message);
        return res.status(502).json({ message: "Care AI could not answer right now. Please try again." });
    }
});

// Backend status
app.get("/", (req, res) => {
    res.send("CareSchedule Backend is Running!");
});

async function startServer() {
    try {
        await connectDB();
        app.listen(5000, () => {
            console.log("CareSchedule server running on http://localhost:5000");
            console.log("DailyMed: http://localhost:5000/api/dailymed/drugnames?drug_name=paracetamol");
        });
    } catch (error) {
        console.error("MongoDB connection failed:", error);
        process.exit(1);
    }
}

startServer();
