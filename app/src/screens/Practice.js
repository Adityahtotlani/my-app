import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView } from 'react-native';
import BreathCircle from '../components/BreathCircle';
import { Play, Pause, SkipForward } from 'lucide-react-native';
import useStore from '../store/useStore';

const FULL_PHASES = [
  { id: 'warmup', name: 'Warming Breaths', duration: 300, breathRate: 4000 },
  { id: 'slow', name: 'SKY - Slow Cycle', duration: 480, breathRate: 10000 },
  { id: 'medium', name: 'SKY - Medium Cycle', duration: 480, breathRate: 6000 },
  { id: 'fast', name: 'SKY - Fast Cycle', duration: 300, breathRate: 2000 },
  { id: 'rest', name: 'Rest & Integration', duration: 300, breathRate: 0, isResting: true },
];

const SHORT_PHASES = [
  { id: 'warmup', name: 'Warming Breaths', duration: 180, breathRate: 4000 },
  { id: 'slow', name: 'SKY - Slow Cycle', duration: 240, breathRate: 10000 },
  { id: 'medium', name: 'SKY - Medium Cycle', duration: 240, breathRate: 6000 },
  { id: 'fast', name: 'SKY - Fast Cycle', duration: 120, breathRate: 2000 },
  { id: 'rest', name: 'Rest & Integration', duration: 120, breathRate: 0, isResting: true },
];

export const Practice = ({ navigation }) => {
  const [isActive, setIsActive] = useState(false);
  const [currentPhaseIndex, setCurrentPhaseIndex] = useState(0);
  const [sessionType, setSessionType] = useState('full');

  const PHASES = sessionType === 'full' ? FULL_PHASES : SHORT_PHASES;
  const [timeLeft, setTimeLeft] = useState(PHASES[0].duration);

  const currentPhase = PHASES[currentPhaseIndex];
  const sessionNotStarted = !isActive && currentPhaseIndex === 0 && timeLeft === PHASES[0].duration;

  // Reset timeLeft when sessionType changes (only when session hasn't started)
  useEffect(() => {
    if (sessionNotStarted) {
      const phases = sessionType === 'full' ? FULL_PHASES : SHORT_PHASES;
      setTimeLeft(phases[0].duration);
    }
  }, [sessionType]);

  useEffect(() => {
    let interval = null;
    if (isActive && timeLeft > 0) {
      interval = setInterval(() => {
        setTimeLeft((prev) => prev - 1);
      }, 1000);
    } else if (isActive && timeLeft === 0) {
      nextPhase();
    }
    return () => clearInterval(interval);
  }, [isActive, timeLeft]);

  const nextPhase = () => {
    if (currentPhaseIndex < PHASES.length - 1) {
      const nextIndex = currentPhaseIndex + 1;
      setCurrentPhaseIndex(nextIndex);
      setTimeLeft(PHASES[nextIndex].duration);
    } else {
      setIsActive(false);
      const totalSeconds = PHASES.reduce((acc, p) => acc + p.duration, 0);
      navigation.navigate('PostSession', { type: sessionType, durationSeconds: totalSeconds });
    }
  };

  const formatTime = (seconds) => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins}:${secs.toString().padStart(2, '0')}`;
  };

  // Phase progress bar calculation
  const phaseProgress =
    (currentPhaseIndex + (1 - timeLeft / currentPhase.duration)) / PHASES.length;

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.phaseName}>{currentPhase.name}</Text>
        <Text style={styles.timer}>{formatTime(timeLeft)}</Text>
      </View>

      {/* Phase Progress Bar */}
      <View style={styles.progressBarWrapper}>
        <View style={styles.progressBarTrack}>
          <View style={[styles.progressBarFill, { width: `${phaseProgress * 100}%` }]} />
        </View>
        <View style={styles.phaseLabelsRow}>
          {PHASES.map((phase, index) => (
            <Text
              key={phase.id}
              style={[
                styles.phaseLabel,
                index === currentPhaseIndex && styles.phaseLabelActive,
              ]}
              numberOfLines={1}
            >
              {phase.name.split(' ')[0]}
            </Text>
          ))}
        </View>
      </View>

      {/* Session Type Selector — only shown before session starts */}
      {sessionNotStarted && (
        <View style={styles.sessionTypeRow}>
          <TouchableOpacity
            style={[styles.typeButton, sessionType === 'full' && styles.typeButtonActive]}
            onPress={() => setSessionType('full')}
          >
            <Text style={[styles.typeButtonText, sessionType === 'full' && styles.typeButtonTextActive]}>
              Full Session
            </Text>
            <Text style={[styles.typeButtonSub, sessionType === 'full' && styles.typeButtonSubActive]}>
              35 min
            </Text>
          </TouchableOpacity>
          <TouchableOpacity
            style={[styles.typeButton, sessionType === 'short' && styles.typeButtonActive]}
            onPress={() => setSessionType('short')}
          >
            <Text style={[styles.typeButtonText, sessionType === 'short' && styles.typeButtonTextActive]}>
              Short Session
            </Text>
            <Text style={[styles.typeButtonSub, sessionType === 'short' && styles.typeButtonSubActive]}>
              15 min
            </Text>
          </TouchableOpacity>
        </View>
      )}

      <View style={styles.center}>
        <BreathCircle
          duration={currentPhase.breathRate}
          isResting={currentPhase.isResting}
        />
      </View>

      <View style={styles.footer}>
        <View style={styles.controls}>
          <TouchableOpacity
            style={styles.controlButton}
            onPress={() => setIsActive(!isActive)}
          >
            {isActive ? <Pause color="#fff" size={32} /> : <Play color="#fff" size={32} />}
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.skipButton}
            onPress={nextPhase}
          >
            <SkipForward color="#64748b" size={24} />
          </TouchableOpacity>
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
  header: {
    alignItems: 'center',
    marginTop: 40,
  },
  phaseName: {
    fontSize: 24,
    fontWeight: '700',
    color: '#1e293b',
  },
  timer: {
    fontSize: 48,
    fontWeight: '300',
    color: '#6366f1',
    marginTop: 10,
  },
  progressBarWrapper: {
    paddingHorizontal: 24,
    marginTop: 16,
  },
  progressBarTrack: {
    height: 6,
    backgroundColor: '#e2e8f0',
    borderRadius: 3,
    overflow: 'hidden',
  },
  progressBarFill: {
    height: 6,
    backgroundColor: '#6366f1',
    borderRadius: 3,
  },
  phaseLabelsRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginTop: 6,
  },
  phaseLabel: {
    fontSize: 10,
    color: '#94a3b8',
    flex: 1,
    textAlign: 'center',
  },
  phaseLabelActive: {
    color: '#6366f1',
    fontWeight: '600',
  },
  sessionTypeRow: {
    flexDirection: 'row',
    paddingHorizontal: 24,
    marginTop: 20,
    gap: 12,
  },
  typeButton: {
    flex: 1,
    paddingVertical: 14,
    borderRadius: 12,
    backgroundColor: '#fff',
    alignItems: 'center',
    borderWidth: 2,
    borderColor: '#e2e8f0',
  },
  typeButtonActive: {
    borderColor: '#6366f1',
    backgroundColor: '#eef2ff',
  },
  typeButtonText: {
    fontSize: 15,
    fontWeight: '600',
    color: '#64748b',
  },
  typeButtonTextActive: {
    color: '#6366f1',
  },
  typeButtonSub: {
    fontSize: 12,
    color: '#94a3b8',
    marginTop: 2,
  },
  typeButtonSubActive: {
    color: '#818cf8',
  },
  center: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  footer: {
    paddingBottom: 40,
    alignItems: 'center',
  },
  controls: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 20,
  },
  controlButton: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: '#6366f1',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#6366f1',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 10,
    elevation: 8,
  },
  skipButton: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: '#e2e8f0',
    justifyContent: 'center',
    alignItems: 'center',
  },
});
