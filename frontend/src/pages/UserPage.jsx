import { Link, useParams } from 'react-router-dom'
import { api } from '../api.js'
import { ArticleCard, Avatar, ErrorBox, Loading, fmtDate, timeAgo, useAsync, useDocTitle } from '../ui.jsx'

export default function UserPage() {
  const { username } = useParams()
  const profile = useAsync(() => api(`/api/users/${username}`), [username])
  useDocTitle(`@${username} | Margin`)
  if (profile.loading) return <div className="container page-pad"><Loading /></div>
  if (profile.error) return <div className="container page-pad"><ErrorBox error={profile.error} /></div>
  const p = profile.data
  return (
    <div className="container page-pad">
      <div className="profile-head">
        <Avatar user={p.user} size={64} />
        <div>
          <h1>{p.user.full_name || p.user.username}</h1>
          <p className="muted">@{p.user.username} · {p.role} · joined {fmtDate(p.joined)} · {p.comment_count} comments</p>
          {p.user.bio && <p>{p.user.bio}</p>}
        </div>
      </div>
      {p.articles.length > 0 && (
        <section>
          <h2 className="side-title">Articles by {p.user.full_name}</h2>
          <div className="card-grid">{p.articles.map((a) => <ArticleCard key={a.id} doc={a} />)}</div>
        </section>
      )}
      <section className="panel">
        <h2>Recent comments</h2>
        {p.recent_comments.length === 0 && <p className="muted">No comments yet.</p>}
        <ul className="mention-feed">
          {p.recent_comments.map((c) => (
            <li key={c.id}><div>
              <span className="muted">On <Link to={`/article/${c.document_slug}#comment-${c.id}`}>{c.document_title}</Link> · {timeAgo(c.created_at)}</span>
              <p>{c.content}</p>
            </div></li>
          ))}
        </ul>
      </section>
    </div>
  )
}
