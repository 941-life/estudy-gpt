// import React from "react";
// import CharacterListItem from "./CharacterListItem";
// import styles from "../styles/CharacterList.module.css";

// function CharacterList({ characters, onSelect }) {
//   return (
//     <>
//       <div className={styles.appbar}>
//         <span className={styles.title}>Chat</span>
//       </div>
//       <div className={styles.list}>
//         <div className={styles.selectTitle}>
//           대화할 친구를 선택하세요
//         </div>
//         {characters.map((character, index) => (
//           <CharacterListItem
//             key={character.id}
//             character={character}
//             onSelect={onSelect}
//             className={`${styles.item} ${styles[`delay-${index}`]}`}
//           />
//         ))}
//       </div>
//     </>
//   );
// }

// export default CharacterList;

import React from "react";
import CharacterListItem from "./CharacterListItem";
import styles from "../styles/CharacterList.module.css";

function CharacterList({ characters, onSelect, userInfo, globalUid }) {
  const handleCharacterSelect = (character) => {
    console.log("=== 캐릭터 선택 시 전달되는 데이터 ===");
    console.log("선택된 캐릭터:", character);
    console.log("사용자 정보:", userInfo);
    console.log("globalUid:", globalUid);
    onSelect(character);
  };

  return (
    <>
      <div className={styles.appbar}>
        <span className={styles.title}>Chat</span>
        {userInfo && (
          <div className={styles.userInfo}>
            <span className={styles.userLevel}>레벨: {userInfo.cefrLevel}</span>
            <span className={styles.sessionCount}>
              세션: {userInfo.totalSessions || 0}
            </span>
          </div>
        )}
      </div>
      <div className={styles.list}>
        <div className={styles.selectTitle}>대화할 친구를 선택하세요</div>
        {userInfo &&
          userInfo.recentScores &&
          userInfo.recentScores.length > 0 && (
            <div className={styles.recentScore}>
              최근 점수:{" "}
              {userInfo.recentScores[userInfo.recentScores.length - 1]}점
            </div>
          )}
        {characters.map((character, index) => (
          <CharacterListItem
            key={character.id}
            character={character}
            onSelect={handleCharacterSelect}
            className={`${styles.item} ${styles[`delay-${index}`]}`}
          />
        ))}
      </div>
    </>
  );
}

export default CharacterList;
