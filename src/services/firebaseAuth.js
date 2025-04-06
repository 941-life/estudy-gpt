import firebaseConfig from "../firebaseConfig";

export const verifyUser = async (userData) => {
  if (!userData || !userData.accessToken) {
    alert("User is not authenticated. Please log in again.");
    return;
  }

  const verifyUrl = `https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=${firebaseConfig.apiKey}`;

  try {
    const response = await fetch(verifyUrl, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        idToken: userData.accessToken,
      }),
    });

    if (response.ok) {
      const data = await response.json();
      const user = data.users[0];
      console.log("User verified:", user);
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
};
