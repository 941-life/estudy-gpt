import React from "react";

function UserInfo({ userData }) {
  return (
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
  );
}

export default UserInfo;
