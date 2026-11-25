import { useMemo, useState } from 'react'
import { KeyTag } from '../../ui.jsx'

// Entity-relationship diagram drawn from the real schema (GET /api/admin/database/tables):
// one box per table, one arrow per foreign key, pointing from the column that holds the key to the row it references.

// Five columns, grouped by role in the data model. A table that is not listed lands in the first column.
const LAYOUT = [
  ['roles', 'role_permissions', 'permissions', 'settings'],
  ['users', 'audit_logs', 'reports'],
  ['likes', 'ratings', 'comments', 'comment_mentions', 'document_views', 'search_click_logs'],
  ['documents', 'seo_metadata'],
  ['categories', 'document_tags', 'tags'],
]
const GROUPS = ['Roles & permissions', 'People', 'Activity (user + article)', 'Articles', 'Classification']
const LOOP_SIDE = ['left', 'left', 'right', 'right', 'right'] // where arrows inside one column are drawn

const BOX_W = 196
const GAP_X = 52
const PAD_X = 44
const TOP = 44
const HEAD_H = 28
const ROW_H = 20
const GAP_Y = 18
// The middle column starts lower, leaving a free lane for the documents.author_id -> users.id arrow.
const MIDDLE_DROP = { keys: 86, all: 196 }

function place(tables, allColumns) {
  const byName = Object.fromEntries(tables.map((t) => [t.name, t]))
  const columns = LAYOUT.map((names) => names.filter((n) => byName[n]))
  const placed = new Set(columns.flat())
  columns[0].push(...tables.map((t) => t.name).filter((n) => !placed.has(n)))
  const boxes = {}
  let height = 0
  columns.forEach((names, ci) => {
    let y = TOP + (ci === 2 ? (allColumns ? MIDDLE_DROP.all : MIDDLE_DROP.keys) : 0)
    names.forEach((name) => {
      const t = byName[name]
      const rows = t.columns.filter((c) => allColumns || c.primary_key || c.foreign_key)
      const h = HEAD_H + rows.length * ROW_H + 8
      boxes[name] = { name, table: t, col: ci, x: PAD_X + ci * (BOX_W + GAP_X), y, h, rows }
      y += h + GAP_Y
    })
    height = Math.max(height, y)
  })
  return { boxes, height: height + 6, width: PAD_X * 2 + 5 * BOX_W + 4 * GAP_X }
}

function rowY(box, column) {
  const i = box.rows.findIndex((r) => r.name === column)
  return box.y + HEAD_H + (i < 0 ? 0 : i) * ROW_H + ROW_H / 2 + 2
}

function relationKind(table, fk) {
  const [target] = fk.references.split('.')
  if (target === table.name) return 'self-reference'
  if (table.primary_key.length === 1 && table.primary_key[0] === fk.column) return 'one-to-one'
  return 'many-to-one'
}

export function relations(tables) {
  return tables.flatMap((t) => t.foreign_keys.map((fk) => {
    const [toTable, toColumn] = fk.references.split('.')
    const column = t.columns.find((c) => c.name === fk.column)
    return { id: `${t.name}.${fk.column}`, from: t.name, column: fk.column, to: toTable, toColumn,
      kind: relationKind(t, fk), onDelete: column?.on_delete || 'NO ACTION', nullable: !!column?.nullable }
  }))
}

function edgePath(from, to, rel) {
  const y1 = rowY(from, rel.column)
  const y2 = rowY(to, rel.toColumn)
  if (from.col === to.col) {
    const left = LOOP_SIDE[from.col] === 'left'
    const x = left ? from.x : from.x + BOX_W
    const reach = (rel.from === rel.to ? 26 : 40) * (left ? -1 : 1)
    return `M ${x} ${y1} C ${x + reach} ${y1}, ${x + reach} ${y2}, ${x + (left ? -7 : 7)} ${y2}`
  }
  const goingLeft = from.col > to.col
  const x1 = goingLeft ? from.x : from.x + BOX_W
  const x2 = goingLeft ? to.x + BOX_W + 7 : to.x - 7
  const bend = Math.min(GAP_X * 0.7, Math.abs(x2 - x1) / 2) * (goingLeft ? -1 : 1)
  return `M ${x1} ${y1} C ${x1 + bend} ${y1}, ${x2 - bend} ${y2}, ${x2} ${y2}`
}

export function SchemaDiagram({ tables, onOpen }) {
  const [allColumns, setAllColumns] = useState(false)
  const [focus, setFocus] = useState(null)
  const { boxes, height, width } = useMemo(() => place(tables, allColumns), [tables, allColumns])
  const rels = useMemo(() => relations(tables), [tables])
  const related = (name) => focus === name || rels.some((r) => (r.from === focus && r.to === name) || (r.to === focus && r.from === name))
  const active = (r) => focus && (r.from === focus || r.to === focus)
  const focusRels = focus ? rels.filter(active) : []
  return (
    <div>
      <div className="toolbar">
        <div className="segmented" role="group" aria-label="Columns shown in each table">
          <button type="button" className={allColumns ? '' : 'is-active'} onClick={() => setAllColumns(false)}>Keys only</button>
          <button type="button" className={allColumns ? 'is-active' : ''} onClick={() => setAllColumns(true)}>All columns</button>
        </div>
        <span className="muted small" aria-live="polite">
          {focus ? `${focus}: ${focusRels.length} relationship${focusRels.length === 1 ? '' : 's'}` : `${tables.length} tables, ${rels.length} foreign keys. Point at a table to trace its relationships; click it to open its rows.`}
        </span>
      </div>
      <div className="erd-wrap">
        <svg className="erd" viewBox={`0 0 ${width} ${height}`} role="img"
          aria-label={`Entity-relationship diagram: ${tables.length} tables linked by ${rels.length} foreign keys`}>
          <defs>
            <marker id="erd-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 z" className="erd-head" /></marker>
            <marker id="erd-arrow-on" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse"><path d="M0 0 L10 5 L0 10 z" className="erd-head is-on" /></marker>
          </defs>
          {GROUPS.map((g, i) => <text key={g} className="erd-group" x={PAD_X + i * (BOX_W + GAP_X)} y={22}>{g}</text>)}
          {rels.filter((r) => boxes[r.from] && boxes[r.to]).map((r) => (
            <path key={r.id} d={edgePath(boxes[r.from], boxes[r.to], r)} markerEnd={`url(#${active(r) ? 'erd-arrow-on' : 'erd-arrow'})`}
              className={`erd-edge${active(r) ? ' is-on' : ''}${focus && !active(r) ? ' is-dim' : ''}${r.nullable ? ' is-optional' : ''}`} />
          ))}
          {Object.values(boxes).map((b) => (
            <g key={b.name} className={`erd-table${focus && !related(b.name) ? ' is-dim' : ''}${focus === b.name ? ' is-focus' : ''}`}
              transform={`translate(${b.x} ${b.y})`} onMouseEnter={() => setFocus(b.name)} onMouseLeave={() => setFocus(null)}
              onFocus={() => setFocus(b.name)} onBlur={() => setFocus(null)} onClick={() => onOpen(b.name)}
              onKeyDown={(e) => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); onOpen(b.name) } }}
              tabIndex={0} role="button" aria-label={`Open table ${b.name}`}>
              <rect className="erd-box" width={BOX_W} height={b.h} rx="7" />
              <path className="erd-head-bg" d={`M0 7 a7 7 0 0 1 7 -7 h${BOX_W - 14} a7 7 0 0 1 7 7 v${HEAD_H - 7} h-${BOX_W} z`} />
              <text className="erd-name" x="10" y="19">{b.name}</text>
              <text className="erd-count" x={BOX_W - 10} y="19" textAnchor="end">{b.table.rows}{b.name.length > 14 ? '' : ' rows'}</text>
              {b.rows.map((c, i) => (
                <g key={c.name} transform={`translate(0 ${HEAD_H + i * ROW_H + 2})`}>
                  <text className={`erd-col${c.primary_key ? ' is-pk' : ''}`} x="10" y="14">{c.name}</text>
                  <text className={`erd-key ${c.primary_key ? 'is-pk' : c.foreign_key ? 'is-fk' : ''}`} x={BOX_W - 10} y="14" textAnchor="end">
                    {c.primary_key && c.foreign_key ? 'PK FK' : c.primary_key ? 'PK' : c.foreign_key ? 'FK' : (c.name.length + String(c.type).length <= 27 ? String(c.type).toLowerCase() : '')}
                  </text>
                </g>
              ))}
            </g>
          ))}
        </svg>
      </div>
      <p className="db-legend">
        <span>The number beside a table name is its row count.</span>
        <span>An arrow runs from the foreign key column to the row it references (the “one” side).</span>
        <span>Solid line: the key is required. Dashed line: the key may be NULL.</span>
        <span><KeyTag kind="PK" /> primary key</span><span><KeyTag kind="FK" /> foreign key</span>
      </p>
    </div>
  )
}
