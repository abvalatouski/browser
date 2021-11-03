# Working with the default browser

The script is targeted on Windows 10.

Supported browsers are:

- Brave;

- Chrome;

- Edge;

- Firefox;

- IE;

- Opera.

## Quick Start

### Installation

```console
powershell -c "Invoke-WebRequest -Outfile browser.bat -Uri https://raw.githubusercontent.com/abvalatouski/browser/master/browser.bat"
```

### Running

```console
browser /?
```

## Goals

- [ ] Implement `open` subcommand for supported browsers properly.
- [ ] Fix invalid PID in `open` subcommand.
