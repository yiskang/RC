---
name: fix-lockfile-registry
description: Rewrites npm package-lock.json "resolved" URLs that point at Autodesk's internal Artifactory npm mirror (npm.autodesk.com) back to the public https://registry.npmjs.org/. Use this whenever a package-lock.json was generated or updated while on Autodesk's corporate VPN (which forces npm through the internal Artifactory mirror) and the repo is public-facing or open source — the internal hostname must never end up committed. Also trigger when the user mentions npm.autodesk.com, Artifactory, npm-remote, an internal registry mirror leaking into a lockfile, or asks to "sanitize", "clean up", or "fix the registry URLs" in a package-lock.json before committing/pushing.
---

# Fix lockfile registry

## Why this exists

Autodesk's corporate network routes npm through an internal Artifactory mirror
(configured via `~/.npmrc`) because the public npm registry isn't reachable over
the VPN. That mirror is a pure passthrough of `registry.npmjs.org` — identical
packages, identical tarballs, just a different URL prefix. Whenever `npm install`
or `npm update` runs on that network, the resulting `package-lock.json` bakes in
`resolved` fields pointing at the internal host. In a public or open-source repo
that's an infrastructure leak, and it should never be committed.

Because the mirror is a byte-for-byte passthrough, fixing this is a safe, purely
textual rewrite — no network access to the public registry is required, and no
package content changes. Don't try to solve this by repointing `.npmrc` at the
public registry; that breaks `npm install` entirely on the VPN. Rewrite the
lockfile after the fact instead.

## What to do

1. Locate the `package-lock.json` that needs fixing (ask the user if it's ambiguous,
   otherwise default to one in the current working directory or the repo root).
2. Run the bundled script against it:

   ```bash
   node <skill_dir>/scripts/rewrite-lockfile-registry.cjs <path-to-package-lock.json>
   ```

   If no path is given, it defaults to `./package-lock.json`.
3. Report what the script printed: how many `resolved` URLs were rewritten, or
   that the file was already clean.
4. If anything changed, remind the user to review the diff before committing —
   it should only touch `resolved` fields, nothing else.

## What the script does

It only rewrites URLs with the exact prefix
`https://npm.autodesk.com/artifactory/api/npm/npm-remote/`, replacing it with
`https://registry.npmjs.org/` and leaving the rest of the path (package name,
version, tarball filename) untouched. It deliberately does **not** touch any
other registry prefix — in particular, an internal `@adsk`-scoped package
registry is a *different* Artifactory repo serving genuinely internal packages,
and those URLs should stay as-is. If a project ever needs a different or
additional internal-prefix mapping, pass it explicitly:

```bash
node <skill_dir>/scripts/rewrite-lockfile-registry.cjs <path> --from=<internal-prefix> --to=<public-prefix>
```
