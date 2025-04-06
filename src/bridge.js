// Flutter로 라우팅 명령을 전송
export function sendRouterCommand(type, path) {
  if (window.FlutterBridge) {
    window.FlutterBridge.postMessage(JSON.stringify({ type, path }));
  } else {
    window.location.href = path; // 웹 독립 실행형 대체
  }
}

// Flutter로부터 인증 이벤트를 수신
window.addEventListener("flutter-auth", (e) => {
  console.log("Received flutter-auth event:", e.detail);
  localStorage.setItem("google_token", e.detail.token); // 토큰 저장
});
