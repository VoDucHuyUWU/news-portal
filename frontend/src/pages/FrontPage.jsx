import { Link } from 'react-router-dom'
import { api } from '../api.js'
import { useAuth } from '../auth.jsx'
import { ErrorBox, Loading, fmtDate, num, useAsync, useDocTitle } from '../ui.jsx'
import { useEnter, useWordHighlight } from '../motion.js'

const shortDate = (iso) => new Date(iso).toLocaleDateString("en-GB", { day: "numeric", month: "short" })

function CoverStory({ item }) {
  const d = item.doc
  const ref = useEnter([d.id])
  return (
    <section className="cover" aria-labelledby="cover-title" ref={ref}>
      <div className="container cover-grid">
        <div className="cover-text">
          <p className="kicker" data-e><span>Cover story</span>{d.category && <Link to={`/category/${d.category.slug}`}>{d.category.name}</Link>}</p>
          <h1 id="cover-title" className="cover-title"><Link to={`/article/${d.slug}`} data-split>{d.title}</Link></h1>
          <p className="cover-dek" data-e>{d.summary}</p>
          <p className="byline" data-e>By <strong>{d.author?.full_name || 'Staff'}</strong><span>{fmtDate(d.published_at)}</span></p>
          <div className="cover-actions" data-e>
            <Link className="btn btn-gold" to={`/article/${d.slug}`}>Read the cover story</Link>
            <Link className="btn btn-ghost" to="/latest">See all stories</Link>
          </div>
        </div>
        <Link to={`/article/${d.slug}`} className="cover-art" tabIndex={-1} aria-hidden="true" data-e-img>
          <img src={d.cover_image_url} alt="" />
        </Link>
      </div>
      <p className="container cover-why" data-e>Chosen by reader attention this week: views, searches, likes and comments.</p>
    </section>
  )
}

function Statement({ text }) {
  const ref = useWordHighlight()
  return (
    <section className="statement" ref={ref} aria-label="What we publish">
      <p className="container statement-text">
        {text.split(/\s+/).map((w, i) => <span key={i} data-w>{w} </span>)}
      </p>
    </section>
  )
}

function Feature({ item }) {
  const d = item.doc
  return (
    <article className="feature">
      <p className="feature-label">{item.label}</p>
      <Link to={`/article/${d.slug}`} className="feature-art" tabIndex={-1} aria-hidden="true"><img src={d.cover_image_url} alt="" loading="lazy" /></Link>
      <p className="kicker kicker-dark">{d.category?.name}</p>
      <h2 className="feature-title"><Link to={`/article/${d.slug}`}>{d.title}</Link></h2>
      <p className="feature-dek">{d.summary}</p>
      <p className="byline byline-dark">By {d.author?.full_name}<span>{fmtDate(d.published_at)}</span>
        {item.label !== 'Newest' && item.value != null && <span>{num(item.value)} {item.label === 'Most searched' ? 'search clicks' : 'reads'}</span>}</p>
    </article>
  )
}

export default function FrontPage() {
  const { site } = useAuth()
  const data = useAsync(() => api('/api/front-page'), [])
  useDocTitle(`${site.site_name}: ${site.site_tagline}`, site.site_tagline)
  if (data.loading && !data.data) return <div className="container page-pad"><Loading /></div>
  if (data.error) return <div className="container page-pad"><ErrorBox error={data.error} onRetry={data.reload} /></div>
  const f = data.data
  return (
    <div className="front">
      {f.cover && <CoverStory item={f.cover} />}

      <section className="container features" aria-label="Featured stories">
        {f.features.map((item) => <Feature key={item.doc.id} item={item} />)}
      </section>

      {site.site_tagline && <Statement text={site.site_tagline} />}

      <section className="contents" aria-labelledby="contents-title">
        <div className="container">
          <div className="contents-head">
            <h2 id="contents-title">In this issue</h2>
            <p>The newest stories in every section, read in order or jump straight in.</p>
          </div>
          <div className="contents-grid">
            {f.sections.map((s) => (
              <div key={s.category.id} className="contents-section">
                <h3><Link to={`/category/${s.category.slug}`}>{s.category.name}</Link></h3>
                <ul>
                  {s.docs.map((d) => (
                    <li key={d.id}><Link to={`/article/${d.slug}`}><span className="contents-entry">{d.title}</span>
                      <span className="leader" aria-hidden="true" /><span className="contents-min">{shortDate(d.published_at)}</span></Link></li>
                  ))}
                </ul>
              </div>
            ))}
          </div>
        </div>
      </section>

      {f.trending_queries.length > 0 && (
        <section className="trending" aria-labelledby="trending-title">
          <div className="container trending-inner">
            <h2 id="trending-title">Readers are searching for</h2>
            <div className="trending-chips">
              {f.trending_queries.map((t) => <Link key={t.query} to={`/search?q=${encodeURIComponent(t.query)}`}>{t.query}</Link>)}
            </div>
          </div>
        </section>
      )}

      <section className="container latest-strip" aria-labelledby="latest-title">
        <div className="strip-head"><h2 id="latest-title">Just published</h2><Link to="/latest" className="more-link">All latest stories</Link></div>
        <div className="strip-grid">
          {f.latest.map((d) => (
            <article key={d.id} className="strip-item">
              <Link to={`/article/${d.slug}`} tabIndex={-1} aria-hidden="true"><img src={d.cover_image_url} alt="" loading="lazy" /></Link>
              <p className="kicker kicker-dark">{d.category?.name}</p>
              <h3><Link to={`/article/${d.slug}`}>{d.title}</Link></h3>
              <p className="byline byline-dark">{fmtDate(d.published_at)}</p>
            </article>
          ))}
        </div>
      </section>
    </div>
  )
}
