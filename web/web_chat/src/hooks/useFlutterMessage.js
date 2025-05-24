import { useEffect } from "react";

function useFlutterMessage(setUserData) {
  useEffect(() => {
    const handleMessage = (event) => {
      if (event.data.type === "auth:success") {
        console.log("Authentication success:", event.data);
        setUserData(event.data); // Save user data
      }
    };

    window.addEventListener("message", handleMessage);

    return () => {
      window.removeEventListener("message", handleMessage);
    };
  }, [setUserData]);
}

export default useFlutterMessage;
