import React from 'react';
import styles from '../styles/CEFRLevelDisplay.module.css';

const CEFRLevelDisplay = ({ level, previousLevel }) => {
  const getLevelColor = (level) => {
    const colors = {
      'A1': '#FF9800',
      'A2': '#FFB74D',
      'B1': '#4CAF50',
      'B2': '#81C784',
      'C1': '#2196F3',
      'C2': '#64B5F6'
    };
    return colors[level] || '#757575';
  };

  const getLevelDescription = (level) => {
    const descriptions = {
      'A1': '입문',
      'A2': '초급',
      'B1': '중급',
      'B2': '중상급',
      'C1': '상급',
      'C2': '고급'
    };
    return descriptions[level] || '';
  };

  return (
    <div className={styles.container}>
      <div className={styles.levelBadge} style={{ backgroundColor: getLevelColor(level) }}>
        <span className={styles.level}>{level}</span>
        <span className={styles.description}>{getLevelDescription(level)}</span>
      </div>
      {previousLevel && previousLevel !== level && (
        <div className={styles.levelChange}>
          <span className={styles.changeIndicator}>
            {level > previousLevel ? '↑' : '↓'}
          </span>
          <span className={styles.previousLevel}>{previousLevel}</span>
        </div>
      )}
    </div>
  );
};

export default CEFRLevelDisplay; 