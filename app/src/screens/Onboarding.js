import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  SafeAreaView,
  ScrollView,
} from 'react-native';
import { Wind, Flame, Star, Sunrise, Sun, Moon } from 'lucide-react-native';
import { schedulePracticeReminder } from '../services/notifications';
import useStore from '../store/useStore';

const INTENTIONS = [
  'Reduce Stress',
  'Better Sleep',
  'More Energy',
  'Inner Peace',
  'Daily Discipline',
];

const REMINDERS = [
  { label: 'Morning · 6:30 AM', icon: Sunrise, hour: 6, minute: 30 },
  { label: 'Midday · 12:00 PM', icon: Sun, hour: 12, minute: 0 },
  { label: 'Evening · 7:00 PM', icon: Moon, hour: 19, minute: 0 },
];

const BULLETS = [
  { icon: Wind, text: '5-phase guided SKY sessions' },
  { icon: Flame, text: 'Daily streak & XP to keep you going' },
  { icon: Star, text: 'Science-backed insights after every session' },
];

export const Onboarding = () => {
  const [step, setStep] = useState(0);
  const [intention, setIntention] = useState(null);
  const [reminderIdx, setReminderIdx] = useState(null);
  const completeOnboarding = useStore((state) => state.completeOnboarding);

  // Step 0 — Welcome
  const renderWelcome = () => (
    <View style={styles.stepContainer}>
      <Text style={styles.title}>Welcome to SKY Companion</Text>
      <Text style={styles.subtitle}>Your daily breath practice, guided.</Text>

      <View style={styles.bulletList}>
        {BULLETS.map(({ icon: Icon, text }) => (
          <View key={text} style={styles.bulletRow}>
            <Icon color="#6366f1" size={24} />
            <Text style={styles.bulletText}>{text}</Text>
          </View>
        ))}
      </View>

      <TouchableOpacity style={styles.primaryBtn} onPress={() => setStep(1)}>
        <Text style={styles.primaryBtnText}>Get Started</Text>
      </TouchableOpacity>
    </View>
  );

  // Step 1 — Intention
  const renderIntention = () => (
    <View style={styles.stepContainer}>
      <Text style={styles.heading}>Why are you here?</Text>

      <View style={styles.chipContainer}>
        {INTENTIONS.map((item) => {
          const selected = intention === item;
          return (
            <TouchableOpacity
              key={item}
              style={[styles.chip, selected && styles.chipSelected]}
              onPress={() => setIntention(item)}
            >
              <Text style={[styles.chipText, selected && styles.chipTextSelected]}>
                {item}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>

      <TouchableOpacity
        style={[styles.primaryBtn, !intention && styles.primaryBtnDisabled]}
        disabled={!intention}
        onPress={() => setStep(2)}
      >
        <Text style={styles.primaryBtnText}>Continue</Text>
      </TouchableOpacity>
    </View>
  );

  // Step 2 — Reminder time
  const renderReminder = () => (
    <View style={styles.stepContainer}>
      <Text style={styles.heading}>Choose your practice time</Text>

      <View style={styles.cardList}>
        {REMINDERS.map((item, idx) => {
          const Icon = item.icon;
          const selected = reminderIdx === idx;
          return (
            <TouchableOpacity
              key={item.label}
              style={[styles.timeCard, selected && styles.timeCardSelected]}
              onPress={() => setReminderIdx(idx)}
            >
              <Icon color={selected ? '#fff' : '#6366f1'} size={28} />
              <Text style={[styles.timeCardText, selected && styles.timeCardTextSelected]}>
                {item.label}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>

      <TouchableOpacity
        style={[styles.primaryBtn, reminderIdx === null && styles.primaryBtnDisabled]}
        disabled={reminderIdx === null}
        onPress={async () => {
          const chosen = REMINDERS[reminderIdx];
          await schedulePracticeReminder(chosen.hour, chosen.minute);
          completeOnboarding(intention);
        }}
      >
        <Text style={styles.primaryBtnText}>Begin Practice</Text>
      </TouchableOpacity>
    </View>
  );

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scroll}>
        {step === 0 && renderWelcome()}
        {step === 1 && renderIntention()}
        {step === 2 && renderReminder()}
      </ScrollView>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#fff',
  },
  scroll: {
    flexGrow: 1,
    justifyContent: 'center',
    padding: 24,
  },
  stepContainer: {
    alignItems: 'center',
  },

  // Step 0
  title: {
    fontSize: 28,
    fontWeight: '800',
    color: '#1e293b',
    textAlign: 'center',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 16,
    color: '#64748b',
    textAlign: 'center',
    marginBottom: 32,
  },
  bulletList: {
    width: '100%',
    marginBottom: 40,
  },
  bulletRow: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#f8fafc',
    padding: 16,
    borderRadius: 14,
    marginBottom: 12,
    gap: 14,
  },
  bulletText: {
    fontSize: 15,
    color: '#1e293b',
    flex: 1,
  },

  // Step 1
  heading: {
    fontSize: 22,
    fontWeight: '700',
    color: '#1e293b',
    textAlign: 'center',
    marginBottom: 24,
  },
  chipContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    gap: 10,
    marginBottom: 40,
  },
  chip: {
    paddingHorizontal: 18,
    paddingVertical: 12,
    borderRadius: 24,
    backgroundColor: '#f1f5f9',
  },
  chipSelected: {
    backgroundColor: '#6366f1',
  },
  chipText: {
    fontSize: 15,
    color: '#475569',
    fontWeight: '600',
  },
  chipTextSelected: {
    color: '#fff',
  },

  // Step 2
  cardList: {
    width: '100%',
    marginBottom: 40,
  },
  timeCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#f8fafc',
    padding: 18,
    borderRadius: 16,
    marginBottom: 12,
    gap: 16,
    borderWidth: 2,
    borderColor: 'transparent',
  },
  timeCardSelected: {
    backgroundColor: '#6366f1',
    borderColor: '#6366f1',
  },
  timeCardText: {
    fontSize: 16,
    fontWeight: '600',
    color: '#1e293b',
  },
  timeCardTextSelected: {
    color: '#fff',
  },

  // Shared
  primaryBtn: {
    backgroundColor: '#6366f1',
    paddingVertical: 16,
    paddingHorizontal: 40,
    borderRadius: 16,
    width: '100%',
    alignItems: 'center',
  },
  primaryBtnDisabled: {
    opacity: 0.5,
  },
  primaryBtnText: {
    color: '#fff',
    fontSize: 17,
    fontWeight: '700',
  },
});
