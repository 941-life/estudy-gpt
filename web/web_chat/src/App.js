// import React, { useState, useEffect } from "react";
// import CharacterList from "./components/CharacterList";
// import ChatRoom from "./components/ChatRoom";
// import characters from "./data/characters";
// import styles from "./styles/App.module.css";
// import useFlutterMessage from "./hooks/useFlutterMessage";
// import { initializeAuth } from "./api/firebase";

// function App() {
//   const [selected, setSelected] = useState(null);
//   const [userData, setUserData] = useState(null);
//   const [isInitialized, setIsInitialized] = useState(false);
//   const [hasInitialized, setHasInitialized] = useState(false);

//   const handleSelect = (character) => setSelected(character);
//   const handleBack = () => setSelected(null);

//   // Flutter에서 메시지를 받는 경우
//   useFlutterMessage(setUserData);

//   // 인증 초기화
//   useEffect(() => {
//     const initAuth = async (userData) => {
//       console.log("Initializing auth with userData:", userData);
//       try {
//         await initializeAuth(userData);
//         setIsInitialized(true);
//         setHasInitialized(true);
//       } catch (error) {
//         console.error("Auth initialization error:", error);
//         setIsInitialized(true);
//         setHasInitialized(true);
//       }
//     };

//     if (!hasInitialized) {
//       // Flutter에서 userData를 받은 경우 즉시 초기화
//       if (userData && userData.uuid) {
//         console.log("Flutter userData received, initializing immediately");
//         initAuth(userData);
//       } else {
//         // userData가 없는 경우 3초 후 웹 전용으로 초기화
//         console.log("Waiting for Flutter message or timeout...");
//         const timer = setTimeout(() => {
//           if (!hasInitialized) {
//             console.log("No Flutter message received, initializing for web");
//             initAuth(null);
//           }
//         }, 3000);

//         return () => {
//           console.log("Clearing timeout");
//           clearTimeout(timer);
//         };
//       }
//     }
//   }, [userData, hasInitialized]);

//   // 디버깅을 위한 userData 변경 감지
//   useEffect(() => {
//     console.log("userData changed:", userData);
//   }, [userData]);

//   if (!isInitialized) {
//     return (
//       <div className={styles.loadingContainer}>
//         <div className={styles.loadingSpinner} />
//         <p>
//           Initializing...{" "}
//           {userData ? `Received UUID: ${userData.uuid}` : "Waiting for data..."}
//         </p>
//       </div>
//     );
//   }

//   return (
//     <div className={styles.app}>
//       <link
//         href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard/dist/web/static/pretendard.css"
//         rel="stylesheet"
//       />
//       {!selected ? (
//         <CharacterList characters={characters} onSelect={handleSelect} />
//       ) : (
//         <ChatRoom character={selected} onBack={handleBack} />
//       )}
//     </div>
//   );
// }

// export default App;

import React, { useState, useEffect } from "react";
import CharacterList from "./components/CharacterList";
import ChatRoom from "./components/ChatRoom";
import characters from "./data/characters";
import styles from "./styles/App.module.css";
import useFlutterMessage from "./hooks/useFlutterMessage";
import { initializeAuth, getUserInfo } from "./api/firebase";

function App() {
  const [selected, setSelected] = useState(null);
  const [userData, setUserData] = useState(null);
  const [userInfo, setUserInfo] = useState(null); // Firebase에서 불러온 사용자 정보
  const [globalUid, setGlobalUid] = useState(null); // 전역 UID
  const [isInitialized, setIsInitialized] = useState(false);
  const [hasInitialized, setHasInitialized] = useState(false);

  const handleSelect = (character) => setSelected(character);
  const handleBack = () => setSelected(null);

  // Flutter에서 메시지를 받는 경우
  useFlutterMessage(setUserData);

  // 인증 초기화 및 사용자 정보 불러오기
  useEffect(() => {
    const initAuth = async (userData) => {
      console.log("Initializing auth with userData:", userData);
      try {
        // 1. 인증 초기화 및 UID 받기
        const uid = await initializeAuth(userData);
        console.log("Auth initialized with UID:", uid);

        // 2. UID를 상태에 저장
        setGlobalUid(uid);

        // 3. Firebase에서 사용자 정보 불러오기
        const userInfo = await getUserInfo(uid);
        console.log("Fetched user info:", userInfo);

        // 4. 사용자 정보를 상태에 저장
        setUserInfo(userInfo);

        // 5. 초기화 완료
        setIsInitialized(true);
        setHasInitialized(true);

        console.log("=== 인증 및 사용자 정보 로딩 완료 ===");
        console.log("최종 UID:", uid);
        console.log("최종 사용자 정보:", userInfo);
      } catch (error) {
        console.error("Auth initialization error:", error);
        setIsInitialized(true);
        setHasInitialized(true);
      }
    };

    if (!hasInitialized) {
      // Flutter에서 userData를 받은 경우 즉시 초기화
      if (userData && userData.uuid) {
        console.log("Flutter userData received, initializing immediately");
        initAuth(userData);
      } else {
        // userData가 없는 경우 3초 후 웹 전용으로 초기화
        console.log("Waiting for Flutter message or timeout...");
        const timer = setTimeout(() => {
          if (!hasInitialized) {
            console.log("No Flutter message received, initializing for web");
            initAuth(null);
          }
        }, 3000);

        return () => {
          console.log("Clearing timeout");
          clearTimeout(timer);
        };
      }
    }
  }, [userData, hasInitialized]);

  // 디버깅을 위한 상태 변경 감지
  useEffect(() => {
    console.log("=== userData 상태 변경 ===");
    console.log("userData:", userData);
  }, [userData]);

  useEffect(() => {
    console.log("=== userInfo 상태 변경 ===");
    console.log("userInfo:", userInfo);
  }, [userInfo]);

  useEffect(() => {
    console.log("=== globalUid 상태 변경 ===");
    console.log("globalUid:", globalUid);
  }, [globalUid]);

  // 로딩 상태 표시
  if (!isInitialized) {
    return (
      <div className={styles.loadingContainer}>
        <div className={styles.loadingSpinner} />
        <p>
          Initializing...{" "}
          {userData ? `Received UUID: ${userData.uuid}` : "Waiting for data..."}
        </p>
        {userData && (
          <p className={styles.loadingDetail}>Processing user data...</p>
        )}
      </div>
    );
  }

  // 초기화는 완료되었지만 사용자 정보가 아직 없는 경우
  if (!userInfo || !globalUid) {
    return (
      <div className={styles.loadingContainer}>
        <div className={styles.loadingSpinner} />
        <p>Loading user information...</p>
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
        <CharacterList
          characters={characters}
          onSelect={handleSelect}
          userInfo={userInfo}
          globalUid={globalUid}
        />
      ) : (
        <ChatRoom
          character={selected}
          userInfo={userInfo}
          globalUid={globalUid}
          onBack={handleBack}
        />
      )}
    </div>
  );
}

export default App;
