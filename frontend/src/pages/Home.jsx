import { Link, useParams, useSearchParams } from 'react-router-dom'
import { api } from '../api.js'
import { useAuth } from '../auth.jsx'
import { ArticleCard, CategoryLink, Empty, ErrorBox, Loading, Pagination, fmtDate, num, useAsync, useDocTitle } from '../ui.jsx'

function Sidebar() {
  const popular = useAsync(() => api('/api/documents/popular', { params: { limit: 5 } }), [])
  const tags = useAsync(() => api('/api/tags'), [])
  return (
    <aside className="sidebar">
      <section className="side-block">
        <h2 className="side-title">Most read</h2>
        <ol className="most-read">
          {(popular.data || []).map((d) => (
            <li key={d.id}>
              <Link to={`/article/${d.slug}`}>{d.title}</Link>
              <span className="muted">{num(d.views_count)} views</span>
            </li>
          ))}
        </ol>
      </section>
      <section className="side-block">
        <h2 className="side-title">Topics</h2>
        <div className="tag-cloud">
          {(tags.data || []).filter((t) => t.document_count > 0).map((t) => (
            <Link key={t.id} to={`/tag/${t.slug}`}>{t.name} <span>{t.document_count}</span></Link>
          ))}
        </div>
      </section>
    </aside>
  )
}

export default function Home() {
  const { categorySlug, tagSlug } = useParams()
  const [params, setParams] = useSearchParams()
  const page = Number(params.get('page') || 1)
  const { site } = useAuth()
  const cats = useAsync(() => api('/api/categories'), [])
  const tags = useAsync(() => (tagSlug ? api('/api/tags') : Promise.resolve([])), [tagSlug])
  const list = useAsync(() => api('/api/documents', { params: { page, category: categorySlug, tag: tagSlug } }),
    [page, categorySlug, tagSlug])
  const category = (cats.data || []).find((c) => c.slug === categorySlug)
  const tag = (tags.data || []).find((t) => t.slug === tagSlug)
  const heading = category ? category.name : tag ? `#${tag.name}` : 'Latest'
  useDocTitle(`${heading} | ${site.site_name}`, category?.description || site.site_tagline)

  const items = list.data?.items || []
  const showLead = !categorySlug && !tagSlug && page === 1 && items.length > 0
  const [lead, ...rest] = showLead ? items : [null, ...items]
  return (
    <div className="container page-pad">
      <div className="section-head" style={{ '--cat': category?.color }}>
        <h1>{heading}</h1>
        <p className="lede">{category?.description || (tag ? `Articles tagged ${tag.name}.` : site.site_tagline)}</p>
        {list.data && <p className="muted">{num(list.data.total)} articles · page {list.data.page} of {list.data.pages}</p>}
      </div>
      <div className="with-sidebar">
        <div>
          <ErrorBox error={list.error} onRetry={list.reload} />
          {list.loading && !list.data && <Loading />}
          {lead && (
            <article className="lead-story" style={{ '--cat': lead.category?.color }}>
              <Link to={`/article/${lead.slug}`} className="lead-media" tabIndex={-1} aria-hidden="true">
                <img src={lead.cover_image_url} alt="" />
              </Link>
              <div className="lead-body">
                <div className="card-meta"><CategoryLink category={lead.category} /><span>{fmtDate(lead.published_at)}</span></div>
                <h2 className="lead-title"><Link to={`/article/${lead.slug}`}>{lead.title}</Link></h2>
                <p className="lead-summary">{lead.summary}</p>
                <p className="muted">By {lead.author?.full_name} · {num(lead.views_count)} views</p>
              </div>
            </article>
          )}
          {list.data && items.length === 0 && <Empty>No published articles here yet.</Empty>}
          <div className="card-grid">
            {rest.map((d) => <ArticleCard key={d.id} doc={d} />)}
          </div>
          <Pagination page={page} pages={list.data?.pages} onPage={(p) => { setParams({ page: p }); window.scrollTo(0, 0) }} />
        </div>
        <Sidebar />
      </div>
    </div>
  )
}
