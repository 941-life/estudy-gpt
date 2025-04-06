// Flutter로부터 메시지를 수신
window.addEventListener("message", (e) => {
  if (e.data.type === "auth:success") {
    console.log("Authentication success:", e.data);
    localStorage.setItem("google_token", e.data.token); // 토큰 저장
    // Flutter로부터 받은 데이터를 커스텀 이벤트로 전달
    window.dispatchEvent(new CustomEvent("flutter-auth", { detail: e.data }));
  }
});

// Google 로그인 요청
export function requestGoogleLogin() {
  if (window.FlutterBridge) {
    // Flutter로 로그인 요청 메시지 전송
    window.FlutterBridge.postMessage(JSON.stringify({ type: "auth:request" }));
  } else {
    // Flutter가 없는 경우 웹 독립 실행형 로그인 처리
    console.log("Requesting Google login in standalone mode");
  }
}
