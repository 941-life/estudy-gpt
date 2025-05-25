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
  const handleSelect = (character) => setSelected(character);
  const handleBack = () => setSelected(null);

  // Flutter 메시지 핸들러 설정
  useFlutterMessage(setUserData);

  // userData가 변경될 때만 인증 초기화
  useEffect(() => {
    const initAuth = async () => {
      try {
        await initializeAuth(userData);
        setIsInitialized(true);
      } catch (error) {
        console.error("Auth initialization error:", error);
        setIsInitialized(true);
      }
    };

    // userData가 있든 없든 인증 초기화 실행
    initAuth();
  }, [userData]);

  if (!isInitialized) {
    return (
      <div className={styles.loadingContainer}>
        <div className={styles.loadingSpinner} />
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
