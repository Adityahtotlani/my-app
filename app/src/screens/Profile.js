import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity, SafeAreaView, Alert } from 'react-native';
import useStore from '../store/useStore';
import { LogOut, User, Settings, Bell, Shield, Flame, Star } from 'lucide-react-native';

const getLevelName = (level) => {
  const names = ['', 'Seeker', 'Practitioner', 'Steady Breather', 'Inner Circle', 'SKY Guide', 'Luminous'];
  return names[level] || 'Seeker';
};

export const Profile = () => {
  const { user, logout } = useStore();

  const handleLogout = () => {
    Alert.alert('Logout', 'Are you sure you want to log out?', [
      { text: 'Cancel', style: 'cancel' },
      { text: 'Logout', style: 'destructive', onPress: logout }
    ]);
  };

  const ProfileItem = ({ icon: Icon, label, value }) => (
    <View style={styles.item}>
      <View style={styles.itemLeft}>
        <Icon color="#64748b" size={20} />
        <Text style={styles.itemLabel}>{label}</Text>
      </View>
      <Text style={styles.itemValue}>{value}</Text>
    </View>
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
        <ProfileItem icon={Settings} label="Practice Reminder" value="6:30 AM" />
        <ProfileItem icon={Bell} label="Notifications" value="Enabled" />
        <ProfileItem icon={Shield} label="Privacy" value="Managed" />
        <ProfileItem icon={Flame} label="Personal Best Streak" value={`${user?.max_streak || 0} days`} />
        <ProfileItem icon={Star} label="Level" value={`${getLevelName(user?.level)} (Lvl ${user?.level})`} />
      </View>

      <TouchableOpacity style={styles.logoutButton} onPress={handleLogout}>
        <LogOut color="#ef4444" size={20} />
        <Text style={styles.logoutText}>Log Out</Text>
      </TouchableOpacity>
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
});
