import { create } from 'zustand';

const useStore = create((set, get) => ({
  user: null,
  token: null,
  isAuthenticated: false,
  hasOnboarded: false,
  intention: null,

  setAuth: (user, token) => set({ user, token, isAuthenticated: !!token }),

  completeOnboarding: (intention) => set({ hasOnboarded: true, intention }),

  logout: () => set({ user: null, token: null, isAuthenticated: false }),

  updateUser: (updates) => set((state) => ({
    user: { ...state.user, ...updates }
  })),

  refreshUser: async () => {
    const { token } = get();
    if (!token) return;

    try {
      const response = await fetch('https://octoally.adityatotlani.ch/api/auth/me', {
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
    const { token, refreshUser } = get();
    if (!token) return;

    try {
      const response = await fetch('https://octoally.adityatotlani.ch/api/sessions/log', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify(sessionData)
      });

      if (response.ok) {
        const data = await response.json();
        // Fetch authoritative user state (streak, XP, level, milestone bonuses)
        await refreshUser();
        return data;
      }
    } catch (error) {
      console.error('Failed to log session:', error);
    }
  }
}));

export default useStore;
