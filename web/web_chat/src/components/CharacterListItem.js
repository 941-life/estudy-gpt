import React from "react";
import styles from "../styles/CharacterListItem.module.css";

function CharacterListItem({ character, onSelect, style }) {
  return (
    <div 
      className={styles.item} 
      onClick={() => onSelect(character)}
      style={style}
      role="button"
      tabIndex={0}
      onKeyPress={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          onSelect(character);
        }
      }}
    >
      <img 
        src={character.imageUrl} 
        alt={character.name} 
        className={styles.avatar}
        loading="lazy"
      />
      <div>
        <div className={styles.desc}>{character.description}</div>
        <div className={styles.sub}>{character.subtitle}</div>
      </div>
    </div>
  );
}

export default CharacterListItem; 