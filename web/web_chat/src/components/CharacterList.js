import React from "react";
import CharacterListItem from "./CharacterListItem";
import styles from "../styles/CharacterList.module.css";

function CharacterList({ characters, onSelect }) {
  return (
    <>
      <div className={styles.appbar}>
        <span className={styles.title}>Practice</span>
        <button className={styles.settingsBtn} title="설정">
          <svg width="24" height="24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 8 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 5 15.4a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 5 8.6a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 8 4.6a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09c0 .66.39 1.26 1 1.51a1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9c.66 0 1.26.39 1.51 1H21a2 2 0 0 1 0 4h-.09c-.25 0-.48.09-.68.26-.2.17-.33.41-.33.68z"/></svg>
        </button>
      </div>
      <div className={styles.list}>
        <div className={styles.selectTitle}>대화할 친구를 선택하세요.</div>
        {characters.map(character => (
          <CharacterListItem key={character.id} character={character} onSelect={onSelect} />
        ))}
      </div>
    </>
  );
}
export default CharacterList; 