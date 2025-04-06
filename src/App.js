import React, { useState, useEffect } from "react";

function App() {
  const [userData, setUserData] = useState(null);

  // Flutter에서 데이터를 전달받는 함수
  useEffect(() => {
    window.handleFlutterMessage = (message) => {
      try {
        // Flutter에서 전달된 JSON 데이터를 디코딩
        const decodedMessage = decodeURIComponent(message);
        const parsedData = JSON.parse(decodedMessage);
        setUserData(parsedData); // 상태에 저장
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
