import React, { useState, useEffect } from "react";

function App() {
  const [userData, setUserData] = useState(null);

  useEffect(() => {
    window.handleFlutterMessage = (message) => {
      console.log("Raw message from Flutter:", message);
      try {
        const parsedData = JSON.parse(message);
        console.log("Parsed data:", parsedData);
        setUserData(parsedData);
      } catch (error) {
        console.error("Error parsing message from Flutter:", error);
      }
    };
  }, []);

  useEffect(() => {
    console.log("Updated userData:", userData);
  }, [userData]);

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
