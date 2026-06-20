# justfile — clap-ext
# https://github.com/casey/just
#
# Run `just` (no args) to list available recipes. All recipes use
# `set -euo pipefail` semantics via `set shell` and a strict shell.
#
# CI parity: every recipe here must mirror what `.github/workflows/*.yml`
# runs, so a developer can reproduce CI locally with `just ci`.

set shell        := ["bash", "-eu", "-o", "pipefail", "-c"]
set dotenv-load  := true
set positional-arguments

# Default recipe — list available recipes.
default:
    @just --list

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

# Debug build of the workspace.
build:
    cargo build --workspace --all-targets

# Release build of the workspace.
build-release:
    cargo build --workspace --release --locked

# ---------------------------------------------------------------------------
# Test
# ---------------------------------------------------------------------------

# Run the full test suite.
test:
    cargo test --workspace --all-targets

# Run tests without rebuilding from scratch.
test-fast:
    cargo test --workspace --all-targets --no-fail-fast

# ---------------------------------------------------------------------------
# Lint
# ---------------------------------------------------------------------------

# Format check (no writes).
fmt:
    cargo fmt --all -- --check

# Apply formatting fixes.
fmt-fix:
    cargo fmt --all

# Clippy with warnings as errors (matches CI).
lint:
    cargo clippy --workspace --all-targets --all-features -- -D warnings

# ---------------------------------------------------------------------------
# Security
# ---------------------------------------------------------------------------

# Audit dependencies for known advisories.
audit:
    cargo audit

# Enforce license / advisory / source policy via cargo-deny.
deny:
    cargo deny check

# Supply-chain "grade": runs udeps (unused deps) + geiger (unsafe).
grade:
    @echo "==> cargo +nightly udeps --workspace"
    cargo +nightly udeps --workspace || true
    @echo "==> cargo geiger --workspace"
    cargo geiger --workspace --all-features || true

# ---------------------------------------------------------------------------
# Convenience
# ---------------------------------------------------------------------------

# Run everything CI runs, locally.
ci: fmt lint build test audit deny
    @echo "==> just ci: all checks passed"

# Update toolchain components needed by these recipes.
setup:
    rustup component add rustfmt clippy
    cargo install --locked cargo-audit cargo-deny cargo-geiger || true
    rustup toolchain install nightly --profile minimal --component clippy || true
