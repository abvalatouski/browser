# Working with the default browser

The script is targeted on Windows 10.

## Quick Start

### Installation

```console
powershell -c "Invoke-WebRequest -Outfile browser.bat -Url https://raw.githubusercontent.com/abvalatouski/browser/master/browser.bat"
```

### Running

```console
browser /?
browser path /d /p /e
```

## Goals

- [ ] Test `path` subcommand with:
  - [x] Chrome;
  - [ ] Edge (the Registry may provide path to `LaunchWinApp`);
  - [x] IE;
  - [x] Firefox;
  - [ ] Go (the Registry provides incorrect path);
  - [x] Opera.
- [ ] Test `open` subcommand with;
  - [x] Chrome;
  - [ ] Edge;
  - [ ] IE;
  - [ ] Firefox;
  - [ ] Go;
  - [ ] Opera.
- [ ] Add support for other browsers.
