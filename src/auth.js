// Flutter로부터 메시지를 수신
window.addEventListener("message", (e) => {
  if (e.data.type === "auth:success") {
    console.log("Authentication success:", e.data);
    localStorage.setItem("google_token", e.data.token); // 토큰 저장
    window.dispatchEvent(new CustomEvent("flutter-auth", { detail: e.data }));
  }
});

// Google 로그인 요청
export function requestGoogleLogin() {
  if (window.FlutterBridge) {
    window.FlutterBridge.postMessage(JSON.stringify({ type: "auth:request" }));
  } else {
    console.log("Requesting Google login in standalone mode");
  }
}
