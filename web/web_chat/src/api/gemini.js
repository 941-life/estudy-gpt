import { GoogleGenerativeAI } from "@google/generative-ai";

const genAI = new GoogleGenerativeAI(process.env.REACT_APP_GEMINI_API_KEY);

const chatSessions = new Map();

const REMINDER_INTERVAL = 5;

const MAX_HISTORY_LENGTH = 10;

export const initializeChatSession = async (characterId, scenarioPrompt) => {
    if (!process.env.REACT_APP_GEMINI_API_KEY) {
        console.error("Gemini API key is not set");
        return null;
    }

    try {
        const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

        const chatSession = await model.startChat({
            history: [
                {
                    role: "user",
                    parts: [{ text: `${scenarioPrompt}\n\nIMPORTANT: You must ALWAYS respond with a maximum of 3 sentences. Never exceed this limit. Keep your responses concise and to the point.` }]
                }
            ],
            generationConfig: {
                temperature: 0.9,
                topK: 40,
                topP: 0.95,
                maxOutputTokens: 2048,
            },
            safetySettings: [
                {
                    category: "HARM_CATEGORY_HARASSMENT",
                    threshold: "BLOCK_NONE",
                },
                {
                    category: "HARM_CATEGORY_HATE_SPEECH",
                    threshold: "BLOCK_NONE",
                },
                {
                    category: "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                    threshold: "BLOCK_NONE",
                },
                {
                    category: "HARM_CATEGORY_DANGEROUS_CONTENT",
                    threshold: "BLOCK_NONE",
                },
            ],
        });

        chatSessions.set(characterId, {
            session: chatSession,
            messageCount: 0,
            scenarioPrompt: scenarioPrompt,
            conversationHistory: []
        });

        return chatSession;
    } catch (error) {
        console.error("Error initializing chat session:", error);
        throw error;
    }
};

export const fetchGeminiReply = async (userMessage, characterId) => {
    if (!process.env.REACT_APP_GEMINI_API_KEY) {
        console.error("Gemini API key is not set");
        return "API 키가 설정되지 않았습니다.";
    }

    try {
        const sessionInfo = chatSessions.get(characterId);
        if (!sessionInfo) {
            throw new Error("Chat session not initialized");
        }

        const { session, messageCount, scenarioPrompt, conversationHistory } = sessionInfo;

        sessionInfo.messageCount++;

        conversationHistory.push({ role: "user", content: userMessage });
        if (conversationHistory.length > MAX_HISTORY_LENGTH) {
            conversationHistory.shift();
        }

        if (messageCount % REMINDER_INTERVAL === 0) {
            const reminderMessage = `Remember: ${scenarioPrompt.split('\n')[0]}\nIMPORTANT: Keep your response to a maximum of 3 sentences.`;
            await session.sendMessage(reminderMessage);
        }

        const result = await session.sendMessage(userMessage);
        const response = await result.response;

        conversationHistory.push({ role: "assistant", content: response.text() });
        if (conversationHistory.length > MAX_HISTORY_LENGTH) {
            conversationHistory.shift();
        }

        return response;
    } catch (error) {
        console.error("Error calling Gemini API:", error);
        throw error;
    }
};

export const clearChatSession = (characterId) => {
    chatSessions.delete(characterId);
};

export const getConversationHistory = (characterId) => {
    const sessionInfo = chatSessions.get(characterId);
    return sessionInfo ? sessionInfo.conversationHistory : [];
};
