import React, { useRef, useEffect, useState } from "react";
import styles from "../styles/ChatRoom.module.css";

function ChatRoom({ character, onBack }) {
  const [messages, setMessages] = useState([
    { from: "me", text: "안녕!" },
    { from: "other", text: "안녕, 여행 계획 짜볼까?" }
  ]);
  const [input, setInput] = useState("");
  const chatEndRef = useRef(null);

  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const handleSend = () => {
    if (!input.trim()) return;
    setMessages([...messages, { from: "me", text: input }]);
    setInput("");
    setTimeout(() => {
      setMessages(msgs => [...msgs, { from: "other", text: "좋은 생각이야!" }]);
    }, 700);
  };

  return (
    <div className={styles.root}>
      <div className={styles.header}>
        <button onClick={onBack} className={styles.backBtn}>←</button>
        <img src={character.imageUrl} alt={character.name} className={styles.avatar} />
        <div className={styles.title}>{character.name}</div>
      </div>
      <div className={styles.messages}>
        {messages.map((msg, idx) => (
          <div key={idx} className={styles["bubble" + (msg.from === "me" ? "Me" : "Other")]}>
            {msg.text}
          </div>
        ))}
        <div ref={chatEndRef} />
      </div>
      <div className={styles.inputbar}>
        <input
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyDown={e => e.key === 'Enter' && handleSend()}
          placeholder="대화를 시작하세요."
        />
        <button onClick={handleSend} className={styles.sendBtn}>전송</button>
      </div>
    </div>
  );
}
export default ChatRoom; 