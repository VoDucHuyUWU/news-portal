import { useState } from 'react'
import { Link } from 'react-router-dom'
import { api } from '../../api.js'
import { ErrorBox, Field, Loading, Modal, Pagination, StatusBadge, num, useAsync, useDocTitle } from '../../ui.jsx'

function Meter({ value }) {
  const tone = value === 100 ? 'good' : value >= 50 ? 'mid' : 'low'
  return <span className={`meter meter-${tone}`} aria-label={`${value}% complete`}><span style={{ width: `${value}%` }} /></span>
}

export function Seo() {
  const [missingOnly, setMissingOnly] = useState(false)
  const [page, setPage] = useState(1)
  const [q, setQ] = useState('')
  const [editing, setEditing] = useState(null)
  const [error, setError] = useState(null)
  const list = useAsync(() => api('/api/admin/seo', { params: { missing_only: missingOnly, page, q } }), [missingOnly, page, q])
  useDocTitle('SEO metadata | Margin admin')
  const open = (item) => setEditing({ id: item.id, title: item.title, slug: item.slug,
    meta_title: item.seo?.meta_title || '', meta_description: item.seo?.meta_description || '', keywords: item.seo?.keywords || '', image_alt: item.seo?.image_alt || '' })
  const save = async (e) => {
    e.preventDefault()
    setError(null)
    try {
      const { id, title, slug, ...body } = editing
      await api(`/api/admin/seo/${id}`, { method: 'PUT', body })
      setEditing(null)
      list.reload()
    } catch (err) { setError(err) }
  }
  const len = editing?.meta_description.length || 0
  return (
    <div>
      <div className="admin-head"><h1>SEO metadata</h1><p className="muted">Titles, descriptions, keywords and image alt text used by search engines, link previews and screen readers.</p></div>
      <div className="toolbar">
        <input type="search" placeholder="Filter by title" value={q} onChange={(e) => { setQ(e.target.value); setPage(1) }} />
        <label className="check"><input type="checkbox" checked={missingOnly} onChange={(e) => { setMissingOnly(e.target.checked); setPage(1) }} /> Only articles with missing fields</label>
      </div>
      <ErrorBox error={list.error} />
      {list.loading && !list.data ? <Loading /> : (
        <div className="table-wrap"><table className="table">
          <thead><tr><th>Article</th><th>Status</th><th>Completeness</th><th>Missing</th><th></th></tr></thead>
          <tbody>
            {(list.data?.items || []).map((i) => (
              <tr key={i.id}>
                <td><strong>{i.title}</strong><div className="muted small">{i.seo?.meta_description || 'No description'}</div></td>
                <td><StatusBadge status={i.status} /></td>
                <td className="nowrap"><Meter value={i.completeness} /> {i.completeness}%</td>
                <td className="small">{i.missing.join(', ') || '—'}</td>
                <td><button className="btn btn-small btn-ghost" onClick={() => open(i)}>Edit</button></td>
              </tr>
            ))}
          </tbody>
        </table></div>
      )}
      <Pagination page={page} pages={list.data?.pages} onPage={setPage} />
      {editing && (
        <Modal title="Edit SEO metadata" onClose={() => setEditing(null)} wide>
          <form className="stack" onSubmit={save}>
            <p className="muted">{editing.title} · <Link to={`/article/${editing.slug}`} target="_blank">open article</Link></p>
            <Field label="Meta title" hint={`${editing.meta_title.length} characters (aim for under 60)`}><input value={editing.meta_title} onChange={(e) => setEditing({ ...editing, meta_title: e.target.value })} /></Field>
            <Field label="Meta description" hint={`${len} characters (50–160 recommended)`}><textarea rows={3} value={editing.meta_description} onChange={(e) => setEditing({ ...editing, meta_description: e.target.value })} /></Field>
            <Field label="Keywords" hint="Comma separated"><input value={editing.keywords} onChange={(e) => setEditing({ ...editing, keywords: e.target.value })} /></Field>
            <Field label="Cover image alt text" hint="Describe the image for screen readers"><input value={editing.image_alt} onChange={(e) => setEditing({ ...editing, image_alt: e.target.value })} /></Field>
            <div className="serp-preview" aria-label="Search result preview">
              <span className="serp-url">margin.demo › article › {editing.slug}</span>
              <span className="serp-title">{editing.meta_title || editing.title}</span>
              <span className="serp-desc">{editing.meta_description || 'No description: search engines will pick text from the page.'}</span>
            </div>
            <ErrorBox error={error} />
            <button className="btn">Save metadata</button>
          </form>
        </Modal>
      )}
    </div>
  )
}

function DailyViews({ series }) {
  const max = Math.max(1, ...series.map((d) => d.views))
  const w = 720
  const h = 180
  const bw = w / series.length
  const ticks = [0, Math.round(max / 2), max]
  return (
    <figure className="chart">
      <svg viewBox={`0 -14 ${w + 40} ${h + 42}`} role="img" aria-label="Daily article views">
        {ticks.map((t) => {
          const y = h - (t / max) * h
          return <g key={t}><line x1="36" x2={w + 40} y1={y} y2={y} className="grid" /><text x="30" y={y + 4} className="axis" textAnchor="end">{t}</text></g>
        })}
        {series.map((d, i) => {
          const bh = (d.views / max) * h
          return (
            <g key={d.date}>
              <rect x={40 + i * bw + 1} y={h - bh} width={Math.max(1, bw - 2)} height={bh} className="bar"><title>{`${d.date}: ${d.views} views`}</title></rect>
              {(i % Math.ceil(series.length / 6) === 0) && <text x={40 + i * bw + bw / 2} y={h + 18} className="axis" textAnchor="middle">{d.date.slice(5)}</text>}
            </g>
          )
        })}
      </svg>
    </figure>
  )
}

function HBars({ rows }) {
  const max = Math.max(1, ...rows.map((r) => r.value))
  return (
    <ul className="hbars">
      {rows.map((r) => (
        <li key={r.label}><span className="hbar-label">{r.label}</span>
          <span className="hbar-track"><span className="hbar-fill" style={{ width: `${(r.value / max) * 100}%`, background: r.color }} /></span>
          <span className="hbar-value">{num(r.value)}</span></li>
      ))}
    </ul>
  )
}

export function Analytics() {
  const [days, setDays] = useState(30)
  const data = useAsync(() => api('/api/admin/analytics', { params: { days } }), [days])
  useDocTitle('Analytics | Margin admin')
  const a = data.data
  return (
    <div>
      <div className="admin-head row-between">
        <div><h1>Analytics</h1><p className="muted">Computed live from view events, search/click logs and engagement tables.</p></div>
        <div className="segmented" role="group" aria-label="Period">
          {[7, 30, 90].map((d) => <button key={d} className={days === d ? 'is-active' : ''} onClick={() => setDays(d)}>{d} days</button>)}
        </div>
      </div>
      <ErrorBox error={data.error} />
      {!a ? <Loading /> : (
        <>
          <div className="stat-grid">
            <div className="stat"><span className="stat-value">{num(a.totals.views_in_period)}</span><span className="stat-label">Article views</span></div>
            <div className="stat"><span className="stat-value">{num(a.totals.searches)}</span><span className="stat-label">Searches</span></div>
            <div className="stat"><span className="stat-value">{a.totals.click_through_rate == null ? '—' : `${Math.round(a.totals.click_through_rate * 100)}%`}</span><span className="stat-label">Searches with a click</span></div>
            <div className="stat"><span className="stat-value">{a.totals.avg_click_rank ?? '—'}</span><span className="stat-label">Average clicked position</span></div>
            <div className="stat"><span className="stat-value">{num(a.totals.new_comments)}</span><span className="stat-label">New comments</span></div>
            <div className="stat"><span className="stat-value">{a.totals.seo_complete_articles}/{a.totals.published_articles}</span><span className="stat-label">Articles with complete SEO</span></div>
          </div>
          <section className="panel"><h2>Views per day</h2><DailyViews series={a.daily_views} /></section>
          <div className="two-col">
            <section className="panel"><h2>Most viewed articles</h2>
              <table className="table"><tbody>{a.top_documents.map((d) => (
                <tr key={d.id}><td><Link to={`/article/${d.slug}`} target="_blank">{d.title}</Link></td><td className="num">{num(d.views)}</td></tr>))}</tbody></table>
            </section>
            <section className="panel"><h2>Views by category</h2>
              <HBars rows={a.views_by_category.map((c) => ({ label: c.category, value: c.views, color: c.color }))} />
            </section>
            <section className="panel"><h2>Top search queries</h2>
              <table className="table"><thead><tr><th>Query</th><th className="num">Searches</th><th className="num">Avg. results</th></tr></thead>
                <tbody>{a.top_queries.map((q) => <tr key={q.query}><td>{q.query}</td><td className="num">{q.searches}</td><td className="num">{q.avg_results}</td></tr>)}</tbody></table>
            </section>
            <section className="panel"><h2>Searches with no results</h2>
              <p className="muted small">Content gaps: topics readers look for that no article covers yet.</p>
              <table className="table"><tbody>{a.zero_result_queries.length ? a.zero_result_queries.map((q) => <tr key={q.query}><td>{q.query}</td><td className="num">{q.searches}</td></tr>)
                : <tr><td className="muted">None in this period.</td></tr>}</tbody></table>
            </section>
          </div>
        </>
      )}
    </div>
  )
}
