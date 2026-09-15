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

## What the guard covers, and what only Google can tell you

`scripts/check-template.mjs` asserts the seven sections and their order, that
the JSON blocks parse, the 1–3 category rule, that `inject_script` is pinned to
`https://js.ciphera.net/*`, that every URL the sandboxed JS injects is covered
by that allowlist, that the test suite has not shrunk, and that `LICENSE` is the
Apache-2.0 text. All eight checks were verified to fail on a real mutation.

It cannot tell you whether the gallery will *accept* the template. Policy,
naming and branding are a human review, and the answer arrives as an issue.

## Trademark

Google's Gallery Terms license its Brand Features "solely for the purpose of
promoting Your participation in the Galleries" — a narrow grant, not permission
to build a co-branded marketing card. The general guidelines add: do not imply a
relationship, and **do not display any Google Brand Feature as the most
prominent element**. So the Pulse Analytics listing card uses `svg: null` in
`pulse-framer/listing/platforms.mjs` — the Pulse mark alone, Tag Manager named in
text only.
