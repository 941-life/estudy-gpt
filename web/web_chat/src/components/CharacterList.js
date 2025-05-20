import React from "react";
import CharacterListItem from "./CharacterListItem";
import styles from "../styles/CharacterList.module.css";

function CharacterList({ characters, onSelect }) {
  return (
    <>
      <div className={styles.appbar}>
        <span className={styles.title}>Chat</span>
      </div>
      <div className={styles.list}>
        <div className={styles.selectTitle}>
          대화할 친구를 선택하세요
        </div>
        {characters.map((character, index) => (
          <CharacterListItem 
            key={character.id} 
            character={character} 
            onSelect={onSelect}
            className={`${styles.item} ${styles[`delay-${index}`]}`}
          />
        ))}
      </div>
    </>
  );
}

export default CharacterList; 