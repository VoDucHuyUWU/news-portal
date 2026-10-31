import { useEffect, useState } from 'react'
import { Link, useSearchParams } from 'react-router-dom'
import { api } from '../../api.js'
import { Avatar, ErrorBox, Field, Loading, Notice, Pagination, StatusBadge, timeAgo, useAsync, useDocTitle } from '../../ui.jsx'

export function Comments() {
  const [params, setParams] = useSearchParams()
  const status = params.get('status') ?? 'pending'
  const page = Number(params.get('page') || 1)
  const list = useAsync(() => api('/api/admin/comments', { params: { status, page } }), [status, page])
  const [msg, setMsg] = useState(null)
  useDocTitle('Comment review | Margin admin')
  const setStatus = async (c, s) => { await api(`/api/admin/comments/${c.id}`, { method: 'PATCH', body: { status: s } }); list.reload() }
  const remove = async (c) => { if (window.confirm('Delete this comment permanently?')) { await api(`/api/admin/comments/${c.id}`, { method: 'DELETE' }); list.reload() } }
  const purge = async () => {
    if (!window.confirm('Delete every comment marked as spam?')) return
    const r = await api('/api/admin/comments/purge-spam', { method: 'POST' })
    setMsg(`${r.deleted} spam comments deleted.`)
    list.reload()
  }
  return (
    <div>
      <div className="admin-head row-between">
        <div><h1>Comment review</h1><p className="muted">Approve, hide or mark comments as spam. Auto-flagged comments wait in “Pending”.</p></div>
        <button className="btn btn-ghost" onClick={purge}>Delete all spam</button>
      </div>
      <div className="segmented" role="group" aria-label="Status">
        {[['pending', 'Pending'], ['visible', 'Visible'], ['hidden', 'Hidden'], ['spam', 'Spam'], ['', 'All']].map(([v, l]) => (
          <button key={v} className={status === v ? 'is-active' : ''} onClick={() => setParams({ status: v })}>{l}</button>
        ))}
      </div>
      {msg && <Notice kind="success">{msg}</Notice>}
      <ErrorBox error={list.error} />
      {list.loading && !list.data ? <Loading /> : (
        <ul className="mod-list">
          {(list.data?.items || []).length === 0 && <li className="muted">Nothing here. The queue is clear.</li>}
          {(list.data?.items || []).map((c) => (
            <li key={c.id} className="mod-item">
              <Avatar user={c.user} size={32} />
              <div className="mod-main">
                <div className="comment-head"><strong>{c.user.full_name}</strong> <span className="muted">@{c.user.username} · {timeAgo(c.created_at)} · on <Link to={`/article/${c.document_slug}`} target="_blank">{c.document_title}</Link></span>
                  <StatusBadge status={c.status} />{c.report_count > 0 && <span className="badge badge-open">{c.report_count} report(s)</span>}</div>
                <p>{c.content}</p>
                {c.flag_reason && <p className="flag">{c.flag_reason}</p>}
                <div className="actions">
                  {c.status !== 'visible' && <button className="btn btn-small" onClick={() => setStatus(c, 'visible')}>Approve</button>}
                  {c.status !== 'hidden' && <button className="btn btn-small btn-ghost" onClick={() => setStatus(c, 'hidden')}>Hide</button>}
                  {c.status !== 'spam' && <button className="btn btn-small btn-ghost" onClick={() => setStatus(c, 'spam')}>Mark spam</button>}
                  <button className="link-btn danger" onClick={() => remove(c)}>Delete</button>
                </div>
              </div>
            </li>
          ))}
        </ul>
      )}
      <Pagination page={page} pages={list.data?.pages} onPage={(p) => setParams({ status, page: p })} />
    </div>
  )
}

export function Reports() {
  const [status, setStatusFilter] = useState('open')
  const list = useAsync(() => api('/api/admin/reports', { params: { status } }), [status])
  const [error, setError] = useState(null)
  useDocTitle('Reports | Margin admin')
  const handle = async (r, newStatus, action) => {
    setError(null)
    try {
      await api(`/api/admin/reports/${r.id}`, { method: 'PATCH', body: { status: newStatus, action } })
      list.reload()
    } catch (err) { setError(err) }
  }
  return (
    <div>
      <div className="admin-head"><h1>Reports</h1><p className="muted">Flags submitted by readers about comments or articles.</p></div>
      <div className="segmented" role="group">
        {['open', 'resolved', 'dismissed'].map((s) => <button key={s} className={status === s ? 'is-active' : ''} onClick={() => setStatusFilter(s)}>{s}</button>)}
      </div>
      <ErrorBox error={error || list.error} />
      {list.loading && !list.data ? <Loading /> : (
        <div className="table-wrap"><table className="table">
          <thead><tr><th>Reported</th><th>Target</th><th>Reason</th><th>By</th><th>Actions</th></tr></thead>
          <tbody>
            {(list.data?.items || []).length === 0 && <tr><td colSpan={5} className="muted">No {status} reports.</td></tr>}
            {(list.data?.items || []).map((r) => (
              <tr key={r.id}>
                <td className="nowrap">{timeAgo(r.created_at)}</td>
                <td><span className="badge">{r.target_type}</span> {r.target_link ? <Link to={r.target_link} target="_blank">{r.target_preview}</Link> : r.target_preview}</td>
                <td>{r.reason}</td>
                <td>{r.reporter?.username || '—'}</td>
                <td className="actions">
                  {r.status === 'open' ? (<>
                    {r.target_type === 'comment' && <button className="btn btn-small" onClick={() => handle(r, 'resolved', 'hide')}>Hide comment</button>}
                    {r.target_type === 'comment' && <button className="btn btn-small btn-ghost" onClick={() => handle(r, 'resolved', 'spam')}>Mark spam</button>}
                    {r.target_type === 'document' && <button className="btn btn-small" onClick={() => handle(r, 'resolved', 'none')}>Resolve (forward to editors)</button>}
                    <button className="link-btn" onClick={() => handle(r, 'dismissed', 'none')}>Dismiss</button>
                  </>) : <StatusBadge status={r.status} />}
                </td>
              </tr>
            ))}
          </tbody>
        </table></div>
      )}
    </div>
  )
}

export function SpamRules() {
  const [form, setForm] = useState(null)
  const [msg, setMsg] = useState(null)
  const [error, setError] = useState(null)
  useDocTitle('Spam control | Margin admin')
  useEffect(() => { api('/api/admin/spam-rules').then(setForm).catch(setError) }, [])
  const save = async (e) => {
    e.preventDefault()
    setError(null)
    try {
      setForm(await api('/api/admin/spam-rules', { method: 'PUT', body: { ...form, max_links_per_comment: Number(form.max_links_per_comment), comment_rate_limit_per_minute: Number(form.comment_rate_limit_per_minute) } }))
      setMsg('Spam rules saved.')
    } catch (err) { setError(err) }
  }
  if (!form) return error ? <ErrorBox error={error} /> : <Loading />
  return (
    <div>
      <div className="admin-head"><h1>Spam control</h1><p className="muted">New comments from readers that break these rules are held in the review queue instead of being published.</p></div>
      <form className="panel stack narrow-panel" onSubmit={save}>
        <Field label="Blocked words and phrases" hint="Comma separated, case-insensitive">
          <textarea rows={4} value={form.spam_keywords} onChange={(e) => setForm({ ...form, spam_keywords: e.target.value })} /></Field>
        <Field label="Maximum links per comment"><input type="number" min={0} max={50} value={form.max_links_per_comment} onChange={(e) => setForm({ ...form, max_links_per_comment: e.target.value })} /></Field>
        <Field label="Maximum comments per user per minute" hint="Faster posting is rejected (HTTP 429)"><input type="number" min={1} max={100} value={form.comment_rate_limit_per_minute} onChange={(e) => setForm({ ...form, comment_rate_limit_per_minute: e.target.value })} /></Field>
        <label className="check"><input type="checkbox" checked={form.comments_require_approval} onChange={(e) => setForm({ ...form, comments_require_approval: e.target.checked })} /> Hold every reader comment for approval</label>
        {msg && <Notice kind="success">{msg}</Notice>}
        <ErrorBox error={error} />
        <button className="btn">Save rules</button>
      </form>
    </div>
  )
}
