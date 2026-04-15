import { create } from 'zustand';

const LEVEL_THRESHOLDS = [
  { level: 6, xp: 12000 },
  { level: 5, xp: 7000 },
  { level: 4, xp: 3500 },
  { level: 3, xp: 1500 },
  { level: 2, xp: 500 },
  { level: 1, xp: 0 },
];

const getLevelFromXP = (xp) => {
  for (const { level, xp: threshold } of LEVEL_THRESHOLDS) {
    if (xp >= threshold) return level;
  }
  return 1;
};

const useStore = create((set, get) => ({
  user: null,
  token: null,
  isAuthenticated: false,

  setAuth: (user, token) => set({ user, token, isAuthenticated: !!token }),

  logout: () => set({ user: null, token: null, isAuthenticated: false }),

  updateUser: (updates) => set((state) => ({
    user: { ...state.user, ...updates }
  })),

  refreshUser: async () => {
    const { token } = get();
    if (!token) return;

    try {
      const response = await fetch('http://localhost:3000/api/auth/me', {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      });
      if (response.ok) {
        const data = await response.json();
        set({ user: data });
      }
    } catch (error) {
      console.error('Refresh failed', error);
    }
  },

  // Session Logging
  logSession: async (sessionData) => {
    const { token, user } = get();
    if (!token) return;

    const xpGain = sessionData.type === 'full' ? 100 : 50;

    try {
      const response = await fetch('http://localhost:3000/api/sessions/log', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(sessionData)
      });

      if (response.ok) {
        const data = await response.json();

        // Optimistic update using non-linear level calculation
        set((state) => {
          const newXP = state.user.total_xp + xpGain;
          return {
            user: {
              ...state.user,
              current_streak: state.user.current_streak + 1,
              total_xp: newXP,
              level: getLevelFromXP(newXP),
            }
          };
        });

        return data;
      }
    } catch (error) {
      console.error('Failed to log session:', error);
    }
  }
}));

export default useStore;
