import React from "react";

function VerifyButton({ onClick }) {
  return (
    <button
      onClick={onClick}
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
  );
}

export default VerifyButton;
