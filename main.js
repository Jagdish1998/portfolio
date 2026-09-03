/* ============================================================
   Portfolio interactions
   ============================================================ */
(function () {
    'use strict';

    var prefersReducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

    /* ---------- footer year ---------- */
    var yearEl = document.getElementById('year');
    if (yearEl) {
        yearEl.textContent = String(new Date().getFullYear());
    }

    /* ---------- theme toggle ---------- */
    (function initTheme() {
        var toggle = document.getElementById('theme-toggle');
        var root = document.documentElement;
        var stored = null;

        try {
            stored = localStorage.getItem('theme');
        } catch (e) {
            /* storage blocked, fall back to system preference */
        }

        var initial = stored || (window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark');
        apply(initial);

        function apply(theme) {
            root.setAttribute('data-theme', theme);
            if (!toggle) return;

            var icon = toggle.querySelector('i');
            var goingTo = theme === 'dark' ? 'light' : 'dark';
            toggle.setAttribute('aria-label', 'Switch to ' + goingTo + ' theme');
            if (icon) {
                icon.className = theme === 'dark' ? 'fa-solid fa-moon' : 'fa-solid fa-sun';
            }

            var meta = document.querySelector('meta[name="theme-color"]');
            if (meta) {
                meta.setAttribute('content', theme === 'dark' ? '#08080a' : '#fbfbfd');
            }
        }

        if (toggle) {
            toggle.addEventListener('click', function () {
                var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
                apply(next);
                try {
                    localStorage.setItem('theme', next);
                } catch (e) {
                    /* ignore */
                }
            });
        }
    })();

    /* ---------- mobile nav ---------- */
    (function initNav() {
        var nav = document.getElementById('primary-nav');
        var openBtn = document.getElementById('nav-open');
        var backdrop = document.getElementById('nav-backdrop');
        var closeBtn = nav ? nav.querySelector('.nav-close') : null;
        if (!nav || !openBtn || !backdrop) return;

        function open() {
            nav.classList.add('is-open');
            backdrop.hidden = false;
            requestAnimationFrame(function () {
                backdrop.classList.add('is-open');
            });
            openBtn.setAttribute('aria-expanded', 'true');
            document.body.classList.add('no-scroll');
            var first = nav.querySelector('a');
            if (first) first.focus();
        }

        function close(returnFocus) {
            nav.classList.remove('is-open');
            backdrop.classList.remove('is-open');
            openBtn.setAttribute('aria-expanded', 'false');
            document.body.classList.remove('no-scroll');
            window.setTimeout(function () {
                if (!nav.classList.contains('is-open')) backdrop.hidden = true;
            }, 350);
            if (returnFocus) openBtn.focus();
        }

        openBtn.addEventListener('click', open);
        backdrop.addEventListener('click', function () {
            close(true);
        });
        if (closeBtn) {
            closeBtn.addEventListener('click', function () {
                close(true);
            });
        }

        nav.addEventListener('click', function (e) {
            if (e.target.closest('a')) close(false);
        });

        // Escape closes, Tab stays inside the open drawer.
        document.addEventListener('keydown', function (e) {
            if (!nav.classList.contains('is-open')) return;

            if (e.key === 'Escape') {
                close(true);
                return;
            }

            if (e.key !== 'Tab') return;

            var items = nav.querySelectorAll('a, button');
            if (!items.length) return;
            var first = items[0];
            var last = items[items.length - 1];

            if (e.shiftKey && document.activeElement === first) {
                e.preventDefault();
                last.focus();
            } else if (!e.shiftKey && document.activeElement === last) {
                e.preventDefault();
                first.focus();
            }
        });

        // Reset when resizing back up to desktop.
        window.addEventListener('resize', function () {
            if (window.innerWidth > 900 && nav.classList.contains('is-open')) close(false);
        });
    })();

    /* ---------- sticky header, scroll progress, back to top ---------- */
    (function initScrollUI() {
        var header = document.getElementById('site-header');
        var bar = document.getElementById('scroll-bar');
        var toTop = document.getElementById('to-top');
        var ticking = false;

        function update() {
            var y = window.scrollY || window.pageYOffset;

            if (header) header.classList.toggle('is-stuck', y > 20);
            if (toTop) toTop.classList.toggle('is-visible', y > 600);

            if (bar) {
                var max = document.documentElement.scrollHeight - window.innerHeight;
                var pct = max > 0 ? (y / max) * 100 : 0;
                bar.style.width = Math.min(100, Math.max(0, pct)) + '%';
            }

            ticking = false;
        }

        window.addEventListener('scroll', function () {
            if (!ticking) {
                ticking = true;
                requestAnimationFrame(update);
            }
        }, { passive: true });

        window.addEventListener('resize', update);
        update();

        if (toTop) {
            toTop.addEventListener('click', function () {
                window.scrollTo({
                    top: 0,
                    behavior: prefersReducedMotion ? 'auto' : 'smooth'
                });
            });
        }
    })();

    /* ---------- active nav link ---------- */
    (function initActiveLink() {
        var links = Array.prototype.slice.call(document.querySelectorAll('.nav-links a[href^="#"]'));
        if (!links.length || !('IntersectionObserver' in window)) return;

        var map = {};
        var sections = [];

        links.forEach(function (link) {
            var id = link.getAttribute('href').slice(1);
            var section = document.getElementById(id);
            if (section) {
                map[id] = link;
                sections.push(section);
            }
        });

        var observer = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (!entry.isIntersecting) return;
                links.forEach(function (l) {
                    l.classList.remove('is-active');
                });
                var active = map[entry.target.id];
                if (active) active.classList.add('is-active');
            });
        }, { rootMargin: '-45% 0px -50% 0px', threshold: 0 });

        sections.forEach(function (s) {
            observer.observe(s);
        });
    })();

    /* ---------- scroll reveal ---------- */
    (function initReveal() {
        var items = Array.prototype.slice.call(document.querySelectorAll('.reveal'));
        if (!items.length) return;

        if (prefersReducedMotion || !('IntersectionObserver' in window)) {
            items.forEach(function (el) {
                el.classList.add('is-visible');
            });
            return;
        }

        var observer = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (!entry.isIntersecting) return;
                var el = entry.target;
                var siblings = Array.prototype.slice.call(el.parentElement.children).filter(function (n) {
                    return n.classList.contains('reveal');
                });
                var index = siblings.indexOf(el);
                el.style.setProperty('--reveal-delay', Math.min(index, 5) * 80 + 'ms');
                el.classList.add('is-visible');
                observer.unobserve(el);
            });
        }, { rootMargin: '0px 0px -8% 0px', threshold: 0.08 });

        items.forEach(function (el) {
            observer.observe(el);
        });
    })();

    /* ---------- animated counters ---------- */
    (function initCounters() {
        var counters = Array.prototype.slice.call(document.querySelectorAll('.counter'));
        if (!counters.length) return;

        function format(el, value) {
            var decimals = parseInt(el.dataset.decimals || '0', 10);
            var suffix = el.dataset.suffix || '';
            return value.toFixed(decimals) + suffix;
        }

        function run(el) {
            var target = parseFloat(el.dataset.count || '0');
            if (prefersReducedMotion) {
                el.textContent = format(el, target);
                return;
            }

            var duration = 1400;
            var start = null;

            function step(now) {
                if (start === null) start = now;
                var progress = Math.min(1, (now - start) / duration);
                var eased = 1 - Math.pow(1 - progress, 3);
                el.textContent = format(el, target * eased);
                if (progress < 1) requestAnimationFrame(step);
            }

            requestAnimationFrame(step);
        }

        if (!('IntersectionObserver' in window)) {
            counters.forEach(run);
            return;
        }

        var observer = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (!entry.isIntersecting) return;
                run(entry.target);
                observer.unobserve(entry.target);
            });
        }, { threshold: 0.4 });

        counters.forEach(function (el) {
            observer.observe(el);
        });
    })();

    /* ---------- about tabs ---------- */
    (function initTabs() {
        var tablist = document.querySelector('.tab-titles');
        if (!tablist) return;

        var tabs = Array.prototype.slice.call(tablist.querySelectorAll('[role="tab"]'));
        if (!tabs.length) return;

        function select(tab) {
            tabs.forEach(function (t) {
                var isActive = t === tab;
                t.classList.toggle('is-active', isActive);
                t.setAttribute('aria-selected', isActive ? 'true' : 'false');
                t.tabIndex = isActive ? 0 : -1;

                var panel = document.getElementById(t.getAttribute('aria-controls'));
                if (panel) {
                    panel.hidden = !isActive;
                    panel.classList.toggle('is-active', isActive);
                }
            });
        }

        tabs.forEach(function (tab) {
            tab.addEventListener('click', function () {
                select(tab);
            });
        });

        tablist.addEventListener('keydown', function (e) {
            var current = tabs.indexOf(document.activeElement);
            if (current === -1) return;

            var next = -1;
            if (e.key === 'ArrowRight') next = (current + 1) % tabs.length;
            else if (e.key === 'ArrowLeft') next = (current - 1 + tabs.length) % tabs.length;
            else if (e.key === 'Home') next = 0;
            else if (e.key === 'End') next = tabs.length - 1;
            if (next === -1) return;

            e.preventDefault();
            select(tabs[next]);
            tabs[next].focus();
        });
    })();

    /* ---------- lightbox ---------- */
    (function initLightbox() {
        var box = document.getElementById('lightbox');
        var gallery = document.getElementById('gallery');
        if (!box || !gallery) return;

        // The gallery markup is the single source of truth, no duplicated array.
        var photos = Array.prototype.slice.call(gallery.querySelectorAll('.photo'));
        if (!photos.length) return;

        var img = document.getElementById('lightbox-img');
        var titleEl = document.getElementById('lightbox-title');
        var captionEl = document.getElementById('lightbox-caption');
        var countEl = document.getElementById('lightbox-count');
        var closeBtn = document.getElementById('lightbox-close');
        var prevBtn = document.getElementById('lightbox-prev');
        var nextBtn = document.getElementById('lightbox-next');
        var openTrigger = document.getElementById('open-gallery');

        var index = 0;
        var lastFocused = null;

        function show(i) {
            index = (i + photos.length) % photos.length;
            var fig = photos[index];
            var thumb = fig.querySelector('img');

            img.src = fig.dataset.full || (thumb ? thumb.src : '');
            img.alt = thumb ? thumb.alt : '';
            titleEl.textContent = fig.dataset.title || '';
            captionEl.textContent = fig.dataset.caption || '';
            countEl.textContent = (index + 1) + ' / ' + photos.length;

            // Warm the neighbours so arrow navigation feels instant.
            [index + 1, index - 1].forEach(function (n) {
                var neighbour = photos[(n + photos.length) % photos.length];
                if (neighbour && neighbour.dataset.full) {
                    var pre = new Image();
                    pre.src = neighbour.dataset.full;
                }
            });
        }

        function open(i) {
            lastFocused = document.activeElement;
            show(i);
            box.hidden = false;
            requestAnimationFrame(function () {
                box.classList.add('is-open');
            });
            document.body.classList.add('no-scroll');
            closeBtn.focus();
        }

        function close() {
            box.classList.remove('is-open');
            document.body.classList.remove('no-scroll');
            window.setTimeout(function () {
                box.hidden = true;
                img.removeAttribute('src');
            }, 300);
            if (lastFocused && lastFocused.focus) lastFocused.focus();
        }

        photos.forEach(function (fig, i) {
            fig.setAttribute('tabindex', '0');
            fig.setAttribute('role', 'button');
            fig.setAttribute('aria-label', 'Open ' + (fig.dataset.title || 'photo') + ' in viewer');

            fig.addEventListener('click', function () {
                open(i);
            });
            fig.addEventListener('keydown', function (e) {
                if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    open(i);
                }
            });
        });

        if (openTrigger) {
            openTrigger.addEventListener('click', function () {
                open(0);
            });
        }

        closeBtn.addEventListener('click', close);
        prevBtn.addEventListener('click', function () {
            show(index - 1);
        });
        nextBtn.addEventListener('click', function () {
            show(index + 1);
        });

        // Click the dimmed area to dismiss.
        box.addEventListener('click', function (e) {
            if (e.target === box) close();
        });

        document.addEventListener('keydown', function (e) {
            if (box.hidden) return;

            if (e.key === 'Escape') {
                close();
            } else if (e.key === 'ArrowRight') {
                show(index + 1);
            } else if (e.key === 'ArrowLeft') {
                show(index - 1);
            } else if (e.key === 'Tab') {
                // Keep focus inside the dialog.
                var items = [closeBtn, prevBtn, nextBtn];
                var pos = items.indexOf(document.activeElement);
                e.preventDefault();
                var nextPos = e.shiftKey ? pos - 1 : pos + 1;
                if (nextPos < 0) nextPos = items.length - 1;
                if (nextPos >= items.length) nextPos = 0;
                items[nextPos].focus();
            }
        });

        // Swipe on touch screens.
        var startX = 0;
        var startY = 0;
        box.addEventListener('touchstart', function (e) {
            startX = e.changedTouches[0].clientX;
            startY = e.changedTouches[0].clientY;
        }, { passive: true });

        box.addEventListener('touchend', function (e) {
            var dx = e.changedTouches[0].clientX - startX;
            var dy = e.changedTouches[0].clientY - startY;
            if (Math.abs(dx) > 50 && Math.abs(dx) > Math.abs(dy)) {
                show(dx < 0 ? index + 1 : index - 1);
            }
        }, { passive: true });
    })();

    /* ---------- copy to clipboard ---------- */
    (function initCopy() {
        var buttons = Array.prototype.slice.call(document.querySelectorAll('.copy-btn'));

        buttons.forEach(function (btn) {
            btn.addEventListener('click', function () {
                var value = btn.dataset.copy || '';
                if (!value || !navigator.clipboard) return;

                navigator.clipboard.writeText(value).then(function () {
                    var icon = btn.querySelector('i');
                    btn.classList.add('is-copied');
                    if (icon) icon.className = 'fa-solid fa-check';
                    btn.setAttribute('aria-label', 'Email address copied');

                    window.setTimeout(function () {
                        btn.classList.remove('is-copied');
                        if (icon) icon.className = 'fa-solid fa-copy';
                        btn.setAttribute('aria-label', 'Copy email address');
                    }, 2000);
                }).catch(function () {
                    /* clipboard denied, nothing to do */
                });
            });
        });
    })();

    /* ---------- contact form ---------- */
    (function initForm() {
        var form = document.getElementById('contact-form');
        if (!form) return;

        var status = document.getElementById('form-status');
        var submitBtn = document.getElementById('submit-btn');
        var honeypot = form.elements['Company'];
        var lastSent = 0;

        // Google Apps Script endpoint. Anything posted here lands in the sheet,
        // so treat it as public and never send secrets through it.
        var scriptURL = 'https://script.google.com/macros/s/AKfycbx2J2WPrY3CFJh2td9vYh7c3IqP7hX9WvoaqC53TtLL7Gq-FczAh58H6rbcBrquQjxk/exec';

        var fields = [
            { el: form.elements['Name'], err: 'err-name', label: 'name' },
            { el: form.elements['Email'], err: 'err-email', label: 'email' },
            { el: form.elements['Message'], err: 'err-message', label: 'message' }
        ];

        function setError(field, message) {
            var wrap = field.el.closest('.field');
            var errEl = document.getElementById(field.err);
            if (wrap) wrap.classList.toggle('has-error', Boolean(message));
            if (errEl) errEl.textContent = message || '';
            field.el.setAttribute('aria-invalid', message ? 'true' : 'false');
        }

        function validate(field) {
            var value = (field.el.value || '').trim();

            if (!value) {
                setError(field, 'Please enter your ' + field.label + '.');
                return false;
            }
            if (field.el.type === 'email' && !/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(value)) {
                setError(field, 'That email address does not look right.');
                return false;
            }
            if (field.label === 'message' && value.length < 10) {
                setError(field, 'A little more detail please, at least 10 characters.');
                return false;
            }

            setError(field, '');
            return true;
        }

        fields.forEach(function (field) {
            if (!field.el) return;
            field.el.addEventListener('blur', function () {
                validate(field);
            });
            field.el.addEventListener('input', function () {
                if (field.el.closest('.field').classList.contains('has-error')) validate(field);
            });
        });

        function setStatus(message, kind) {
            if (!status) return;
            status.textContent = message;
            status.className = 'form-status' + (kind ? ' is-' + kind : '');
        }

        form.addEventListener('submit', function (e) {
            e.preventDefault();

            // Bot filled the hidden field: pretend it worked, send nothing.
            if (honeypot && honeypot.value) {
                setStatus('Message sent successfully.', 'success');
                form.reset();
                return;
            }

            // Simple throttle so one impatient click does not become ten rows.
            var now = Date.now();
            if (now - lastSent < 15000) {
                setStatus('Just a moment before sending another message.', 'error');
                return;
            }

            var firstInvalid = null;
            var valid = true;
            fields.forEach(function (field) {
                if (!field.el) return;
                if (!validate(field)) {
                    valid = false;
                    if (!firstInvalid) firstInvalid = field.el;
                }
            });

            if (!valid) {
                setStatus('Please fix the highlighted fields.', 'error');
                if (firstInvalid) firstInvalid.focus();
                return;
            }

            submitBtn.disabled = true;
            submitBtn.classList.add('is-loading');
            setStatus('Sending your message…', '');

            fetch(scriptURL, { method: 'POST', body: new FormData(form) })
                .then(function (response) {
                    if (!response.ok) throw new Error('Request failed with status ' + response.status);
                    lastSent = Date.now();
                    setStatus('Thanks, your message is on its way.', 'success');
                    form.reset();
                    fields.forEach(function (field) {
                        if (field.el) setError(field, '');
                    });
                })
                .catch(function () {
                    setStatus('Something went wrong. Please email jagdish.cet.edu@gmail.com directly.', 'error');
                })
                .finally(function () {
                    submitBtn.disabled = false;
                    submitBtn.classList.remove('is-loading');
                    window.setTimeout(function () {
                        if (status && status.classList.contains('is-success')) setStatus('', '');
                    }, 6000);
                });
        });
    })();
})();
