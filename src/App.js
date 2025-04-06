import React, { useState } from "react";
import useFlutterMessage from "./hooks/useFlutterMessage";
import { verifyUser } from "./services/firebaseAuth";
import UserInfo from "./components/UserInfo";
import VerifyButton from "./components/VerifyButton";

function App() {
  const [userData, setUserData] = useState(null);

  // Listen for messages from Flutter
  useFlutterMessage(setUserData);

  return (
    <div style={{ textAlign: "center", marginTop: "50px" }}>
      <h1>React App</h1>
      {userData ? (
        <div>
          <UserInfo userData={userData} />
          <VerifyButton onClick={() => verifyUser(userData)} />
        </div>
      ) : (
        <p>No user data received yet.</p>
      )}
    </div>
  );
}

export default App;
