import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";

// Firebase 설정 객체
const firebaseConfig = {
  apiKey: "AIzaSyDo1b3OFEjeQ5YenIB_jbcQSM8rog5eN6A",
  authDomain: "estudy-5b2ba.firebaseapp.com",
  projectId: "estudy-5b2ba",
  storageBucket: "estudy-5b2ba.firebasestorage.app",
  messagingSenderId: "398236771666",
  appId: "1:398236771666:web:a5357d1182c1d871c2068b",
  measurementId: "G-E7VX9YXJZ7",
};

// Firebase 앱 초기화
const app = initializeApp(firebaseConfig);

// Firebase 인증 객체 가져오기
const auth = getAuth(app);

export { app, auth };
export default firebaseConfig;
