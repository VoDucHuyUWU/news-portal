import { Link } from 'react-router-dom'
import { api } from '../api.js'
import { useAuth } from '../auth.jsx'
import { Avatar, ErrorBox, Loading, num, useAsync, useDocTitle } from '../ui.jsx'

const PRINCIPLES = [
  ['Original reporting, plainly written', 'Every story is written for our readers from the ground up. We explain the idea first and the jargon second.'],
  ['Evidence before opinion', 'We describe what research and established sources actually show, and say clearly where the evidence is thin.'],
  ['Corrections in the open', 'When we get something wrong we fix it and say so. Readers can flag any story or comment with one click.'],
  ['A respectful conversation', 'Comments are moderated against spam and abuse so that discussion stays useful for everyone.'],
]

export default function About() {
  const { site } = useAuth()
  const data = useAsync(() => api('/api/about'), [])
  useDocTitle(`About us | ${site.site_name}`, `About ${site.site_name}: who we are, what we cover and how we work.`)
  const a = data.data
  return (
    <div className="about">
      <header className="page-hero about-hero">
        <div className="container">
          <p className="kicker">About us</p>
          <h1>A magazine for curious people</h1>
          <p className="about-mission">{site.site_name} publishes clear, carefully researched explainers on technology, science, health,
            the environment, money and learning. We write for readers who want to understand how things work, not just what happened.</p>
        </div>
      </header>
      <ErrorBox error={data.error} onRetry={data.reload} />
      {!a ? <div className="container page-pad"><Loading /></div> : (
        <>
          <section className="container numbers" aria-label="In numbers">
            {[['articles', 'stories published'], ['sections', 'sections'], ['readers', 'registered readers'], ['comments', 'reader comments'], ['searches', 'searches answered']].map(([k, l]) => (
              <div key={k}><strong>{num(a.stats[k])}</strong><span>{l}</span></div>
            ))}
          </section>

          <section className="container about-block">
            <h2>What we cover</h2>
            <div className="cover-sections">
              {a.sections.map((s) => (
                <Link key={s.id} to={`/category/${s.slug}`} className="cover-section">
                  <span className="cover-section-name">{s.name}</span>
                  <span className="cover-section-desc">{s.description}</span>
                  <span className="cover-section-count">{s.document_count} stories</span>
                </Link>
              ))}
            </div>
          </section>

          <section className="about-dark">
            <div className="container about-block">
              <h2>How we work</h2>
              <div className="principles">
                {PRINCIPLES.map(([t, d]) => <div key={t} className="principle"><h3>{t}</h3><p>{d}</p></div>)}
              </div>
            </div>
          </section>

          <section className="container about-block">
            <h2>The writers</h2>
            <div className="writers">
              {a.writers.map((w) => (
                <Link key={w.id} to={`/u/${w.username}`} className="writer">
                  <Avatar user={w} size={64} />
                  <span className="writer-name">{w.full_name}</span>
                  <span className="writer-bio">{w.bio}</span>
                  <span className="writer-count">{w.articles} stories</span>
                </Link>
              ))}
            </div>
          </section>

          <section className="container about-block about-contact">
            <div>
              <h2>Contact and corrections</h2>
              <p>Spotted an error, or have an idea for a story? Use the <em>Report a problem</em> link at the end of any article, or write to the editors.
                Members can comment on every story and mention other readers with @username.</p>
              <p><Link className="btn btn-gold-dark" to="/register">Become a member</Link></p>
            </div>
            <aside className="project-note">
              <h3>About this project</h3>
              <p>{site.site_name} is a demonstration News &amp; Digital Magazine Portal built for an academic project (Phase 1). The writers are fictional, the articles
                are original explainers written for the demo, cover art is generated, and reader activity in the seed data is simulated.</p>
            </aside>
          </section>
        </>
      )}
    </div>
  )
}
