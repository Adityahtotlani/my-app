import * as Notifications from 'expo-notifications';
import * as Device from 'expo-device';
import { Platform } from 'react-native';

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldShowAlert: true,
    shouldPlaySound: true,
    shouldSetBadge: false,
  }),
});

export async function registerForPushNotificationsAsync() {
  let token;

  if (Platform.OS === 'android') {
    await Notifications.setNotificationChannelAsync('default', {
      name: 'default',
      importance: Notifications.AndroidImportance.MAX,
      vibrationPattern: [0, 250, 250, 250],
      lightColor: '#6366f1',
    });
  }

  if (Device.isDevice) {
    const { status: existingStatus } = await Notifications.getPermissionsAsync();
    let finalStatus = existingStatus;
    if (existingStatus !== 'granted') {
      const { status } = await Notifications.requestPermissionsAsync();
      finalStatus = status;
    }
    if (finalStatus !== 'granted') {
      alert('Failed to get push token for push notification!');
      return;
    }
    
    // Learn more about Expo push tokens: https://docs.expo.dev/push-notifications/push-notifications-setup/
    try {
      token = (await Notifications.getExpoPushTokenAsync({
        projectId: 'your-project-id', // Replace with your actual Expo project ID
      })).data;
    } catch (e) {
      console.log('Error getting token', e);
    }
  }

  return token;
}

export async function schedulePracticeReminder(hour = 6, minute = 30) {
  await Notifications.cancelAllScheduledNotificationsAsync();

  const id = await Notifications.scheduleNotificationAsync({
    content: {
      title: "Time for SKY Practice 🧘‍♂️",
      body: "Start your day with clarity and focus. Your guided session is ready.",
    },
    trigger: {
      hour,
      minute,
      repeats: true,
    },
  });

  return id;
}
