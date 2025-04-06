import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";

// Firebase 설정 객체
const firebaseConfig = {
  apiKey: "AIzaSyC5YiKlyI7L1ohECh0eRQ_eeIvWISMpwfQ",
  authDomain: "estudy-67e52.firebaseapp.com",
  projectId: "estudy-67e52",
  storageBucket: "estudy-67e52.firebasestorage.app",
  messagingSenderId: "670797546076",
  appId: "1:670797546076:web:dbf056f81236a0f3065c99",
  measurementId: "G-P4HE27QM5M",
};

// Firebase 앱 초기화
const app = initializeApp(firebaseConfig);

// Firebase 인증 객체 가져오기
const auth = getAuth(app);

export { app, auth };
