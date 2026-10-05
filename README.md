# kube-lint-pretty

A single-file Bash wrapper around [KubeLinter](https://github.com/stackrox/kube-linter) that turns its wall of text into a readable report: findings grouped by category, a proportional overview bar, repeated checks collapsed, and the original exit code preserved for CI.

<img width="873" height="801" alt="image" src="https://github.com/user-attachments/assets/d531d8c3-d0f9-4c20-83bd-bde8d4abd638" />


## Requirements

- **`kube-linter` must be installed and in your `PATH`.** Developed and tested against 0.8.3 ([releases](https://github.com/stackrox/kube-linter/releases), or `brew install kube-linter`). Override the binary with `KUBE_LINTER=/path/to/kube-linter`.

## Install

It is a single file. Pick one:

```sh
# system-wide
sudo curl -fsSL -o /usr/local/bin/kube-lint-pretty \
  https://raw.githubusercontent.com/shushyu/kube-lint-pretty/main/kube-lint-pretty \
  && sudo chmod +x /usr/local/bin/kube-lint-pretty
```

## Usage

```sh
kube-lint-pretty insecure.yaml
kube-lint-pretty ./manifests/
kube-lint-pretty --config .kube-linter.yaml ./helm-chart/
```
