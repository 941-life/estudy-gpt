import React, { useRef, useEffect, useState } from "react";
import styles from "../styles/ChatRoom.module.css";
import { fetchGeminiReply, initializeChatSession, clearChatSession, getConversationHistory } from "../api/gemini";
import { saveChat, updateChatAnalysis, initializeAuth } from "../api/firebase";
import ScenarioSelector from "./ScenarioSelector";
import AnalysisModal from "./AnalysisModal";

function ChatRoom({ character, onBack }) {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [selectedScenario, setSelectedScenario] = useState(null);
  const [chatId, setChatId] = useState(null);
  const [isCompleting, setIsCompleting] = useState(false);
  const [showAnalysis, setShowAnalysis] = useState(false);
  const [analysis, setAnalysis] = useState(null);
  const [isAuthReady, setIsAuthReady] = useState(false);
  const [isInitializing, setIsInitializing] = useState(true);
  const chatEndRef = useRef(null);
  const inputRef = useRef(null);

  useEffect(() => {
    const initAuth = async () => {
      setIsInitializing(true);
      try {
        await initializeAuth();
        setIsAuthReady(true);
      } catch (error) {
        console.error('인증 초기화 중 오류:', error);
      } finally {
        setIsInitializing(false);
      }
    };
    initAuth();
  }, []);

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
    if (!loading && inputRef.current) {
      inputRef.current.focus();
    }
  }, [loading, messages]);

  useEffect(() => {
    if (selectedScenario) {
      initializeChatSession(character.id, selectedScenario.prompt)
        .catch(err => {
          console.error("Failed to initialize chat session:", err);
          setMessages(msgs => [...msgs, {
            from: "other",
            text: "채팅 세션을 시작하지 못했어요. 다시 시도해주세요."
          }]);
        });
    }
  }, [selectedScenario, character.id]);

  useEffect(() => {
    return () => {
      if (character.id) {
        clearChatSession(character.id);
      }
    };
  }, [character.id]);

  const analyzeChat = async (messages) => {
    try {
      const userMessages = messages.filter(msg => msg.role === 'user').map(msg => msg.content);
      const prompt = `You are a friendly English conversation partner analyzing a casual chat. Focus only on significant language errors while accepting natural casual speech patterns.

      IMPORTANT GUIDELINES:
      - DO NOT correct casual expressions like "plz", "thx", "gonna", "wanna", etc.
      - DO NOT mark missing periods or casual capitalization as errors
      - DO NOT correct common chat abbreviations or emoticons
      - DO NOT correct informal/conversational grammar that native speakers commonly use
      - Only correct clear mistakes that affect understanding or are definitely wrong
      - Focus on helping them communicate more naturally, not on strict grammar rules
      
      IMPORTANT: Respond ONLY with valid JSON, no other text.
      Format your response exactly like this:
      {
        "corrections": [
          {
            "original": "original sentence",
            "corrected": "corrected sentence",
            "explanation": "friendly explanation focusing on natural communication (2 lines max)"
          }
        ],
        "summary": "encouraging feedback about their communication style (2 lines max)",
        "score": number between 0 and 100 (based on successful communication, not grammar perfection)
      }

      Analyze these messages:
      ${JSON.stringify(userMessages, null, 2)}`;
      
      const response = await fetchGeminiReply(prompt, character.id);
      const responseText = await response.text();
      
      try {
        const jsonMatch = responseText.match(/\{[\s\S]*\}/);
        if (!jsonMatch) {
          throw new Error('No JSON found in response');
        }
        
        const parsedAnalysis = JSON.parse(jsonMatch[0]);

        if (!parsedAnalysis.corrections || !Array.isArray(parsedAnalysis.corrections)) {
          throw new Error('Invalid corrections format');
        }
        if (!parsedAnalysis.summary || typeof parsedAnalysis.summary !== 'string') {
          throw new Error('Invalid summary format');
        }
        if (!parsedAnalysis.score || typeof parsedAnalysis.score !== 'number') {
          throw new Error('Invalid score format');
        }

        return parsedAnalysis;
      } catch (e) {
        console.error('Failed to parse analysis response:', e);
        return {
          corrections: [],
          summary: "분석 결과를 파싱하는데 실패했습니다. 다시 시도해주세요.",
          score: 0
        };
      }
    } catch (error) {
      console.error('Error analyzing chat:', error);
      throw error;
    }
  };

  const handleSendMessage = async (message) => {
    if (!message.trim() || !isAuthReady) return;

    const newMessage = {
      role: 'user',
      content: message,
      timestamp: new Date()
    };

    setMessages(prev => [...prev, newMessage]);
    setInput("");
    setLoading(true);

    try {
      if (!chatId) {
        const newChatId = await saveChat(message, character.id);
        setChatId(newChatId);
      }

      const response = await fetchGeminiReply(message, character.id);
      const responseText = await response.text();
      const cleanResponse = removeMarkdown(responseText);

      const aiMessage = {
        role: 'assistant',
        content: cleanResponse,
        timestamp: new Date()
      };
      setMessages(prev => [...prev, aiMessage]);
    } catch (error) {
      console.error('AI 응답 생성 중 오류:', error);
      setMessages(prev => [...prev, {
        role: 'assistant',
        content: '죄송합니다. 응답을 생성하는 중에 오류가 발생했습니다.',
        timestamp: new Date()
      }]);
    } finally {
      setLoading(false);
    }
  };

  const handleFinishChat = async () => {
    if (!chatId) return;

    setIsCompleting(true);
    try {
      const analysis = await analyzeChat(messages);
      setAnalysis(analysis);
      setShowAnalysis(true);

      try {
        await updateChatAnalysis(chatId, {
          ...analysis,
          messages: messages.filter(msg => msg.role === 'user').map(msg => ({
            content: msg.content,
            timestamp: msg.timestamp
          }))
        });
      } catch (error) {
        console.error('분석 결과 저장 중 오류:', error);
      }
    } catch (error) {
      console.error('채팅 분석 중 오류:', error);
      setMessages(prev => [...prev, {
        role: 'assistant',
        content: '채팅 분석 중 오류가 발생했습니다. 다시 시도해주세요.',
        timestamp: new Date()
      }]);
    } finally {
      setIsCompleting(false);
    }
  };

  const handleKeyPress = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage(input);
    }
  };

  if (isInitializing) {
    return (
      <div className={styles.loadingContainer}>
        <div className={styles.loadingSpinner} />
      </div>
    );
  }

  if (!selectedScenario) {
    return <ScenarioSelector onSelect={setSelectedScenario} character={character} />;
  }

  return (
    <div className={styles.root}>
      <div className={styles.header}>
        <button onClick={onBack} className={styles.backBtn}>←</button>
        <img src={character.imageUrl} alt={character.name} className={styles.avatar} />
        <div className={styles.title}>{character.name}</div>
        <button
          onClick={handleFinishChat}
          className={`${styles.completeBtn} ${isCompleting ? styles.completing : ''}`}
          disabled={!chatId || isCompleting}
        >
          {isCompleting ? "처리 중..." : "채팅 종료"}
        </button>
      </div>
      <div className={styles.messages}>
        {messages.map((msg, idx) => (
          <div key={idx} className={styles["bubble" + (msg.role === "user" ? "Me" : "Other")]}>
            {msg.content}
          </div>
        ))}
        {loading && (
          <div className={styles.bubbleOther}>
            <div className={styles.typingIndicator}>
              <div className={styles.typingDot} />
              <div className={styles.typingDot} />
              <div className={styles.typingDot} />
            </div>
          </div>
        )}
        <div ref={chatEndRef} />
      </div>
      <div className={styles.inputbar}>
        <input
          ref={inputRef}
          id="chat-input"
          name="chat-input"
          value={input}
          onChange={e => setInput(e.target.value)}
          onKeyDown={handleKeyPress}
          placeholder="대화를 시작하세요."
          disabled={loading}
          autoComplete="off"
        />
        <button
          onClick={() => handleSendMessage(input)}
          className={styles.sendBtn}
          disabled={loading || !input.trim()}
        >
          전송
        </button>
      </div>
      {showAnalysis && analysis && (
        <AnalysisModal
          analysis={analysis}
          onClose={() => setShowAnalysis(false)}
        />
      )}
    </div>
  );
}

export default ChatRoom;
