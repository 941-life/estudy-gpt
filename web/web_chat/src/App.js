import React, { useState, useEffect } from "react";
import CharacterList from "./components/CharacterList";
import ChatRoom from "./components/ChatRoom";
import characters from "./data/characters";
import styles from "./styles/App.module.css";

function App() {
  const [selected, setSelected] = useState(null);
  const [userData, setUserData] = useState(null);

  useEffect(() => {
    const handleMessage = (event) => {
      if (event.data.type === 'auth:success') {
        const { email, displayName, photoUrl, accessToken: uuid } = event.data;
        
        setUserData({
          email,
          displayName,
          photoUrl,
          uuid
        });

        if (window.FlutterBridge) {
          window.FlutterBridge.postMessage(JSON.stringify({
            type: 'auth:received',
            status: 'success',
            uuid
          }));
        }
      }
    };

    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, []);

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
        <ChatRoom 
          character={selected} 
          onBack={handleBack} 
          userData={userData}
        />
      )}
    </div>
  );
}

export default App; 