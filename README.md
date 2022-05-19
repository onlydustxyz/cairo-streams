<div align="center">
  <h1 align="center">Cairo Streams</h1>
  <p align="center">
    <a href="http://makeapullrequest.com">
      <img alt="pull requests welcome badge" src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg?style=flat">
    </a>
    <a href="https://twitter.com/intent/follow?screen_name=onlydust_xyz">
        <img src="https://img.shields.io/twitter/follow/onlydust_xyz?style=social&logo=twitter"
            alt="follow on Twitter"></a>
    <a href="https://opensource.org/licenses/Apache-2.0"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg"
            alt="License"></a>
    <a href=""><img src="https://img.shields.io/badge/semver-0.0.1-blue"
            alt="License"></a>            
  </p>
  
  <h3 align="center">Array stream library written in pure Cairo</h3>
</div>

## Usage

> ## ⚠️ WARNING! ⚠️
>
> This repo contains highly experimental code.
> Expect rapid iteration.
> **Use at your own risk.**

As this library is written in pure Cairo, without hint, you can use it in your StarkNet contracts without any issue.

### Set up the project

#### Requirements

- [Protostar](https://github.com/software-mansion/protostar) >= 0.2.0
- [Python <=3.8](https://www.python.org/downloads/)

#### 📦 Install

```bash
protostar install
python -m venv env
source env/bin/activate
pip install -r requirements.txt
```

### ⛏️ Compile

```bash
make
```

## Testing

```bash
make test
```
