import { useEffect, useRef, useState } from 'react'
import { Link, useParams } from 'react-router-dom'
import { api } from '../api.js'
import { useAuth } from '../auth.jsx'
import { Avatar, ErrorBox, Loading, Modal, Notice, TagList, fmtDate, num, timeAgo, useAsync,
  useDocTitle } from '../ui.jsx'

function Stars({ value, onRate, disabled }) {
  const [hover, setHover] = useState(0)
  return (
    <div className="stars" role="radiogroup" aria-label="Rate this article" onMouseLeave={() => setHover(0)}>
      {[1, 2, 3, 4, 5].map((n) => (
        <button key={n} type="button" role="radio" aria-checked={value === n} aria-label={`${n} star${n > 1 ? 's' : ''}`}
          className={`star ${(hover || value) >= n ? 'is-on' : ''}`} disabled={disabled}
          onMouseEnter={() => setHover(n)} onClick={() => onRate(n)}>★</button>
      ))}
    </div>
  )
}

function ReportButton({ targetType, targetId, label = 'Report' }) {
  const { user } = useAuth()
  const [open, setOpen] = useState(false)
  const [reason, setReason] = useState('')
  const [msg, setMsg] = useState(null)
  if (!user) return null
  const send = async (e) => {
    e.preventDefault()
    try {
      const r = await api('/api/reports', { method: 'POST', body: { target_type: targetType, target_id: targetId, reason } })
      setMsg(r.message)
      setTimeout(() => setOpen(false), 1400)
    } catch (err) {
      setMsg(err.message)
    }
  }
  return (
    <>
      <button className="link-btn" onClick={() => { setOpen(true); setMsg(null); setReason('') }}>{label}</button>
      {open && (
        <Modal title={`Report this ${targetType}`} onClose={() => setOpen(false)}>
          <form onSubmit={send} className="stack">
            <label className="field"><span className="field-label">What is wrong?</span>
              <textarea required minLength={3} rows={3} value={reason} onChange={(e) => setReason(e.target.value)}
                placeholder="Spam, harassment, wrong information…" /></label>
            {msg && <Notice>{msg}</Notice>}
            <button className="btn">Send report</button>
          </form>
        </Modal>
      )}
    </>
  )
}

function MentionText({ text }) {
  return text.split(/(@[A-Za-z0-9_]{3,40})/g).map((part, i) =>
    part.startsWith('@') ? <Link key={i} className="mention" to={`/u/${part.slice(1)}`}>{part}</Link> : part)
}

function CommentBox({ documentId, parentId, onPosted, autoFocus, onCancel }) {
  const [text, setText] = useState('')
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState(null)
  const [suggest, setSuggest] = useState([])
  const ref = useRef(null)
  const mentionQuery = () => {
    const el = ref.current
    const before = el ? text.slice(0, el.selectionStart) : text
    const m = before.match(/@([A-Za-z0-9_]{1,40})$/)
    return m ? m[1] : null
  }
  useEffect(() => {
    const q = mentionQuery()
    if (!q) { setSuggest([]); return }
    const t = setTimeout(() => api('/api/users/lookup', { params: { q } }).then(setSuggest).catch(() => setSuggest([])), 150)
    return () => clearTimeout(t)
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [text])
  const pick = (username) => {
    const el = ref.current
    const pos = el.selectionStart
    const before = text.slice(0, pos).replace(/@([A-Za-z0-9_]{1,40})$/, `@${username} `)
    setText(before + text.slice(pos))
    setSuggest([])
    el.focus()
  }
  const submit = async (e) => {
    e.preventDefault()
    setBusy(true)
    setError(null)
    try {
      const c = await api(`/api/documents/${documentId}/comments`, { method: 'POST', body: { content: text, parent_id: parentId } })
      setText('')
      onPosted(c)
    } catch (err) {
      setError(err)
    } finally {
      setBusy(false)
    }
  }
  return (
    <form className="comment-form" onSubmit={submit}>
      <div className="mention-wrap">
        <textarea ref={ref} rows={parentId ? 2 : 3} required maxLength={3000} value={text} autoFocus={autoFocus}
          onChange={(e) => setText(e.target.value)} aria-label="Write a comment"
          placeholder={parentId ? 'Write a reply…' : 'Share your thoughts. Type @ to mention someone.'} />
        {suggest.length > 0 && (
          <ul className="mention-menu" role="listbox">
            {suggest.map((u) => (
              <li key={u.id}><button type="button" onClick={() => pick(u.username)}>
                <Avatar user={u} size={22} /> <strong>@{u.username}</strong> <span className="muted">{u.full_name}</span>
              </button></li>
            ))}
          </ul>
        )}
      </div>
      <ErrorBox error={error} />
      <div className="row-end">
        {onCancel && <button type="button" className="btn btn-ghost btn-small" onClick={onCancel}>Cancel</button>}
        <button className="btn btn-small" disabled={busy || !text.trim()}>{parentId ? 'Reply' : 'Post comment'}</button>
      </div>
    </form>
  )
}

function Comments({ doc }) {
  const { user } = useAuth()
  const comments = useAsync(() => api(`/api/documents/${doc.id}/comments`), [doc.id])
  const [replyTo, setReplyTo] = useState(null)
  const [flash, setFlash] = useState(null)
  const all = comments.data || []
  const roots = all.filter((c) => !c.parent_id)
  const repliesOf = (id) => all.filter((c) => c.parent_id === id)
  const posted = (c) => {
    comments.setData([...all, c])
    setReplyTo(null)
    setFlash(c.status === 'pending' ? 'Your comment is waiting for a moderator to review it.' : null)
  }
  const remove = async (c) => {
    if (!window.confirm('Delete this comment?')) return
    await api(`/api/comments/${c.id}`, { method: 'DELETE' })
    comments.setData(all.filter((x) => x.id !== c.id && x.parent_id !== c.id))
  }
  const renderComment = (c) => (
    <li key={c.id} id={`comment-${c.id}`} className={`comment ${c.status === 'pending' ? 'is-pending' : ''}`}>
      <Avatar user={c.user} size={34} />
      <div className="comment-main">
        <div className="comment-head">
          <Link to={`/u/${c.user.username}`} className="comment-author">{c.user.full_name || c.user.username}</Link>
          <span className="muted">@{c.user.username} · {timeAgo(c.created_at)}</span>
          {c.status === 'pending' && <span className="badge badge-pending">awaiting review</span>}
        </div>
        <p className="comment-text"><MentionText text={c.content} /></p>
        <div className="comment-actions">
          {user && !c.parent_id && <button className="link-btn" onClick={() => setReplyTo(c.id)}>Reply</button>}
          {user && user.id !== c.user.id && <ReportButton targetType="comment" targetId={c.id} />}
          {user && user.id === c.user.id && <button className="link-btn" onClick={() => remove(c)}>Delete</button>}
        </div>
        {replyTo === c.id && <CommentBox documentId={doc.id} parentId={c.id} onPosted={posted} autoFocus onCancel={() => setReplyTo(null)} />}
        {repliesOf(c.id).length > 0 && <ul className="comment-list replies">{repliesOf(c.id).map(renderComment)}</ul>}
      </div>
    </li>
  )
  return (
    <section className="comments" aria-labelledby="comments-title">
      <h2 id="comments-title">Comments <span className="muted">{all.filter((c) => c.status === 'visible').length}</span></h2>
      {user ? <CommentBox documentId={doc.id} onPosted={posted} /> : (
        <Notice><Link to={`/login?next=/article/${doc.slug}`}>Log in</Link> or <Link to="/register">create an account</Link> to join the conversation.</Notice>
      )}
      {flash && <Notice kind="warn">{flash}</Notice>}
      <ErrorBox error={comments.error} />
      {comments.loading && !comments.data ? <Loading /> : (
        roots.length ? <ul className="comment-list">{roots.map(renderComment)}</ul> : <p className="muted">No comments yet. Start the discussion.</p>
      )}
    </section>
  )
}

function ReadingProgress() {
  const [pct, setPct] = useState(0)
  useEffect(() => {
    const onScroll = () => {
      const el = document.querySelector('.article-main')
      if (!el) return
      const rect = el.getBoundingClientRect()
      const total = rect.height - window.innerHeight * 0.6
      setPct(Math.min(100, Math.max(0, (-rect.top / Math.max(1, total)) * 100)))
    }
    window.addEventListener('scroll', onScroll, { passive: true })
    onScroll()
    return () => window.removeEventListener('scroll', onScroll)
  }, [])
  return <div className="progress" aria-hidden="true"><span style={{ width: `${pct}%` }} /></div>
}

function useOutline(html) {
  const [items, setItems] = useState([])
  useEffect(() => {
    const heads = [...document.querySelectorAll('.prose h2')]
    heads.forEach((h, i) => { h.id = `section-${i + 1}` })
    setItems(heads.map((h) => ({ id: h.id, text: h.textContent })))
  }, [html])
  return items
}

export default function Article() {
  const { slug } = useParams()
  const { user, site } = useAuth()
  const doc = useAsync(() => api(`/api/documents/${slug}`), [slug, user?.id])
  const related = useAsync(() => api(`/api/documents/${slug}/related`), [slug])
  const [eng, setEng] = useState(null)
  const [copied, setCopied] = useState(false)
  const d = doc.data
  const outline = useOutline(d?.content)
  useEffect(() => { setEng(null); window.scrollTo(0, 0) }, [slug])
  useDocTitle(d ? (d.seo?.meta_title || `${d.title} | ${site.site_name}`) : site.site_name, d?.seo?.meta_description || d?.summary)
  if (doc.loading && !d) return <div className="container page-pad"><Loading /></div>
  if (doc.error) return <div className="container narrow page-pad"><ErrorBox error={doc.error} /><Link to="/">Back to the front page</Link></div>
  const e = eng || d
  const like = async () => setEng(await api(`/api/documents/${d.id}/like`, { method: 'POST' }))
  const rate = async (score) => setEng(await api(`/api/documents/${d.id}/rating`, { method: 'PUT', body: { score } }))
  const copy = () => navigator.clipboard?.writeText(window.location.href).then(() => { setCopied(true); setTimeout(() => setCopied(false), 1500) })
  return (
    <article className="article">
      <ReadingProgress />
      <header className="article-hero">
        <div className="container article-hero-inner">
          <p className="kicker">{d.category && <Link to={`/category/${d.category.slug}`}>{d.category.name}</Link>}<span>{d.reading_minutes} min read</span></p>
          <h1 className="article-title">{d.title}</h1>
          <p className="article-dek">{d.summary}</p>
          <p className="byline">By {d.author ? <Link to={`/u/${d.author.username}`}><strong>{d.author.full_name}</strong></Link> : 'Staff'}
            <span>{fmtDate(d.published_at)}</span><span>{num(d.views_count)} reads</span></p>
        </div>
      </header>
      {d.cover_image_url && (
        <figure className="container article-cover">
          <img src={d.cover_image_url} alt={d.seo?.image_alt || ''} />
          {d.seo?.image_alt && <figcaption>{d.seo.image_alt}</figcaption>}
        </figure>
      )}
      <div className="container article-layout">
        <aside className="article-margin" aria-label="Article details">
          {outline.length > 0 && (
            <nav className="outline" aria-label="In this article">
              <span className="note-label">In this article</span>
              <ol>{outline.map((o) => <li key={o.id}><a href={`#${o.id}`}>{o.text}</a></li>)}</ol>
            </nav>
          )}
          <dl className="margin-facts">
            <div><dt>Rating</dt><dd>{e.rating_avg ? `${e.rating_avg.toFixed(1)} / 5 (${e.rating_count})` : 'Not rated yet'}</dd></div>
            <div><dt>Likes</dt><dd>{e.like_count}</dd></div>
            <div><dt>Comments</dt><dd>{d.comment_count}</dd></div>
          </dl>
          <TagList tags={d.tags} />
          <button className="link-btn share" onClick={copy}>{copied ? 'Link copied' : 'Copy link to share'}</button>
        </aside>
        <div className="article-main">
          {d.status && d.status !== 'published' && <Notice kind="warn">Preview: this article is not published.</Notice>}
          <div className="prose dropcap" dangerouslySetInnerHTML={{ __html: d.content }} />
          <p className="endmark" aria-hidden="true">◆</p>
          <div className="engage">
            {user ? (
              <>
                <button className={`btn like-btn ${e.liked_by_me ? 'is-liked' : ''}`} onClick={like} aria-pressed={e.liked_by_me}>
                  {e.liked_by_me ? '♥ Liked' : '♡ Like'} <span>{e.like_count}</span>
                </button>
                <div className="rate"><span className="muted">Your rating</span><Stars value={e.my_rating || 0} onRate={rate} /></div>
                <ReportButton targetType="document" targetId={d.id} label="Report a problem" />
              </>
            ) : (
              <p className="muted">♥ {e.like_count} likes. <Link to={`/login?next=/article/${d.slug}`}>Log in</Link> to like, rate and comment.</p>
            )}
          </div>
          {d.author && (
            <div className="author-box">
              <Avatar user={d.author} size={56} />
              <div><span className="note-label">About the writer</span>
                <Link to={`/u/${d.author.username}`} className="author-name">{d.author.full_name}</Link>
                <p>{d.author.bio}</p></div>
            </div>
          )}
          <Comments doc={d} />
        </div>
      </div>
      {related.data?.length > 0 && (
        <section className="up-next">
          <div className="container">
            <h2>Up next</h2>
            <div className="strip-grid">
              {related.data.map((r) => (
                <article key={r.id} className="strip-item strip-item-dark">
                  <Link to={`/article/${r.slug}`} tabIndex={-1} aria-hidden="true"><img src={r.cover_image_url} alt="" loading="lazy" /></Link>
                  <p className="kicker">{r.category?.name}</p>
                  <h3><Link to={`/article/${r.slug}`}>{r.title}</Link></h3>
                </article>
              ))}
            </div>
          </div>
        </section>
      )}
    </article>
  )
}
