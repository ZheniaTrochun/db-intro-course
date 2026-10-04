import { exit } from "process";

const sqlContent = await Bun.stdin.text();

if (!sqlContent.trim()) {
  console.log("No SQL content to check.");
  exit(0);
}

const geminiModel = process.env.GEMINI_MODEL;
console.log(`Gemini LLM Model: ${geminiModel}`);

const apiKey = process.env.GEMINI_API_KEY;
if (!apiKey) {
  console.error("❌ GEMINI_API_KEY is not set!");
  exit(1);
}

const prompt = `
You are an expert SQL reviewer. Your ONLY task is to detect typos in table names, column names, keyword misspellings, or weird identifiers in the following SQL code (e.g., 'crated_at' instead of 'created_at', 'usr_id', 'selete', 'udpate', 'passowrd').

Rules:
1. Set "ok" to false ONLY if you find clear typos or spelling mistakes in column names, table names, or SQL words.
2. If "ok" is false, "summary" MUST contain a concise description of found typos and suggested fixes.
3. If no typos are found, set "ok" to true and "summary" to "No typos found.".
4. Do NOT judge formatting, naming conventions, or style. Focus SOLELY on typos and misspellings in identifiers or syntax.

SQL Code to check:
\`\`\`sql
${sqlContent}
\`\`\`
`;

try {
  const url = `https://generativelanguage.googleapis.com/v1beta/interactions`;

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "x-goog-api-key": apiKey
    },
    body: JSON.stringify({
      model: geminiModel,
      input: prompt,
      response_format: {
        type: "text",
        mime_type: "application/json",
        schema: {
          type: "object",
          properties: {
            ok: { type: "boolean" },
            summary: { type: "string" },
          },
          required: ["ok", "summary"],
        }
      },
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error(`❌ Gemini API Error (${response.status}):`, errorText);
    exit(0);
  }

  const data = await response.json() as {
    steps?: {
      type: string,
      content: {
        text: string
      }[]
    }[]
  };
  const rawJson = data.steps?.filter(el => el.type === "model_output")[0]?.content
    .reduce((acc, v) => acc.concat(v.text), "")
    .replace(/```json\n/, "")
    .replace(/\n```/, "");

  if (!rawJson) {
    console.error("❌ Empty response from Gemini API");
    exit(0);
  }

  const result: { ok: boolean; summary: string } = JSON.parse(rawJson);

  if (!result.ok) {
    console.error(`❌ Typo detected by Gemini:\n${result.summary}`);
    exit(1);
  }

  console.log(`✅ Gemini Typo Check Passed: ${result.summary}`);
} catch (err) {
  console.error("❌ Error communicating with Gemini API:", err);
  exit(0);
}

