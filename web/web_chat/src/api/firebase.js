import { initializeApp } from "firebase/app";
import { getDatabase, ref, push, set, get } from "firebase/database";
import { getAuth, signInAnonymously } from "firebase/auth";

const firebaseConfig = {
  apiKey: process.env.REACT_APP_FIREBASE_API_KEY,
  authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN,
  databaseURL: process.env.REACT_APP_FIREBASE_DATABASE_URL,
  projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID,
  storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET,
  messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID,
  appId: process.env.REACT_APP_FIREBASE_APP_ID,
  measurementId: process.env.REACT_APP_FIREBASE_MEASUREMENT_ID,
};

const app = initializeApp(firebaseConfig);
const db = getDatabase(app);
const auth = getAuth(app);

export const initializeAuth = async (userData) => {
  try {
    // const userCredential = await signInAnonymously(auth);
    // const uid = userCredential.user.uid;
    const uid = userData.uuid;

    const userRef = ref(db, `users/${uid}`);
    const snapshot = await get(userRef);

    if (!snapshot.exists()) {
      await set(userRef, {
        cefrLevel: "A1",
        createdAt: Date.now(),
        totalSessions: 0,
        recentScores: [],
      });
    }

    return uid;
  } catch (error) {
    console.error("Error initializing anonymous auth:", error);
    throw error;
  }
};

export const saveChat = async (message, characterId) => {
  try {
    const uid = auth.currentUser.uid;
    const chatRef = ref(db, `users/${uid}/chat/Conversation`);
    const newChatRef = push(chatRef);

    await set(newChatRef, {
      role: "user",
      content: message,
      characterId,
      timestamp: Date.now(),
    });

    return newChatRef.key;
  } catch (error) {
    console.error("Error saving chat:", error.message);
    throw error;
  }
};

//추후 오답노트 기록 불러올 일 생기면 사용할 함수
export const getChatsByUser = async () => {
  try {
    const uid = auth.currentUser.uid;
    const chatRef = ref(db, `users/${uid}/chat/Conversation`);
    const snapshot = await get(chatRef);

    if (snapshot.exists()) {
      const chats = [];
      snapshot.forEach((childSnapshot) => {
        chats.push({
          id: childSnapshot.key,
          ...childSnapshot.val(),
        });
      });
      return chats;
    }
    return [];
  } catch (error) {
    console.error("Error retrieving chats:", error.message);
    throw error;
  }
};

export const updateChatAnalysis = async (chatId, analysis) => {
  try {
    const uid = auth.currentUser.uid;
    const analysisRef = ref(db, `users/${uid}/wrongNote/${chatId}`);
    const now = new Date();
    await set(analysisRef, {
      ...analysis,
      analyzedAt: now.toISOString(),
    });
  } catch (error) {
    console.error("Error updating chat analysis:", error.message);
    throw error;
  }
};
