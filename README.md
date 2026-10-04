# kube-lint-pretty

A single-file Bash wrapper around [KubeLinter](https://github.com/stackrox/kube-linter) that turns its wall of text into a readable report: findings grouped by category, a proportional overview bar, repeated checks collapsed, and the original exit code preserved for CI.

```
insecure-nginx                                                           11 findings
Deployment apps/v1 in default, from test/fixtures/insecure.yaml

██████████████████████████████████████████████████████████████▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░░░░░░░
█ Security 8   ▒ Resources 2   ░ Hygiene 1

Security  8
  NET_RAW capability configuration (2)                       drop-net-raw-capability
  - Container "nginx" adds the forbidden NET_RAW capability.
  - Container "nginx" does not drop NET_RAW.
  Host network namespace enabled                                        host-network
  Workload shares the host network namespace.
  Host process namespace enabled                                            host-pid
  Workload shares the host process namespace.
  Writable root filesystem                                      no-read-only-root-fs
  Container "nginx" does not use a read-only root filesystem.
  Privilege escalation allowed                        privilege-escalation-container
  Container "nginx" permits privilege escalation.
  Privileged container                                          privileged-container
  Container "nginx" runs in privileged mode.
  Container may run as root                                          run-as-non-root
  Container "nginx" is not configured with runAsNonRoot.

Resources  2
  CPU requirements missing                                    unset-cpu-requirements
  Container "nginx" has no CPU request.
  Memory requirements missing                              unset-memory-requirements
  Container "nginx" has no memory limit.

Hygiene  1
  Image uses :latest                                                      latest-tag
  Container "nginx" uses nginx:latest; use an immutable, versioned image tag.

✗ 11 findings in 1 object, exit code 1
```

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
