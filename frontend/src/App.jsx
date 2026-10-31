import { useEffect, useRef, useState } from 'react'
import { Link, NavLink, Navigate, Route, Routes, useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from './auth.jsx'
import { api } from './api.js'
import { Avatar, Loading, useAsync } from './ui.jsx'
import FrontPage from './pages/FrontPage.jsx'
import Latest from './pages/Latest.jsx'
import Attention from './pages/Attention.jsx'
import About from './pages/About.jsx'
import Article from './pages/Article.jsx'
import Search from './pages/Search.jsx'
import { Login, Register } from './pages/AuthPages.jsx'
import Profile from './pages/Profile.jsx'
import UserPage from './pages/UserPage.jsx'
import AdminApp from './pages/admin/AdminApp.jsx'

const today = new Date().toLocaleDateString('en-GB', { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' })

function SectionsMenu({ onClose }) {
  const cats = useAsync(() => api('/api/categories'), [])
  const ref = useRef(null)
  useEffect(() => {
    const onKey = (e) => e.key === 'Escape' && onClose()
    const onClick = (e) => ref.current && !ref.current.contains(e.target) && !e.target.closest('.sections-toggle') && onClose()
    window.addEventListener('keydown', onKey)
    document.addEventListener('mousedown', onClick)
    return () => { window.removeEventListener('keydown', onKey); document.removeEventListener('mousedown', onClick) }
  }, [onClose])
  return (
    <div className="sections-panel" ref={ref} role="dialog" aria-label="Sections">
      <div className="container sections-grid">
        {(cats.data || []).map((c) => (
          <Link key={c.id} to={`/category/${c.slug}`} className="section-entry" onClick={onClose}>
            <span className="section-entry-name">{c.name}</span>
            <span className="section-entry-desc">{c.description}</span>
            <span className="section-entry-count">{c.document_count} stories</span>
          </Link>
        ))}
      </div>
    </div>
  )
}

function Header() {
  const { user, site, logout, isStaff } = useAuth()
  const [sectionsOpen, setSectionsOpen] = useState(false)
  const [searchOpen, setSearchOpen] = useState(false)
  const [compact, setCompact] = useState(false)
  const [q, setQ] = useState('')
  const mastRef = useRef(null)
  const navigate = useNavigate()
  const location = useLocation()
  useEffect(() => { setSectionsOpen(false); setSearchOpen(false) }, [location.pathname])
  useEffect(() => {
    const el = mastRef.current
    if (!el || !('IntersectionObserver' in window)) return
    const obs = new IntersectionObserver(([e]) => setCompact(!e.isIntersecting))
    obs.observe(el)
    return () => obs.disconnect()
  }, [])
  const submit = (e) => {
    e.preventDefault()
    if (q.trim()) navigate(`/search?q=${encodeURIComponent(q.trim())}`)
  }
  const sectionActive = location.pathname.startsWith('/category') || location.pathname.startsWith('/tag')
  return (
    <header className="site-header">
      <div className="topline">
        <div className="container topline-inner">
          <span>{today}</span>
          <div className="topline-account">
            {user ? (
              <>
                {isStaff && <Link to="/admin">Admin</Link>}
                <Link to="/profile" className="account-link"><Avatar user={user} size={22} />{user.username}</Link>
                <button className="link-btn" onClick={() => { logout(); navigate('/') }}>Log out</button>
              </>
            ) : (
              <>
                <Link to="/login">Log in</Link>
                <Link to="/register" className="topline-cta">Subscribe free</Link>
              </>
            )}
          </div>
        </div>
      </div>
      <div className="masthead" ref={mastRef}>
        <Link to="/" className="masthead-title" aria-label={`${site.site_name} home`}>{site.site_name}</Link>
        <p className="masthead-tagline">{site.site_tagline}</p>
      </div>
      <nav className={`navbar ${compact ? 'is-compact' : ''}`} aria-label="Main">
        <div className="container navbar-inner">
          <div className="navbar-left">
            <button className={`sections-toggle ${sectionsOpen || sectionActive ? 'is-active' : ''}`} aria-expanded={sectionsOpen}
              onClick={() => setSectionsOpen(!sectionsOpen)}>
              <span className="burger" aria-hidden="true"><i /><i /><i /></span>Sections
            </button>
            <Link to="/" className="navbar-mark" aria-hidden={!compact} tabIndex={compact ? 0 : -1}>{site.site_name}</Link>
          </div>
          <div className="navbar-links">
            <NavLink to="/latest">Latest</NavLink>
            <NavLink to="/attention">Attention</NavLink>
            <NavLink to="/about">About us</NavLink>
          </div>
          <div className="navbar-right">
            {searchOpen ? (
              <form onSubmit={submit} role="search" className="navbar-search">
                <input autoFocus type="search" value={q} onChange={(e) => setQ(e.target.value)} placeholder="Search the archive" aria-label="Search" />
              </form>
            ) : null}
            <button className="icon-search" aria-label={searchOpen ? 'Close search' : 'Search'} onClick={() => setSearchOpen(!searchOpen)}>
              {searchOpen ? '×' : <svg viewBox="0 0 24 24" width="18" height="18" aria-hidden="true"><circle cx="10.5" cy="10.5" r="6.5" fill="none" stroke="currentColor" strokeWidth="2" /><line x1="15.5" y1="15.5" x2="21" y2="21" stroke="currentColor" strokeWidth="2" strokeLinecap="round" /></svg>}
            </button>
          </div>
        </div>
        {sectionsOpen && <SectionsMenu onClose={() => setSectionsOpen(false)} />}
      </nav>
    </header>
  )
}

function Footer() {
  const { site } = useAuth()
  const cats = useAsync(() => api('/api/categories'), [])
  return (
    <footer className="site-footer">
      <div className="container footer-grid">
        <div>
          <div className="footer-title">{site.site_name}</div>
          <p>{site.site_tagline}</p>
        </div>
        <div>
          <h2 className="footer-head">Sections</h2>
          <ul>{(cats.data || []).map((c) => <li key={c.id}><Link to={`/category/${c.slug}`}>{c.name}</Link></li>)}</ul>
        </div>
        <div>
          <h2 className="footer-head">The magazine</h2>
          <ul>
            <li><Link to="/latest">Latest</Link></li>
            <li><Link to="/attention">Attention</Link></li>
            <li><Link to="/about">About us</Link></li>
            <li><Link to="/search">Search the archive</Link></li>
          </ul>
        </div>
      </div>
      <div className="container footer-note">
        Demo project for a News &amp; Digital Magazine Portal (Phase 1). Articles are original explainers written for this demo; cover art is generated.
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
      <Link className="btn" to="/">Back to the front page</Link>
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
          <Route path="/" element={<FrontPage />} />
          <Route path="/latest" element={<Latest />} />
          <Route path="/category/:categorySlug" element={<Latest />} />
          <Route path="/tag/:tagSlug" element={<Latest />} />
          <Route path="/attention" element={<Attention />} />
          <Route path="/about" element={<About />} />
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
