import React from 'react';
import { View, Text, StyleSheet } from 'react-native';

const Placeholder = ({ name }) => (
  <View style={styles.container}>
    <Text style={styles.text}>{name} Screen</Text>
    <Text style={styles.subtext}>Coming Soon</Text>
  </View>
);

export { Practice } from './Practice';
export { Login } from './Login';
export { Register } from './Register';
export { Home } from './Home';
export { Profile } from './Profile';
export { Progress } from './Progress';
export { PostSession } from './PostSession';
export { Community } from './Community';

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#f8fafc',
  },
  text: {
    fontSize: 24,
    fontWeight: 'bold',
    color: '#1e293b',
  },
  subtext: {
    fontSize: 16,
    color: '#64748b',
    marginTop: 8,
  },
});
