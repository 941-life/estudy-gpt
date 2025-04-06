import React, { useState, useEffect } from "react";

function App() {
  const [userData, setUserData] = useState(null);

  useEffect(() => {
    window.addEventListener("message", (event) => {
      if (event.data.type === "auth:success") {
        console.log("Authentication success:", event.data);
        localStorage.setItem("google_token", event.data.token); // 토큰 저장
        setUserData(event.data); // 사용자 데이터 저장
      }
    });
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
