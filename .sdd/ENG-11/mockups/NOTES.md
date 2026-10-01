# Quote PDF redesign — mockup notes

- `quote.html` — the mockup source (4 pages: quote, site photos, before we start, terms,
  plus a 5th unnumbered page showing the uncategorised-photos variant)
- `quote-mockup.pdf` — rendered preview, real font embedded
- `fonts/` — Archivo 400/600/700 TrueType

Sample data is invented; the layout is what's up for review.

## What changed from the current quote

| | Now | Proposed |
|---|---|---|
| Company details | Header, plus a bordered block repeating name/address/email/phone at the foot | Header only |
| Insurance | Bold, boxed, same weight as the company block | One 7pt grey line in the page footer |
| Scope | None — just cost line items | Scope of work / What's included / Not included |
| Line items | `description` + amount, padded to 8 blank rows | One description per row, no filler rows |
| Total | A table row like any other | Solid maple-red band, the one loud element |
| Type | Source Sans Pro (not actually loading — see below) | Archivo |
| Pages | Quote, photos, Further Details, Terms | Same four, restyled |
| Photos | One flat grid | Optionally grouped into tasks, each with an optional description |
| Signature | Signature + date lines on page 1 | Removed for now |

## Design tokens

Pulled from the existing logo — sage conifers, maple-red leaf.

```
ink        #22271F   bark black — headings, totals
body       #3A3F35   running text
muted      #6E7365   labels, secondary, footer
moss       #7C8B6A   conifer sage — bullets, accent rules
rule       #DDE0D6   hairlines
rule-firm  #BFC4B4   section rules
wash       #EFF1EA   panel tint
leaf       #8A1C1C   maple red — used once, at full strength
```

## wkhtmltopdf constraints found while building this

The renderer is wkhtmltopdf 0.12.6 (Qt WebKit). Verified by rendering, not assumed:

1. **No CSS custom properties.** `var(--x)` silently resolves to nothing — the red
   total band, the panel tint and the bullets all disappeared on the first pass. Use
   SCSS variables in `pdf_styles.scss`, which compile away before the engine sees them.
2. **No flexbox/grid.** Already true of the current templates (hence the `-webkit-box`
   hacks). Everything here is tables and block layout.
3. **Positioned `::before` pseudo-elements are unreliable.** The list markers are native
   `list-style` discs/squares instead; the `li` carries the marker colour and an inner
   `<span>` carries the text colour back.
4. **Fonts are the open question.** On this Mac, the wkhtmltopdf binary reaches *no*
   font at all beyond the PDF base-14 — `@font-face` fails for both local-file and
   remote `.ttf`, and even installed system fonts (Inter, Avenir Next) fall back to
   Helvetica. So the current PDFs are almost certainly rendering in Helvetica, not the
   Source Sans Pro the stylesheet asks for.

   `quote-mockup.pdf` was rendered through headless Chrome so the intended font is
   visible. **Before committing to Archivo, confirm on the production box** that either
   path works there:
   - install the TTFs system-wide (`/usr/share/fonts/truetype/archivo` + `fc-cache -fv`)
     and reference the family by name — most reliable on Linux; or
   - `@font-face` with a `file://` path plus `--enable-local-file-access`.

   If neither works on the server, the fallback is a base-14 face and the layout still
   holds — but the "modern font" goal wouldn't be met, so this is worth checking early.
5. **Page fit.** Archivo sets wider than Helvetica, so the vertical rhythm is tuned
   fairly tight. See the scaling measurements below.

## Open questions for implementation

- Scope / included / excluded are **new fields** — nothing in `estimates` or `trees`
  holds them today. They'd need columns plus UI in the estimate editor.
- Photo tasks are new too. `tree_images` has no grouping or per-group description, so
  grouping needs a task concept (or reuse of `trees`, which already has `description`)
  plus an ordering. The template must handle both states: grouped, and a plain grid when
  nothing is categorised.
- "Valid through" doesn't exist — there's no quote expiry field today. `Issued` can come
  from `quote_sent_date` or `Date.today`.
- The header carries no quote number or arborist, so nothing new is needed there. The
  page footer identifies the document by service address instead.
- The same template serves quote / invoice / receipt (`_quote.html.erb` switches on
  `estimate.invoice`). The redesign needs the invoice and receipt variants worked through
  too — this mockup only covers the quote.


## How it scales (measured, not estimated)

Rendered through headless Chrome with Archivo on Letter, varying only the number of
cost rows. "With scope" means a 3-line scope paragraph, 6 included lines and 4 exclusions.

| Cost rows | With scope sections | Without scope sections |
|---|---|---|
| 2  | 1 page | 1 page |
| 8  | 1 page | 1 page |
| 9  | 1 page | — |
| 10 | 2 pages | — |
| 14 | 2 pages | — |
| 16 | — | 1 page |
| 20 | — | 1 page |

So: **the break point is 10 cost rows with the scope sections present, and 20+ without**
(20 was the largest tried and still fit — the real ceiling is higher).

**Fewer items degrades cleanly.** With the filler rows gone, the page simply ends earlier
— no stretched boxes, no empty grid. A 2-item quote leaves roughly the bottom fifth blank.

**Dropping the scope sections degrades cleanly too.** The masthead, parties panel, pricing
and total stay coherent; the page just ends higher, leaving roughly the bottom 40% white on
an 8-item quote. Nothing needs re-balancing, so making the section optional is safe. If a
quote routinely has no scope *and* few items, the page will look sparse — that's the only
cosmetic cost.

### Two structural weaknesses this exposed

Both come from pages being hand-built `<div class="page">` blocks with markup repeated per
page, and both have the same fix.

1. **The footer floats up with the content** instead of pinning to the bottom of the sheet.
   On a 2-item quote the "Insured with…" line lands mid-page.
2. **Overflow pages inherit nothing.** At 10+ items the pricing table spills onto a second
   sheet that has no masthead and no logo, and the hardcoded "Page 1 of 4" is simply wrong.
   (The red total band does stay intact — `page-break-inside: avoid` holds.)

The fix in wkhtmltopdf is `--header-html` / `--footer-html`, which repeat on every sheet
and substitute real page numbers (`[page]`, `[topage]`). Worth adopting regardless of
whether the renderer changes, because it also removes the four duplicated footer blocks
in the template. On a Chrome-based renderer the equivalent is `@page` margin boxes.

## Renderer options

wkhtmltopdf 0.12.6 is **archived — no longer maintained** — and bundles a fork of Qt
WebKit roughly a decade older than current browsers. That is the root cause of every
constraint listed above. Options, roughly in order of fit:

| Option | What it buys | What it costs |
|---|---|---|
| **Grover** (Ruby gem over Puppeteer/Chrome) | CSS variables, flexbox/grid, woff2 web fonts, modern selectors, `@page` margin boxes. Keeps the existing ERB templates. | Node + Chromium on the server (~300 MB), more RAM per render, cold-start latency unless the browser is kept warm |
| **WeasyPrint** (Python) | Strongest CSS Paged Media support — running headers, page counters, orphan/widow control. Much lighter than Chrome. | A Python dependency in a Ruby shop; no JS execution |
| **DocRaptor** (hosted PrinceXML) | Best-in-class print fidelity, zero server infrastructure | Paid per document; data leaves your infrastructure |
| **PrinceXML** (self-hosted) | Same fidelity, stays in-house | Paid commercial licence |
| **Prawn** (pure Ruby) | No browser at all | You draw the document in Ruby — the whole HTML/CSS workflow is discarded |

**Recommendation: stay on wkhtmltopdf and install the font on the server.** Grover was the
initial recommendation, but the production box rules it out — see the decision below.

Grover remains the better technical answer on a larger instance: it would remove the `var()`,
flexbox and pseudo-element workarounds and make the typography a non-issue. It is a
size-up-the-box decision, not a rendering decision.

## Render time: wkhtmltopdf vs Chrome

Measured locally (macOS, warm cache) on this 5-page mockup, same input served over
localhost, 5 runs each. Chrome runs waited for a complete PDF (`%%EOF` present), so the
numbers are not cut short.

| | Run times | Steady state |
|---|---|---|
| wkhtmltopdf 0.12.6 | 2.89 / 1.20 / 0.84 / 0.90 / 0.99 s | **~0.85–1.0 s** |
| Headless Chrome, cold start every run | 1.14 / 0.79 / 0.88 / 0.75 / 0.82 s | **~0.75–0.9 s** |
| Bare `node` process startup | 67 / 51 / 51 / 50 / 48 ms | **~50 ms** |

Chrome launching cold was, if anything, marginally *faster* than wkhtmltopdf here.

**What this does and doesn't tell you.** Grover is not wkhtmltopdf-vs-Chrome — it spawns a
Node process per render which drives Chromium over Puppeteer. So its cost is roughly the
Chrome figure plus ~50 ms of Node startup plus the Puppeteer launch handshake, which was
not measured (no Puppeteer installed here). Expect Grover in the same ~1 s ballpark rather
than a step change in either direction, but **this needs measuring on the production box**
before it's a commitment — different hardware, cold page cache, and less RAM headroom.

**Where the real time goes.** Both renderers fetch the logo, and the photos page pulls every
tree image from S3. On a quote with a dozen photos that network time dominates and is
identical for both, which compresses any renderer difference further.

**Why it matters here.** `pdf_quote` runs synchronously inside the request — `send_file` in
`quotes_controller` and `invoices_controller`, and `QuoteMailer.new.quote_email(...)` is
called directly rather than via `deliver_later`. So this latency is user-facing on every
path. Moving generation into delayed_job would take the renderer question off the critical
path entirely and is worth considering independently of Grover.

**The real cost of Grover is memory, not milliseconds.** Chromium's resident footprint is
substantially larger than wkhtmltopdf's, and concurrent renders multiply it. On a small
production box that's the constraint to check, not render time.

## Memory cost of a Chrome-based renderer

Measured locally (macOS, desktop Chrome build, this 5-page mockup), peak resident set
sampled every 30 ms while a render was in flight:

| Renderer | Processes | Peak RSS |
|---|---|---|
| wkhtmltopdf | 1 | **48–49 MB** |
| Headless Chrome | 10–14 | largest single process 226 MB; others 78–222 MB; **naive sum ~1.35 GB** |

**Do not take 1.35 GB at face value.** Summing RSS across a Chrome process tree
double-counts heavily — every child process's RSS includes the same shared Chrome
framework mappings. The true incremental cost is well below the sum. It is also the full
desktop Chrome build; Puppeteer installs `chrome-headless-shell`, a stripped binary that
starts fewer processes and carries less baggage.

**Ballpark for a Linux production box: roughly 300–600 MB resident per in-flight render**,
against ~50 MB today. Call it a 6–12× increase. That range is reasoned from the numbers
above rather than measured on Linux, so treat it as a planning figure, not a guarantee.

### The number that actually matters is concurrency

Deployment is Passenger (`capistrano-passenger`), so the worst case is
`passenger_max_pool_size × per-render footprint`. With a pool of 6 and every worker
rendering at once, that is potentially 2–3 GB of Chromium on top of the Rails processes —
on a small VPS that is an OOM, not a slowdown.

Two things de-risk it, and the first is worth doing anyway:

1. **Move PDF generation into delayed_job.** With a single worker, concurrency is capped at
   one render at a time and the ceiling becomes ~400 MB regardless of web traffic. It also
   takes the latency off the request path — `pdf_quote` is currently synchronous in
   `quotes_controller`, `invoices_controller` and `QuoteMailer`.
2. **Keep one warm browser** rather than launching per render, if Grover is configured for
   it — trades a permanently resident ~300 MB for no launch cost per PDF. Better on a box
   with RAM to spare, worse on a tight one.

### Check before committing

On the production box:

```
free -m                              # total and available RAM
passenger-status                     # current pool size and process count
```

If available RAM is comfortably above ~1 GB with the app running, Grover behind a
delayed_job worker is safe. If it is tight, either size up the box or stay on wkhtmltopdf
and prove the font there instead.

## Decision: production box is a t3.small — Grover is out

Reported from the live box:

```
Mem:   total 1905   used 1326   free 151   buff/cache 633   available 578
Swap:  total 2047   used 171
```

| | Per render | Share of the 578 MB available |
|---|---|---|
| wkhtmltopdf (measured) | ~49 MB | **8%** |
| Chrome / Grover (ballpark) | 300–600 MB | **51–103%** |

One Chrome render would consume between half and all of the available memory, on a box
that is **already 171 MB into swap** before anything is added. That is not a tight fit, it
is an OOM risk — and a t3.small is burstable 2 vCPU, so Chromium's CPU-heavy startup would
also eat CPU credits on every quote.

**So: keep wkhtmltopdf.** The design was built and verified against it throughout, so
nothing in the mockup changes. The only outstanding item is the font.

### Installing Archivo on the server

The macOS wkhtmltopdf binary reaching no fonts at all is a quirk of that build. On Linux,
wkhtmltopdf goes through fontconfig and installed families work normally — this is the
well-trodden path, so the odds are good.

Four weights are needed: 400, 500, 600, 700. The mockup uses all four (500 appears on the
subtotal/HST figures). `fonts/archivo-*.ttf` in this folder holds them.

**Step 1 — get the files onto the box.** They are currently only on the dev machine:
`.sdd/` is untracked, so nothing carries them. For a quick test, from the Mac:

```
scp .sdd/ENG-11/mockups/fonts/archivo-*.ttf ubuntu@98.88.77.57:/tmp/
```

For the durable version, commit them into the repo (e.g. `app/assets/fonts/archivo/`) so
every deploy has them, and install from the release directory instead of `/tmp`.

**Step 2 — install and rebuild the cache.**

```
sudo mkdir -p /usr/local/share/fonts/archivo
sudo cp /tmp/archivo-*.ttf /usr/local/share/fonts/archivo/
sudo chmod 644 /usr/local/share/fonts/archivo/*.ttf
sudo fc-cache -fv
```

**Step 3 — verify fontconfig sees it.**

```
fc-list | grep -i archivo      # should list all four weights
fc-match Archivo               # must NOT report DejaVu Sans
```

Also build the cache as the user Passenger runs as, since fontconfig keeps a per-user cache
and will otherwise rescan on first render:

```
sudo -u <app_user> fc-cache -f
```

**Step 4 — prove it end to end before building anything.** This is the point of doing the
install early. Change one line in `pdf_styles.scss:7`:

```scss
.page {
  font-family: 'Archivo', 'Helvetica Neue', Helvetica, Arial, sans-serif;
}
```

Deploy, generate a real quote, and check which font actually got embedded:

```
strings tmp/Quote_<id>.pdf | grep BaseFont | sort -u
```

`Archivo` means the font risk is closed and the redesign is safe to build against
wkhtmltopdf. `Helvetica` means fall back to the ladder below.

No `@font-face` is needed on the server — naming the installed family is enough, and the
`@font-face` block in the mockup exists only so the file renders standalone in a browser.

**Persistence.** `/usr/local/share/fonts` sits outside Capistrano's release directory, so
the install survives deploys. But it is manual server state that the repo knows nothing
about — a replacement instance or an AMI rebuild loses it silently, and the next quote
quietly renders in Helvetica. It belongs in provisioning (user-data, Ansible, or a
Capistrano task) before this is considered done.

**Undo**, if needed: `sudo rm -rf /usr/local/share/fonts/archivo && sudo fc-cache -fv`

### Still worth doing regardless

Move PDF generation into delayed_job. `pdf_quote` is synchronous in `quotes_controller`,
`invoices_controller` and `QuoteMailer`, so every quote download and every quote email
blocks a Passenger worker for ~1 s today. On a 2 GB box with 578 MB spare, freeing
Passenger workers faster matters on its own terms.

## Local rendering: why fonts fail on macOS, and what to do

**Root cause, diagnosed.** The `wkhtmltopdf-binary` gem ships `wkhtmltopdf_macos_cocoa`,
an **x86_64** Mach-O binary. On Apple Silicon it runs under Rosetta and its Qt font
database is completely non-functional — it resolves *every* family to Helvetica, including
Georgia and Courier New, which are unquestionably installed. This is not an Archivo problem
and no amount of font installation fixes it.

There is no native fix: Homebrew has dropped both the `wkhtmltopdf` formula and cask (the
upstream project is archived), and upstream never shipped an arm64 macOS build.

### The differences are NOT minor — and they bias the wrong way

Helvetica is **narrower** than Archivo at the same point size. Concretely, during this
work the identical markup produced:

- **4 pages** through wkhtmltopdf falling back to Helvetica
- **5 pages** through Chrome with real Archivo

Page 1 needed roughly 120 px shaved off before Archivo fit. That is an ~8–10% difference in
vertical extent, which is more than enough to hide or invent a page break.

Critically the error runs in the dangerous direction: **local macOS output is more forgiving
than production**, so a layout that looks fine on the dev machine can overflow on the
server. Everything else — colour, rules, backgrounds, table structure, the total band —
renders identically, so it is pagination and only pagination that is at risk.

### Fix: render through the production environment locally

`docker/` in this folder mirrors the server — Ubuntu amd64, the same wkhtmltopdf build the
gem selects there, Archivo installed the same way:

```
./docker/render.sh                    # quote.html -> quote-linux.pdf
./docker/render.sh foo.html out.pdf
```

`render.sh` extracts the production Linux binary from the already-installed gem, so there
is nothing extra to download and no second wkhtmltopdf version to keep in sync. It prints
the embedded `BaseFont` list at the end, which is the same check being run on the server.

Set `UBUNTU_BUILD` if the box is not 22.04 (`lsb_release -rs` there to confirm); the gem
carries 16.04, 18.04, 20.04, 21.10 and 22.04 amd64 builds.

`--platform linux/amd64` is deliberate — t3.small is x86_64, and emulation is slower but
gives exact font metrics, which is the whole point.

**Not yet verified end to end**: Docker Desktop was not running when this was written, so
the image has not been built. The script passes a syntax check and the gem contains the
expected binary, but expect to shake out one or two issues on first run.

### Practical workflow

Design iteration in Chrome is fine and fast — it renders Archivo correctly, and the
`@font-face` block in `quote.html` exists for exactly that. Use the Docker path before
committing a layout change, to confirm pagination. That is the only thing Chrome cannot
tell you.

## Implementation status (applied to the real templates)

Applied and verified by rendering real estimates out of the dev database through
the actual `GenerateQuote` path — quote (#13588, 4 costs, 3 photos), invoice
(#13566) and receipt (#13592). All three render without error.

**Changed**

| File | What |
|---|---|
| `app/assets/stylesheets/pdf_styles.scss` | Rewritten on the new tokens as SCSS variables. Repair-tracker rules preserved verbatim — `equipment_requests/pdf` shares this stylesheet. |
| `quotes/pdf/main.html.erb` | Computes `document_title` once and passes it down; all three document types switch here. |
| `quotes/pdf/_header.html.erb` | Masthead — the only copy of company contact details now. |
| `quotes/pdf/_cont_header.html.erb` | **New.** Lighter header for continuation pages. |
| `quotes/pdf/_footer.html.erb` | **New.** Insurance/HST as one quiet line. |
| `quotes/pdf/_quote.html.erb` | Title + meta, parties panel, scope placeholders, pricing. Signature block and the old repeated liability block removed. |
| `quotes/pdf/_cost_summary.html.erb` | One row per cost, no filler rows, red total band, optional "Paid by". |
| `quotes/pdf/_images.html.erb` | Restyled 3-up grid, 6 per page. |
| `quotes/pdf/_details.html.erb`, `_terms.html.erb` | Restyled as numbered lists. **Copy preserved verbatim.** |

**Decisions worth revisiting**

- **Empty scope sections are omitted, not shown blank.** `scope_of_work`, `inclusions`
  and `exclusions` are hardcoded empty in `_quote.html.erb` with a marked block. They
  render nothing rather than a bare heading, because these go to customers and an empty
  "Scope of work" heading reads as broken. Swap the three assignments for real accessors
  to wire them up; markup and styling underneath are finished.
- **Terms numbering preserved.** The original ran 1, 2, 4, 5, 6, 7, 8, 9 — there has never
  been a clause 3. `value` attributes keep those exact numbers rather than silently
  renumbering legal copy. Remove them to run 1-8.
- **`customer_detail` is now nil-guarded** with a fallback to `estimate.customer`. The
  previous template dereferenced a `has_one` unguarded.
- **Photo aspect ratio**: `max-height` alongside `width: 100%` made Qt WebKit scale the
  axes independently and visibly squashed the photos. Confirmed by rendering — the cap is
  gone and `height: auto` does the work.

**Not done, deliberately**

- `quotes/pdf/receipt.html.erb` is **dead code** — nothing renders it (both `GenerateQuote`
  and `GenerateReceipt` go through `main`), and it holds hardcoded org details (a Brampton
  address, a named arborist, a GST number) that do not match the organizations table. Left
  untouched; it should probably be deleted.
- `--header-html` / `--footer-html` for real repeating headers and page numbers. Still the
  right fix for the float-up footer and header-less overflow pages, but it changes the
  `GenerateQuote`/`GenerateReceipt` plumbing rather than the templates.
- Photo task grouping — needs the data model first.

**Note:** `CLAUDE.md` says Rails 6 / Vue 2; the lockfile is **Rails 8.0.5**. Worth
correcting, and it matters here because `compact_blank` and `where.missing` (both used
above) need 6.1+.

## Previewing in Chrome against the local site

There is already a route that renders the document as HTML instead of a PDF:

```
http://localhost:<port>/estimates/<estimate_id>/quotes/pdf
```

(`quotes#pdf` — `render 'quotes/pdf/main', layout: 'pdf'`.) Verified working: returns 200,
carries the new markup, and the compiled `pdf_styles.css` is linked and served, with the
SCSS variables resolved to literal hex.

**To see the real font**, install Archivo for macOS apps — the same family-name resolution
production uses, so no app change is needed:

```
cp .sdd/ENG-11/mockups/fonts/archivo-*.ttf ~/Library/Fonts/
```

Reload and Chrome picks up `font-family: 'Archivo'`. Without this it silently falls back to
Helvetica Neue, which is narrower and will mislead you about fit.

**What this preview does and does not tell you.** It is accurate for typography, colour,
spacing and structure. It is *not* authoritative for pagination: the browser flows one
continuous column, and Chrome's line breaking differs from Qt WebKit's regardless. Use
Cmd+P (Letter, margins None, **Background graphics on** — otherwise the red total band and
tinted panels disappear) for an approximation, and `docker/render.sh` when page fit
actually matters.

### Do not try to fix the preview width in CSS

`.page` deliberately has no width. Constraining it (`max-width: 8.5in; margin: 0 auto`)
looks like a free win for browser preview but **changes the PDF** — wkhtmltopdf does not
map CSS inches to its page width the way a browser does, so the content shrinks and leaves
a dead right margin. Tried, verified by pixel-diffing the rendered pages, reverted. Narrow
the browser window or use print preview instead.

## Spacing: the `.spacious` variant

With the scope sections absent — the common case while they are unwired, and an ongoing
one since they are optional — the masthead, parties panel and pricing table stacked up
tight against each other. With the sections present, those same gaps are fine, because the
sections themselves supply the separation.

Rather than pick one compromise, `_quote.html.erb` computes:

```erb
<% scope_present = scope_of_work.present? || inclusions.any? || exclusions.any? %>
```

and adds `.spacious` to the title block and parties panel when it is false:

| | Default (scope present) | `.spacious` (no scope) |
|---|---|---|
| Title → parties panel | 8px | **22px** |
| Parties panel → pricing | 14px | **28px** |

Unconditional spacing was rejected: the extra ~35px would have put a dense quote (full
scope sections plus 8 cost rows) within a few pixels of overflowing page 1.

Both paths verified by rendering real estimates:

- **No scope** (the shipped state) — quote, invoice and receipt all breathe, 4 / 1 / 1 pages.
- **With scope** — temporarily injected a full scope block (6 inclusions, 4 exclusions, a
  3-line scope paragraph), rendered, confirmed the tight spacing applies and page 1 still
  holds with room to spare. Injection reverted afterwards.

## Total band alignment

Three fixes, all in `.total-band`:

| | Before | After |
|---|---|---|
| Label size | 11pt | **15.5pt** — matches the amount |
| Label/amount alignment | `vertical-align: top` inherited, different sizes → different baselines | **`vertical-align: baseline`**, same size → one baseline |
| Horizontal inset | `padding: 9px 15px` — inset 15px while the cost rows sat flush | **`padding: 10px 0`** — "Total" lines up with the item descriptions, the amount with the amounts |

Label stays at weight 600 against the amount's 700, so the number remains the emphasis.

### Shared inset across the pricing block

Zeroing the band's padding aligned it with the rows but pressed the text against the band's
left edge. Fixed by insetting the *whole block* by one shared token instead:

```scss
$price-inset: 14px;   // matches the parties panel, so the two boxed elements agree
```

applied to `.pricing .item` (padding-left), `.pricing .amount` (padding-right),
`.total-band td` and `.paid-note`. Descriptions line up down the left and amounts down the
right, through the cost rows, the subtotal/HST rows and the band.

**Watch the shorthand.** `.pricing td` and `.pricing tr.sum td` previously set
`padding: 6px 0` / `padding: 5px 0`, and `.pricing tr.sum td` is *more* specific than
`.pricing .item`, so a shorthand there silently resets the horizontal inset on the
subtotal/HST rows. Both now set `padding-top`/`padding-bottom` only.

The hairline rules still span the full content width while the text sits inset — that is
deliberate, and it is what ties the rows to the band.

**Open question:** the `Pricing` section heading stays at the page margin while the rows are
inset 14px, so there is a small step between them. That is the conventional treatment —
heading at the margin, tabular content indented — and it keeps `Pricing` aligned with the
`Scope of work` / `What's included` headings above it. Easy to inset the heading too if the
step reads wrong once the scope sections are wired up.

**Do not set `line-height` on `.total-band td`.** Tried `line-height: 1` on the theory that
the inherited 1.4 was adding dead space below the baseline. It does the opposite: the 1.4
distributes half-leading evenly above and below the glyphs, which is what centres them.
Forcing 1 squeezes the line box and the taller ascent pushes the text up against the band's
top edge. Verified by rendering and reverted; there is a comment in the stylesheet.

Page counts unchanged: quote 4, invoice 1, receipt 1.

## Scope / Included / Excluded — wired up

Stored on a separate `quote_scopes` table rather than on estimates, so the core model
doesn't gain three optional columns most estimates never use.

| Layer | File |
|---|---|
| Migration | `db/migrate/20260930000000_create_quote_scopes.rb` |
| Model | `app/models/quote_scope.rb` |
| Serializer | `app/serializers/quote_scope_serializer.rb` (+ `has_one` on EstimateSerializer) |
| Controller | `app/controllers/quote_scopes_controller.rb` — single upsert action |
| Route | `POST /estimates/:estimate_id/quote_scope/update` |
| Display | `components/quote/views/collapsed.vue` |
| Editor | `components/quote/actions/editScope.vue` + `components/quote/forms/scopeList.vue` |
| PDF | `_quote.html.erb` now reads `estimate.quote_scope` |

**Column is `scope_of_work`, not `scope`** — `scope` is ActiveRecord's own class method and
not worth the ambiguity.

**Lists are normalised in the model** (`before_save`): blank and whitespace-only rows are
dropped and entries are stripped, because the editor lets you add a bullet and leave it
empty. Readers coerce nil JSON to `[]`, so callers never branch on nil.

**One record per estimate**, enforced by a unique index rather than only by `has_one`.

**The Quote box is now always rendered** on the estimate page (it was gated on
`quote_sent_date`), because the scope is part of the quote you send — it has to be editable
before the first send. `Resend` now reads `Send` until a quote has gone out.

### Verified

- `spec/models/quote_scope_spec.rb` + `spec/controllers/quote_scopes_controller_spec.rb`
  — 14 examples. Full `spec/models` + `spec/controllers`: **212 examples, 0 failures**.
- Serializer output checked against a real estimate; an estimate with no record serializes
  `quote_scope: nil` rather than erroring.
- PDF rendered from live data with a real record — sections appear, and the `.spacious`
  spacing correctly switches off once scope is present.
- `./bin/webpack` compiles clean.

### Notes for later

- `ApplicationController` has a blanket `rescue_from StandardError` that turns
  `RecordNotFound` into a **500**, not a 404. Cross-org access *is* blocked (verified: no
  record written), but the status code is misleading. Pre-existing, affects every
  controller.
- `CLAUDE.md` lists `bundle exec rubocop`, but rubocop is **not in the bundle** — that
  command fails. Same file also says Rails 6; it is Rails 8.0.5.

## Type scale bumped ~20%

Every `pt` font-size in `pdf_styles.scss` multiplied by **1.2**, rounded to the nearest
half-point. `font-size: 0` on the hairline rules left alone.

| Role | Before | After |
|---|---|---|
| Body / list text | 9.5pt | 11.5pt |
| Footer (insurance line) | 7pt | 8.5pt |
| Photo caption | 7.5pt | 9pt |
| Company block | 8pt | 9.5pt |
| Meta, party detail, note box | 8.5pt | 10pt |
| Party name | 11pt | 13pt |
| Section heading | 11.5pt | 14pt |
| Continuation page title | 16pt | 19pt |
| Total band (label + amount) | 15.5pt | 18.5pt |
| Logo-name fallback | 20pt | 24pt |
| Document title | 22pt | 26.5pt |

Spacing was deliberately **not** scaled — the paddings are px-based and the page still
holds, so the extra density reads as intentional rather than cramped.

### Page fit at the new size

Verified against real data, with the dense case built inside a rolled-back transaction so
the dev database was untouched: **8 cost rows plus a full scope block (3-line paragraph,
6 inclusions, 4 exclusions) still fits page 1**, with the footer landing near the bottom
rather than mid-page. The page is now well used at that size instead of half empty.

## Bug found and fixed: PDF had no charset

`app/views/layouts/pdf.html.erb` never declared one, so wkhtmltopdf decoded the page as
**Latin-1** and mojibaked every non-ASCII character. An em dash in a cost description came
out as `a€"`; accented customer names and curly apostrophes would break identically.

Confirmed it was the render path, not the database: an em dash round-trips intact through
both `costs` (latin1_swedish_ci) and `quote_scopes` (utf8mb4) — the connection charset
handles it.

Fix is one line, `<meta charset="utf-8">` first in `<head>`, with a comment saying why it
must stay there. Re-rendered and the dashes are correct.

This was **pre-existing and affects every quote, invoice and receipt ever generated** — it
just became visible because the redesign's content uses em dashes and the new scope field
is free-form prose where people will type them naturally.

## Section rhythm reopened after the type bump

The section spacing was tuned at the old 9.5pt body size and stayed put when the type
scaled 20%, which left the scope sections reading jammed against each other.

| | Before | After |
|---|---|---|
| Between sections (`.section` margin-bottom) | 9px | **20px** |
| Heading to its own content (`.section-head` margin-bottom) | 7px | **10px** |
| Heading rule padding | 3px | 4px |
| Parties panel to first section | 14px | **20px** — matches `.section` |

The parties panel gap was raised alongside them: at 14px the space above the *first*
section was tighter than the gaps between sections, which made the panel look attached to
the scope block.

Page fit re-checked with the dense case (8 cost rows + full scope, in a rolled-back
transaction): page 1 still holds, with the footer near the bottom. An odd extra gap that
had appeared mid-pricing-table at the tighter spacing is gone too.

## Optional "Valid Until" date

**Stored on `estimates`, not on `quote_scopes`.** The estimates table already holds the
quote date family — `quote_sent_date`, `quote_accepted_date` — so `quote_valid_until` sits
with its siblings. `quote_scopes` holds the scope prose; a single nullable date is a
different kind of thing and putting it there would have made that table's name a misnomer.
Say the word if you'd rather it moved.

| Layer | Change |
|---|---|
| Migration | `20260930000001_add_quote_valid_until_to_estimates.rb` |
| Params | `:quote_valid_until` added to `estimate_params` — reuses the existing `PUT /estimates/:id` |
| Serializer | `attribute :quote_valid_until` on EstimateSerializer |
| UI | "Valid Until" row in the Quote box with the standard `pencil-square` edit affordance |
| Editor | `components/quote/actions/editValidUntil.vue` — date picker plus an explicit "Clear the date" |
| PDF | `Valid until` row in the meta block, directly under `Date tendered` |

**Suppressed on invoices and receipts.** An expiry is only meaningful while the document is
still a quote, so the PDF row is gated on `estimate.invoice&.number.blank?` as well as the
date being present.

**Clearing sends `''`, not `null`.** Rails casts an empty string to nil for a date column,
whereas a JSON null gets dropped by `permit` and the date would silently stay set.

**One thing to note about an existing component:** `estimateState/actions/editDifficulty.vue`
emits `EventBus.$emit('ESTIMATE_UPDATED', { difficulty: ... })`, but singleEstimate's handler
only acts on payloads shaped `{ estimate: ... }` — so that emit is a no-op and the page does
not refresh after a difficulty change. The new component passes `response.data` through
instead, which is the shape the handler expects. Not fixed here since it is out of scope.

Verified end to end in a rolled-back transaction: set → serialized → appears in HTML and
PDF; cleared → row gone; on an invoice → suppressed. New spec
`spec/views/quotes/pdf/_quote.html.erb_spec.rb` covers all three plus the scope-section
and `.spacious` behaviour.

### Datepicker sidebar: use the non-scrolling wrapper

`editValidUntil.vue` first used `app-scrollable-sidebar`, copied from the cost editor. That
wrapper sets `#sidebar-top { max-height: 90%; overflow: scroll; }`, which **clips the
datepicker's dropdown calendar** to a sliver — the calendar is absolutely positioned and
the overflow container cuts it off.

Every other datepicker sidebar in the app already avoids this:

| Component | Wrapper |
|---|---|
| `estimate/actions/schedule` | `app-right-sidebar-form` |
| `vehicles/actions/addExpiration` | `app-right-sidebar-form` |
| `job/actions/start`, `job/actions/complete` | `app-right-sidebar` |
| `invoice/actions/send` | `app-right-sidebar` |

Switched to `app-right-sidebar-form`, with a comment at the top of the file so it does not
get changed back.

`editScope.vue` correctly keeps `app-scrollable-sidebar` — the inclusion/exclusion lists
can grow long and genuinely need to scroll, and it contains no dropdowns.