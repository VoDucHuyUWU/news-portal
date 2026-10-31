// Thin fetch wrapper: JSON in/out, bearer token, per-browser session id for search logs.
const TOKEN_KEY = 'margin_token'

function sessionId() {
  let id = localStorage.getItem('margin_session')
  if (!id) {
    id = (crypto.randomUUID ? crypto.randomUUID() : String(Math.random()).slice(2)).replace(/-/g, '')
    localStorage.setItem('margin_session', id)
  }
  return id
}

export const tokenStore = {
  get: () => localStorage.getItem(TOKEN_KEY),
  set: (t) => (t ? localStorage.setItem(TOKEN_KEY, t) : localStorage.removeItem(TOKEN_KEY)),
}

export class ApiError extends Error {
  constructor(status, message) {
    super(message)
    this.status = status
  }
}

function errorMessage(data, status) {
  if (!data) return `Request failed (${status})`
  if (typeof data.detail === 'string') return data.detail
  if (Array.isArray(data.detail)) {
    return data.detail.map((d) => `${(d.loc || []).slice(-1)[0] || 'field'}: ${d.msg}`).join('; ')
  }
  return `Request failed (${status})`
}

export async function api(path, { method = 'GET', body, params, form } = {}) {
  const url = new URL(path, window.location.origin)
  Object.entries(params || {}).forEach(([k, v]) => {
    if (v !== undefined && v !== null && v !== '') url.searchParams.set(k, v)
  })
  const headers = { 'X-Session-Id': sessionId() }
  const token = tokenStore.get()
  if (token) headers.Authorization = `Bearer ${token}`
  let payload
  if (form) payload = form
  else if (body !== undefined) {
    headers['Content-Type'] = 'application/json'
    payload = JSON.stringify(body)
  }
  const res = await fetch(url, { method, headers, body: payload })
  if (res.status === 204) return null
  const data = await res.json().catch(() => null)
  if (!res.ok) {
    if (res.status === 401 && token) {
      tokenStore.set(null)
      window.dispatchEvent(new Event('margin:logout'))
    }
    throw new ApiError(res.status, errorMessage(data, res.status))
  }
  return data
}
