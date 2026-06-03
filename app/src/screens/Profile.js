import React, { useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView, Alert, Modal } from 'react-native';
import useStore from '../store/useStore';
import { schedulePracticeReminder } from '../services/notifications';
import { LogOut, User, Settings, Bell, Shield, Flame, Star, Sunrise, Sun, Moon } from 'lucide-react-native';

const REMINDERS = [
  { label: 'Morning · 6:30 AM', icon: Sunrise, hour: 6, minute: 30 },
  { label: 'Midday · 12:00 PM', icon: Sun, hour: 12, minute: 0 },
  { label: 'Evening · 7:00 PM', icon: Moon, hour: 19, minute: 0 },
];

const formatReminder = (hour, minute) => {
  const period = hour < 12 ? 'AM' : 'PM';
  const displayHour = hour % 12 || 12;
  const displayMinute = minute.toString().padStart(2, '0');
  return `${displayHour}:${displayMinute} ${period}`;
};

const getLevelName = (level) => {
  const names = ['', 'Seeker', 'Practitioner', 'Steady Breather', 'Inner Circle', 'SKY Guide', 'Luminous'];
  return names[level] || 'Seeker';
};

export const Profile = () => {
  const { user, logout, reminderHour, reminderMinute, setReminder } = useStore();
  const [showReminderModal, setShowReminderModal] = useState(false);
  const [selectedIdx, setSelectedIdx] = useState(() =>
    REMINDERS.findIndex((r) => r.hour === reminderHour && r.minute === reminderMinute)
  );

  const handleLogout = () => {
    Alert.alert('Logout', 'Are you sure you want to log out?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Logout', style: 'destructive', onPress: logout },
    ]);
  };

  const handleSaveReminder = async () => {
    if (selectedIdx === -1) return;
    const chosen = REMINDERS[selectedIdx];
    await schedulePracticeReminder(chosen.hour, chosen.minute);
    setReminder(chosen.hour, chosen.minute);
    setShowReminderModal(false);
  };

  const ProfileItem = ({ icon: Icon, label, value, onPress }) => (
    <TouchableOpacity style={styles.item} onPress={onPress} disabled={!onPress}>
      <View style={styles.itemLeft}>
        <Icon color="#64748b" size={20} />
        <Text style={styles.itemLabel}>{label}</Text>
      </View>
      <Text style={[styles.itemValue, onPress && styles.itemValueTappable]}>{value}</Text>
    </TouchableOpacity>
  );

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.header}>
        <View style={styles.avatar}>
          <User color="#6366f1" size={40} />
        </View>
        <Text style={styles.email}>{user?.email}</Text>
        <View style={styles.levelBadge}>
          <Text style={styles.levelBadgeText}>{getLevelName(user?.level)}</Text>
        </View>
        <View style={styles.badge}>
          <Text style={styles.badgeText}>Verified Practitioner</Text>
        </View>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Account Settings</Text>
        <ProfileItem
          icon={Settings}
          label="Practice Reminder"
          value={formatReminder(reminderHour, reminderMinute)}
          onPress={() => setShowReminderModal(true)}
        />
        <ProfileItem icon={Bell} label="Notifications" value="Enabled" />
        <ProfileItem icon={Shield} label="Privacy" value="Managed" />
        <ProfileItem icon={Flame} label="Personal Best Streak" value={`${user?.max_streak || 0} days`} />
        <ProfileItem icon={Star} label="Level" value={`${getLevelName(user?.level)} (Lvl ${user?.level})`} />
      </View>

      <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
        <LogOut color="#ef4444" size={20} />
        <Text style={styles.logoutText}>Log Out</Text>
      </TouchableOpacity>

      <Modal visible={showReminderModal} transparent animationType="slide">
        <View style={styles.modalOverlay}>
          <View style={styles.modalSheet}>
            <Text style={styles.modalTitle}>Change Reminder</Text>
            {REMINDERS.map((item, idx) => {
              const Icon = item.icon;
              const selected = selectedIdx === idx;
              return (
                <TouchableOpacity
                  key={item.label}
                  style={[styles.timeCard, selected && styles.timeCardSelected]}
                  onPress={() => setSelectedIdx(idx)}
                >
                  <Icon color={selected ? '#fff' : '#6366f1'} size={24} />
                  <Text style={[styles.timeCardText, selected && styles.timeCardTextSelected]}>
                    {item.label}
                  </Text>
                </TouchableOpacity>
              );
            })}
            <TouchableOpacity
              style={[styles.saveButton, selectedIdx === -1 && styles.saveButtonDisabled]}
              onPress={handleSaveReminder}
              disabled={selectedIdx === -1}
            >
              <Text style={styles.saveButtonText}>Save</Text>
            </TouchableOpacity>
            <TouchableOpacity onPress={() => setShowReminderModal(false)}>
              <Text style={styles.cancelText}>Cancel</Text>
            </TouchableOpacity>
          </View>
        </View>
      </Modal>
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
    padding: 40,
    backgroundColor: '#fff',
    borderBottomWidth: 1,
    borderBottomColor: '#f1f5f9',
  },
  avatar: {
    width: 80,
    height: 80,
    borderRadius: 40,
    backgroundColor: '#eef2ff',
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 15,
  },
  email: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1e293b',
  },
  levelBadge: {
    backgroundColor: '#eef2ff',
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 20,
    marginTop: 8,
  },
  levelBadgeText: {
    color: '#6366f1',
    fontSize: 12,
    fontWeight: '600',
  },
  badge: {
    backgroundColor: '#dcfce7',
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 20,
    marginTop: 8,
  },
  badgeText: {
    color: '#166534',
    fontSize: 12,
    fontWeight: '600',
  },
  section: {
    padding: 20,
    marginTop: 20,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#64748b',
    marginBottom: 15,
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  item: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: '#fff',
    padding: 15,
    borderRadius: 12,
    marginBottom: 10,
  },
  itemLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 12,
  },
  itemLabel: {
    fontSize: 16,
    color: '#1e293b',
  },
  itemValue: {
    fontSize: 16,
    color: '#94a3b8',
  },
  itemValueTappable: {
    color: '#6366f1',
    fontWeight: '600',
  },
  logoutButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 10,
    marginTop: 'auto',
    marginBottom: 40,
    marginHorizontal: 20,
    padding: 15,
    backgroundColor: '#fee2e2',
    borderRadius: 12,
  },
  logoutText: {
    color: '#ef4444',
    fontSize: 16,
    fontWeight: 'bold',
  },
  modalOverlay: {
    flex: 1,
    backgroundColor: 'rgba(0,0,0,0.4)',
    justifyContent: 'flex-end',
  },
  modalSheet: {
    backgroundColor: '#fff',
    borderTopLeftRadius: 24,
    borderTopRightRadius: 24,
    padding: 24,
    paddingBottom: 40,
  },
  modalTitle: {
    fontSize: 20,
    fontWeight: '700',
    color: '#1e293b',
    marginBottom: 20,
  },
  timeCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#f8fafc',
    padding: 16,
    borderRadius: 14,
    marginBottom: 12,
    gap: 14,
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
  saveButton: {
    backgroundColor: '#6366f1',
    paddingVertical: 16,
    borderRadius: 14,
    alignItems: 'center',
    marginTop: 8,
    marginBottom: 12,
  },
  saveButtonDisabled: {
    opacity: 0.5,
  },
  saveButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '700',
  },
  cancelText: {
    textAlign: 'center',
    fontSize: 15,
    color: '#94a3b8',
  },
});
