import React, { useState, useEffect } from "react";
import CharacterList from "./components/CharacterList";
import ChatRoom from "./components/ChatRoom";
import characters from "./data/characters";
import styles from "./styles/App.module.css";
import useFlutterMessage from "./hooks/useFlutterMessage";
import { initializeAuth } from "./api/firebase";

function App() {
  const [selected, setSelected] = useState(null);
  const [userData, setUserData] = useState(null);
  const [isInitialized, setIsInitialized] = useState(false);
  const [hasInitialized, setHasInitialized] = useState(false);

  const handleSelect = (character) => setSelected(character);
  const handleBack = () => setSelected(null);

  // Flutter에서 메시지를 받는 경우
  useFlutterMessage(setUserData);

  // 인증 초기화
  useEffect(() => {
    const initAuth = async (userData) => {
      console.log("Initializing auth with userData:", userData);
      try {
        await initializeAuth(userData);
        setIsInitialized(true);
        setHasInitialized(true);
      } catch (error) {
        console.error("Auth initialization error:", error);
        setIsInitialized(true);
        setHasInitialized(true);
      }
    };

    if (!hasInitialized) {
      // Flutter에서 userData를 받은 경우 즉시 초기화
      if (userData && userData.uuid) {
        console.log("Flutter userData received, initializing immediately");
        initAuth(userData);
      } else {
        // userData가 없는 경우 3초 후 웹 전용으로 초기화
        console.log("Waiting for Flutter message or timeout...");
        const timer = setTimeout(() => {
          if (!hasInitialized) {
            console.log("No Flutter message received, initializing for web");
            initAuth(null);
          }
        }, 3000);

        return () => {
          console.log("Clearing timeout");
          clearTimeout(timer);
        };
      }
    }
  }, [userData, hasInitialized]);

  // 디버깅을 위한 userData 변경 감지
  useEffect(() => {
    console.log("userData changed:", userData);
  }, [userData]);

  if (!isInitialized) {
    return (
      <div className={styles.loadingContainer}>
        <div className={styles.loadingSpinner} />
        <p>
          Initializing...{" "}
          {userData ? `Received UUID: ${userData.uuid}` : "Waiting for data..."}
        </p>
      </div>
    );
  }

  return (
    <div className={styles.app}>
      <link
        href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css"
        rel="stylesheet"
      />
      {!selected ? (
        <CharacterList characters={characters} onSelect={handleSelect} />
      ) : (
        <ChatRoom character={selected} onBack={handleBack} />
      )}
    </div>
  );
}

export default App;
