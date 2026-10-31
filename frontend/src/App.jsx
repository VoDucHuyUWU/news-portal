import { useState } from 'react'
import { Link, NavLink, Navigate, Route, Routes, useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from './auth.jsx'
import { api } from './api.js'
import { Avatar, Loading, useAsync } from './ui.jsx'
import Home from './pages/Home.jsx'
import Article from './pages/Article.jsx'
import Search from './pages/Search.jsx'
import { Login, Register } from './pages/AuthPages.jsx'
import Profile from './pages/Profile.jsx'
import UserPage from './pages/UserPage.jsx'
import AdminApp from './pages/admin/AdminApp.jsx'

function Header() {
  const { user, site, logout, isStaff } = useAuth()
  const [q, setQ] = useState('')
  const [open, setOpen] = useState(false)
  const navigate = useNavigate()
  const cats = useAsync(() => api('/api/categories'), [])
  const submit = (e) => {
    e.preventDefault()
    navigate(`/search?q=${encodeURIComponent(q.trim())}`)
    setOpen(false)
  }
  return (
    <header className="site-header">
      <div className="header-row container">
        <Link to="/" className="wordmark" aria-label={`${site.site_name} home`}>
          <span className="wordmark-bar" aria-hidden="true" />{site.site_name}
        </Link>
        <form className="header-search" onSubmit={submit} role="search">
          <input type="search" placeholder="Search articles" value={q} onChange={(e) => setQ(e.target.value)} aria-label="Search articles" />
        </form>
        <button className="menu-toggle" onClick={() => setOpen(!open)} aria-expanded={open} aria-label="Menu">Menu</button>
        <div className={`header-account ${open ? 'is-open' : ''}`}>
          {user ? (
            <>
              {isStaff && <Link className="btn btn-small btn-ghost" to="/admin" onClick={() => setOpen(false)}>Admin</Link>}
              <Link to="/profile" className="account-link" onClick={() => setOpen(false)}><Avatar user={user} size={30} /><span>{user.username}</span></Link>
              <button className="btn btn-small btn-ghost" onClick={() => { logout(); navigate('/') }}>Log out</button>
            </>
          ) : (
            <>
              <Link className="btn btn-small btn-ghost" to="/login" onClick={() => setOpen(false)}>Log in</Link>
              <Link className="btn btn-small" to="/register" onClick={() => setOpen(false)}>Create account</Link>
            </>
          )}
        </div>
      </div>
      <nav className={`category-nav ${open ? 'is-open' : ''}`} aria-label="Categories">
        <div className="container category-nav-inner">
          <NavLink to="/" end onClick={() => setOpen(false)}>Latest</NavLink>
          {(cats.data || []).map((c) => (
            <NavLink key={c.id} to={`/category/${c.slug}`} style={{ '--cat': c.color }} onClick={() => setOpen(false)}>{c.name}</NavLink>
          ))}
        </div>
      </nav>
    </header>
  )
}

function Footer() {
  const { site } = useAuth()
  return (
    <footer className="site-footer">
      <div className="container footer-inner">
        <div>
          <div className="wordmark wordmark-small"><span className="wordmark-bar" aria-hidden="true" />{site.site_name}</div>
          <p>{site.site_tagline}</p>
        </div>
        <p className="muted">Demo project: News &amp; Digital Magazine Portal (Phase 1). Articles are original explainers written for this demo.</p>
      </div>
    </footer>
  )
}

function RequireAuth({ children }) {
  const { user, ready } = useAuth()
  const location = useLocation()
  if (!ready) return <Loading />
  if (!user) return <Navigate to={`/login?next=${encodeURIComponent(location.pathname)}`} replace />
  return children
}

function NotFound() {
  return (
    <div className="container narrow page-pad">
      <h1>Page not found</h1>
      <p>The page you asked for does not exist or has been unpublished.</p>
      <Link className="btn" to="/">Back to the latest articles</Link>
    </div>
  )
}

export default function App() {
  const location = useLocation()
  if (location.pathname.startsWith('/admin')) {
    return (
      <Routes>
        <Route path="/admin/*" element={<RequireAuth><AdminApp /></RequireAuth>} />
      </Routes>
    )
  }
  return (
    <div className="site">
      <a className="skip-link" href="#main">Skip to content</a>
      <Header />
      <main id="main">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/category/:categorySlug" element={<Home />} />
          <Route path="/tag/:tagSlug" element={<Home />} />
          <Route path="/article/:slug" element={<Article />} />
          <Route path="/search" element={<Search />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="/profile" element={<RequireAuth><Profile /></RequireAuth>} />
          <Route path="/u/:username" element={<UserPage />} />
          <Route path="*" element={<NotFound />} />
        </Routes>
      </main>
      <Footer />
    </div>
  )
}
