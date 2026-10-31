import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'

export const fmtDate = (iso) =>
  iso ? new Date(iso).toLocaleDateString('en-GB', { day: 'numeric', month: 'short', year: 'numeric' }) : ''

export const fmtDateTime = (iso) =>
  iso ? new Date(iso).toLocaleString('en-GB', { day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' }) : ''

export function timeAgo(iso) {
  const s = (Date.now() - new Date(iso).getTime()) / 1000
  if (s < 60) return 'just now'
  const units = [[31536000, 'year'], [2592000, 'month'], [86400, 'day'], [3600, 'hour'], [60, 'minute']]
  for (const [secs, name] of units) {
    const n = Math.floor(s / secs)
    if (n >= 1) return `${n} ${name}${n > 1 ? 's' : ''} ago`
  }
  return 'just now'
}

export const num = (n) => (n ?? 0).toLocaleString('en-US')

export function useDocTitle(title, description) {
  useEffect(() => {
    if (title) document.title = title
    const meta = document.querySelector('meta[name="description"]')
    if (meta && description) meta.setAttribute('content', description)
  }, [title, description])
}

export function useAsync(fn, deps) {
  const [state, setState] = useState({ data: null, error: null, loading: true })
  const [tick, setTick] = useState(0)
  useEffect(() => {
    let alive = true
    setState((s) => ({ ...s, loading: true, error: null }))
    fn()
      .then((data) => alive && setState({ data, error: null, loading: false }))
      .catch((error) => alive && setState({ data: null, error, loading: false }))
    return () => {
      alive = false
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [...deps, tick])
  return { ...state, reload: () => setTick((t) => t + 1), setData: (d) => setState((s) => ({ ...s, data: d })) }
}

export function Loading({ label = 'Loading' }) {
  return <div className="loading" role="status">{label}…</div>
}

export function ErrorBox({ error, onRetry }) {
  if (!error) return null
  return (
    <div className="alert alert-error" role="alert">
      {error.message || String(error)}
      {onRetry && <button className="btn btn-small" onClick={onRetry}>Try again</button>}
    </div>
  )
}

export function Notice({ kind = 'info', children }) {
  return <div className={`alert alert-${kind}`} role="status">{children}</div>
}

export function Avatar({ user, size = 36 }) {
  const name = user?.full_name || user?.username || '?'
  const initials = name.split(/\s+/).map((p) => p[0]).slice(0, 2).join('').toUpperCase()
  const hue = [...(user?.username || 'x')].reduce((a, c) => a + c.charCodeAt(0), 0) % 360
  if (user?.avatar_url) return <img className="avatar" src={user.avatar_url} alt="" width={size} height={size} />
  return (
    <span className="avatar" style={{ width: size, height: size, background: `hsl(${hue} 45% 42%)`, fontSize: size * 0.38 }} aria-hidden="true">
      {initials}
    </span>
  )
}

export function CategoryLink({ category }) {
  if (!category) return null
  return (
    <Link className="category-link" to={`/category/${category.slug}`} style={{ '--cat': category.color }}>
      {category.name}
    </Link>
  )
}

export function TagList({ tags }) {
  if (!tags?.length) return null
  return (
    <ul className="tag-list">
      {tags.map((t) => (
        <li key={t.id}><Link to={`/tag/${t.slug}`}>#{t.name}</Link></li>
      ))}
    </ul>
  )
}

export function Highlight({ text, terms }) {
  if (!terms?.length || !text) return text
  const escaped = terms.filter(Boolean).map((t) => t.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'))
  if (!escaped.length) return text
  const re = new RegExp(`(${escaped.join('|')})`, 'gi')
  return text.split(re).map((part, i) => (i % 2 ? <mark key={i}>{part}</mark> : part))
}

export function ArticleCard({ doc, terms, onOpen, variant = 'card' }) {
  const href = `/article/${doc.slug}`
  return (
    <article className={`card card-${variant}`} style={{ '--cat': doc.category?.color || '#141B2D' }}>
      {doc.cover_image_url && (
        <Link to={href} onClick={onOpen} className="card-media" tabIndex={-1} aria-hidden="true">
          <img src={doc.cover_image_url} alt="" loading="lazy" />
        </Link>
      )}
      <div className="card-body">
        <div className="card-meta">
          <CategoryLink category={doc.category} />
          <span>{fmtDate(doc.published_at || doc.created_at)}</span>
        </div>
        <h3 className="card-title">
          <Link to={href} onClick={onOpen}><Highlight text={doc.title} terms={terms} /></Link>
        </h3>
        <p className="card-summary"><Highlight text={doc.summary} terms={terms} /></p>
        <div className="card-foot">
          <span>{doc.author?.full_name || 'Staff'}</span>
          <span>{num(doc.views_count)} views</span>
        </div>
      </div>
    </article>
  )
}

export function Pagination({ page, pages, onPage }) {
  if (!pages || pages <= 1) return null
  const around = [...new Set([1, page - 1, page, page + 1, pages])].filter((p) => p >= 1 && p <= pages).sort((a, b) => a - b)
  const items = []
  around.forEach((p, i) => {
    if (i && p - around[i - 1] > 1) items.push(<span key={`gap${p}`} className="page-gap">…</span>)
    items.push(
      <button key={p} className={`page-btn ${p === page ? 'is-current' : ''}`} aria-current={p === page ? 'page' : undefined}
        onClick={() => onPage(p)}>{p}</button>,
    )
  })
  return (
    <nav className="pagination" aria-label="Pagination">
      <button className="page-btn" disabled={page <= 1} onClick={() => onPage(page - 1)}>Previous</button>
      {items}
      <button className="page-btn" disabled={page >= pages} onClick={() => onPage(page + 1)}>Next</button>
    </nav>
  )
}

export function Modal({ title, onClose, children, wide }) {
  useEffect(() => {
    const onKey = (e) => e.key === 'Escape' && onClose()
    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [onClose])
  return (
    <div className="modal-backdrop" onMouseDown={(e) => e.target === e.currentTarget && onClose()}>
      <div className={`modal ${wide ? 'modal-wide' : ''}`} role="dialog" aria-modal="true" aria-label={title}>
        <header className="modal-head">
          <h2>{title}</h2>
          <button className="icon-btn" onClick={onClose} aria-label="Close">×</button>
        </header>
        <div className="modal-body">{children}</div>
      </div>
    </div>
  )
}

export function Field({ label, hint, children }) {
  return (
    <label className="field">
      <span className="field-label">{label}</span>
      {children}
      {hint && <span className="field-hint">{hint}</span>}
    </label>
  )
}

export function StatusBadge({ status }) {
  return <span className={`badge badge-${status}`}>{status}</span>
}

export function Empty({ children }) {
  return <div className="empty">{children}</div>
}
