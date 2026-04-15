import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, SafeAreaView, ScrollView, ActivityIndicator } from 'react-native';
import { VictoryLine, VictoryChart, VictoryTheme, VictoryAxis } from 'victory-native';
import useStore from '../store/useStore';
import StreakCalendar from '../components/StreakCalendar';

const LEVEL_THRESHOLDS = [0, 500, 1500, 3500, 7000, 12000];
const LEVEL_NAMES = ['', 'Seeker', 'Practitioner', 'Steady Breather', 'Inner Circle', 'SKY Guide', 'Luminous'];

const getLevelName = (level) => LEVEL_NAMES[level] || 'Seeker';

const getXPProgress = (totalXP, level) => {
  if (level >= 6) return { prevThreshold: 12000, nextThreshold: 12000, isMax: true };
  const prevThreshold = LEVEL_THRESHOLDS[level - 1];
  const nextThreshold = LEVEL_THRESHOLDS[level];
  return { prevThreshold, nextThreshold, isMax: false };
};

export const Progress = () => {
  const [history, setHistory] = useState([]);
  const [practicedDates, setPracticedDates] = useState([]);
  const [moodTrend, setMoodTrend] = useState([]);
  const [loading, setLoading] = useState(true);
  const token = useStore((state) => state.token);
  const user = useStore((state) => state.user);

  useEffect(() => {
    fetchAll();
  }, []);

  const fetchAll = async () => {
    try {
      await Promise.all([fetchHistory(), fetchStreakCalendar(), fetchMoodTrend()]);
    } finally {
      setLoading(false);
    }
  };

  const fetchHistory = async () => {
    try {
      const response = await fetch('http://localhost:3000/api/sessions/history', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      const data = await response.json();
      setHistory(data);
    } catch (error) {
      console.error('Failed to fetch history', error);
    }
  };

  const fetchStreakCalendar = async () => {
    try {
      const response = await fetch('http://localhost:3000/api/sessions/streak-calendar', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      const data = await response.json();
      setPracticedDates(data.dates || []);
    } catch (error) {
      console.error('Failed to fetch streak calendar', error);
    }
  };

  const fetchMoodTrend = async () => {
    try {
      const response = await fetch('http://localhost:3000/api/sessions/mood-trend', {
        headers: { 'Authorization': `Bearer ${token}` }
      });
      const data = await response.json();
      setMoodTrend(data);
    } catch (error) {
      console.error('Failed to fetch mood trend', error);
    }
  };

  if (loading) {
    return (
      <View style={styles.loading}>
        <ActivityIndicator size="large" color="#6366f1" />
      </View>
    );
  }

  const totalXP = user?.total_xp || 0;
  const level = user?.level || 1;
  const { prevThreshold, nextThreshold, isMax } = getXPProgress(totalXP, level);
  const xpFillRatio = isMax
    ? 1
    : (totalXP - prevThreshold) / (nextThreshold - prevThreshold);

  const totalSessions = history.length;
  const avgDuration = totalSessions > 0
    ? Math.floor(history.reduce((acc, s) => acc + s.duration_seconds, 0) / totalSessions / 60)
    : 0;
  const personalBest = user?.max_streak || 0;

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <Text style={styles.title}>Your Progress</Text>

        {/* A. Streak Calendar */}
        <View style={styles.card}>
          <StreakCalendar practicedDates={practicedDates} />
        </View>

        {/* B. Mood Trend Chart */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Mood Trend (Last 14 Sessions)</Text>
          {moodTrend.length > 0 ? (
            <VictoryChart
              theme={VictoryTheme.material}
              domainPadding={10}
              height={200}
              domain={{ y: [1, 5] }}
            >
              <VictoryAxis
                style={{
                  axis: { stroke: '#e2e8f0' },
                  tickLabels: { fontSize: 10, fill: '#64748b' }
                }}
              />
              <VictoryAxis
                dependentAxis
                tickValues={[1, 2, 3, 4, 5]}
                style={{
                  axis: { stroke: 'transparent' },
                  grid: { stroke: '#f1f5f9' },
                  tickLabels: { fontSize: 10, fill: '#64748b' }
                }}
              />
              <VictoryLine
                data={moodTrend}
                x="day"
                y="mood"
                style={{
                  data: { stroke: '#10b981', strokeWidth: 2 }
                }}
              />
            </VictoryChart>
          ) : (
            <Text style={styles.emptyText}>No mood data yet. Log some sessions to see your trend.</Text>
          )}
        </View>

        {/* C. XP / Level Card */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>XP &amp; Level</Text>
          <View style={styles.levelRow}>
            <Text style={styles.levelNumber}>Lvl {level}</Text>
            <Text style={styles.levelName}>{getLevelName(level)}</Text>
          </View>
          <View style={styles.progressBar}>
            <View style={[styles.progressFill, { width: `${Math.min(xpFillRatio * 100, 100)}%` }]} />
          </View>
          <View style={styles.xpRow}>
            <Text style={styles.xpLabel}>{totalXP} XP</Text>
            {isMax ? (
              <Text style={styles.xpLabel}>Max Level</Text>
            ) : (
              <Text style={styles.xpLabel}>{nextThreshold} XP to next level</Text>
            )}
          </View>
        </View>

        {/* D. Stats Row */}
        <View style={styles.statsGrid}>
          <View style={styles.miniCard}>
            <Text style={styles.miniLabel}>Total Sessions</Text>
            <Text style={styles.miniValue}>{totalSessions}</Text>
          </View>
          <View style={styles.miniCard}>
            <Text style={styles.miniLabel}>Avg. Duration</Text>
            <Text style={styles.miniValue}>{avgDuration}m</Text>
          </View>
          <View style={styles.miniCard}>
            <Text style={styles.miniLabel}>Personal Best</Text>
            <Text style={styles.miniValue}>{personalBest} days</Text>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f8fafc',
  },
  content: {
    padding: 20,
  },
  loading: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  title: {
    fontSize: 28,
    fontWeight: '800',
    color: '#1e293b',
    marginBottom: 20,
  },
  card: {
    backgroundColor: '#fff',
    padding: 20,
    borderRadius: 20,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
  },
  cardTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#64748b',
    marginBottom: 10,
  },
  emptyText: {
    textAlign: 'center',
    color: '#94a3b8',
    marginVertical: 20,
  },
  levelRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    marginBottom: 12,
  },
  levelNumber: {
    fontSize: 22,
    fontWeight: '800',
    color: '#6366f1',
  },
  levelName: {
    fontSize: 18,
    fontWeight: '600',
    color: '#1e293b',
  },
  progressBar: {
    height: 10,
    backgroundColor: '#f1f5f9',
    borderRadius: 5,
    overflow: 'hidden',
    marginBottom: 8,
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#6366f1',
    borderRadius: 5,
  },
  xpRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  xpLabel: {
    fontSize: 12,
    color: '#94a3b8',
  },
  statsGrid: {
    flexDirection: 'row',
    gap: 12,
  },
  miniCard: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 20,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
  },
  miniLabel: {
    fontSize: 11,
    color: '#64748b',
    marginBottom: 5,
    textAlign: 'center',
  },
  miniValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1e293b',
  },
});
