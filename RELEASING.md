# Releasing the Pulse Analytics GTM template

The Community Template Gallery indexes a **public GitHub repository**, not an
upload. There is no package to publish: the gallery reads `template.tpl` and
`metadata.yaml` from this repo at the commits `metadata.yaml` names.

## First submission (once)

1. The repo must be **public**, with **Issues enabled** — ⚠️ not optional.
   Google's reviewers file feedback as **issues on this repo**, and it is the
   only channel they use. Disable issues and a rejection is invisible.
2. `LICENSE` must be **ALL CAPS** and contain **only** the Apache-2.0 text.
3. Everything must be on the **`main`** branch. The gallery reads no other.
4. Go to <https://tagmanager.google.com/gallery> → **⋮** → **Submit Template**
5. Paste the repository URL → **Submit**

Then wait. A review is days, not minutes, and arrives as an issue here.

## Every release

1. Edit `template.tpl`. Run the guard:

   ```bash
   node scripts/check-template.mjs
   ```

2. Merge to `main`. CI runs the guard on the PR **and** on the push.
3. **Note the merge commit's SHA** and add a new entry at the **top** of
   `versions:` in `metadata.yaml`:

   ```yaml
   versions:
     - sha: <the new 40-char commit sha>
       changeNotes: What changed, in one line.
   ```

4. 🔴 **Verify the sha is a real commit on this repo before pushing it** —
   `git cat-file -e <sha>^{commit}`. CI checks the *shape* (40 hex characters,
   newest first, `homepage` present) but deliberately **not** that each sha
   exists, because a shallow CI clone cannot resolve an ancestor and the guard
   would red a correct file. A sha that is not a commit here does not error
   anywhere: the gallery just keeps serving the previous version, quietly.
5. Commit `metadata.yaml` and push. The gallery picks the new version up on its
   own schedule.

⚠️ **`metadata.yaml` is a chicken-and-egg file.** The sha it names is the commit
holding the template, which cannot exist until that commit is made — so the
first release is two commits, and the metadata commit is never the one it names.

## 🔴 Two things the gallery requires that nothing documents

The first submission was rejected with exactly one sentence — *"Error submitting
the template: The template.tpl file is invalid."* — no field, no line number.
The structural guard was green at the time. Diffing against two templates that
are actually in the gallery (`plausible/plausible-gtm-template`,
`microsoft/clarity-gtm-template`) found both differences:

1. **A UTF-8 BOM.** Both accepted files start with `EF BB BF`. The GTM editor
   writes one on export, so every hand-written template is missing it.
2. **A `brand` block in `___INFO___`**, with `id`, `displayName` and a
   **base64 PNG data URI** `thumbnail`. Both accepted files have one; neither the
   gallery docs nor the submission form mention it.

Ours reuses the 64 px Pulse mark already embedded in `pulse-framer/public/icon.svg`
— one mark, one source, rather than a second copy that can drift.

Both are now asserted by `scripts/check-template.mjs`, and both were verified to
fail it on a real mutation. 🔑 **The lesson is about the guard, not the gallery:**
it passed a file Google rejected, because it checked what was easy to check
rather than what acceptance actually depends on. Diff against a known-good
artefact before trusting a guard you wrote from a spec.

## What the guard covers, and what only Google can tell you

`scripts/check-template.mjs` asserts the seven sections and their order, that
the JSON blocks parse, the 1–3 category rule, that `inject_script` is pinned to
`https://js.ciphera.net/*`, that every URL the sandboxed JS injects is covered
by that allowlist, that the test suite has not shrunk, and that `LICENSE` is the
Apache-2.0 text. All eight checks were verified to fail on a real mutation.

It cannot tell you whether the gallery will *accept* the template. Policy,
naming and branding are a human review, and the answer arrives as an issue.

## Before a Pulse repo goes public

The scan that matters is wider than "look for secrets". Credentials and
hostnames are the obvious half; the half that slipped through on this repo was
an **internal service name** sitting in a prose comment, which no credential
pattern matches. So check for all four:

1. credentials — tokens, passwords, keys
2. internal hostnames and addresses — `*-ops`, private ranges, non-public subdomains
3. **internal service names** — anything the outside world has no reason to know exists
4. customer and partner identifiers — a design partner's domain has been scrubbed
   from a Pulse repo's history once already

## Trademark

Google's Gallery Terms license its Brand Features "solely for the purpose of
promoting Your participation in the Galleries" — a narrow grant, not permission
to build a co-branded marketing card. The general guidelines add: do not imply a
relationship, and **do not display any Google Brand Feature as the most
prominent element**. So the Pulse Analytics listing card uses `svg: null` in
`pulse-framer/listing/platforms.mjs` — the Pulse mark alone, Tag Manager named in
text only.
