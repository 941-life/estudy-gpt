import React, { useState, useEffect } from "react";

function App() {
  const [userData, setUserData] = useState(null);

  useEffect(() => {
    window.addEventListener("message", (event) => {
      console.log("Received message from Flutter:", event.data);
      if (event.data.type === "auth:success") {
        console.log("Authentication success:", event.data);
        localStorage.setItem("google_token", event.data.token); // 토큰 저장
        setUserData(event.data); // 사용자 데이터 저장
      }
    });
  }, []);

  useEffect(() => {
    console.log("Updated userData:", userData);
  }, [userData]);

  // Gmail 버튼 클릭 시 Flutter로 명령 전달
  const handleGmailRedirect = () => {
    if (window.FlutterBridge) {
      window.FlutterBridge.postMessage(
        JSON.stringify({
          type: "router:push",
          path: "https://mail.google.com", // Gmail URL
        })
      );
    } else {
      console.error("FlutterBridge is not available.");
    }
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
