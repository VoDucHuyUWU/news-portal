import { createContext, useCallback, useContext, useEffect, useState } from 'react'
import { api, tokenStore } from './api.js'

const AuthContext = createContext(null)

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [ready, setReady] = useState(false)
  const [site, setSite] = useState({ site_name: 'Margin', site_tagline: '' })

  const refresh = useCallback(async () => {
    if (!tokenStore.get()) {
      setUser(null)
      return
    }
    try {
      setUser(await api('/api/auth/me'))
    } catch {
      setUser(null)
    }
  }, [])

  useEffect(() => {
    Promise.all([refresh(), api('/api/settings/public').then(setSite).catch(() => {})]).finally(() => setReady(true))
    const onLogout = () => setUser(null)
    window.addEventListener('margin:logout', onLogout)
    return () => window.removeEventListener('margin:logout', onLogout)
  }, [refresh])

  const finish = (data) => {
    tokenStore.set(data.access_token)
    setUser(data.user)
    return data.user
  }
  const value = {
    user, ready, site, setUser, refresh,
    login: async (login, password) => finish(await api('/api/auth/login', { method: 'POST', body: { login, password } })),
    register: async (body) => finish(await api('/api/auth/register', { method: 'POST', body })),
    logout: () => {
      tokenStore.set(null)
      setUser(null)
    },
    can: (...perms) => !!user && perms.some((p) => user.permissions.includes(p)),
    isStaff: !!user && user.permissions.length > 0,
  }
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export const useAuth = () => useContext(AuthContext)
