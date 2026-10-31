import { useState } from 'react'
import { Link } from 'react-router-dom'
import { api } from '../api.js'
import { useAuth } from '../auth.jsx'
import { Avatar, ErrorBox, Field, Notice, fmtDate, timeAgo, useAsync, useDocTitle } from '../ui.jsx'

export default function Profile() {
  const { user, setUser } = useAuth()
  const [form, setForm] = useState({ full_name: user.full_name, email: user.email, bio: user.bio || '', avatar_url: user.avatar_url || '' })
  const [pw, setPw] = useState({ current_password: '', new_password: '' })
  const [msg, setMsg] = useState(null)
  const [error, setError] = useState(null)
  const mentions = useAsync(() => api('/api/users/me/mentions'), [])
  useDocTitle('Your profile | Margin')
  const set = (k) => (e) => setForm({ ...form, [k]: e.target.value })
  const save = async (e) => {
    e.preventDefault()
    setError(null)
    try {
      setUser(await api('/api/users/me', { method: 'PATCH', body: { ...form, avatar_url: form.avatar_url || null } }))
      setMsg('Profile saved.')
    } catch (err) { setError(err) }
  }
  const changePw = async (e) => {
    e.preventDefault()
    setError(null)
    try {
      await api('/api/users/me/password', { method: 'POST', body: pw })
      setPw({ current_password: '', new_password: '' })
      setMsg('Password changed.')
    } catch (err) { setError(err) }
  }
  return (
    <div className="container page-pad">
      <div className="profile-head">
        <Avatar user={user} size={64} />
        <div>
          <h1>{user.full_name || user.username}</h1>
          <p className="muted">@{user.username} · {user.role.label} · joined {fmtDate(user.created_at)} · <Link to={`/u/${user.username}`}>View public profile</Link></p>
        </div>
      </div>
      {msg && <Notice kind="success">{msg}</Notice>}
      <ErrorBox error={error} />
      <div className="two-col">
        <section className="panel">
          <h2>Profile</h2>
          <form className="stack" onSubmit={save}>
            <Field label="Full name"><input value={form.full_name} onChange={set('full_name')} /></Field>
            <Field label="Email"><input type="email" required value={form.email} onChange={set('email')} /></Field>
            <Field label="Avatar image URL" hint="Optional. Leave empty to use your initials."><input value={form.avatar_url} onChange={set('avatar_url')} /></Field>
            <Field label="Bio"><textarea rows={3} maxLength={1000} value={form.bio} onChange={set('bio')} /></Field>
            <button className="btn">Save profile</button>
          </form>
          <h2>Change password</h2>
          <form className="stack" onSubmit={changePw}>
            <Field label="Current password"><input type="password" required value={pw.current_password} onChange={(e) => setPw({ ...pw, current_password: e.target.value })} autoComplete="current-password" /></Field>
            <Field label="New password" hint="At least 8 characters"><input type="password" required minLength={8} value={pw.new_password} onChange={(e) => setPw({ ...pw, new_password: e.target.value })} autoComplete="new-password" /></Field>
            <button className="btn btn-ghost">Change password</button>
          </form>
        </section>
        <section className="panel">
          <h2>Mentions of you</h2>
          <p className="muted">Comments where someone tagged you with @{user.username}.</p>
          {(mentions.data || []).length === 0 && <p className="muted">Nobody has mentioned you yet.</p>}
          <ul className="mention-feed">
            {(mentions.data || []).map((m) => (
              <li key={m.comment_id}>
                <Avatar user={m.by} size={28} />
                <div>
                  <strong>{m.by.full_name}</strong> <span className="muted">on <Link to={`/article/${m.document_slug}#comment-${m.comment_id}`}>{m.document_title}</Link> · {timeAgo(m.created_at)}</span>
                  <p>{m.content}</p>
                </div>
              </li>
            ))}
          </ul>
        </section>
      </div>
    </div>
  )
}
