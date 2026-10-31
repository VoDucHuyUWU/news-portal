import { useState } from 'react'
import { Link, useNavigate, useSearchParams } from 'react-router-dom'
import { useAuth } from '../auth.jsx'
import { ErrorBox, Field, useDocTitle } from '../ui.jsx'

const DEMO = [
  ['admin', 'Super Admin'], ['editor', 'Content Manager'], ['moderator', 'Moderator'], ['seo', 'Data & SEO Specialist'], ['reader', 'Member'],
]

export function Login() {
  const { login } = useAuth()
  const navigate = useNavigate()
  const [params] = useSearchParams()
  const [form, setForm] = useState({ login: '', password: '' })
  const [error, setError] = useState(null)
  const [busy, setBusy] = useState(false)
  useDocTitle('Log in | Margin')
  const submit = async (e) => {
    e.preventDefault()
    setBusy(true)
    setError(null)
    try {
      const user = await login(form.login, form.password)
      navigate(params.get('next') || (user.permissions.length ? '/admin' : '/'))
    } catch (err) {
      setError(err)
    } finally {
      setBusy(false)
    }
  }
  return (
    <div className="container auth-page">
      <form className="auth-card" onSubmit={submit}>
        <h1>Log in</h1>
        <Field label="Username or email"><input required autoComplete="username" value={form.login} onChange={(e) => setForm({ ...form, login: e.target.value })} /></Field>
        <Field label="Password"><input required type="password" autoComplete="current-password" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} /></Field>
        <ErrorBox error={error} />
        <button className="btn btn-block" disabled={busy}>{busy ? 'Logging in…' : 'Log in'}</button>
        <p className="muted">New here? <Link to="/register">Create an account</Link></p>
      </form>
      <aside className="demo-accounts">
        <h2>Demo accounts</h2>
        <p className="muted">All use the password <code>demo1234</code>. Pick one to see what each role can do.</p>
        <ul>
          {DEMO.map(([u, role]) => (
            <li key={u}><button type="button" className="link-btn" onClick={() => setForm({ login: u, password: 'demo1234' })}>
              <strong>{u}</strong></button> <span className="muted">{role}</span></li>
          ))}
        </ul>
      </aside>
    </div>
  )
}

export function Register() {
  const { register } = useAuth()
  const navigate = useNavigate()
  const [form, setForm] = useState({ username: '', email: '', full_name: '', password: '' })
  const [error, setError] = useState(null)
  const [busy, setBusy] = useState(false)
  useDocTitle('Create account | Margin')
  const set = (k) => (e) => setForm({ ...form, [k]: e.target.value })
  const submit = async (e) => {
    e.preventDefault()
    setBusy(true)
    setError(null)
    try {
      await register(form)
      navigate('/profile')
    } catch (err) {
      setError(err)
    } finally {
      setBusy(false)
    }
  }
  return (
    <div className="container auth-page">
      <form className="auth-card" onSubmit={submit}>
        <h1>Create an account</h1>
        <p className="muted">Members can comment, like and rate articles, and mention other readers.</p>
        <Field label="Username" hint="3–40 letters, numbers or underscores"><input required pattern="[A-Za-z0-9_]{3,40}" value={form.username} onChange={set('username')} autoComplete="username" /></Field>
        <Field label="Full name"><input value={form.full_name} onChange={set('full_name')} autoComplete="name" /></Field>
        <Field label="Email"><input required type="email" value={form.email} onChange={set('email')} autoComplete="email" /></Field>
        <Field label="Password" hint="At least 8 characters"><input required minLength={8} type="password" value={form.password} onChange={set('password')} autoComplete="new-password" /></Field>
        <ErrorBox error={error} />
        <button className="btn btn-block" disabled={busy}>{busy ? 'Creating…' : 'Create account'}</button>
        <p className="muted">Already have an account? <Link to="/login">Log in</Link></p>
      </form>
    </div>
  )
}
