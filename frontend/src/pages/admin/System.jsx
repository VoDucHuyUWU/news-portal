import { useEffect, useState } from 'react'
import { api } from '../../api.js'
import { useAuth } from '../../auth.jsx'
import { ErrorBox, Field, Loading, Modal, Notice, Pagination, fmtDateTime, useAsync, useDocTitle } from '../../ui.jsx'

export function Users() {
  const { user: me } = useAuth()
  const [q, setQ] = useState('')
  const [role, setRole] = useState('')
  const [page, setPage] = useState(1)
  const [creating, setCreating] = useState(null)
  const [error, setError] = useState(null)
  const roles = useAsync(() => api('/api/admin/roles'), [])
  const list = useAsync(() => api('/api/admin/users', { params: { q, role, page } }), [q, role, page])
  useDocTitle('Users | Margin admin')
  const update = async (u, body) => {
    setError(null)
    try { await api(`/api/admin/users/${u.id}`, { method: 'PATCH', body }); list.reload(); roles.reload() } catch (err) { setError(err) }
  }
  const create = async (e) => {
    e.preventDefault()
    setError(null)
    try {
      await api('/api/admin/users', { method: 'POST', body: { ...creating, role_id: Number(creating.role_id) } })
      setCreating(null)
      list.reload()
    } catch (err) { setError(err) }
  }
  return (
    <div>
      <div className="admin-head row-between">
        <div><h1>Users</h1><p className="muted">Manage accounts, assign roles and deactivate users.</p></div>
        <button className="btn" onClick={() => setCreating({ username: '', email: '', full_name: '', password: '', role_id: roles.data?.find((r) => r.name === 'user')?.id || '' })}>New user</button>
      </div>
      <div className="toolbar">
        <input type="search" placeholder="Search name, username or email" value={q} onChange={(e) => { setQ(e.target.value); setPage(1) }} />
        <select value={role} onChange={(e) => { setRole(e.target.value); setPage(1) }} aria-label="Filter by role">
          <option value="">All roles</option>
          {(roles.data || []).map((r) => <option key={r.id} value={r.name}>{r.label}</option>)}
        </select>
      </div>
      <ErrorBox error={error || list.error} />
      {list.loading && !list.data ? <Loading /> : (
        <div className="table-wrap"><table className="table">
          <thead><tr><th>User</th><th>Email</th><th>Role</th><th>Status</th><th>Last login</th><th></th></tr></thead>
          <tbody>
            {(list.data?.items || []).map((u) => (
              <tr key={u.id} className={u.is_active ? '' : 'is-muted'}>
                <td><strong>{u.full_name || u.username}</strong><div className="muted small">@{u.username}</div></td>
                <td>{u.email}</td>
                <td>
                  <select value={u.role.id} onChange={(e) => update(u, { role_id: Number(e.target.value) })} aria-label={`Role of ${u.username}`}>
                    {(roles.data || []).map((r) => <option key={r.id} value={r.id}>{r.label}</option>)}
                  </select>
                </td>
                <td>{u.is_active ? <span className="badge badge-visible">active</span> : <span className="badge badge-hidden">deactivated</span>}</td>
                <td className="nowrap small">{u.last_login_at ? fmtDateTime(u.last_login_at) : 'never'}</td>
                <td>{u.id !== me.id && <button className="link-btn" onClick={() => update(u, { is_active: !u.is_active })}>{u.is_active ? 'Deactivate' : 'Reactivate'}</button>}</td>
              </tr>
            ))}
          </tbody>
        </table></div>
      )}
      <Pagination page={page} pages={list.data?.pages} onPage={setPage} />
      {creating && (
        <Modal title="New user" onClose={() => setCreating(null)}>
          <form className="stack" onSubmit={create}>
            <Field label="Username"><input required pattern="[A-Za-z0-9_]{3,40}" value={creating.username} onChange={(e) => setCreating({ ...creating, username: e.target.value })} /></Field>
            <Field label="Full name"><input value={creating.full_name} onChange={(e) => setCreating({ ...creating, full_name: e.target.value })} /></Field>
            <Field label="Email"><input required type="email" value={creating.email} onChange={(e) => setCreating({ ...creating, email: e.target.value })} /></Field>
            <Field label="Temporary password" hint="At least 8 characters"><input required minLength={8} value={creating.password} onChange={(e) => setCreating({ ...creating, password: e.target.value })} /></Field>
            <Field label="Role"><select value={creating.role_id} onChange={(e) => setCreating({ ...creating, role_id: e.target.value })}>
              {(roles.data || []).map((r) => <option key={r.id} value={r.id}>{r.label}</option>)}</select></Field>
            <ErrorBox error={error} />
            <button className="btn">Create user</button>
          </form>
        </Modal>
      )}
    </div>
  )
}

export function Roles() {
  const roles = useAsync(() => api('/api/admin/roles'), [])
  const perms = useAsync(() => api('/api/admin/permissions'), [])
  const [draft, setDraft] = useState({})
  const [msg, setMsg] = useState(null)
  const [error, setError] = useState(null)
  useDocTitle('Roles & permissions | Margin admin')
  useEffect(() => {
    if (roles.data) setDraft(Object.fromEntries(roles.data.map((r) => [r.id, new Set(r.permissions)])))
  }, [roles.data])
  const toggle = (roleId, code) => {
    const next = new Set(draft[roleId])
    next.has(code) ? next.delete(code) : next.add(code)
    setDraft({ ...draft, [roleId]: next })
  }
  const save = async (role) => {
    setError(null)
    setMsg(null)
    try {
      await api(`/api/admin/roles/${role.id}/permissions`, { method: 'PUT', body: { permissions: [...draft[role.id]] } })
      setMsg(`Permissions for ${role.label} saved.`)
      roles.reload()
    } catch (err) { setError(err) }
  }
  if (!roles.data || !perms.data) return <Loading />
  const dirty = (r) => draft[r.id] && (draft[r.id].size !== r.permissions.length || r.permissions.some((p) => !draft[r.id].has(p)))
  return (
    <div>
      <div className="admin-head"><h1>Roles &amp; permissions</h1><p className="muted">Tick a box to grant a permission to every user with that role. The API checks these permissions on every request.</p></div>
      {msg && <Notice kind="success">{msg}</Notice>}
      <ErrorBox error={error} />
      <div className="table-wrap"><table className="table matrix">
        <thead><tr><th>Permission</th>{roles.data.map((r) => <th key={r.id} className="center">{r.label}<div className="muted small">{r.user_count} users</div></th>)}</tr></thead>
        <tbody>
          {perms.data.map((p) => (
            <tr key={p.id}><td><code>{p.code}</code><div className="muted small">{p.description}</div></td>
              {roles.data.map((r) => (
                <td key={r.id} className="center"><input type="checkbox" aria-label={`${p.code} for ${r.label}`} checked={!!draft[r.id]?.has(p.code)} onChange={() => toggle(r.id, p.code)} /></td>
              ))}</tr>
          ))}
          <tr><td></td>{roles.data.map((r) => <td key={r.id} className="center"><button className="btn btn-small" disabled={!dirty(r)} onClick={() => save(r)}>Save</button></td>)}</tr>
        </tbody>
      </table></div>
    </div>
  )
}

export function Logs() {
  const [tab, setTab] = useState('audit')
  const [page, setPage] = useState(1)
  const [action, setAction] = useState('')
  const audit = useAsync(() => (tab === 'audit' ? api('/api/admin/audit-logs', { params: { page, action } }) : Promise.resolve(null)), [tab, page, action])
  const search = useAsync(() => (tab === 'search' ? api('/api/admin/search-logs', { params: { page } }) : Promise.resolve(null)), [tab, page])
  useDocTitle('System logs | Margin admin')
  const data = tab === 'audit' ? audit : search
  return (
    <div>
      <div className="admin-head"><h1>System logs</h1><p className="muted">Audit trail of sign-ins and administrative actions, and the raw search/click log collected for Phase 2.</p></div>
      <div className="toolbar">
        <div className="segmented" role="group">
          <button className={tab === 'audit' ? 'is-active' : ''} onClick={() => { setTab('audit'); setPage(1) }}>Audit log</button>
          <button className={tab === 'search' ? 'is-active' : ''} onClick={() => { setTab('search'); setPage(1) }}>Search &amp; click log</button>
        </div>
        {tab === 'audit' && (
          <select value={action} onChange={(e) => { setAction(e.target.value); setPage(1) }} aria-label="Filter by action">
            <option value="">All actions</option>
            {['auth.', 'user.', 'role.', 'settings.', 'document.', 'category.', 'tag.', 'comment.', 'report.', 'seo.', 'spam_rules.'].map((a) => <option key={a} value={a}>{a}*</option>)}
          </select>
        )}
      </div>
      <ErrorBox error={data.error} />
      {data.loading && !data.data ? <Loading /> : tab === 'audit' ? (
        <div className="table-wrap"><table className="table">
          <thead><tr><th>Time</th><th>Action</th><th>Actor</th><th>Entity</th><th>Detail</th><th>IP</th></tr></thead>
          <tbody>{(audit.data?.items || []).map((l) => (
            <tr key={l.id}><td className="nowrap small">{fmtDateTime(l.timestamp)}</td><td><code>{l.action}</code></td><td>{l.actor?.username || '—'}</td>
              <td className="small">{l.entity}{l.entity_id && ` #${l.entity_id}`}</td><td className="small">{l.detail}</td><td className="small muted">{l.ip_address}</td></tr>))}</tbody>
        </table></div>
      ) : (
        <div className="table-wrap"><table className="table">
          <thead><tr><th>ID</th><th>Event</th><th>user_id</th><th>query_string</th><th className="num">Results</th><th>clicked_doc_id</th><th className="num">Rank</th><th>timestamp</th></tr></thead>
          <tbody>{(search.data?.items || []).map((l) => (
            <tr key={l.id}><td className="small">{l.id}</td><td><span className={`badge badge-${l.event_type === 'click' ? 'visible' : 'draft'}`}>{l.event_type}</span></td>
              <td>{l.user_id ?? 'guest'}</td><td>{l.query_string}</td><td className="num">{l.results_count ?? ''}</td>
              <td>{l.clicked_doc_id ?? ''}</td><td className="num">{l.click_rank ?? ''}</td><td className="nowrap small">{fmtDateTime(l.timestamp)}</td></tr>))}</tbody>
        </table></div>
      )}
      <Pagination page={page} pages={data.data?.pages} onPage={setPage} />
    </div>
  )
}

const SETTING_LABELS = {
  site_name: ['Site name', 'Shown in the header, footer and page titles'],
  site_tagline: ['Tagline', 'Shown on the home page and footer'],
  page_size: ['Articles per page', 'Home, directory and search pages'],
  allow_registration: ['Allow new registrations', 'true or false'],
  comments_require_approval: ['Hold all reader comments for approval', 'true or false'],
  max_links_per_comment: ['Max links per comment', 'More links send a comment to review'],
  comment_rate_limit_per_minute: ['Comments per user per minute', 'Rate limit against flooding'],
  spam_keywords: ['Spam keywords', 'Comma separated'],
}

export function SettingsPage() {
  const [form, setForm] = useState(null)
  const [msg, setMsg] = useState(null)
  const [error, setError] = useState(null)
  const { refresh } = useAuth()
  useDocTitle('Global settings | Margin admin')
  useEffect(() => { api('/api/admin/settings').then(setForm).catch(setError) }, [])
  const save = async (e) => {
    e.preventDefault()
    setError(null)
    try {
      setForm(await api('/api/admin/settings', { method: 'PUT', body: form }))
      setMsg('Settings saved.')
      refresh()
    } catch (err) { setError(err) }
  }
  if (!form) return error ? <ErrorBox error={error} /> : <Loading />
  const bool = (k) => ['allow_registration', 'comments_require_approval'].includes(k)
  return (
    <div>
      <div className="admin-head"><h1>Global settings</h1><p className="muted">Site-wide configuration. Changes are recorded in the audit log.</p></div>
      <form className="panel stack narrow-panel" onSubmit={save}>
        {Object.entries(SETTING_LABELS).map(([k, [label, hint]]) => bool(k) ? (
          <label key={k} className="check"><input type="checkbox" checked={form[k] === 'true'} onChange={(e) => setForm({ ...form, [k]: e.target.checked ? 'true' : 'false' })} /> {label}</label>
        ) : (
          <Field key={k} label={label} hint={hint}>
            {k === 'spam_keywords' || k === 'site_tagline'
              ? <textarea rows={2} value={form[k]} onChange={(e) => setForm({ ...form, [k]: e.target.value })} />
              : <input value={form[k]} onChange={(e) => setForm({ ...form, [k]: e.target.value })} />}
          </Field>
        ))}
        {msg && <Notice kind="success">{msg}</Notice>}
        <ErrorBox error={error} />
        <button className="btn">Save settings</button>
      </form>
    </div>
  )
}
