# gitignore Toolkit

[![License: MIT](https://img.shields.io/badge/license-MIT-green.svg)]()
[![Version](https://img.shields.io/badge/version-0.1.1-blue.svg)]()
[![Status](https://img.shields.io/badge/status-active-brightgreen.svg)]()

## Overview

The **gitignore Toolkit** provides a curated library of `.gitignore` templates and a command‑line tool to manage them. It helps teams and developers maintain clean, consistent `.gitignore` files across multiple languages, frameworks, and environments.

This tool simplifies:

- **Creating** new `.gitignore` files using templates
- **Merging** templates into existing `.gitignore` files
- **Replacing** `.gitignore` files safely, with backups
- Case‑insensitive lookup for template names

---

## Features

| Feature                 | Description                                          |
| ----------------------- | ---------------------------------------------------- |
| Template Library        | 20+ `.gitignore` templates stored in version control |
| Insert Mode             | Creates `.gitignore` in the current directory        |
| Merge Mode              | Merges and deduplicates new ignore rules             |
| Replace Mode            | Safely overwrites `.gitignore` with automatic backup |
| Case‑Insensitive Lookup | `latex` resolves `LaTeX.gitignore`, etc.             |

---

## Installation

From the project root:

```bash
./INSTALL -i
```

This installs:

| Component         | Location                                        |
| ----------------- | ----------------------------------------------- |
| Command Script(s) | `$BIN_DIR` (default `/usr/local/bin`)           |
| Template Library  | `$LIB_DIR` (default `/opt/davit/lib/gitignore`) |

To uninstall:

```bash
./INSTALL -u
```

---

## Usage Examples (Terminal)

### Insert a Template

```bash
gitignore.sh -i node
```

Creates a `.gitignore` using `Node.gitignore`.

### Merge a Template

```bash
gitignore.sh -m python
```

Merges and removes duplicates.

### Replace `.gitignore`

```bash
gitignore.sh -r java
```

Backs up existing `.gitignore` to `old.gitignore`.

---

## Template Library Catalog

Templates are stored in:

```
/opt/davit/lib/gitignore/
```

| Template Name (callable) | Actual File      |
| ------------------------ | ---------------- |
| node                     | Node.gitignore   |
| python                   | Python.gitignore |
| latex                    | LaTeX.gitignore  |
| java                     | Java.gitignore   |
| go                       | Go.gitignore     |
| c                        | C.gitignore      |
| cpp                      | C++.gitignore    |
| rust                     | Rust.gitignore   |
| macos                    | macOS.gitignore  |
| vscode                   | VSCode.gitignore |

> Template names are always called **lowercase**, actual filenames retain proper capitalization.

---

## Creating / Updating Templates

1. Copy a similar template:

```bash
cp ./lib/gitignore/Example.gitignore ./lib/gitignore/MyTool.gitignore
```

2. Edit rules.
3. Re-run `./INSTALL -i` to deploy updates.

**Template Guidelines:**

- Include editor/build/cache files
- Do **not** include user‑specific settings or secrets

---

## Troubleshooting / Gotchas

| Issue                                 | Fix                                        |
| ------------------------------------- | ------------------------------------------ |
| Template name not found               | Ensure lowercase call matches catalog keys |
| Duplicate lines appear                | Use merge mode — it auto‑deduplicates      |
| `.gitignore` overwritten unexpectedly | Restore from `old.gitignore` backup        |

---

## Roadmap

- GitHub Actions CI for validation/test
- Template version tracking
- manifest.json metadata system
- Organizational alias management integration
- Integration with SNAPSHOT archiver

---

## License

MIT

---

## Contributing

Pull requests and discussions welcome.
