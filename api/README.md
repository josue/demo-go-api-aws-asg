## Golang REST API

A simple Golang REST API.
- Route: `/` - Simple JSON response with `message` & timestamp.
- Route: `/health` - Health outputs `"ok - {hostname}"` & timestamp.

----

## 📦 Requirements:

- Git 2.1+
- Golang 1.10+

Homebrew: `brew install git go`

_(This has been tested on MacOS v10.14 - Mojave)_

----

## 👷 Setup App ➠ 💾 Compile

Makefile targets:

- Run: `make run`
- Test: `make test`
- Build (native): `make build`
- Build for linux: `make linux`