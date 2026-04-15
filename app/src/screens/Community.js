import React from 'react';
import { View, Text, StyleSheet, SafeAreaView } from 'react-native';

export const Community = () => {
  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.content}>
        <Text style={styles.header}>Community</Text>

        {/* Satsang Finder Card */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Satsang Finder</Text>
          <Text style={styles.cardBody}>
            Find local & virtual group sessions near you — coming soon.
          </Text>
        </View>

        {/* Stat Card */}
        <View style={[styles.card, styles.statCard]}>
          <Text style={styles.statText}>
            You're practicing alongside thousands of Art of Living alumni worldwide.
          </Text>
        </View>

        {/* XP Reminder Card */}
        <View style={[styles.card, styles.xpCard]}>
          <Text style={styles.xpBadge}>+75 XP</Text>
          <Text style={styles.xpLabel}>when you attend a Satsang</Text>
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
  },
  header: {
    fontSize: 28,
    fontWeight: '700',
    color: '#1e293b',
    marginBottom: 24,
    marginTop: 8,
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
    fontSize: 18,
    fontWeight: '700',
    color: '#1e293b',
    marginBottom: 8,
  },
  cardBody: {
    fontSize: 15,
    color: '#64748b',
    lineHeight: 22,
  },
  statCard: {
    backgroundColor: '#eef2ff',
  },
  statText: {
    fontSize: 15,
    color: '#3730a3',
    lineHeight: 22,
    fontStyle: 'italic',
  },
  xpCard: {
    backgroundColor: '#f0fdf4',
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  xpBadge: {
    fontSize: 20,
    fontWeight: '700',
    color: '#16a34a',
  },
  xpLabel: {
    fontSize: 15,
    color: '#15803d',
  },
});
