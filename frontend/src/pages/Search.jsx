import { useEffect, useState } from 'react'
import { useSearchParams } from 'react-router-dom'
import { api } from '../api.js'
import { useAuth } from '../auth.jsx'
import { ArticleCard, Empty, ErrorBox, Loading, Pagination, num, useAsync, useDocTitle } from '../ui.jsx'

const FIELDS = ['q', 'category', 'tag', 'date_from', 'date_to', 'sort']

export default function Search() {
  const [params, setParams] = useSearchParams()
  const { site } = useAuth()
  const current = Object.fromEntries(FIELDS.map((f) => [f, params.get(f) || '']))
  const page = Number(params.get('page') || 1)
  const [form, setForm] = useState(current)
  useEffect(() => setForm(current), [params.toString()]) // eslint-disable-line react-hooks/exhaustive-deps
  const cats = useAsync(() => api('/api/categories'), [])
  const tags = useAsync(() => api('/api/tags'), [])
  const hasQuery = FIELDS.some((f) => f !== 'sort' && current[f])
  const result = useAsync(() => (hasQuery ? api('/api/search', { params: { ...current, page } }) : Promise.resolve(null)),
    [params.toString()])
  useDocTitle(`${current.q ? `"${current.q}"` : 'Search'} | ${site.site_name}`)
  const terms = (result.data?.query || '').toLowerCase().split(/\s+/).filter((t) => t.length > 1)

  const submit = (e) => {
    e.preventDefault()
    const next = Object.fromEntries(Object.entries(form).filter(([, v]) => v))
    setParams(next)
  }
  const logClick = (doc, index) => {
    const id = result.data?.search_log_id
    if (!id) return
    const rank = (result.data.page - 1) * result.data.page_size + index + 1
    api('/api/search/click', { method: 'POST', body: { search_log_id: id, document_id: doc.id, rank } }).catch(() => {})
  }
  const set = (k) => (e) => setForm({ ...form, [k]: e.target.value })
  return (
    <div className="container page-pad">
      <div className="section-head">
        <h1>Search</h1>
        <p className="lede">Keyword search across titles, summaries, article text and tags. Combine it with filters.</p>
      </div>
      <form className="search-panel" onSubmit={submit} role="search">
        <input className="search-input" type="search" value={form.q} onChange={set('q')} placeholder="Try: sleep, heat pump, inflation" aria-label="Keywords" autoFocus />
        <div className="filters">
          <label>Category
            <select value={form.category} onChange={set('category')}>
              <option value="">All categories</option>
              {(cats.data || []).map((c) => <option key={c.id} value={c.slug}>{c.name}</option>)}
            </select>
          </label>
          <label>Tag
            <select value={form.tag} onChange={set('tag')}>
              <option value="">All tags</option>
              {(tags.data || []).map((t) => <option key={t.id} value={t.slug}>{t.name}</option>)}
            </select>
          </label>
          <label>From <input type="date" value={form.date_from} onChange={set('date_from')} /></label>
          <label>To <input type="date" value={form.date_to} onChange={set('date_to')} /></label>
          <label>Sort
            <select value={form.sort || 'relevance'} onChange={set('sort')}>
              <option value="relevance">Best match</option>
              <option value="newest">Newest</option>
              <option value="oldest">Oldest</option>
              <option value="popular">Most viewed</option>
            </select>
          </label>
          <button className="btn">Search</button>
          {hasQuery && <button type="button" className="btn btn-ghost" onClick={() => setParams({})}>Clear</button>}
        </div>
      </form>
      <ErrorBox error={result.error} />
      {result.loading && hasQuery && <Loading label="Searching" />}
      {!hasQuery && <Empty>Type a keyword or choose a filter to start.</Empty>}
      {result.data && (
        <>
          <p className="result-count">{num(result.data.total)} result{result.data.total === 1 ? '' : 's'}
            {result.data.query && <> for <strong>“{result.data.query}”</strong></>}</p>
          {result.data.total === 0 && <Empty>No articles match. Try fewer or different words, or remove a filter.</Empty>}
          <div className="card-grid">
            {result.data.items.map((d, i) => <ArticleCard key={d.id} doc={d} terms={terms} onOpen={() => logClick(d, i)} />)}
          </div>
          <Pagination page={result.data.page} pages={result.data.pages}
            onPage={(p) => { setParams({ ...Object.fromEntries(params), page: p }); window.scrollTo(0, 0) }} />
        </>
      )}
    </div>
  )
}
