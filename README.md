# Jagdish Sahoo

**Senior Software Development Engineer** · India, open to remote

I build enterprise Java and Spring Boot microservices, React frontends and AWS
cloud systems that stay fast under real traffic.

[View the portfolio](https://jagdish1998.github.io/portfolio/)

---

## Profile

Senior Software Development Engineer with around 4.3 years developing
enterprise Java and Spring Boot microservices, React frontends and AWS cloud
solutions using Docker, ECS and EC2 across financial services and e-commerce
platforms.

## Technical Skills

| Area | Technologies |
| --- | --- |
| Languages | Java, Python, ReactJS |
| Frameworks & Technologies | Spring, Spring Boot, Spring Security, REST APIs, JPA, Hibernate, JWT, OAuth |
| Cloud & DevOps | AWS EC2, AWS ECS, AWS EKS, IAM, VPC, CodeCommit, CodePipeline, CloudFront, CloudWatch, Route53, Docker, Jenkins, Kafka |
| Databases | PostgreSQL, MySQL, DynamoDB |
| Web & Tools | HTML5, CSS3, IntelliJ, Eclipse, STS, VS Code, Postman, Git, SVN |
| Foundations & Practice | Data Structures, Algorithms, OOP, Agile, Scrum |
| AI Tools | Amazon Kiro, AWS Transform, Copilot, Claude, Cursor |

## Experience

**Lead Software Engineer** — Persistent Systems
*June 2025 – Present*

**Digital Specialist Engineer I** — Infosys
*June 2022 – June 2025*

**Student Placement Coordinator** — Odisha University of Technology and Research
*Apr 2021 – Apr 2022*

**Open Source Contributor** — GirlScript Summer of Code
*Feb 2021 – May 2021*

## Education

**Master of Computer Applications** — Odisha University of Technology and
Research, Bhubaneswar · *2019 – 2022*

**Bachelor of Science, Chemistry** — Maharaja Sriram Chandra Bhanja Deo
University, Baripada · *2016 – 2019*

**Higher Secondary, Class 11–12** — Barbil Junior College, Barbil · *2014 – 2016*

**Secondary School, Class 10** — Saraswati Shishu Vidya Mandir, Barbil
· *2013 – 2014*

## Coding Profiles

| Platform | Standing |
| --- | --- |
| LeetCode | 1100+ problems solved, top 10% ranking |
| GeeksForGeeks | 380+ problems solved |
| CodeChef | 3★, 1400+ rating across 50+ contests |

Strongest in mathematical algorithms, graph theory and advanced data structures.
Profile links are on the portfolio site.

## What I Work On

**REST API design and integration** — resource-oriented services built on
stateless communication and standard HTTP semantics, so the contract stays
maintainable as the surface grows.

**Spring Security** — authentication and authorisation via configurable filter
chains, role-based access control, password encoding and CSRF protection.

**Event-driven systems with Kafka** — asynchronous publish and subscribe
pipelines that keep services loosely coupled and fault tolerant when a consumer
needs to catch up.

## Contact

Email: jagdish.cet.edu@gmail.com
Location: India, open to remote
CV: `images/Resume_Jagdish_Sahoo.pdf`

---

## About this repository

The portfolio site itself. Plain HTML, CSS and JavaScript, no framework and no
build step.

```
index.html          markup for every section
style.css           design tokens, layout, responsive rules
main.js             theme toggle, nav, tabs, lightbox, counters, form
site.webmanifest    icons and theme colour
images/             source photos and generated icons
images/opt/         generated, size-optimised image variants
```

Run it through any static server, since the fonts and the contact form need a
real HTTP origin:

```bash
python -m http.server 5500
# http://127.0.0.1:5500/
```

### Asset scripts

Source images are camera originals, far too large to serve. These scripts
generate everything in `images/opt/` plus the favicons. Originals are never
modified and the output is committed, so the site needs no build step.

| Script | Purpose |
| --- | --- |
| `optimize-images.ps1` | Resizes every image to 500/800/1600px variants, honouring EXIF orientation |
| `make-logo.ps1` | Keys the black backdrop out of `logo.png` and emits light and dark wordmark variants |
| `make-favicon.ps1` | Builds `favicon.ico` (16/32/48), the Apple touch icon and 192/512 PWA icons from the logo's "J" |
| `crop-hero.ps1` | Crops the hero portrait out of `background.png` |

```powershell
powershell -ExecutionPolicy Bypass -File .\optimize-images.ps1
```

### Project screenshots

Headless Edge captures these, at 2x so the downscale to 800px is sharp:

```powershell
& "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe" `
  --headless=new --disable-gpu --hide-scrollbars --force-device-scale-factor=2 `
  --window-size=1440,900 --virtual-time-budget=12000 `
  --screenshot="$env:TEMP\shot.png" `
  "https://jagdish1998.github.io/linkedin-optimiser/"
```

Two things that are easy to get wrong. Capture at a desktop viewport width, not a
portrait one: 1000px collapses that hero into a single column, so the shot shows a
layout no visitor on a laptop ever sees. And keep `--virtual-time-budget`, or the
shot can land before webfonts and entrance animations have settled.

Then crop rather than shrink. A whole page scaled into a 650px card reads as a
screenshot of a website; one component filling the frame reads as a product.
`images/work-3.png` is the hero's report card cropped to 4:5 with about 14% padding,
sitting slightly high in the frame so the stacked card behind it stays in shot.
`images/work-5.png` is a full-height 4:5 slice of this site's own hero, anchored
right of centre so the portrait is in frame rather than cut in half. Regenerate the
`-800` variant afterwards; the work sources only need that one size, since the cards
never load them larger.

`work-4` and `work-5` are the exception: generated tiles rather than screenshots,
because llm-gateway is an API and job-tracker has no dashboard yet. Both are dark
gradients in the site palette with a motif drawn on top, one an open circuit breaker
over descending stage bars and the other event-log lanes filling up, kept distinct so
two abstract cards do not read as the same wallpaper twice. Both carry grain on
purpose, since a smooth dark gradient bands badly once it is JPEG'd, and both are
encoded at quality 84 rather than the pipeline's 78 for the same reason.

### Notes on decisions worth keeping

- **Images.** Originals total 44.6MB; generated variants are 5.7MB. The gallery
  went from roughly 33MB to 521KB by serving 500px tiles via `srcset` and
  loading the 1600px version only when the lightbox opens.
- **Photography grid.** A CSS grid, not multi-column masonry. Multi-column flows
  top-to-bottom per column, so on-screen order did not match the DOM order the
  lightbox arrows step through.
- **Logo.** `logo.png` is two-tone: an accent "J" at `rgb(255,0,79)` and
  "agdish." in white on black. Alpha comes from `max(R,G,B)`, not luminance,
  otherwise the pink J lands around 33% opaque. A coloured mark cannot be
  recoloured with a CSS `invert`, hence separate light and dark variants.
- **Favicon.** The wordmark is illegible below about 64px, so the icons use the
  leading "J" in white on the brand accent.
- **Type.** Inter for UI and body, JetBrains Mono for labels. Inter matches the
  previous Poppins x-height so nothing renders smaller, but is 4.4% narrower.
- **Theme.** Dark by default, light optional, persisted to `localStorage` and
  applied by an inline script before first paint to avoid a flash.
- **Contact form.** Posts to a Google Apps Script endpoint. That URL is public
  by nature, so the sheet is writable by anyone; there is a honeypot and a
  submit throttle, but no real authentication.

### Accessibility

Semantic landmarks, skip link, visible focus styles and `prefers-reduced-motion`
support. The lightbox and tab strip are keyboard operable with focus trapping,
and the form has real labels, inline validation and an `aria-live` status region.
Full WCAG conformance has not been verified; that needs manual testing with
assistive technology.

### Work remaining

- Selected Projects holds six cards, in this order:
  [order-saga](https://github.com/Jagdish1998/order-saga),
  [sql-guard-mcp](https://github.com/Jagdish1998/sql-guard-mcp),
  [linkedin-optimiser](https://github.com/Jagdish1998/linkedin-optimiser),
  [llm-gateway](https://github.com/Jagdish1998/llm-gateway),
  [job-tracker](https://github.com/Jagdish1998/job-tracker) and this site.
- Image numbers follow card order, so inserting a card means renumbering the rest.
  `work-3` and `work-6` are real captures, `work-1` and `work-2` are still
  placeholder renders, and `work-4` and `work-5` are generated tiles: llm-gateway is
  an API with no UI, and job-tracker has no dashboard yet.
- Only linkedin-optimiser has a live demo link. order-saga and sql-guard-mcp need
  one once they are deployed.
- `og:url` and `og:image` in `index.html` need the final deployed URL.
- Font Awesome ships about 273KB of webfonts for 24 icons; inline SVG would be
  the largest remaining performance win.

## Licence

Code is free to reference. The photographs and the CV are not; please do not
reuse those.
