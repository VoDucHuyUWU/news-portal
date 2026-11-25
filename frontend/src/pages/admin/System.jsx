import { useEffect, useState } from 'react'
import { api } from '../../api.js'
import { useAuth } from '../../auth.jsx'
import { SchemaDiagram, relations } from './Schema.jsx'
import { ColHead, ColumnPicker, DataTable, ErrorBox, Field, KeyTag, Loading, Modal, Notice, Pagination, fmtDateTime, num, useAsync, useColumns, useDocTitle } from '../../ui.jsx'

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
  const cols = useColumns('users', [
    { id: 'id', label: 'id', badge: 'PK', header: <ColHead name="id" pk />, tdClass: 'small', cell: (u) => u.id },
    { id: 'user', label: 'User', cell: (u) => <><strong>{u.full_name || u.username}</strong><div className="muted small">@{u.username}</div></> },
    { id: 'email', label: 'Email', cell: (u) => u.email },
    { id: 'role', label: 'Role', badge: 'FK', header: <ColHead name="Role" fk="roles.id" />, cell: (u) => (
      <select value={u.role.id} onChange={(e) => update(u, { role_id: Number(e.target.value) })} aria-label={`Role of ${u.username}`}>
        {(roles.data || []).map((r) => <option key={r.id} value={r.id}>{r.label}</option>)}
      </select>) },
    { id: 'status', label: 'Status', cell: (u) => (u.is_active ? <span className="badge badge-visible">active</span> : <span className="badge badge-hidden">deactivated</span>) },
    { id: 'last_login', label: 'Last login', tdClass: 'nowrap small', cell: (u) => (u.last_login_at ? fmtDateTime(u.last_login_at) : 'never') },
    { id: 'actions', label: 'Actions', header: '', fixed: true,
      cell: (u) => u.id !== me.id && <button className="link-btn" onClick={() => update(u, { is_active: !u.is_active })}>{u.is_active ? 'Deactivate' : 'Reactivate'}</button> },
  ])
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
      <ColumnPicker cols={cols} />
      <ErrorBox error={error || list.error} />
      {list.loading && !list.data ? <Loading /> : (
        <DataTable cols={cols} rows={list.data?.items || []} rowClass={(u) => (u.is_active ? '' : 'is-muted')} empty="No users match." />
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
  const auditCols = useColumns('audit-log', [
    { id: 'id', label: 'id', badge: 'PK', header: <ColHead name="id" pk />, tdClass: 'small', cell: (l) => l.id },
    { id: 'time', label: 'Time', tdClass: 'nowrap small', cell: (l) => fmtDateTime(l.timestamp) },
    { id: 'action', label: 'Action', cell: (l) => <code>{l.action}</code> },
    { id: 'actor', label: 'Actor', badge: 'FK', header: <ColHead name="Actor" fk="users.id" />, cell: (l) => l.actor?.username || '—' },
    { id: 'entity', label: 'Entity', tdClass: 'small', cell: (l) => <>{l.entity}{l.entity_id && ` #${l.entity_id}`}</> },
    { id: 'detail', label: 'Detail', tdClass: 'small', cell: (l) => l.detail },
    { id: 'ip', label: 'IP', tdClass: 'small muted', cell: (l) => l.ip_address },
  ])
  const searchCols = useColumns('search-log', [
    { id: 'id', label: 'id', badge: 'PK', header: <ColHead name="id" pk />, tdClass: 'small', cell: (l) => l.id },
    { id: 'event', label: 'Event', cell: (l) => <span className={`badge badge-${l.event_type === 'click' ? 'visible' : 'draft'}`}>{l.event_type}</span> },
    { id: 'user_id', label: 'user_id', badge: 'FK', header: <ColHead name="user_id" fk="users.id" />, cell: (l) => l.user_id ?? 'guest' },
    { id: 'query_string', label: 'query_string', cell: (l) => l.query_string },
    { id: 'results', label: 'Results', thClass: 'num', tdClass: 'num', cell: (l) => l.results_count ?? '' },
    { id: 'search_id', label: 'search_id', badge: 'FK', header: <ColHead name="search_id" fk="search_click_logs.id" />, cell: (l) => l.search_id ?? '' },
    { id: 'clicked_doc_id', label: 'clicked_doc_id', badge: 'FK', header: <ColHead name="clicked_doc_id" fk="documents.id" />, cell: (l) => l.clicked_doc_id ?? '' },
    { id: 'rank', label: 'Rank', thClass: 'num', tdClass: 'num', cell: (l) => l.click_rank ?? '' },
    { id: 'timestamp', label: 'timestamp', tdClass: 'nowrap small', cell: (l) => fmtDateTime(l.timestamp) },
  ])
  const cols = tab === 'audit' ? auditCols : searchCols
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
      <ColumnPicker cols={cols} />
      <ErrorBox error={data.error} />
      {data.loading && !data.data ? <Loading /> : (
        <DataTable cols={cols} rows={data.data?.items || []} empty="No log entries." />
      )}
      <Pagination page={page} pages={data.data?.pages} onPage={setPage} />
    </div>
  )
}

// ---------- Database browser: every SQL table as it is stored (columns, PK, FK, raw rows) ----------
function dbValue(v) {
  if (v === null || v === undefined) return <span className="db-null">NULL</span>
  if (typeof v === 'boolean') return v ? 'true' : 'false'
  const text = typeof v === 'object' ? JSON.stringify(v) : String(v)
  return text.length > 48 ? <span className="db-long">{text}</span> : text
}

export function Database() {
  const tables = useAsync(() => api('/api/admin/database/tables'), [])
  const [name, setName] = useState('documents')
  const [page, setPage] = useState(1)
  const [newestFirst, setNewestFirst] = useState(false)
  const [view, setView] = useState('data')
  const rows = useAsync(() => api(`/api/admin/database/tables/${name}`, { params: { page, newest_first: newestFirst } }), [name, page, newestFirst])
  useDocTitle('Database | Margin admin')
  const open = (table) => { setName(table); setPage(1); setView('data') }
  const relCols = useColumns('db-relations', [
    { id: 'from', label: 'Table', cell: (r) => <button type="button" className="link-btn" onClick={() => open(r.from)}>{r.from}</button> },
    { id: 'column', label: 'Foreign key column', badge: 'FK', header: <ColHead name="Foreign key column" />, cell: (r) => <code>{r.column}</code> },
    { id: 'to', label: 'References', badge: 'PK', header: <ColHead name="References" />, cell: (r) => <><button type="button" className="link-btn" onClick={() => open(r.to)}>{r.to}</button>.<code>{r.toColumn}</code></> },
    { id: 'kind', label: 'Relationship', cell: (r) => r.kind },
    { id: 'required', label: 'Required', cell: (r) => (r.nullable ? 'optional (NULL allowed)' : 'required') },
    { id: 'on_delete', label: 'ON DELETE', cell: (r) => <code>{r.onDelete}</code> },
  ])
  const meta = (tables.data || []).find((t) => t.name === name)
  const schema = meta?.columns || (rows.data?.name === name ? rows.data.columns : [])
  const cols = useColumns(`db.${name}`, schema.map((c) => ({
    id: c.name,
    label: c.name,
    badge: c.primary_key ? 'PK' : c.foreign_key ? 'FK' : null,
    tdClass: c.primary_key ? 'is-key' : '',
    header: (<>
      {c.name}{c.primary_key && <KeyTag kind="PK" />}{c.foreign_key && <KeyTag kind="FK" title={`Foreign key to ${c.foreign_key}`} />}
      <div className="col-type">{c.type}{c.nullable ? '' : ' · not null'}{c.unique ? ' · unique' : ''}</div>
      {c.foreign_key && <div className="col-ref"><button type="button" className="link-btn" onClick={() => open(c.foreign_key.split('.')[0])}>→ {c.foreign_key}</button></div>}
    </>),
    cell: (r) => dbValue(r[c.name]),
  })))
  const pk = meta?.primary_key || []
  const items = rows.data?.name === name ? rows.data.items : []
  return (
    <div>
      <div className="admin-head"><h1>Database</h1><p className="muted">Every table exactly as the SQL database stores it: real column names and types, primary keys, foreign keys and raw rows, plus a diagram of how the tables relate. Read-only.</p></div>
      <ErrorBox error={tables.error} />
      <div className="segmented" role="group" aria-label="View">
        <button type="button" className={view === 'data' ? 'is-active' : ''} onClick={() => setView('data')}>Table data</button>
        <button type="button" className={view === 'schema' ? 'is-active' : ''} onClick={() => setView('schema')}>Relationships</button>
      </div>
      {view === 'schema' && (!tables.data ? <Loading /> : (
        <>
          <SchemaDiagram tables={tables.data} onOpen={open} />
          <h2 className="db-subhead">All {relations(tables.data).length} foreign keys</h2>
          <ColumnPicker cols={relCols} />
          <DataTable className="db-table" cols={relCols} rows={relations(tables.data)} />
        </>
      ))}
      {view === 'data' && (<>
      <div className="toolbar">
        <select value={name} onChange={(e) => open(e.target.value)} aria-label="Table">
          {(tables.data || [{ name, rows: 0 }]).map((t) => <option key={t.name} value={t.name}>{t.name} ({num(t.rows)} rows)</option>)}
        </select>
        <label className="check"><input type="checkbox" checked={newestFirst} onChange={(e) => { setNewestFirst(e.target.checked); setPage(1) }} /> Newest first (primary key descending)</label>
      </div>
      {meta && (
        <div className="db-meta">
          <span><strong>{meta.name}</strong>: {num(meta.rows)} rows, {meta.columns.length} columns</span>
          <span>Primary key<KeyTag kind="PK" /> {pk.map((k) => <code key={k}>{k}</code>).reduce((a, b) => (a.length ? [...a, ' + ', b] : [b]), [])}</span>
          <span>Foreign keys<KeyTag kind="FK" /> {meta.foreign_keys.length === 0 ? 'none' : meta.foreign_keys.map((f, i) => (
            <span key={f.column}>{i > 0 && ', '}<code>{f.column}</code> → <button type="button" className="link-btn" onClick={() => open(f.references.split('.')[0])}>{f.references}</button></span>))}</span>
        </div>
      )}
      {schema.length > 0 && <ColumnPicker cols={cols} />}
      <ErrorBox error={rows.error} />
      {(rows.loading && !rows.data) || schema.length === 0 ? <Loading /> : (
        <DataTable className="db-table" cols={cols} rows={items} rowKey={(r) => (pk.length ? pk.map((k) => r[k]).join('|') : JSON.stringify(r))} empty="This table has no rows." />
      )}
      <Pagination page={page} pages={rows.data?.pages} onPage={setPage} />
      <p className="db-legend"><span><KeyTag kind="PK" /> primary key: identifies one row</span><span><KeyTag kind="FK" /> foreign key: points to a row in another table (click the arrow to open it)</span><span><span className="db-null">NULL</span> = no value</span></p>
      </>)}
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
