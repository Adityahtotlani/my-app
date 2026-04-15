import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

const CELL_SIZE = 28;
const CELL_GAP = 4;
const COLUMNS = 10;
const ROWS = 7;
const TOTAL_DAYS = COLUMNS * ROWS; // 70

const StreakCalendar = ({ practicedDates }) => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);

  const practicedSet = new Set(practicedDates || []);

  // Build array of 70 day-strings, index 0 = oldest, index 69 = today
  const days = [];
  for (let i = TOTAL_DAYS - 1; i >= 0; i--) {
    const d = new Date(today);
    d.setDate(today.getDate() - i);
    const iso = d.toISOString().slice(0, 10);
    days.push(iso);
  }

  const todayIso = today.toISOString().slice(0, 10);

  return (
    <View>
      <Text style={styles.label}>Practice Streak Calendar (last 70 days)</Text>
      <View style={styles.grid}>
        {days.map((iso) => {
          const isPracticed = practicedSet.has(iso);
          const isToday = iso === todayIso;
          return (
            <View
              key={iso}
              style={[
                styles.cell,
                isPracticed ? styles.cellActive : styles.cellInactive,
                isToday && styles.cellToday,
              ]}
            />
          );
        })}
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  label: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#64748b',
    marginBottom: 12,
  },
  grid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: CELL_GAP,
  },
  cell: {
    width: CELL_SIZE,
    height: CELL_SIZE,
    borderRadius: 6,
  },
  cellActive: {
    backgroundColor: '#6366f1',
  },
  cellInactive: {
    backgroundColor: '#e2e8f0',
  },
  cellToday: {
    borderWidth: 2,
    borderColor: '#6366f1',
  },
});

export default StreakCalendar;
