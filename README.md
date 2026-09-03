# Portfolio — Jagdish Sahoo

Personal portfolio site. Plain HTML, CSS and JavaScript, no build step and no
framework. Open `index.html` and it runs.

Live: https://jagdish1998.github.io/portfolio/

## Sections

Hero, About (tabbed summary, skills, experience, education), Coding Profiles,
Photography with a lightbox, Services, Work, and Contact with a working form.

## Running locally

Any static server works. The form and the fonts need a real HTTP origin, so
open it through a server rather than as a `file://` URL.

```bash
python -m http.server 5500
# then visit http://127.0.0.1:5500/
```

## Project layout

```
index.html          markup for every section
style.css           design tokens, layout, responsive rules
main.js             theme toggle, nav, tabs, lightbox, counters, form
site.webmanifest    icons and theme colour for installable/PWA metadata
images/             original photos and generated icons
images/opt/         generated, size-optimised image variants
*.ps1               asset pipeline scripts (see below)
```

## Asset pipeline

Source images are camera originals and are far too large to serve directly.
Three PowerShell scripts generate everything in `images/opt/` plus the favicons.
Originals are never modified, and the generated output is committed so the site
needs no build step.

| Script | Purpose |
| --- | --- |
| `optimize-images.ps1` | Resizes every image to 500/800/1600px variants, honouring EXIF orientation |
| `make-logo.ps1` | Keys the black backdrop out of `logo.png` and emits light and dark wordmark variants |
| `make-favicon.ps1` | Builds `favicon.ico` (16/32/48), the Apple touch icon and the 192/512 PWA icons from the logo's "J" |

Run them after adding or replacing images:

```powershell
powershell -ExecutionPolicy Bypass -File .\optimize-images.ps1
```

## Notes on some decisions

**Images.** The originals total 44.6MB; the generated variants are 6.1MB. The
photography grid alone went from roughly 33MB to 521KB by serving 500px tiles
via `srcset` and loading the 1600px version only when the lightbox opens.

**Photography layout.** A CSS grid rather than multi-column masonry. Multi-column
flows top-to-bottom per column, so the on-screen order did not match the DOM
order the lightbox arrows step through.

**Logo.** `logo.png` is two-tone: an accent "J" at `rgb(255,0,79)` and "agdish."
in white, both on solid black. Alpha is derived from `max(R,G,B)` rather than
luminance, otherwise the pink J ends up around 33% opaque. Because a coloured
mark cannot be recoloured with a CSS `invert` filter, there are separate light
and dark variants.

**Favicon.** The full wordmark is illegible below about 64px, so the icons use
the leading "J" in white on the brand accent.

**Type.** Inter for UI and body, JetBrains Mono for labels and dates. Inter has
the same x-height as the previous Poppins so nothing renders smaller, but is
4.4% narrower, which fits more characters per line.

**Theme.** Dark by default with a light option, persisted to `localStorage` and
applied by an inline script before first paint to avoid a flash of the wrong
colour scheme.

**Contact form.** Posts to a Google Apps Script endpoint. That URL is public by
nature, so treat the sheet as writable by anyone; there is a honeypot field and
a submit throttle, but no real authentication.

## Accessibility

Semantic landmarks, a skip link, visible focus styles, and `prefers-reduced-motion`
support. The lightbox and tab strip are keyboard operable with focus trapping,
and the form has real labels, inline validation and an `aria-live` status region.

Full WCAG conformance has not been verified; that needs manual testing with
assistive technology.

## Known work remaining

- The three cards under Selected Projects are placeholders and need real
  projects, screenshots and links.
- `og:url` and `og:image` in `index.html` need the final deployed URL.
- Font Awesome ships about 273KB of webfonts for 24 icons. Replacing them with
  inline SVG is the largest remaining performance win.
- `images/icon-logo.png` is no longer referenced.

## Licence

Code is free to reference. The photographs and the CV are not; please do not
reuse those.
