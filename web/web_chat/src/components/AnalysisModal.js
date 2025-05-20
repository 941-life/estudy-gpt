import React from 'react';
import styles from '../styles/AnalysisModal.module.css';

function AnalysisModal({ analysis, onClose }) {
  if (!analysis) return null;

  const levels = [
    { level: 'A1', color: '#e74c3c' },
    { level: 'A2', color: '#e67e22' },
    { level: 'B1', color: '#f1c40f' },
    { level: 'B2', color: '#2ecc71' },
    { level: 'C1', color: '#3498db' },
    { level: 'C2', color: '#9b59b6' }
  ];
  const currentLevelIndex = levels.findIndex(l => l.level === analysis.newCefrLevel);

  return (
    <div className={styles.modalOverlay}>
      <div className={styles.modal}>
        <div className={styles.header}>
          <h2>대화 분석 결과</h2>
          <button onClick={onClose} className={styles.closeButton}>×</button>
        </div>

        <div className={styles.scoreSection}>
          <div className={styles.scoreCircle}>
            <span className={styles.score}>{analysis.score}</span>
            <span className={styles.scoreLabel}>점</span>
          </div>
          
          <div className={styles.levelDisplay}>
            <div className={styles.levelProgress}>
              {levels.map((level, index) => (
                <div 
                  key={level.level} 
                  className={`${styles.levelStep} ${index <= currentLevelIndex ? styles.active : ''}`}
                  style={{ '--level-color': level.color }}
                >
                  <div className={styles.levelValue}>{level.level}</div>
                </div>
              ))}
            </div>
            {analysis.previousCefrLevel && analysis.previousCefrLevel !== analysis.newCefrLevel && (
              <div className={styles.levelChange}>
                Level changed from {analysis.previousCefrLevel} to {analysis.newCefrLevel}
              </div>
            )}
          </div>
        </div>

        <div className={styles.summarySection}>
          <h3>전체 피드백</h3>
          <p>{analysis.summary}</p>
        </div>

        <div className={styles.correctionsSection}>
          <h3>문장별 교정</h3>
          {analysis.corrections.map((correction, index) => (
            <div key={index} className={styles.correctionItem}>
              <div className={styles.original}>
                <span className={styles.label}>원문:</span>
                <p>{correction.original}</p>
              </div>
              <div className={styles.corrected}>
                <span className={styles.label}>교정:</span>
                <p>{correction.corrected}</p>
              </div>
              <div className={styles.explanation}>
                <span className={styles.label}>설명:</span>
                <p>{correction.explanation}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

export default AnalysisModal; 