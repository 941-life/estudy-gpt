import React, { useState } from "react";
import CharacterList from "./components/CharacterList";
import ChatRoom from "./components/ChatRoom";
import characters from "./data/characters";
import styles from "./styles/App.module.css";

function App() {
  const [selected, setSelected] = useState(null);
  const handleSelect = (character) => setSelected(character);
  const handleBack = () => setSelected(null);

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
      {!selected && (
        <nav className={styles.navbar}>
          <img src={process.env.PUBLIC_URL + "/img/home.png"} alt="home" className={styles.navicon} />
          <img src={process.env.PUBLIC_URL + "/img/list.png"} alt="list" className={styles.navicon} />
          <img src={process.env.PUBLIC_URL + "/img/person.png"} alt="person" className={styles.navicon} />
        </nav>
      )}
    </div>
  );
}
export default App; 