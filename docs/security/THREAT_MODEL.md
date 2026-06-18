---
title: "Threat Model"
version: 0.1.0
lastUpdated: 2026-06-16
---

# Threat Model

> **Source of truth:** clap-ext (Shared Rust CLI extension library: common subcommands, config flags, error display for clap-based CLIs)
> **Scope:** Public Rust API surface, build-time macros, dependency manifest, CI/CD, distribution

## Assets

1. **Public Rust API (`clap_ext::*`)** — Exported traits, derive macros, error types. Downstream CLIs depend on these signatures. A signature change is a breaking change.
2. **Build-time macros (`#[derive(CliExt)]`)** — Proc macros that emit boilerplate. If mutable, can ship a macro that generates code that calls out to a malicious endpoint at build time.
3. **Dependency manifest (`Cargo.toml`, `Cargo.lock`)** — Pins to specific dep versions. A modified `Cargo.toml` can pull a malicious replacement; `Cargo.lock` is the checksum defense.
4. **CI pipeline (GitHub Actions)** — Builds, tests, and publishes to crates.io. If mutable, can inject backdoors into release artifacts.
5. **Release artifacts (`clap_ext-*.crate`, signatures)** — Published to crates.io. If mutable in transit, downstream consumers fetch a backdoored crate.

## Threats (STRIDE)

| Category | Threat | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| **Spoofing** | An adversary publishes a `clap-ext` fork under a similar name (e.g., `clap_extras`, `clap_extended`) and downstream `cargo add` resolves the wrong crate. | Low | Critical | Releases are published under the canonical crates.io name `clap-ext`. README documents the canonical install. The crate is signed with Sigstore. |
| **Tampering** | A `Cargo.toml` `replace` directive is added to point a dep at a malicious local fork. | Low | Critical | `Cargo.lock` is committed and CI runs `cargo update --locked` on every push. Any `replace` that does not match a `Cargo.lock` entry fails the build. |
| **Repudiation** | A contributor pushes a tagged release and later denies the content. | Low | Medium | All git tags are signed (gitsign, keyless). Releases include the commit SHA in the release body. |
| **Information Disclosure** | A debug or internal API leaks via accidental `pub` export. | Low | Medium | `cargo doc` and `clippy::pub_use_of_private_extern_crate` are wired in CI; accidental exports are flagged. `#![deny(missing_docs)]` enforces doc coverage. |
| **Denial of Service** | A malicious or malformed input to a public function (e.g., a regex with catastrophic backtracking) causes a DoS in a downstream CLI. | Low | Medium | All public functions that take untrusted input validate the input (length, charset, range) and reject patterns that could trigger ReDoS. CI runs `cargo test --release` and `cargo bench` on every push. |
| **Elevation of Privilege** | A malicious Rust dependency in the workspace (e.g., a typosquatted crate) executes arbitrary code at build time. | Low | Critical | `Cargo.lock` is committed; CI runs `cargo audit` on every push. `cargo build --locked` prevents drift. The workspace uses `[patch.crates-io]` only for explicitly audited internal forks. Proc macros run in a sandboxed proc-macro server with `--no-proc-macro` opt-in. |

## Residual Risk and Revision Cadence

The most material residual risk is **typosquatted crates.io name** — if a downstream consumer mistypes the crate name, cargo may resolve to a different crate. The strongest available mitigation is the canonical name documentation in the README + Sigstore signing, but crates.io has no built-in typo defense. The next highest residual is **proc-macro compromise** — a malicious proc-macro runs arbitrary code at build time. This threat model should be revised quarterly (February, May, August, November) or whenever a new public API is added, a new derive macro is introduced, or a new dependency is integrated. The revision trigger is any PR that adds an exported trait, a new derive macro, or a new `proc-macro` dep.
