import React, { useState, useEffect } from "react";

function App() {
  const [userData, setUserData] = useState(null);

  useEffect(() => {
    // Listen for messages from Flutter
    window.addEventListener("message", (event) => {
      if (event.data.type === "auth:success") {
        console.log("Authentication success:", event.data);
        setUserData(event.data); // Save user data
      }
    });
  }, []);

  const handleGmailRedirect = async () => {
    if (userData && userData.accessToken) {
      const gmailUrl = `https://mail.google.com/mail/u/0/?authuser=${userData.email}`;
      const headers = new Headers();
      headers.append("Authorization", `Bearer ${userData.accessToken}`);

      try {
        // Attempt to authenticate with Gmail
        const response = await fetch(gmailUrl, { headers });
        if (response.ok) {
          window.open(gmailUrl, "_blank"); // Open Gmail in a new tab
        } else {
          console.error("Failed to authenticate with Gmail:", response.status);
          alert("Failed to authenticate with Gmail. Please try again.");
        }
      } catch (error) {
        console.error("Error during Gmail redirect:", error);
        alert("An error occurred. Please try again.");
      }
    } else {
      alert("User is not authenticated. Please log in again.");
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
