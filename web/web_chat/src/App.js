import React, { useState } from "react";
import CharacterList from "./components/CharacterList";
import ChatRoom from "./components/ChatRoom";
import characters from "./data/characters";
import styles from "./styles/App.module.css";
import useFlutterMessage from "./hooks/useFlutterMessage";

function App() {
  const [selected, setSelected] = useState(null);
  const [userData, setUserData] = useState(null);
  const handleSelect = (character) => setSelected(character);
  const handleBack = () => setSelected(null);

  useFlutterMessage(setUserData);

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
