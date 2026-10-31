import { Link, NavLink, Navigate, Route, Routes, useNavigate } from 'react-router-dom'
import { api } from '../../api.js'
import { useAuth } from '../../auth.jsx'
import { Avatar, ErrorBox, Loading, fmtDateTime, num, useAsync, useDocTitle } from '../../ui.jsx'
import { DocumentEditor, Documents, Taxonomy } from './Content.jsx'
import { Comments, Reports, SpamRules } from './Moderation.jsx'
import { Analytics, Seo } from './SeoAnalytics.jsx'
import { Logs, Roles, SettingsPage, Users } from './System.jsx'

// Menu groups mirror the four staff roles; each item appears only if the user holds the permission.
export const MENU = [
  { group: 'Content', role: 'Content Manager', items: [
    { to: '/admin/documents', label: 'Articles', perms: ['documents.manage', 'documents.publish'] },
    { to: '/admin/taxonomy', label: 'Categories & tags', perms: ['taxonomy.manage'] },
  ] },
  { group: 'Community', role: 'Moderator', items: [
    { to: '/admin/comments', label: 'Comment review', perms: ['comments.moderate'] },
    { to: '/admin/reports', label: 'Reports', perms: ['reports.handle'] },
    { to: '/admin/spam', label: 'Spam control', perms: ['comments.moderate'] },
  ] },
  { group: 'SEO & data', role: 'Data & SEO Specialist', items: [
    { to: '/admin/seo', label: 'SEO metadata', perms: ['seo.manage'] },
    { to: '/admin/analytics', label: 'Analytics', perms: ['analytics.view'] },
  ] },
  { group: 'System', role: 'Super Admin', items: [
    { to: '/admin/users', label: 'Users', perms: ['users.manage'] },
    { to: '/admin/roles', label: 'Roles & permissions', perms: ['roles.manage'] },
    { to: '/admin/logs', label: 'System logs', perms: ['logs.view'] },
    { to: '/admin/settings', label: 'Global settings', perms: ['settings.manage'] },
  ] },
]

function Dashboard() {
  const { user } = useAuth()
  const data = useAsync(() => api('/api/admin/dashboard'), [])
  useDocTitle('Dashboard | Margin admin')
  return (
    <div>
      <div className="admin-head">
        <h1>Welcome back, {user.full_name.split(' ')[0] || user.username}</h1>
        <p className="muted">You are signed in as <strong>{user.role.label}</strong>. The menu shows only the tools your role can use.</p>
      </div>
      <ErrorBox error={data.error} />
      {data.loading ? <Loading /> : (
        <>
          <div className="stat-grid">
            {(data.data?.cards || []).map((c) => (
              <Link key={c.label} to={c.link} className="stat"><span className="stat-value">{num(c.value)}</span><span className="stat-label">{c.label}</span></Link>
            ))}
          </div>
          <section className="panel">
            <h2>Your permissions</h2>
            <ul className="perm-chips">{user.permissions.map((p) => <li key={p}><code>{p}</code></li>)}</ul>
          </section>
          {data.data?.recent_activity && (
            <section className="panel">
              <h2>Recent system activity</h2>
              <table className="table">
                <tbody>
                  {data.data.recent_activity.map((a) => (
                    <tr key={a.id}><td className="nowrap muted">{fmtDateTime(a.timestamp)}</td><td><code>{a.action}</code></td>
                      <td>{a.actor?.username || 'system'}</td><td>{a.detail}</td></tr>
                  ))}
                </tbody>
              </table>
            </section>
          )}
        </>
      )}
    </div>
  )
}

function Guard({ perms, children }) {
  const { can } = useAuth()
  if (!can(...perms)) {
    return <div className="alert alert-error">Your role does not have access to this page ({perms.join(' or ')}).</div>
  }
  return children
}

export default function AdminApp() {
  const { user, isStaff, logout, can, site } = useAuth()
  const navigate = useNavigate()
  if (!isStaff) {
    return (
      <div className="container narrow page-pad">
        <h1>Staff area</h1>
        <p>Your account ({user.role.label}) does not have any administrative permissions.</p>
        <Link className="btn" to="/">Back to the site</Link>
      </div>
    )
  }
  const g = (perms, el) => <Guard perms={perms}>{el}</Guard>
  return (
    <div className="admin">
      <aside className="admin-nav">
        <Link to="/" className="wordmark wordmark-small"><span className="wordmark-bar" aria-hidden="true" />{site.site_name}</Link>
        <div className="admin-user"><Avatar user={user} size={32} /><div><strong>{user.username}</strong><span>{user.role.label}</span></div></div>
        <nav aria-label="Admin">
          <NavLink to="/admin" end>Dashboard</NavLink>
          {MENU.map((section) => {
            const items = section.items.filter((i) => can(...i.perms))
            if (!items.length) return null
            return (
              <div key={section.group} className="admin-nav-group">
                <span className="admin-nav-title">{section.group}</span>
                {items.map((i) => <NavLink key={i.to} to={i.to}>{i.label}</NavLink>)}
              </div>
            )
          })}
        </nav>
        <div className="admin-nav-foot">
          <Link to="/">View site</Link>
          <button className="link-btn" onClick={() => { logout(); navigate('/') }}>Log out</button>
        </div>
      </aside>
      <main className="admin-main" id="main">
        <Routes>
          <Route index element={<Dashboard />} />
          <Route path="documents" element={g(['documents.manage', 'documents.publish', 'seo.manage'], <Documents />)} />
          <Route path="documents/new" element={g(['documents.manage'], <DocumentEditor />)} />
          <Route path="documents/:id" element={g(['documents.manage'], <DocumentEditor />)} />
          <Route path="taxonomy" element={g(['taxonomy.manage'], <Taxonomy />)} />
          <Route path="comments" element={g(['comments.moderate'], <Comments />)} />
          <Route path="reports" element={g(['reports.handle'], <Reports />)} />
          <Route path="spam" element={g(['comments.moderate'], <SpamRules />)} />
          <Route path="seo" element={g(['seo.manage'], <Seo />)} />
          <Route path="analytics" element={g(['analytics.view'], <Analytics />)} />
          <Route path="users" element={g(['users.manage'], <Users />)} />
          <Route path="roles" element={g(['roles.manage'], <Roles />)} />
          <Route path="logs" element={g(['logs.view'], <Logs />)} />
          <Route path="settings" element={g(['settings.manage'], <SettingsPage />)} />
          <Route path="*" element={<Navigate to="/admin" replace />} />
        </Routes>
      </main>
    </div>
  )
}
