import { Link, useParams, useSearchParams } from 'react-router-dom'
import { api } from '../api.js'
import { useAuth } from '../auth.jsx'
import { Empty, ErrorBox, Loading, Pagination, fmtDate, num, useAsync, useDocTitle } from '../ui.jsx'

const monthOf = (iso) => new Date(iso).toLocaleDateString('en-GB', { month: 'long', year: 'numeric' })

export default function Latest() {
  const { categorySlug, tagSlug } = useParams()
  const [params, setParams] = useSearchParams()
  const page = Number(params.get('page') || 1)
  const { site } = useAuth()
  const cats = useAsync(() => api('/api/categories'), [])
  const tags = useAsync(() => (tagSlug ? api('/api/tags') : Promise.resolve([])), [tagSlug])
  const list = useAsync(() => api('/api/documents', { params: { page, page_size: 10, category: categorySlug, tag: tagSlug } }),
    [page, categorySlug, tagSlug])
  const category = (cats.data || []).find((c) => c.slug === categorySlug)
  const tag = (tags.data || []).find((t) => t.slug === tagSlug)
  const title = category ? category.name : tag ? tag.name : 'Latest'
  const eyebrow = category ? 'Section' : tag ? 'Topic' : 'The newest stories'
  useDocTitle(`${title} | ${site.site_name}`, category?.description || site.site_tagline)
  const items = list.data?.items || []
  const groups = []
  items.forEach((d) => {
    const m = monthOf(d.published_at)
    if (!groups.length || groups[groups.length - 1].month !== m) groups.push({ month: m, docs: [] })
    groups[groups.length - 1].docs.push(d)
  })
  return (
    <div>
      <header className="page-hero">
        <div className="container">
          <p className="kicker">{eyebrow}</p>
          <h1>{title}</h1>
          <p className="page-hero-dek">{category?.description || (tag ? `Every story about ${tag.name}.` : 'Every story in the order it was published, newest first.')}</p>
          {list.data && <p className="page-hero-meta">{num(list.data.total)} stories · page {list.data.page} of {list.data.pages}</p>}
        </div>
      </header>
      <div className="container page-pad">
        <ErrorBox error={list.error} onRetry={list.reload} />
        {list.loading && !list.data && <Loading />}
        {list.data && items.length === 0 && <Empty>No published stories here yet.</Empty>}
        {groups.map((g) => (
          <section key={g.month} className="month">
            <h2 className="month-title">{g.month}</h2>
            {g.docs.map((d) => (
              <article key={d.id} className="row-story">
                <div className="row-date"><span className="row-day">{new Date(d.published_at).getDate()}</span>
                  <span>{new Date(d.published_at).toLocaleDateString('en-GB', { month: 'short' })}</span></div>
                <Link to={`/article/${d.slug}`} className="row-art" tabIndex={-1} aria-hidden="true"><img src={d.cover_image_url} alt="" loading="lazy" /></Link>
                <div className="row-text">
                  <p className="kicker kicker-dark">{d.category && <Link to={`/category/${d.category.slug}`}>{d.category.name}</Link>}</p>
                  <h3><Link to={`/article/${d.slug}`}>{d.title}</Link></h3>
                  <p className="row-dek">{d.summary}</p>
                  <p className="byline byline-dark">By {d.author?.full_name}<span>{fmtDate(d.published_at)}</span><span>{num(d.views_count)} reads</span></p>
                  {d.tags?.length > 0 && <p className="row-tags">{d.tags.map((t) => <Link key={t.id} to={`/tag/${t.slug}`}>{t.name}</Link>)}</p>}
                </div>
              </article>
            ))}
          </section>
        ))}
        <Pagination page={page} pages={list.data?.pages} onPage={(p) => { setParams({ page: p }); window.scrollTo(0, 0) }} />
      </div>
    </div>
  )
}
