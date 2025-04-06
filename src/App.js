import React, { useState, useEffect } from "react";
import firebase from "./firebaseConfig"; // Firebase 설정 가져오기

function App() {
  const [userData, setUserData] = useState(null);

  useEffect(() => {
    window.addEventListener("message", (event) => {
      if (event.data.type === "auth:success") {
        console.log("Authentication success:", event.data);
        setUserData(event.data); // 사용자 데이터 저장
      }
    });
  }, []);

  const handleGmailRedirect = () => {
    window.open("https://mail.google.com", "_blank");
  };

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
          <button
            onClick={handleGmailRedirect}
            style={{
              marginTop: "20px",
              padding: "10px 20px",
              fontSize: "16px",
              backgroundColor: "#4285F4",
              color: "white",
              border: "none",
              borderRadius: "5px",
              cursor: "pointer",
            }}
          >
            Open Gmail
          </button>
        </div>
      ) : (
        <p>No user data received yet.</p>
      )}
    </div>
  );
}

export default App;
