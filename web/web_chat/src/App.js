import React, { useState } from "react";
import CharacterList from "./components/CharacterList";
import ChatRoom from "./components/ChatRoom";
import characters from "./data/characters";
import styles from "./styles/App.module.css";
import useFlutterMessage from "./hooks/useFlutterMessage";
import { initializeAuth } from "./api/firebase";

function App() {
  const [selected, setSelected] = useState(null);
  const [userData, setUserData] = useState(null);
  const handleSelect = (character) => setSelected(character);
  const handleBack = () => setSelected(null);

  useFlutterMessage(setUserData);

  React.useEffect(() => {
    if (userData) {
      initializeAuth(userData);
    }
  }, [userData]);

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
