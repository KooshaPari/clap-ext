# clap-ext — Build system alias (just = make replacement)
set dotenv-load

# default: list recipes
default:
    @just --list

# install
install:
    @echo "TODO: install clap-ext deps"

# build
build:
    @echo "TODO: build clap-ext"

# test
test:
    @echo "TODO: test clap-ext"

# lint
lint:
    @echo "TODO: lint clap-ext"

# format
format:
    @echo "TODO: format clap-ext"

# verify (justfile-verify-in-pre-commit hook gate)
verify:
    @just --evaluate
