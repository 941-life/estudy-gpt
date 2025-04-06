import React, { useState, useEffect } from "react";

function App() {
  const [userData, setUserData] = useState(null);

  // Flutter에서 데이터를 전달받는 함수
  useEffect(() => {
    window.handleFlutterMessage = (message) => {
      console.log("Raw message from Flutter:", message); // 디버깅용 로그
      try {
        const decodedMessage = decodeURIComponent(message);
        console.log("Decoded message:", decodedMessage); // 디코딩된 메시지
        const parsedData = JSON.parse(decodedMessage);
        console.log("Parsed data:", parsedData); // 파싱된 데이터
        setUserData(parsedData);
      } catch (error) {
        console.error("Error parsing message from Flutter:", error);
      }
    };
  }, []);

  return (
    <div style={{ textAlign: "center", marginTop: "50px" }}>
      <h1>React App</h1>
      {userData ? (
        <div>
          <h2>Logged-in User Information</h2>
          <p>
            <strong>Name:</strong> {userData.displayName}
          </p>
          <p>
            <strong>Email:</strong> {userData.email}
          </p>
          <img
            src={userData.photoUrl}
            alt="User Avatar"
            style={{ borderRadius: "50%", width: "100px", height: "100px" }}
          />
        </div>
      ) : (
        <p>No user data received yet.</p>
      )}
    </div>
  );
}

export default App;
