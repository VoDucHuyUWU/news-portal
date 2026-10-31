import { useState } from 'react'
import { Link } from 'react-router-dom'
import { api } from '../api.js'
import { useAuth } from '../auth.jsx'
import { ErrorBox, Loading, num, useAsync, useDocTitle } from '../ui.jsx'

function Ranking({ title, note, items, unit, decimals = 0, big }) {
  return (
    <section className={`ranking ${big ? 'ranking-big' : ''}`}>
      <h2>{title}</h2>
      {note && <p className="ranking-note">{note}</p>}
      {items.length === 0 ? <p className="muted">Not enough activity yet.</p> : (
        <ol>
          {items.map(({ doc, value }, i) => (
            <li key={doc.id}>
              <span className="rank">{i + 1}</span>
              {big && i === 0 && <Link to={`/article/${doc.slug}`} className="ranking-art" tabIndex={-1} aria-hidden="true"><img src={doc.cover_image_url} alt="" /></Link>}
              <div>
                <p className="kicker kicker-dark">{doc.category?.name}</p>
                <Link to={`/article/${doc.slug}`} className="ranking-title">{doc.title}</Link>
                <span className="ranking-value">{decimals ? value.toFixed(decimals) : num(value)} {unit}</span>
              </div>
            </li>
          ))}
        </ol>
      )}
    </section>
  )
}

export default function Attention() {
  const [days, setDays] = useState(7)
  const { site } = useAuth()
  const data = useAsync(() => api('/api/attention', { params: { days, limit: 5 } }), [days])
  useDocTitle(`Attention | ${site.site_name}`, 'What readers are reading, searching for and discussing.')
  const a = data.data
  const maxQ = Math.max(1, ...(a?.trending_queries || []).map((q) => q.searches))
  return (
    <div>
      <header className="page-hero page-hero-split">
        <div className="container">
          <p className="kicker">Reader attention</p>
          <h1>Attention</h1>
          <p className="page-hero-dek">What readers are reading, searching for and talking about. Every ranking is counted live from activity on the site.</p>
          <div className="period" role="group" aria-label="Period">
            {[[7, 'This week'], [30, 'This month'], [90, 'Last 3 months']].map(([d, l]) => (
              <button key={d} className={days === d ? 'is-active' : ''} onClick={() => setDays(d)}>{l}</button>
            ))}
          </div>
          {a && <div className="hero-stats"><div><strong>{num(a.totals.views)}</strong><span>stories read</span></div>
            <div><strong>{num(a.totals.searches)}</strong><span>searches</span></div></div>}
        </div>
      </header>
      <div className="container page-pad">
        <ErrorBox error={data.error} onRetry={data.reload} />
        {!a ? <Loading /> : (
          <div className="attention-grid">
            <Ranking big title="Most read" note="Stories with the most reads in this period." items={a.most_read} unit="reads" />
            <Ranking big title="Most searched" note="Stories readers opened most often from search results." items={a.most_searched} unit="clicks from search" />
            <section className="ranking">
              <h2>Trending searches</h2>
              <p className="ranking-note">What people typed into the search box.</p>
              <ul className="query-bars">
                {a.trending_queries.map((q) => (
                  <li key={q.query}><Link to={`/search?q=${encodeURIComponent(q.query)}`}>{q.query}</Link>
                    <span className="qbar"><span style={{ width: `${(q.searches / maxQ) * 100}%` }} /></span><span className="qnum">{q.searches}</span></li>
                ))}
              </ul>
            </section>
            <Ranking title="Most discussed" note="All time, by visible comments." items={a.most_discussed} unit="comments" />
            <Ranking title="Highest rated" note="All time, at least two ratings." items={a.top_rated} unit="/ 5" decimals={1} />
            <Ranking title="Most liked" note="All time." items={a.most_liked} unit="likes" />
          </div>
        )}
      </div>
    </div>
  )
}
