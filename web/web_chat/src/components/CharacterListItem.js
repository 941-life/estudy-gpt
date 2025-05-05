import React from "react";
import styles from "../styles/CharacterListItem.module.css";

function CharacterListItem({ character, onSelect }) {
  return (
    <div className={styles.item} onClick={() => onSelect(character)}>
      <img src={character.imageUrl} alt={character.name} className={styles.avatar} />
      <div>
        <div className={styles.desc}>{character.description}</div>
        <div className={styles.sub}>{character.subtitle}</div>
      </div>
    </div>
  );
}
export default CharacterListItem; 