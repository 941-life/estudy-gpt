import React, { useRef, useEffect, useState } from "react";
import styles from "../styles/ChatRoom.module.css";
import {
  fetchGeminiReply,
  initializeChatSession,
  clearChatSession,
} from "../api/gemini";
import { saveChat, updateChatAnalysis, updateUserInfo } from "../api/firebase";
import ScenarioSelector from "./ScenarioSelector";
import AnalysisModal from "./AnalysisModal";

const LEVEL_ADJUSTMENTS = {
  A1: {
    vocab: "basic (up to 500 words)",
    grammar: "simple present tense and basic present continuous",
    sentenceLength: "5-7 words",
    focus: "concrete, everyday topics",
  },
  A2: {
    vocab: "basic (up to 1000 words)",
    grammar: "simple past and future tenses",
    sentenceLength: "7-10 words",
    focus: "familiar topics and daily routines",
  },
  B1: {
    vocab: "intermediate (up to 2000 words)",
    grammar: "various tenses and modal verbs",
    sentenceLength: "10-15 words",
    focus: "abstract topics and opinions",
  },
  B2: {
    vocab: "advanced (up to 4000 words)",
    grammar: "complex grammar structures",
    sentenceLength: "15-20 words",
    focus: "complex topics and hypothetical situations",
  },
  C1: {
    vocab: "sophisticated (up to 8000 words)",
    grammar: "advanced grammar structures",
    sentenceLength: "20+ words",
    focus: "abstract concepts and specialized topics",
  },
  C2: {
    vocab: "native-like expressions",
    grammar: "complex grammar naturally",
    sentenceLength: "natural length",
    focus: "any topic with depth and precision",
  },
};

function ChatRoom({ character, userInfo, globalUid, onBack }) {
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [selectedScenario, setSelectedScenario] = useState(null);
  const [chatId, setChatId] = useState(null);
  const [isCompleting, setIsCompleting] = useState(false);
  const [showAnalysis, setShowAnalysis] = useState(false);
  const [analysis, setAnalysis] = useState(null);
  const [userLevel, setUserLevel] = useState("A1");
  const chatEndRef = useRef(null);
  const inputRef = useRef(null);

  // 전달받은 userInfo에서 CEFR 레벨 설정
  useEffect(() => {
    if (userInfo && userInfo.cefrLevel) {
      setUserLevel(userInfo.cefrLevel);
      console.log("=== ChatRoom에서 받은 사용자 정보 ===");
      console.log("userInfo:", userInfo);
      console.log("설정된 userLevel:", userInfo.cefrLevel);
      console.log("globalUid:", globalUid);
    }
  }, [userInfo, globalUid]);

  const removeMarkdown = (text) => {
    return text
      .replace(/\*\*(.*?)\*\*/g, "$1")
      .replace(/\*(.*?)\*/g, "$1")
      .replace(/_(.*?)_/g, "$1")
      .replace(/`(.*?)`/g, "$1")
      .replace(/\[(.*?)\]\((.*?)\)/g, "$1")
      .replace(/\n/g, " ")
      .replace(/\s+/g, " ")
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

  const getLevelAdjustedPrompt = (basePrompt) => {
    const level = LEVEL_ADJUSTMENTS[userLevel];
    return `${basePrompt}\n\nIMPORTANT: Stay in character while following these guidelines:

1. CHARACTER:
- Maintain your personality traits and speech patterns
- Use your characteristic expressions
- Stay consistent with your character's style

2. CONVERSATION:
- Ask 2-3 follow-up questions per topic
- Use questions matching your character's interests
- Show curiosity in topics that fit your personality
- Ask for details in your character's way

3. LANGUAGE (CEFR ${userLevel}):
- Use ${level.vocab}
- Use ${level.grammar}
- Keep sentences ${level.sentenceLength}
- Focus on ${level.focus}

4. TOPICS:
- Discuss topics your character cares about
- Share your character's perspective
- Ask questions reflecting your character's interests
- Build on responses while staying in character

5. CORRECTIONS:
- Focus on major errors only
- Rephrase mistakes while staying in character
- Keep the conversation natural

Goal: Maintain character while helping practice English.`;
  };

  useEffect(() => {
    if (selectedScenario) {
      const adjustedPrompt = getLevelAdjustedPrompt(selectedScenario.prompt);
      initializeChatSession(character.id, adjustedPrompt).catch((err) => {
        console.error("Failed to initialize chat session:", err);
        setMessages((msgs) => [
          ...msgs,
          {
            from: "other",
            text: "채팅 세션을 시작하지 못했어요. 다시 시도해주세요.",
          },
        ]);
      });
    }
  }, [selectedScenario, character.id, userLevel]);

  useEffect(() => {
    return () => {
      if (character.id) {
        clearChatSession(character.id);
      }
    };
  }, [character.id]);

  const analyzeChat = async (messages) => {
    try {
      const userMessages = messages
        .filter((msg) => msg.role === "user")
        .map((msg) => msg.content);

      const currentLevel = userInfo?.cefrLevel || "A1";

      const prompt = `You are a friendly English conversation partner analyzing a casual chat. Your role is to evaluate the user's English and provide constructive feedback.

      IMPORTANT GUIDELINES FOR ERROR CORRECTION:
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
        "summary": "encouraging feedback about their communication style and specific areas for improvement (2-3 lines)"
      }

      Analyze these messages:
      ${JSON.stringify(userMessages, null, 2)}`;

      const response = await fetchGeminiReply(prompt, character.id);
      const responseText = await response.text();

      try {
        const jsonMatch = responseText.match(/\{[\s\S]*\}/);
        if (!jsonMatch) {
          throw new Error("No JSON found in response");
        }

        const parsedAnalysis = JSON.parse(jsonMatch[0]);

        if (
          !parsedAnalysis.corrections ||
          !Array.isArray(parsedAnalysis.corrections)
        ) {
          throw new Error("Invalid corrections format");
        }
        if (
          !parsedAnalysis.summary ||
          typeof parsedAnalysis.summary !== "string"
        ) {
          throw new Error("Invalid summary format");
        }

        const correctionCount = parsedAnalysis.corrections.length;
        const score = Math.max(0, 100 - correctionCount * 10);

        const newLevel = await checkAndUpdateCEFRLevel(score);

        return {
          ...parsedAnalysis,
          score,
          previousCefrLevel: currentLevel,
          newCefrLevel: newLevel,
        };
      } catch (e) {
        console.error("Failed to parse analysis response:", e);
        return {
          corrections: [],
          summary: "분석 결과를 파싱하는데 실패했습니다. 다시 시도해주세요.",
          score: 0,
          previousCefrLevel: currentLevel,
          newCefrLevel: currentLevel,
        };
      }
    } catch (error) {
      console.error("Error analyzing chat:", error);
      throw error;
    }
  };

  const checkAndUpdateCEFRLevel = async (score) => {
    try {
      if (!globalUid || !userInfo) {
        console.error("globalUid 또는 userInfo가 없습니다.");
        return "A1";
      }

      console.log("=== CEFR 레벨 업데이트 시작 ===");
      console.log("현재 점수:", score);
      console.log("현재 사용자 정보:", userInfo);

      const recentScores = userInfo.recentScores || [];
      const totalSessions = userInfo.totalSessions || 0;

      const newScoreEntry = {
        score,
        timestamp: Date.now(),
      };
      recentScores.push(newScoreEntry);

      // 최근 10개 점수만 유지
      if (recentScores.length > 10) {
        recentScores.shift();
      }

      let newLevel = userInfo.cefrLevel;
      const isInitialStage = totalSessions < 20;

      if (isInitialStage) {
        if (userInfo.cefrLevel === "A1") {
          const highScores = recentScores.filter((s) => s.score >= 60);
          if (highScores.length >= 2) {
            newLevel = "A2";
          }
        } else {
          const highScores = recentScores.filter((s) => s.score >= 90);
          if (highScores.length >= 9) {
            newLevel = getNextLevel(userInfo.cefrLevel);
          }
          const lowScores = recentScores.filter((s) => s.score <= 50);
          if (lowScores.length >= 6) {
            newLevel = getPreviousLevel(userInfo.cefrLevel);
          }
        }
      } else {
        const highScores = recentScores.filter((s) => s.score >= 80);
        if (highScores.length >= 4) {
          newLevel = getNextLevel(userInfo.cefrLevel);
        }
        const lowScores = recentScores.filter((s) => s.score <= 60);
        if (lowScores.length >= 3) {
          newLevel = getPreviousLevel(userInfo.cefrLevel);
        }
      }

      // 업데이트할 데이터 준비
      const updateData = {
        recentScores,
        totalSessions: totalSessions + 1,
      };

      if (newLevel !== userInfo.cefrLevel) {
        updateData.cefrLevel = newLevel;
        updateData.levelHistory = [
          ...(userInfo.levelHistory || []),
          {
            level: newLevel,
            changedAt: Date.now(),
            reason: newLevel > userInfo.cefrLevel ? "upgrade" : "downgrade",
          },
        ];
        console.log("레벨 변경:", userInfo.cefrLevel, "->", newLevel);
      }

      // Firebase 업데이트
      await updateUserInfo(updateData, globalUid);
      console.log("사용자 정보 업데이트 완료:", updateData);

      return newLevel;
    } catch (error) {
      console.error("Error updating CEFR level:", error);
      return userInfo?.cefrLevel || "A1";
    }
  };

  const getNextLevel = (currentLevel) => {
    const levels = ["A1", "A2", "B1", "B2", "C1", "C2"];
    const currentIndex = levels.indexOf(currentLevel);
    return currentIndex < levels.length - 1
      ? levels[currentIndex + 1]
      : currentLevel;
  };

  const getPreviousLevel = (currentLevel) => {
    const levels = ["A1", "A2", "B1", "B2", "C1", "C2"];
    const currentIndex = levels.indexOf(currentLevel);
    return currentIndex > 0 ? levels[currentIndex - 1] : currentLevel;
  };

  const handleSendMessage = async (message) => {
    if (!message.trim() || !globalUid) return;

    const newMessage = {
      role: "user",
      content: message,
      timestamp: new Date(),
    };

    console.log('New message being added:', newMessage);
    setMessages((prev) => {
      const updated = [...prev, newMessage];
      console.log('Updated messages array:', updated);
      return updated;
    });
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
        role: "assistant",
        content: cleanResponse,
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, aiMessage]);
    } catch (error) {
      console.error("AI 응답 생성 중 오류:", error);
      setMessages((prev) => [
        ...prev,
        {
          role: "assistant",
          content:
            "죄송합니다. 응답을 생성하는 중에 오류가 발생했습니다. 잠시 후 다시 시도해주세요.",
          timestamp: new Date(),
        },
      ]);
    } finally {
      setLoading(false);
    }
  };

  const handleFinishChat = async () => {
    if (!chatId) return;

    setIsCompleting(true);
    try {
      const analysis = await analyzeChat(messages);
      console.log('Analysis result:', analysis);
      setAnalysis(analysis);
      setShowAnalysis(true);

      try {
        await updateChatAnalysis(chatId, {
          ...analysis,
          messages: messages
            .filter((msg) => msg.role === "user")
            .map((msg) => ({
              content: msg.content,
              timestamp: msg.timestamp,
            })),
        });
      } catch (error) {
        console.error("분석 결과 저장 중 오류:", error);
      }
    } catch (error) {
      console.error("채팅 분석 중 오류:", error);
      setMessages((prev) => [
        ...prev,
        {
          role: "assistant",
          content: "채팅 분석 중 오류가 발생했습니다. 다시 시도해주세요.",
          timestamp: new Date(),
        },
      ]);
    } finally {
      setIsCompleting(false);
    }
  };

  const handleKeyPress = (e) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage(input);
    }
  };

  // 로딩 상태 체크
  if (!globalUid || !userInfo) {
    return (
      <div className={styles.loadingContainer}>
        <div className={styles.loadingSpinner} />
        <div className={styles.loadingText}>
          잠시만 기다려주세요
          <div className={styles.loadingSubText}>
            사용자 정보를 불러오는 중입니다
          </div>
        </div>
      </div>
    );
  }

  if (!selectedScenario) {
    return (
      <ScenarioSelector onSelect={setSelectedScenario} character={character} />
    );
  }

  return (
    <div className={styles.root}>
      <div className={styles.header}>
        <button onClick={onBack} className={styles.backBtn}>
          ←
        </button>
        <img
          src={character.imageUrl}
          alt={character.name}
          className={styles.avatar}
        />
        <div className={styles.title}>
          {character.name}
        </div>
        <button
          onClick={handleFinishChat}
          className={`${styles.completeBtn} ${
            isCompleting ? styles.completing : ""
          }`}
          disabled={!chatId || isCompleting}
        >
          {isCompleting ? "처리 중..." : "오답 노트"}
        </button>
      </div>
      <div className={styles.messages}>
        {messages.map((msg, idx) => (
          <div
            key={idx}
            className={
              styles["bubble" + (msg.role === "user" ? "Me" : "Other")]
            }
          >
            {typeof msg.content === 'string' ? msg.content : JSON.stringify(msg.content)}
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
          onChange={(e) => setInput(e.target.value)}
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
          analysis={{
            ...analysis,
            score: analysis.score?.toString() || '0',
            timestamp: analysis.timestamp?.toString() || new Date().toString(),
            corrections: analysis.corrections || [],
            summary: analysis.summary || '',
            previousCefrLevel: analysis.previousCefrLevel || 'A1',
            newCefrLevel: analysis.newCefrLevel || 'A1'
          }}
          onClose={() => setShowAnalysis(false)}
        />
      )}
    </div>
  );
}

export default ChatRoom;
