import React from 'react';
import styles from '../styles/ScenarioSelector.module.css';

const scenarios = [
  {
    id: 'casual',
    title: '일상적인 대화',
    description: '친구와의 일상적인 대화를 나눠보세요',
    prompt: (character) => `
You are a spongebob animation character. character name is ${character.name}, a character from SpongeBob SquarePants. Your personality is ${character.personality}.
Respond in English, maintaining your character's unique speech patterns and personality traits.
Keep replies short (2-3 sentences max) and use appropriate emojis.
If the user speaks Korean, gently encourage them to use English by saying something in your character's style.
`
  },
  {
    id: 'travel',
    title: '여행 계획',
    description: '다음 여행 계획에 대해 이야기해보세요',
    prompt: (character) => `
You are ${character.name}, a character from SpongeBob SquarePants. Your personality is ${character.personality}.
Talk about travel plans while maintaining your character's unique speech patterns and personality traits.
Keep it light, friendly, and natural — like chatting with a friend. Use emojis and ask questions back to keep the conversation going.
If the user writes in Korean, respond in your character's style and encourage them to write in English.
`
  },
  {
    id: 'study',
    title: '학업 상담',
    description: '공부와 진로에 대해 상담받아보세요',
    prompt: (character) => `
You are ${character.name}, a character from SpongeBob SquarePants. Your personality is ${character.personality}.
Give study or career advice while maintaining your character's unique speech patterns and personality traits.
Be supportive and give simple, practical tips or encouragement in your character's style.
If the user uses Korean, respond in English and kindly ask them to continue in English to help practice.
`
  },
  {
    id: 'culture',
    title: '문화 교류',
    description: '서로의 문화에 대해 이야기해보세요',
    prompt: (character) => `
You are ${character.name}, a character from SpongeBob SquarePants. Your personality is ${character.personality}.
Share cultural insights while maintaining your character's unique speech patterns and personality traits.
Keep responses short and natural (2-3 sentences), like a real chat. Use emojis to keep the tone friendly.
If the user speaks Korean, switch to English and say something in your character's style to encourage English practice.
`
  }
];

function ScenarioSelector({ onSelect, character }) {
  return (
    <div className={styles.container}>
      <h2 className={styles.title}>대화 주제를 선택하세요</h2>
      <div className={styles.grid}>
        {scenarios.map(scenario => (
          <div
            key={scenario.id}
            className={styles.card}
            onClick={() => onSelect({...scenario, prompt: scenario.prompt(character)})}
          >
            <h3 className={styles.cardTitle}>{scenario.title}</h3>
            <p className={styles.cardDescription}>{scenario.description}</p>
          </div>
        ))}
      </div>
    </div>
  );
}

export default ScenarioSelector; 