import React, { useState, useEffect } from "react";
import firebaseConfig from "./firebaseConfig"; // Import Firebase config

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

  const verifyUser = async () => {
    if (userData && userData.accessToken) {
      const verifyUrl = `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${firebaseConfig.apiKey}`; // Use apiKey from firebaseConfig

      try {
        const response = await fetch(verifyUrl, {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            idToken: userData.accessToken, // Firebase accessToken
          }),
        });

        if (response.ok) {
          const data = await response.json();
          const user = data.users[0]; // Extract the first user object
          console.log("User verified:", user);

          // Display UID and email verification status
          alert(
            `Updated User verified:\nEmail: ${user.email}\nUID: ${user.localId}\nEmail Verified: ${user.emailVerified}`
          );
        } else {
          const errorData = await response.json();
          console.error("Failed to verify user:", response.status, errorData);
          alert(`Failed to verify user: ${errorData.error.message}`);
        }
      } catch (error) {
        console.error("Error verifying user:", error);
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
            onClick={verifyUser}
            style={{
              marginTop: "20px",
              padding: "10px 20px",
              fontSize: "16px",
              backgroundColor: "#34A853",
              color: "white",
              border: "none",
              borderRadius: "5px",
              cursor: "pointer",
            }}
          >
            Verify User
          </button>
        </div>
      ) : (
        <p>No user data received yet.</p>
      )}
    </div>
  );
}

export default App;
