import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView, ScrollView, Linking } from 'react-native';
import useStore from '../store/useStore';
import { Flame, Star, Trophy, ArrowRight } from 'lucide-react-native';

const MILESTONES = [
  {
    minStreak: 90,
    title: "You're a Practitioner Now \u2726",
    body: "90 days. You've earned the title. Consider deepening your practice with Part 2.",
    teacher: 'Art of Living Foundation',
  },
  {
    minStreak: 40,
    title: 'The 40-Day Transformation \u2726',
    body: '40 days of consistent practice creates lasting physiological change. Welcome to the other side.',
    teacher: 'Bhanu Narasimhan, Sr. Teacher',
  },
  {
    minStreak: 21,
    title: '21 Days \u2014 You\u2019ve built a habit \u2726',
    body: 'Neuroscience confirms: 21 days is when new neural pathways stabilise. You\u2019re there.',
    teacher: 'Dinesh K., AoL Faculty',
  },
  {
    minStreak: 7,
    title: "You've built your first week \u2726",
    body: 'The first week is the hardest. Your body is learning a new rhythm. Keep going.',
    teacher: 'Ravi Shankar, Sr. Teacher',
  },
];

export const Home = ({ navigation }) => {
  const user = useStore((state) => state.user);
  const refreshUser = useStore((state) => state.refreshUser);
  const [retreatDismissed, setRetreatDismissed] = useState(false);

  useEffect(() => {
    refreshUser();
  }, []);

  const streak = user?.current_streak || 0;

  const activeMilestone = MILESTONES.find((m) => streak >= m.minStreak) || null;

  const showRetreatBanner = streak >= 30 && !retreatDismissed;

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.content}>
        <View style={styles.header}>
          <Text style={styles.greeting}>Namaste,</Text>
          <Text style={styles.username}>{user?.email.split('@')[0]}</Text>
        </View>

        <View style={styles.statsContainer}>
          <View style={styles.statCard}>
            <Flame color="#ef4444" size={32} />
            <Text style={styles.statValue}>{user?.current_streak || 0}</Text>
            <Text style={styles.statLabel}>Day Streak</Text>
          </View>
          <View style={styles.statCard}>
            <Trophy color="#eab308" size={32} />
            <Text style={styles.statValue}>{user?.level || 1}</Text>
            <Text style={styles.statLabel}>Level</Text>
          </View>
        </View>

        <View style={styles.xpCard}>
          <View style={styles.xpHeader}>
            <Star color="#6366f1" size={24} />
            <Text style={styles.xpTitle}>Total XP: {user?.total_xp || 0}</Text>
          </View>
          <View style={styles.progressBar}>
            <View style={[styles.progressFill, { width: `${(user?.total_xp % 1000) / 10}%` }]} />
          </View>
          <Text style={styles.xpFooter}>{1000 - (user?.total_xp % 1000)} XP to Level {user?.level + 1}</Text>
        </View>

        <TouchableOpacity
          style={styles.ctaButton}
          onPress={() => navigation.navigate('Practice')}
        >
          <View>
            <Text style={styles.ctaTitle}>Ready for SKY?</Text>
            <Text style={styles.ctaSubtitle}>Guided Daily Practice • 35m</Text>
          </View>
          <ArrowRight color="#fff" size={24} />
        </TouchableOpacity>

        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Your Journey</Text>
        </View>

        <View style={styles.journeyCard}>
          <Text style={styles.journeyText}>You've completed the SKY Breath Meditation course. Keep the momentum going to experience deep rest and clarity.</Text>
        </View>

        {activeMilestone && (
          <View style={styles.milestoneCard}>
            <Text style={styles.milestoneTitle}>{activeMilestone.title}</Text>
            <Text style={styles.milestoneBody}>{activeMilestone.body}</Text>
            <Text style={styles.milestoneTeacher}>{activeMilestone.teacher}</Text>
          </View>
        )}

        {showRetreatBanner && (
          <View style={styles.retreatCard}>
            <Text style={styles.retreatTitle}>Ready to go deeper?</Text>
            <Text style={styles.retreatBody}>
              You've practiced 30 days in a row. The AoL Part 2 retreat is where the next transformation happens.
            </Text>
            <TouchableOpacity
              style={styles.retreatButton}
              onPress={() => Linking.openURL('https://www.artofliving.org/us-en/advance-meditation-course')}
            >
              <Text style={styles.retreatButtonText}>Browse Upcoming Retreats</Text>
            </TouchableOpacity>
            <TouchableOpacity onPress={() => setRetreatDismissed(true)}>
              <Text style={styles.retreatDismiss}>Remind me later</Text>
            </TouchableOpacity>
          </View>
        )}
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
  header: {
    marginBottom: 30,
  },
  greeting: {
    fontSize: 18,
    color: '#64748b',
  },
  username: {
    fontSize: 28,
    fontWeight: '800',
    color: '#1e293b',
  },
  statsContainer: {
    flexDirection: 'row',
    gap: 15,
    marginBottom: 20,
  },
  statCard: {
    flex: 1,
    backgroundColor: '#fff',
    padding: 20,
    borderRadius: 20,
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
  },
  statValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1e293b',
    marginTop: 10,
  },
  statLabel: {
    fontSize: 14,
    color: '#64748b',
    marginTop: 2,
  },
  xpCard: {
    backgroundColor: '#fff',
    padding: 20,
    borderRadius: 20,
    marginBottom: 30,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
  },
  xpHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 10,
    marginBottom: 15,
  },
  xpTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1e293b',
  },
  progressBar: {
    height: 10,
    backgroundColor: '#f1f5f9',
    borderRadius: 5,
    overflow: 'hidden',
  },
  progressFill: {
    height: '100%',
    backgroundColor: '#6366f1',
  },
  xpFooter: {
    fontSize: 12,
    color: '#94a3b8',
    marginTop: 10,
    textAlign: 'right',
  },
  ctaButton: {
    backgroundColor: '#6366f1',
    padding: 25,
    borderRadius: 20,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 30,
    shadowColor: '#6366f1',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 10,
    elevation: 8,
  },
  ctaTitle: {
    color: '#fff',
    fontSize: 20,
    fontWeight: 'bold',
  },
  ctaSubtitle: {
    color: 'rgba(255, 255, 255, 0.8)',
    fontSize: 14,
    marginTop: 4,
  },
  sectionHeader: {
    marginBottom: 15,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1e293b',
  },
  journeyCard: {
    backgroundColor: '#eef2ff',
    padding: 20,
    borderRadius: 20,
    borderWidth: 1,
    borderColor: '#e0e7ff',
    marginBottom: 20,
  },
  journeyText: {
    color: '#4338ca',
    lineHeight: 22,
    fontSize: 15,
  },
  milestoneCard: {
    backgroundColor: '#fff',
    padding: 16,
    borderRadius: 16,
    borderLeftWidth: 4,
    borderLeftColor: '#6366f1',
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.05,
    shadowRadius: 10,
    elevation: 2,
  },
  milestoneTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#6366f1',
    marginBottom: 8,
  },
  milestoneBody: {
    fontSize: 14,
    color: '#475569',
    lineHeight: 20,
    marginBottom: 8,
  },
  milestoneTeacher: {
    fontSize: 12,
    color: '#94a3b8',
  },
  retreatCard: {
    backgroundColor: '#fef9c3',
    borderWidth: 1,
    borderColor: '#fde68a',
    padding: 16,
    borderRadius: 16,
    marginBottom: 20,
  },
  retreatTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#1e293b',
    marginBottom: 8,
  },
  retreatBody: {
    fontSize: 14,
    color: '#475569',
    lineHeight: 20,
    marginBottom: 16,
  },
  retreatButton: {
    backgroundColor: '#6366f1',
    padding: 12,
    borderRadius: 10,
    alignItems: 'center',
    marginBottom: 12,
  },
  retreatButtonText: {
    color: '#fff',
    fontSize: 14,
    fontWeight: '600',
  },
  retreatDismiss: {
    textAlign: 'center',
    fontSize: 13,
    color: '#94a3b8',
  },
});
