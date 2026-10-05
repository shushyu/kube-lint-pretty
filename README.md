# kube-lint-pretty

A single-file Bash wrapper around [KubeLinter](https://github.com/stackrox/kube-linter) that turns its wall of text into a readable report: findings grouped by category, a proportional overview bar, repeated checks collapsed, and the original exit code preserved for CI.

<img width="873" height="801" alt="image" src="https://github.com/user-attachments/assets/d531d8c3-d0f9-4c20-83bd-bde8d4abd638" />


## Requirements

- **`kube-linter` must be installed and in your `PATH`.** Developed and tested against 0.8.3 ([releases](https://github.com/stackrox/kube-linter/releases), or `brew install kube-linter`). Override the binary with `KUBE_LINTER=/path/to/kube-linter`.
- Bash 3.2+ (the macOS default works), plus `awk`, `sed`, `sort`, `cut`, `uniq`, `wc`, `tr`, `mktemp`, `tput`. Linux, macOS and WSL.

## Install

It is a single file. Pick one:

```sh
# system-wide
sudo curl -fsSL -o /usr/local/bin/kube-lint-pretty \
  https://raw.githubusercontent.com/shushyu/kube-lint-pretty/main/kube-lint-pretty \
  && sudo chmod +x /usr/local/bin/kube-lint-pretty

# or without sudo (make sure ~/.local/bin is in PATH)
mkdir -p ~/.local/bin \
  && curl -fsSL -o ~/.local/bin/kube-lint-pretty \
  https://raw.githubusercontent.com/shushyu/kube-lint-pretty/main/kube-lint-pretty \
  && chmod +x ~/.local/bin/kube-lint-pretty

# or from a clone
git clone https://github.com/shushyu/kube-lint-pretty && cd kube-lint-pretty
sudo make install                    # or: make install PREFIX="$HOME/.local"
```

Pin a version by replacing `main` with a tag (e.g. `v1.0.0`) in the URL.

## Usage

```sh
kube-lint-pretty insecure.yaml
kube-lint-pretty ./manifests/
kube-lint-pretty --config .kube-linter.yaml ./helm-chart/
```

All arguments are passed to `kube-linter lint` unchanged.

| Variable | Effect |
|---|---|
| `NO_COLOR=1` | no ANSI colors |
| `FORCE_COLOR=1` | colors even when stdout is not a TTY (CI logs) |
| `NO_UNICODE=1` | ASCII fallback (`[FAIL]`, `#=+-` bar). Also automatic when the locale is not UTF-8 |
| `KLP_FIX=1` | show the remediation once per check |
| `KLP_RAW=1` | print the original kube-linter output instead |
| `KUBE_LINTER` | path/name of the kube-linter binary |

Output width follows the terminal (`tput cols`, else `$COLUMNS`), clamped to 40-84 columns.

## Exit codes and CI

The exit code is exactly the one from `kube-linter` (0 clean, 1 findings, other = tool/usage error; 127 if the binary is missing) and is printed in the footer. Colors are off when stdout is not a TTY. If kube-linter fails without any parsable finding (missing file, bad flag), its original output goes to stderr and no findings are invented. If the parsed count differs from kube-linter's own count, a note is written to stderr.

GitLab CI example:

```yaml
kubelint:
  script:
    - FORCE_COLOR=1 kube-lint-pretty manifests/
```

## Development

```sh
make lint   # shellcheck
make test   # integration tests, needs kube-linter in PATH
```

## License

MIT
