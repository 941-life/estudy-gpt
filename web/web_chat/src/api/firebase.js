// import { initializeApp } from "firebase/app";
// import { getDatabase, ref, push, set, get } from "firebase/database";
// import { getAuth, signInAnonymously } from "firebase/auth";

// const firebaseConfig = {
//   apiKey: process.env.REACT_APP_FIREBASE_API_KEY,
//   authDomain: process.env.REACT_APP_FIREBASE_AUTH_DOMAIN,
//   databaseURL: process.env.REACT_APP_FIREBASE_DATABASE_URL,
//   projectId: process.env.REACT_APP_FIREBASE_PROJECT_ID,
//   storageBucket: process.env.REACT_APP_FIREBASE_STORAGE_BUCKET,
//   messagingSenderId: process.env.REACT_APP_FIREBASE_MESSAGING_SENDER_ID,
//   appId: process.env.REACT_APP_FIREBASE_APP_ID,
//   measurementId: process.env.REACT_APP_FIREBASE_MEASUREMENT_ID,
// };

// const app = initializeApp(firebaseConfig);
// const db = getDatabase(app);
// const auth = getAuth(app);

// let globalUid = null;
// let isInitializing = false; // 초기화 진행 중 플래그 추가

// export const initializeAuth = async (userData) => {
//   // 이미 초기화 중이거나 완료된 경우 중복 실행 방지
//   if (isInitializing || globalUid) {
//     console.log("Auth already initialized or in progress");
//     return globalUid;
//   }

//   isInitializing = true; // 초기화 시작 표시

//   try {
//     let uid;

//     if (userData && userData.uuid) {
//       // Flutter에서 uuid를 받은 경우
//       uid = userData.uuid;
//       console.log("=== Flutter에서 받은 uuid ===");
//       console.log("userData:", userData);
//       console.log("userData.uuid:", userData.uuid);
//       console.log("설정된 uid:", uid);
//     } else if (!auth.currentUser) {
//       // 웹에서 직접 접속한 경우에만 익명 인증 실행
//       const userCredential = await signInAnonymously(auth);
//       uid = userCredential.user.uid;
//       console.log("=== Firebase 익명 인증으로 생성된 uid ===");
//       console.log("userCredential:", userCredential);
//       console.log("userCredential.user.uid:", userCredential.user.uid);
//       console.log("설정된 uid:", uid);
//     } else {
//       // 이미 인증된 경우
//       uid = auth.currentUser.uid;
//       console.log("=== 이미 인증된 사용자 ===");
//       console.log("auth.currentUser.uid:", uid);
//     }

//     globalUid = uid;
//     console.log("=== 최종 설정된 globalUid ===");
//     console.log("globalUid:", globalUid);

//     const userRef = ref(db, `users/${uid}`);
//     const snapshot = await get(userRef);

//     if (!snapshot.exists()) {
//       await set(userRef, {
//         cefrLevel: "A1",
//         createdAt: Date.now(),
//         totalSessions: 0,
//         recentScores: [],
//       });
//     }

//     return uid;
//   } catch (error) {
//     console.error("Error initializing auth:", error);
//     throw error;
//   } finally {
//     isInitializing = false; // 초기화 완료 표시
//   }
// };

// // 나머지 함수들은 동일...
// export const saveChat = async (message, characterId) => {
//   try {
//     if (!globalUid) {
//       throw new Error("User not initialized");
//     }

//     console.log("=== saveChat 함수에서 사용되는 uid ===");
//     console.log("globalUid:", globalUid);

//     const chatRef = ref(db, `users/${globalUid}/chat/Conversation`);
//     const newChatRef = push(chatRef);

//     await set(newChatRef, {
//       role: "user",
//       content: message,
//       characterId,
//       timestamp: Date.now(),
//     });

//     return newChatRef.key;
//   } catch (error) {
//     console.error("Error saving chat:", error.message);
//     throw error;
//   }
// };

// export const getChatsByUser = async () => {
//   try {
//     if (!globalUid) {
//       throw new Error("User not initialized");
//     }

//     const chatRef = ref(db, `users/${globalUid}/chat/Conversation`);
//     const snapshot = await get(chatRef);

//     if (snapshot.exists()) {
//       const chats = [];
//       snapshot.forEach((childSnapshot) => {
//         chats.push({
//           id: childSnapshot.key,
//           ...childSnapshot.val(),
//         });
//       });
//       return chats;
//     }
//     return [];
//   } catch (error) {
//     console.error("Error retrieving chats:", error.message);
//     throw error;
//   }
// };

// export const updateChatAnalysis = async (chatId, analysis) => {
//   try {
//     if (!globalUid) {
//       throw new Error("User not initialized");
//     }

//     const analysisRef = ref(db, `users/${globalUid}/wrongNote/${chatId}`);
//     const now = new Date();
//     await set(analysisRef, {
//       ...analysis,
//       analyzedAt: now.toISOString(),
//     });
//   } catch (error) {
//     console.error("Error updating chat analysis:", error.message);
//     throw error;
//   }
// };

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

let globalUid = null;
let isInitializing = false; // 초기화 진행 중 플래그 추가

export const initializeAuth = async (userData) => {
  // 이미 초기화 중이거나 완료된 경우 중복 실행 방지
  if (isInitializing || globalUid) {
    console.log("Auth already initialized or in progress");
    return globalUid;
  }

  isInitializing = true; // 초기화 시작 표시

  try {
    let uid;

    if (userData && userData.uuid) {
      // Flutter에서 uuid를 받은 경우
      uid = userData.uuid;
      console.log("=== Flutter에서 받은 uuid ===");
      console.log("userData:", userData);
      console.log("userData.uuid:", userData.uuid);
      console.log("설정된 uid:", uid);
    } else if (!auth.currentUser) {
      // 웹에서 직접 접속한 경우에만 익명 인증 실행
      const userCredential = await signInAnonymously(auth);
      uid = userCredential.user.uid;
      console.log("=== Firebase 익명 인증으로 생성된 uid ===");
      console.log("userCredential:", userCredential);
      console.log("userCredential.user.uid:", userCredential.user.uid);
      console.log("설정된 uid:", uid);
    } else {
      // 이미 인증된 경우
      uid = auth.currentUser.uid;
      console.log("=== 이미 인증된 사용자 ===");
      console.log("auth.currentUser.uid:", uid);
    }

    globalUid = uid;
    console.log("=== 최종 설정된 globalUid ===");
    console.log("globalUid:", globalUid);

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
    console.error("Error initializing auth:", error);
    throw error;
  } finally {
    isInitializing = false; // 초기화 완료 표시
  }
};

// 사용자 정보 불러오기 함수 추가
export const getUserInfo = async (uid = null) => {
  try {
    const targetUid = uid || globalUid;

    if (!targetUid) {
      throw new Error("User not initialized");
    }

    console.log("=== 사용자 정보 불러오기 시작 ===");
    console.log("사용할 uid:", targetUid);

    const userRef = ref(db, `users/${targetUid}`);
    const snapshot = await get(userRef);

    if (snapshot.exists()) {
      const userData = snapshot.val();
      console.log("불러온 사용자 데이터:", userData);
      console.log("사용자 데이터 구조:", {
        cefrLevel: userData.cefrLevel,
        totalSessions: userData.totalSessions,
        recentScores: userData.recentScores,
        createdAt: userData.createdAt,
        chat: userData.chat ? "존재함" : "없음",
        wrongNote: userData.wrongNote ? "존재함" : "없음",
      });

      return userData;
    } else {
      console.log("사용자 데이터가 존재하지 않습니다. 기본값 반환");
      return {
        cefrLevel: "A1",
        createdAt: Date.now(),
        totalSessions: 0,
        recentScores: [],
      };
    }
  } catch (error) {
    console.error("사용자 정보 불러오기 실패:", error);
    return {
      cefrLevel: "A1",
      createdAt: Date.now(),
      totalSessions: 0,
      recentScores: [],
    };
  }
};

// 사용자 정보 업데이트 함수 추가
export const updateUserInfo = async (updates, uid = null) => {
  try {
    const targetUid = uid || globalUid;

    if (!targetUid) {
      throw new Error("User not initialized");
    }

    console.log("=== 사용자 정보 업데이트 시작 ===");
    console.log("사용할 uid:", targetUid);
    console.log("업데이트할 데이터:", updates);

    const userRef = ref(db, `users/${targetUid}`);

    // 기존 데이터 가져오기
    const snapshot = await get(userRef);
    const currentData = snapshot.exists() ? snapshot.val() : {};

    // 기존 데이터와 업데이트할 데이터 병합
    const updatedData = {
      ...currentData,
      ...updates,
      updatedAt: Date.now(),
    };

    await set(userRef, updatedData);

    console.log("사용자 정보 업데이트 완료:", updatedData);
    return updatedData;
  } catch (error) {
    console.error("사용자 정보 업데이트 실패:", error);
    throw error;
  }
};

// 현재 globalUid 반환 함수 추가
export const getCurrentUid = () => {
  return globalUid;
};

// 나머지 함수들은 동일...
export const saveChat = async (message, characterId) => {
  try {
    if (!globalUid) {
      throw new Error("User not initialized");
    }

    console.log("=== saveChat 함수에서 사용되는 uid ===");
    console.log("globalUid:", globalUid);

    const chatRef = ref(db, `users/${globalUid}/chat/Conversation`);
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

export const getChatsByUser = async () => {
  try {
    if (!globalUid) {
      throw new Error("User not initialized");
    }

    const chatRef = ref(db, `users/${globalUid}/chat/Conversation`);
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
    if (!globalUid) {
      throw new Error("User not initialized");
    }

    const analysisRef = ref(db, `users/${globalUid}/wrongNote/${chatId}`);
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
