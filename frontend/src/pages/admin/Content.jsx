import { useEffect, useState } from 'react'
import { Link, useNavigate, useParams, useSearchParams } from 'react-router-dom'
import { api } from '../../api.js'
import { useAuth } from '../../auth.jsx'
import { ErrorBox, Field, Loading, Modal, Notice, Pagination, StatusBadge, fmtDate, num, useAsync, useDocTitle } from '../../ui.jsx'

export function Documents() {
  const { can } = useAuth()
  const [params, setParams] = useSearchParams()
  const status = params.get('status') || ''
  const page = Number(params.get('page') || 1)
  const [q, setQ] = useState(params.get('q') || '')
  const list = useAsync(() => api('/api/admin/documents', { params: { status, page, q: params.get('q') } }), [params.toString()])
  useDocTitle('Articles | Margin admin')
  const act = async (doc, action) => {
    if (action === 'delete' && !window.confirm(`Delete "${doc.title}" permanently?`)) return
    if (action === 'delete') await api(`/api/admin/documents/${doc.id}`, { method: 'DELETE' })
    else await api(`/api/admin/documents/${doc.id}/${action}`, { method: 'POST' })
    list.reload()
  }
  return (
    <div>
      <div className="admin-head row-between">
        <div><h1>Articles</h1><p className="muted">Create, edit, publish and unpublish content.</p></div>
        {can('documents.manage') && <Link className="btn" to="/admin/documents/new">New article</Link>}
      </div>
      <form className="toolbar" onSubmit={(e) => { e.preventDefault(); setParams({ status, q }) }}>
        <input type="search" placeholder="Search titles" value={q} onChange={(e) => setQ(e.target.value)} />
        <div className="segmented" role="group" aria-label="Status filter">
          {[['', 'All'], ['published', 'Published'], ['draft', 'Drafts']].map(([v, l]) => (
            <button type="button" key={v} className={status === v ? 'is-active' : ''} onClick={() => setParams({ status: v, q })}>{l}</button>
          ))}
        </div>
      </form>
      <ErrorBox error={list.error} />
      {list.loading && !list.data ? <Loading /> : (
        <div className="table-wrap">
          <table className="table">
            <thead><tr><th>Title</th><th>Category</th><th>Author</th><th>Status</th><th>Updated</th><th className="num">Views</th><th>Actions</th></tr></thead>
            <tbody>
              {(list.data?.items || []).map((d) => (
                <tr key={d.id}>
                  <td><strong>{d.title}</strong><div className="muted small">{d.tags.map((t) => t.name).join(', ')}</div></td>
                  <td>{d.category?.name || '—'}</td>
                  <td>{d.author?.full_name || '—'}</td>
                  <td><StatusBadge status={d.status} /></td>
                  <td className="nowrap">{fmtDate(d.updated_at)}</td>
                  <td className="num">{num(d.views_count)}</td>
                  <td className="actions">
                    {can('documents.manage') && <Link to={`/admin/documents/${d.id}`}>Edit</Link>}
                    <Link to={`/article/${d.slug}`} target="_blank">View</Link>
                    {can('documents.publish') && (d.status === 'published'
                      ? <button className="link-btn" onClick={() => act(d, 'unpublish')}>Unpublish</button>
                      : <button className="link-btn" onClick={() => act(d, 'publish')}>Publish</button>)}
                    {can('documents.manage') && <button className="link-btn danger" onClick={() => act(d, 'delete')}>Delete</button>}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
      <Pagination page={page} pages={list.data?.pages} onPage={(p) => setParams({ status, q, page: p })} />
    </div>
  )
}

const EMPTY = { title: '', summary: '', content: '<p></p>', category_id: '', tag_ids: [], new_tags: '', author_id: '', cover_image_url: '', status: 'draft' }

export function DocumentEditor() {
  const { id } = useParams()
  const { can } = useAuth()
  const navigate = useNavigate()
  const [form, setForm] = useState(EMPTY)
  const [loading, setLoading] = useState(!!id)
  const [error, setError] = useState(null)
  const [saved, setSaved] = useState(null)
  const [preview, setPreview] = useState(false)
  const cats = useAsync(() => api('/api/admin/categories'), [])
  const tags = useAsync(() => api('/api/admin/tags'), [])
  const authors = useAsync(() => api('/api/admin/authors'), [])
  useDocTitle(`${id ? 'Edit' : 'New'} article | Margin admin`)
  useEffect(() => {
    if (!id) return
    api(`/api/admin/documents/${id}`).then((d) => {
      setForm({ title: d.title, summary: d.summary, content: d.content, category_id: d.category?.id || '', tag_ids: d.tags.map((t) => t.id),
        new_tags: '', author_id: d.author?.id || '', cover_image_url: d.cover_image_url || '', status: d.status, slug: d.slug })
      setLoading(false)
    }).catch((e) => { setError(e); setLoading(false) })
  }, [id])
  const set = (k) => (e) => setForm({ ...form, [k]: e.target.value })
  const toggleTag = (tid) => setForm({ ...form, tag_ids: form.tag_ids.includes(tid) ? form.tag_ids.filter((x) => x !== tid) : [...form.tag_ids, tid] })
  const upload = async (e) => {
    const file = e.target.files[0]
    if (!file) return
    const fd = new FormData()
    fd.append('file', file)
    try {
      const r = await api('/api/admin/uploads', { method: 'POST', form: fd })
      setForm((f) => ({ ...f, cover_image_url: r.url }))
    } catch (err) { setError(err) }
  }
  const save = async (e) => {
    e.preventDefault()
    setError(null)
    const body = { ...form, category_id: form.category_id ? Number(form.category_id) : null, author_id: form.author_id ? Number(form.author_id) : null,
      new_tags: form.new_tags.split(',').map((t) => t.trim()).filter(Boolean), cover_image_url: form.cover_image_url || null }
    delete body.slug
    try {
      const d = await api(id ? `/api/admin/documents/${id}` : '/api/admin/documents', { method: id ? 'PUT' : 'POST', body })
      setSaved(`Saved at ${new Date().toLocaleTimeString()}.`)
      tags.reload()
      if (!id) navigate(`/admin/documents/${d.id}`, { replace: true })
      else setForm((f) => ({ ...f, new_tags: '', tag_ids: d.tags.map((t) => t.id), slug: d.slug }))
    } catch (err) { setError(err) }
  }
  if (loading) return <Loading />
  return (
    <form onSubmit={save} className="editor">
      <div className="admin-head row-between">
        <div><h1>{id ? 'Edit article' : 'New article'}</h1>{form.slug && <p className="muted">/article/{form.slug}</p>}</div>
        <div className="row-end">
          <Link className="btn btn-ghost" to="/admin/documents">Back</Link>
          {form.slug && <Link className="btn btn-ghost" to={`/article/${form.slug}`} target="_blank">Open page</Link>}
          <button className="btn">Save</button>
        </div>
      </div>
      {saved && <Notice kind="success">{saved}</Notice>}
      <ErrorBox error={error} />
      <div className="editor-grid">
        <div className="stack">
          <Field label="Title"><input required minLength={3} value={form.title} onChange={set('title')} /></Field>
          <Field label="Summary" hint="Shown on listing cards. Leave empty to generate it from the article text."><textarea rows={3} value={form.summary} onChange={set('summary')} /></Field>
          <div className="field">
            <div className="row-between"><span className="field-label">Content (HTML)</span>
              <button type="button" className="link-btn" onClick={() => setPreview(!preview)}>{preview ? 'Edit HTML' : 'Preview'}</button></div>
            {preview ? <div className="prose preview" dangerouslySetInnerHTML={{ __html: form.content }} />
              : <textarea className="code" rows={18} required value={form.content} onChange={set('content')} />}
            <span className="field-hint">Allowed: p, h2, h3, strong, em, ul, ol, li, blockquote, a, img, figure. Scripts are removed on save.</span>
          </div>
        </div>
        <div className="stack editor-side">
          <Field label="Status">
            <select value={form.status} onChange={set('status')} disabled={!can('documents.publish')}>
              <option value="draft">Draft</option><option value="published">Published</option>
            </select>
          </Field>
          <Field label="Category">
            <select value={form.category_id} onChange={set('category_id')}>
              <option value="">Uncategorised</option>
              {(cats.data || []).map((c) => <option key={c.id} value={c.id}>{c.name}</option>)}
            </select>
          </Field>
          <Field label="Author">
            <select value={form.author_id} onChange={set('author_id')}>
              <option value="">Me</option>
              {(authors.data || []).map((a) => <option key={a.id} value={a.id}>{a.full_name || a.username}</option>)}
            </select>
          </Field>
          <div className="field"><span className="field-label">Tags</span>
            <div className="tag-picker">
              {(tags.data || []).map((t) => (
                <label key={t.id} className={form.tag_ids.includes(t.id) ? 'is-on' : ''}>
                  <input type="checkbox" checked={form.tag_ids.includes(t.id)} onChange={() => toggleTag(t.id)} />{t.name}
                </label>
              ))}
            </div>
          </div>
          <Field label="New tags" hint="Comma separated; created on save"><input value={form.new_tags} onChange={set('new_tags')} placeholder="e.g. Batteries, Policy" /></Field>
          <Field label="Cover image URL"><input value={form.cover_image_url} onChange={set('cover_image_url')} /></Field>
          <label className="field"><span className="field-label">…or upload an image</span><input type="file" accept="image/png,image/jpeg,image/gif,image/webp" onChange={upload} /></label>
          {form.cover_image_url && <img className="cover-preview" src={form.cover_image_url} alt="Cover preview" />}
        </div>
      </div>
    </form>
  )
}

function TaxonomyList({ kind, items, onChange }) {
  const [editing, setEditing] = useState(null)
  const [error, setError] = useState(null)
  const isCat = kind === 'categories'
  const save = async (e) => {
    e.preventDefault()
    setError(null)
    const body = isCat ? { name: editing.name, description: editing.description || '', color: editing.color || '#3157D5' } : { name: editing.name }
    try {
      await api(`/api/admin/${kind}${editing.id ? `/${editing.id}` : ''}`, { method: editing.id ? 'PUT' : 'POST', body })
      setEditing(null)
      onChange()
    } catch (err) { setError(err) }
  }
  const remove = async (item) => {
    const warn = isCat ? ' Its articles will become uncategorised.' : ''
    if (!window.confirm(`Delete "${item.name}"?${warn}`)) return
    await api(`/api/admin/${kind}/${item.id}`, { method: 'DELETE' })
    onChange()
  }
  return (
    <section className="panel">
      <div className="row-between"><h2>{isCat ? 'Categories' : 'Tags'}</h2>
        <button className="btn btn-small" onClick={() => setEditing({ name: '', color: '#3157D5' })}>Add {isCat ? 'category' : 'tag'}</button></div>
      <table className="table">
        <thead><tr><th>Name</th><th>Slug</th><th className="num">Articles</th><th></th></tr></thead>
        <tbody>
          {items.map((i) => (
            <tr key={i.id}>
              <td>{isCat && <span className="swatch" style={{ background: i.color }} />}{i.name}</td>
              <td className="muted">{i.slug}</td><td className="num">{i.document_count}</td>
              <td className="actions"><button className="link-btn" onClick={() => setEditing(i)}>Edit</button>
                <button className="link-btn danger" onClick={() => remove(i)}>Delete</button></td>
            </tr>
          ))}
        </tbody>
      </table>
      {editing && (
        <Modal title={`${editing.id ? 'Edit' : 'New'} ${isCat ? 'category' : 'tag'}`} onClose={() => setEditing(null)}>
          <form className="stack" onSubmit={save}>
            <Field label="Name"><input required minLength={2} value={editing.name} onChange={(e) => setEditing({ ...editing, name: e.target.value })} /></Field>
            {isCat && <>
              <Field label="Description"><textarea rows={2} value={editing.description || ''} onChange={(e) => setEditing({ ...editing, description: e.target.value })} /></Field>
              <Field label="Colour"><input type="color" value={editing.color} onChange={(e) => setEditing({ ...editing, color: e.target.value })} /></Field>
            </>}
            <ErrorBox error={error} />
            <button className="btn">Save</button>
          </form>
        </Modal>
      )}
    </section>
  )
}

export function Taxonomy() {
  const cats = useAsync(() => api('/api/admin/categories'), [])
  const tags = useAsync(() => api('/api/admin/tags'), [])
  useDocTitle('Categories & tags | Margin admin')
  return (
    <div>
      <div className="admin-head"><h1>Categories &amp; tags</h1><p className="muted">Organise articles for browsing, filtering and (in Phase 2) search facets.</p></div>
      <div className="two-col">
        <TaxonomyList kind="categories" items={cats.data || []} onChange={cats.reload} />
        <TaxonomyList kind="tags" items={tags.data || []} onChange={tags.reload} />
      </div>
    </div>
  )
}
