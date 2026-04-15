import React, { useEffect } from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { Home, Practice, Progress, Profile, Login, Register, PostSession, Community } from './src/screens';
import { Home as HomeIcon, Play, BarChart2, User, Users } from 'lucide-react-native';
import useStore from './src/store/useStore';
import { registerForPushNotificationsAsync, schedulePracticeReminder } from './src/services/notifications';

const Tab = createBottomTabNavigator();
const Stack = createNativeStackNavigator();

function AuthStack() {
  return (
    <Stack.Navigator screenOptions={{ headerShown: false }}>
      <Stack.Screen name="Login" component={Login} />
      <Stack.Screen name="Register" component={Register} />
    </Stack.Navigator>
  );
}

function MainTabs() {
  return (
    <Tab.Navigator
      screenOptions={{
        tabBarActiveTintColor: '#6366f1',
        tabBarInactiveTintColor: '#94a3b8',
        headerShown: false,
      }}
    >
      <Tab.Screen 
        name="Home" 
        component={Home} 
        options={{ tabBarIcon: ({ color }) => <HomeIcon color={color} size={24} /> }}
      />
      <Tab.Screen 
        name="Practice" 
        component={Practice} 
        options={{ tabBarIcon: ({ color }) => <Play color={color} size={24} /> }}
      />
      <Tab.Screen
        name="Progress"
        component={Progress}
        options={{ tabBarIcon: ({ color }) => <BarChart2 color={color} size={24} /> }}
      />
      <Tab.Screen
        name="Community"
        component={Community}
        options={{ tabBarIcon: ({ color }) => <Users color={color} size={24} /> }}
      />
      <Tab.Screen
        name="Profile"
        component={Profile}
        options={{ tabBarIcon: ({ color }) => <User color={color} size={24} /> }}
      />
    </Tab.Navigator>
  );
}

export default function App() {
  const isAuthenticated = useStore((state) => state.isAuthenticated);

  useEffect(() => {
    if (isAuthenticated) {
      registerForPushNotificationsAsync();
      schedulePracticeReminder(6, 30);
    }
  }, [isAuthenticated]);

  return (
    <NavigationContainer>
      {isAuthenticated ? (
        <Stack.Navigator screenOptions={{ headerShown: false }}>
          <Stack.Screen name="Main" component={MainTabs} />
          <Stack.Screen name="PostSession" component={PostSession} />
        </Stack.Navigator>
      ) : (
        <AuthStack />
      )}
    </NavigationContainer>
  );
}
