# Pulse Analytics for Google Tag Manager

A Community Template that installs [Pulse Analytics](https://pulse.ciphera.net),
privacy-first web analytics from [Ciphera](https://ciphera.net), through GTM
without a Custom HTML tag.

No cookies, no personal data, and the script it loads is under 3 KB.

## Install

Once the template is in the Community Template Gallery:

1. In GTM, go to **Templates → Tag Templates → Search Gallery**
2. Find **Pulse Analytics**, add it to your workspace
3. **Tags → New → Pulse Analytics**
4. Leave **Domain** blank for a single-site container, or set it to the domain
   your site is registered under in Pulse Analytics
5. Trigger: **All Pages** (Initialization is better still, if you use it)
6. **Submit**

You need a Pulse Analytics account with a site registered for that domain. The
free plan is enough to start.

## Options

| Option | Default | What it does |
|---|---|---|
| **Domain** | the page's own hostname | The domain the site is registered under. Leave blank for one container serving one site; set it when a container serves several domains, or when the registered domain differs from the hostname. |
| **Also track clicks, copies and form submits** | off | Loads the companion script. A second, separate request on purpose — the core script's size is a published claim, so nothing is folded into it. |
| **API origin** (advanced) | — | Only if you proxy Pulse Analytics through your own domain. A bare origin; the script appends its own path. |

## Why it configures through `window.pulseConfig`

The Pulse Analytics docs show a tag carrying `data-domain`. This template cannot
emit that, and no GTM template can: the sandboxed
`injectScript(url, onSuccess, onFailure, cacheToken)` takes a URL and callbacks
and has **no parameter for HTML attributes**. GTM also strips `data-*` from
Custom HTML tags.

The tracker reads `document.currentScript` first and falls back to
`window.pulseConfig` — a fallback it carries deliberately for tag managers. So
the template sets `window.pulseConfig` and then injects the script, which is the
same install by a different road.

It **merges** into an existing `window.pulseConfig` rather than replacing it, so
a setting you made by hand is not silently dropped.

## A note on sovereignty

Pulse Analytics exists partly so that measuring your traffic does not require a
US provider. Running it *through* Google Tag Manager puts one back in the path:
the container script is served by Google, and Google sees the request for it.
The tag itself sends nothing to Google, and Pulse Analytics still sets no cookies
and stores no personal data — but if avoiding that path is the reason you chose
Pulse Analytics, install the tag directly instead. The
[framework guides](https://docs.ciphera.net/pulse/framework-guides) show how.

## Development

```bash
node scripts/check-template.mjs
```

The guard checks what the gallery would otherwise tell you about days later, in
a review issue: the seven sections and their order, that the JSON blocks parse,
the 1–3 category rule, that `inject_script` is pinned to Pulse Analytics' own
origin, that every URL the JS injects is covered by that allowlist, that the
test suite has not shrunk, and that `LICENSE` is the Apache-2.0 text.

## Licence

Copyright 2026 Ciphera BV. Apache-2.0 — `LICENSE` is the licence text verbatim,
which the gallery requires.

This template is not affiliated with, endorsed by, or sponsored by Google.
Google Tag Manager is a trademark of Google LLC.
