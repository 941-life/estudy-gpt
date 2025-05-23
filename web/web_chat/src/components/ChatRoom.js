import React, { useRef, useEffect, useState } from "react";
import styles from "../styles/ChatRoom.module.css";
import { fetchGeminiReply, initializeChatSession, clearChatSession, getConversationHistory } from "../api/gemini";
import { saveChat, updateChatAnalysis, initializeAuth } from "../api/firebase";
import ScenarioSelector from "./ScenarioSelector";
import AnalysisModal from "./AnalysisModal";
import { auth, db } from "../firebase/firebaseConfig";
import { get, ref, update } from "firebase/database";

const CEFR_CRITERIA = {
  'A1': {
    score: [0, 30],
    criteria: [
      'Can use basic vocabulary and simple phrases',
      'Can understand and use familiar everyday expressions',
      'Can introduce themselves and others',
      'Can ask and answer simple questions about personal details'
    ]
  },
  'A2': {
    score: [31, 50],
    criteria: [
      'Can communicate in simple and routine tasks',
      'Can describe in simple terms aspects of their background',
      'Can handle short social exchanges',
      'Can understand sentences and frequently used expressions'
    ]
  },
  'B1': {
    score: [51, 70],
    criteria: [
      'Can deal with most situations likely to arise while traveling',
      'Can produce simple connected text on familiar topics',
      'Can describe experiences, events, dreams, and ambitions',
      'Can give reasons and explanations for opinions and plans'
    ]
  },
  'B2': {
    score: [71, 85],
    criteria: [
      'Can interact with a degree of fluency and spontaneity',
      'Can produce clear, detailed text on a wide range of subjects',
      'Can explain a viewpoint on a topical issue',
      'Can understand the main ideas of complex text'
    ]
  },
  'C1': {
    score: [86, 95],
    criteria: [
      'Can express ideas fluently and spontaneously',
      'Can use language flexibly and effectively for social and professional purposes',
      'Can produce clear, well-structured, detailed text on complex subjects',
      'Can understand implicit meaning'
    ]
  },
  'C2': {
    score: [96, 100],
    criteria: [
      'Can understand with ease virtually everything heard or read',
      'Can summarize information from different sources',
      'Can express themselves spontaneously, very fluently and precisely',
      'Can differentiate finer shades of meaning'
    ]
  }
};

const LEVEL_ADJUSTMENTS = {
  'A1': {
    vocab: 'basic (up to 500 words)',
    grammar: 'simple present tense and basic present continuous',
    sentenceLength: '5-7 words',
    focus: 'concrete, everyday topics'
  },
  'A2': {
    vocab: 'basic (up to 1000 words)',
    grammar: 'simple past and future tenses',
    sentenceLength: '7-10 words',
    focus: 'familiar topics and daily routines'
  },
  'B1': {
    vocab: 'intermediate (up to 2000 words)',
    grammar: 'various tenses and modal verbs',
    sentenceLength: '10-15 words',
    focus: 'abstract topics and opinions'
  },
  'B2': {
    vocab: 'advanced (up to 4000 words)',
    grammar: 'complex grammar structures',
    sentenceLength: '15-20 words',
    focus: 'complex topics and hypothetical situations'
  },
  'C1': {
    vocab: 'sophisticated (up to 8000 words)',
    grammar: 'advanced grammar structures',
    sentenceLength: '20+ words',
    focus: 'abstract concepts and specialized topics'
  },
  'C2': {
    vocab: 'native-like expressions',
    grammar: 'complex grammar naturally',
    sentenceLength: 'natural length',
    focus: 'any topic with depth and precision'
  }
};

function ChatRoom({ character, onBack, userData }) {
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
  const [userLevel, setUserLevel] = useState("A1");
  const [showAuthError, setShowAuthError] = useState(false);
  const [authError, setAuthError] = useState('');
  const chatEndRef = useRef(null);
  const inputRef = useRef(null);

  useEffect(() => {
    const initAuth = async () => {
      setIsInitializing(true);
      try {
        if (userData && userData.email) {
          await initializeAuth(userData);
          setIsAuthReady(true);
          
          if (window.FlutterBridge) {
            window.FlutterBridge.postMessage(JSON.stringify({
              type: 'auth:status',
              status: 'authenticated',
              uid: userData.uid
            }));
          }
        } else {
          throw new Error('User data is required for authentication');
        }

        const uid = userData.uid;
        const userRef = ref(db, `users/${uid}`);
        const snapshot = await get(userRef);
        if (snapshot.exists()) {
          const userData = snapshot.val();
          if (userData.cefrLevel) {
            setUserLevel(userData.cefrLevel);
          }
        }
      } catch (error) {
        console.error('인증 초기화 중 오류:', error);
        setAuthError(error.message);
        setShowAuthError(true);
        if (window.FlutterBridge) {
          window.FlutterBridge.postMessage(JSON.stringify({
            type: 'auth:status',
            status: 'error',
            error: error.message,
            uid: userData?.uid
          }));
        }
      } finally {
        setIsInitializing(false);
      }
    };
    initAuth();
  }, [userData]);

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
      initializeChatSession(character.id, adjustedPrompt)
          .catch(err => {
            console.error("Failed to initialize chat session:", err);
            setMessages(msgs => [...msgs, {
              from: "other",
              text: "채팅 세션을 시작하지 못했어요. 다시 시도해주세요."
            }]);
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
      const userMessages = messages.filter(msg => msg.role === 'user').map(msg => msg.content);
      
      const uid = auth.currentUser.uid;
      const userRef = ref(db, `users/${uid}`);
      const snapshot = await get(userRef);
      const currentLevel = snapshot.exists() ? snapshot.val().cefrLevel : 'A1';
      
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
          throw new Error('No JSON found in response');
        }

        const parsedAnalysis = JSON.parse(jsonMatch[0]);

        if (!parsedAnalysis.corrections || !Array.isArray(parsedAnalysis.corrections)) {
          throw new Error('Invalid corrections format');
        }
        if (!parsedAnalysis.summary || typeof parsedAnalysis.summary !== 'string') {
          throw new Error('Invalid summary format');
        }

        const correctionCount = parsedAnalysis.corrections.length;
        const score = Math.max(0, 100 - (correctionCount * 10));

        const newLevel = await checkAndUpdateCEFRLevel(score);

        return {
          ...parsedAnalysis,
          score,
          previousCefrLevel: currentLevel,
          newCefrLevel: newLevel
        };
      } catch (e) {
        console.error('Failed to parse analysis response:', e);
        return {
          corrections: [],
          summary: "분석 결과를 파싱하는데 실패했습니다. 다시 시도해주세요.",
          score: 0,
          previousCefrLevel: currentLevel,
          newCefrLevel: currentLevel
        };
      }
    } catch (error) {
      console.error('Error analyzing chat:', error);
      throw error;
    }
  };

  const checkAndUpdateCEFRLevel = async (score) => {
    try {
      const uid = auth.currentUser.uid;
      const userRef = ref(db, `users/${uid}`);
      const snapshot = await get(userRef);
      
      if (!snapshot.exists()) return 'A1';

      const userData = snapshot.val();
      const recentScores = userData.recentScores || [];
      const totalSessions = userData.totalSessions || 0;
      
      recentScores.push({
        score,
        timestamp: Date.now()
      });

      if (recentScores.length > 10) {
        recentScores.shift();
      }

      let newLevel = userData.cefrLevel;
      const isInitialStage = totalSessions < 20;

      if (isInitialStage) {
        if (userData.cefrLevel === 'A1') {
          const highScores = recentScores.filter(s => s.score >= 60);
          if (highScores.length >= 2) {
            newLevel = 'A2';
          }
        } else {
          const highScores = recentScores.filter(s => s.score >= 90);
          if (highScores.length >= 9) {
            newLevel = getNextLevel(userData.cefrLevel);
          }
          const lowScores = recentScores.filter(s => s.score <= 50);
          if (lowScores.length >= 6) {
            newLevel = getPreviousLevel(userData.cefrLevel);
          }
        }
      } else {
        const highScores = recentScores.filter(s => s.score >= 80);
        if (highScores.length >= 4) {
          newLevel = getNextLevel(userData.cefrLevel);
        }
        const lowScores = recentScores.filter(s => s.score <= 60);
        if (lowScores.length >= 3) {
          newLevel = getPreviousLevel(userData.cefrLevel);
        }
      }

      if (newLevel !== userData.cefrLevel) {
        await update(userRef, {
          cefrLevel: newLevel,
          recentScores,
          totalSessions: totalSessions + 1,
          levelHistory: [...(userData.levelHistory || []), {
            level: newLevel,
            changedAt: Date.now(),
            reason: newLevel > userData.cefrLevel ? 'upgrade' : 'downgrade'
          }]
        });
      } else {
        await update(userRef, {
          recentScores,
          totalSessions: totalSessions + 1
        });
      }

      return newLevel;
    } catch (error) {
      console.error('Error updating CEFR level:', error);
      return 'A1';
    }
  };

  const getNextLevel = (currentLevel) => {
    const levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    const currentIndex = levels.indexOf(currentLevel);
    return currentIndex < levels.length - 1 ? levels[currentIndex + 1] : currentLevel;
  };

  const getPreviousLevel = (currentLevel) => {
    const levels = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
    const currentIndex = levels.indexOf(currentLevel);
    return currentIndex > 0 ? levels[currentIndex - 1] : currentLevel;
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
        content: '죄송합니다. 응답을 생성하는 중에 오류가 발생했습니다. 잠시 후 다시 시도해주세요.',
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

  const AuthErrorPopup = () => (
    <div className={styles.errorPopup}>
      <div className={styles.errorContent}>
        <h3>인증 오류</h3>
        <p>{authError}</p>
        <button onClick={() => {
          setShowAuthError(false);
          onBack();
        }}>
          확인
        </button>
      </div>
    </div>
  );

  if (!isAuthReady || showAuthError) {
    return (
      <div className={styles.container}>
        {showAuthError && <AuthErrorPopup />}
      </div>
    );
  }

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
            {isCompleting ? "처리 중..." : "오답 노트"}
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

