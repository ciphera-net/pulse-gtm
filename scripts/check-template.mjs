// Structure guard for template.tpl.
//
// The Community Template Gallery rejects a malformed template with a message
// that arrives days later, as a GitHub issue on this repo, from a reviewer. That
// is a slow way to learn about a typo, so the checkable parts are checked here.
import { readFileSync } from "node:fs"

const SECTIONS = [
  "TERMS_OF_SERVICE",
  "INFO",
  "TEMPLATE_PARAMETERS",
  "SANDBOXED_JS_FOR_WEB_TEMPLATE",
  "WEB_PERMISSIONS",
  "TESTS",
  "NOTES",
]

// The tag may only ever load Pulse's own scripts. Widening this is a security
// decision, not a formatting one — the allowlist is what stops a template
// parameter from being turned into an arbitrary script include.
const ALLOWED_SCRIPT_URLS = ["https://js.ciphera.net/*"]

const src = readFileSync("template.tpl", "utf8").replace(/^﻿/, "")
const fail = (m) => { console.error(`✗ ${m}`); process.exitCode = 1 }
const ok = (m) => console.log(`✓ ${m}`)

const found = [...src.matchAll(/^___([A-Z_]+)___$/gm)].map((m) => m[1])
if (found.join() !== SECTIONS.join()) {
  fail(`sections are ${found.join(", ")}; expected ${SECTIONS.join(", ")} in that order`)
} else {
  ok("all seven sections present, in order")
}

// Split on the headers rather than matching between them: under the `m` flag a
// trailing `$` in a lookahead means end-of-LINE, so the obvious regex returns
// the first line of a section and every JSON parse fails with "unexpected end
// of input" — which reads like malformed JSON rather than a bad reader.
const parts = src.split(/^___([A-Z_]+)___$/m)
const bodies = new Map()
for (let i = 1; i < parts.length - 1; i += 2) bodies.set(parts[i], parts[i + 1])
const section = (name) => (bodies.has(name) ? bodies.get(name).trim() : null)

let info, params, perms
try {
  info = JSON.parse(section("INFO"))
  params = JSON.parse(section("TEMPLATE_PARAMETERS"))
  perms = JSON.parse(section("WEB_PERMISSIONS"))
  ok("INFO, TEMPLATE_PARAMETERS and WEB_PERMISSIONS are valid JSON")
} catch (e) {
  fail(`a JSON section does not parse: ${e.message}`)
  process.exit(1)
}

if (info.type !== "TAG") fail(`INFO.type is ${info.type}, expected TAG`)
if (String(info.containerContexts) !== "WEB") fail(`INFO.containerContexts is ${info.containerContexts}, expected [WEB]`)
// Gallery rule: 1-3 categories, from its own enum.
if (!Array.isArray(info.categories) || info.categories.length < 1 || info.categories.length > 3) {
  fail(`INFO.categories must hold 1-3 entries, found ${JSON.stringify(info.categories)}`)
}
if (!info.description) fail("INFO.description is empty — it is the gallery listing's subtitle")
ok(`INFO: ${info.displayName} / ${info.categories.join(", ")}`)

const permIds = perms.map((p) => p.instance.key.publicId)
for (const required of ["inject_script", "access_globals"]) {
  if (!permIds.includes(required)) fail(`missing the ${required} permission`)
}
ok(`permissions: ${permIds.join(", ")}`)

const urls = perms
  .filter((p) => p.instance.key.publicId === "inject_script")
  .flatMap((p) => p.instance.param.filter((x) => x.key === "urls"))
  .flatMap((x) => x.value.listItem.map((li) => li.string))
if (urls.join() !== ALLOWED_SCRIPT_URLS.join()) {
  fail(`inject_script allowlist is ${JSON.stringify(urls)}; expected ${JSON.stringify(ALLOWED_SCRIPT_URLS)}`)
} else {
  ok(`inject_script allowlist pinned to ${urls.join(", ")}`)
}

// Every URL the sandboxed JS injects must be covered by that allowlist, or the
// tag fails at runtime in the customer's browser rather than here.
const js = section("SANDBOXED_JS_FOR_WEB_TEMPLATE")
const injected = [...js.matchAll(/https:\/\/[^'"\s]+/g)].map((m) => m[0])
for (const u of injected) {
  if (!urls.some((pat) => new RegExp("^" + pat.replace(/[.]/g, "\\.").replace(/\*/g, ".*") + "$").test(u))) {
    fail(`the sandboxed JS references ${u}, which the inject_script allowlist does not cover`)
  }
}
ok(`${injected.length} script URL(s) in the JS, all covered by the allowlist`)

// GTM strips data-* attributes and injectScript has no attribute parameter, so
// a data-domain here would be a silent no-op that looks like configuration.
// 🔴 Strip comments first. The JS explains at length why data-domain is NOT
// used, and a naive text search fires on that explanation — a guard that reds
// the build for saying the right thing gets deleted, not obeyed.
const jsCode = js.replace(/\/\*[\s\S]*?\*\//g, "").replace(/(^|[^:])\/\/.*$/gm, "$1")
if (/data-domain/.test(jsCode)) fail("the sandboxed JS sets data-domain; GTM cannot set attributes — use window.pulseConfig")
else ok("no data-* attribute use in the JS (comments excluded)")

const scenarios = (section("TESTS").match(/^- name:/gm) || []).length
if (scenarios < 6) fail(`only ${scenarios} test scenario(s); the suite has shrunk`)
else ok(`${scenarios} test scenarios`)

// LICENSE: the gallery requires an ALL-CAPS filename holding only Apache-2.0.
const licence = readFileSync("LICENSE", "utf8")
if (!/Apache License/.test(licence) || !/Version 2\.0/.test(licence)) fail("LICENSE is not the Apache-2.0 text")
else ok("LICENSE is the Apache-2.0 text")

if (process.exitCode) console.error("\ntemplate.tpl did NOT pass")
else console.log("\ntemplate.tpl passed")
