import React, { useMemo } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView } from 'react-native';
import useStore from '../store/useStore';

const MOODS = [
  { emoji: '😔', score: 1 },
  { emoji: '😕', score: 2 },
  { emoji: '😐', score: 3 },
  { emoji: '🙂', score: 4 },
  { emoji: '😊', score: 5 },
];

const INSIGHTS = [
  'Your HRV improves within minutes of rhythmic breathing.',
  'SKY breathing activates the parasympathetic nervous system.',
  'Slow breath at 5 breaths/min maximises vagal tone.',
  'Post-session rest consolidates neuroplasticity gains.',
  'Coherent breathing synchronises heart and brain rhythms.',
];

const formatDuration = (seconds) => {
  const mins = Math.floor(seconds / 60);
  const secs = seconds % 60;
  return `${mins}m ${secs}s`;
};

export const PostSession = ({ navigation, route }) => {
  const { durationSeconds = 0, type = 'full' } = route.params || {};
  const logSession = useStore((state) => state.logSession);
  const xpEarned = type === 'full' ? 100 : 50;

  const insight = useMemo(() => {
    return INSIGHTS[Math.floor(Math.random() * INSIGHTS.length)];
  }, []);

  const handleMoodSelect = async (score) => {
    await logSession({ type, durationSeconds, moodScore: score });
    navigation.navigate('Home');
  };

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.title}>Session Complete</Text>

        {/* Session Summary Card */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Summary</Text>
          <View style={styles.statRow}>
            <View style={styles.stat}>
              <Text style={styles.statValue}>{formatDuration(durationSeconds)}</Text>
              <Text style={styles.statLabel}>Duration</Text>
            </View>
            <View style={styles.statDivider} />
            <View style={styles.stat}>
              <Text style={styles.statValue}>+{xpEarned} XP</Text>
              <Text style={styles.statLabel}>Earned</Text>
            </View>
          </View>
        </View>

        {/* Insight Card */}
        <View style={[styles.card, styles.insightCard]}>
          <Text style={styles.insightLabel}>Science Insight</Text>
          <Text style={styles.insightText}>{insight}</Text>
        </View>

        {/* Mood Log */}
        <View style={styles.moodSection}>
          <Text style={styles.moodTitle}>How do you feel?</Text>
          <View style={styles.moodRow}>
            {MOODS.map(({ emoji, score }) => (
              <TouchableOpacity
                key={score}
                style={styles.moodButton}
                onPress={() => handleMoodSelect(score)}
              >
                <Text style={styles.moodEmoji}>{emoji}</Text>
              </TouchableOpacity>
            ))}
          </View>
        </View>
      </View>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8fafc',
  },
  content: {
    flex: 1,
    padding: 24,
    justifyContent: 'center',
  },
  title: {
    fontSize: 28,
    fontWeight: '700',
    color: '#1e293b',
    textAlign: 'center',
    marginBottom: 24,
  },
  card: {
    backgroundColor: '#fff',
    borderRadius: 16,
    padding: 20,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.06,
    shadowRadius: 8,
    elevation: 3,
  },
  cardTitle: {
    fontSize: 14,
    fontWeight: '600',
    color: '#64748b',
    marginBottom: 12,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  statRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
  },
  stat: {
    alignItems: 'center',
    flex: 1,
  },
  statValue: {
    fontSize: 22,
    fontWeight: '700',
    color: '#6366f1',
  },
  statLabel: {
    fontSize: 13,
    color: '#94a3b8',
    marginTop: 4,
  },
  statDivider: {
    width: 1,
    height: 40,
    backgroundColor: '#e2e8f0',
  },
  insightCard: {
    backgroundColor: '#eef2ff',
  },
  insightLabel: {
    fontSize: 12,
    fontWeight: '600',
    color: '#6366f1',
    marginBottom: 8,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  insightText: {
    fontSize: 15,
    color: '#1e293b',
    lineHeight: 22,
  },
  moodSection: {
    marginTop: 8,
  },
  moodTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1e293b',
    textAlign: 'center',
    marginBottom: 16,
  },
  moodRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  moodButton: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: '#fff',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 6,
    elevation: 3,
  },
  moodEmoji: {
    fontSize: 28,
  },
});
