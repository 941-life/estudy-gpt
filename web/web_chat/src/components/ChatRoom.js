import React, { useRef, useEffect, useState } from "react";
import styles from "../styles/ChatRoom.module.css";
import { fetchGeminiReply } from "../api/gemini";
import ScenarioSelector from "./ScenarioSelector";

function ChatRoom({ character, onBack }) {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [selectedScenario, setSelectedScenario] = useState(null);
  const chatEndRef = useRef(null);
  const inputRef = useRef(null);

  const removeMarkdown = (text) => {
    return text
      .replace(/\*\*(.*?)\*\*/g, '$1')
      .replace(/\*(.*?)\*/g, '$1')
      .replace(/_(.*?)_/g, '$1')
      .replace(/`(.*?)`/g, '$1')
      .replace(/\[(.*?)\]\((.*?)\)/g, '$1')
      .replace(/\n/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
  };

  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  const handleSend = async () => {
    if (!input.trim() || loading) return;

    const userMessage = input;
    setMessages([...messages, { from: "me", text: userMessage }]);
    setInput("");
    setLoading(true);

    try {
      const prompt = `${selectedScenario.prompt}\n\nUser: ${userMessage}`;
      const geminiResponse = await fetchGeminiReply(prompt);
      const responseText = geminiResponse.candidates[0].content.parts[0].text;
      const cleanResponse = removeMarkdown(responseText);
      setMessages(msgs => [...msgs, { from: "other", text: cleanResponse }]);
    } catch (err) {
      console.error('Error:', err);
      setMessages(msgs => [...msgs, { from: "other", text: "응답을 불러오지 못했어요 😥" }]);
    } finally {
      setLoading(false);
      inputRef.current?.focus();
    }
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSend();
    }
  };

  if (!selectedScenario) {
    return <ScenarioSelector onSelect={setSelectedScenario} character={character} />;
  }

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
        {loading && <div className={styles.bubbleOther}>응답 중...</div>}
        <div ref={chatEndRef} />
      </div>
      <div className={styles.inputbar}>
        <input
          ref={inputRef}
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyDown={handleKeyPress}
          placeholder="대화를 시작하세요."
          disabled={loading}
        />
        <button 
          onClick={handleSend} 
          className={styles.sendBtn} 
          disabled={loading || !input.trim()}
        >
          전송
        </button>
      </div>
    </div>
  );
}

export default ChatRoom;
