import React, { useEffect } from 'react';
import { View, StyleSheet, Dimensions } from 'react-native';
import Animated, { 
  useAnimatedStyle, 
  useSharedValue, 
  withRepeat, 
  withTiming, 
  Easing,
  interpolate,
  Extrapolate
} from 'react-native-reanimated';

const { width } = Dimensions.get('window');
const CIRCLE_SIZE = width * 0.7;

export default function BreathCircle({ duration = 4000, isResting = false }) {
  const animation = useSharedValue(0);

  useEffect(() => {
    if (isResting) {
      animation.value = withTiming(0, { duration: 1000 });
      return;
    }

    animation.value = withRepeat(
      withTiming(1, { 
        duration: duration / 2, 
        easing: Easing.bezier(0.42, 0, 0.58, 1) 
      }),
      -1,
      true
    );
  }, [duration, isResting]);

  const animatedStyle = useAnimatedStyle(() => {
    const scale = interpolate(
      animation.value,
      [0, 1],
      [1, 1.4],
      Extrapolate.CLAMP
    );

    const opacity = interpolate(
      animation.value,
      [0, 1],
      [0.3, 0.8],
      Extrapolate.CLAMP
    );

    return {
      transform: [{ scale }],
      opacity,
    };
  });

  return (
    <View style={styles.container}>
      {/* Background Glow */}
      <Animated.View style={[styles.glow, animatedStyle]} />
      
      {/* Main Circle */}
      <View style={styles.circle}>
        <Animated.View style={[styles.innerCircle, animatedStyle]} />
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    width: CIRCLE_SIZE,
    height: CIRCLE_SIZE,
    justifyContent: 'center',
    alignItems: 'center',
  },
  glow: {
    position: 'absolute',
    width: CIRCLE_SIZE,
    height: CIRCLE_SIZE,
    borderRadius: CIRCLE_SIZE / 2,
    backgroundColor: '#818cf8',
  },
  circle: {
    width: CIRCLE_SIZE * 0.8,
    height: CIRCLE_SIZE * 0.8,
    borderRadius: (CIRCLE_SIZE * 0.8) / 2,
    backgroundColor: '#ffffff',
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 10,
    elevation: 5,
  },
  innerCircle: {
    width: CIRCLE_SIZE * 0.6,
    height: CIRCLE_SIZE * 0.6,
    borderRadius: (CIRCLE_SIZE * 0.6) / 2,
    backgroundColor: '#6366f1',
  },
});
