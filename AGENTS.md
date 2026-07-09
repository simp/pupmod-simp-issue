# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`simp-issue` is a small SIMP Puppet module that manages the login banner files
**`/etc/issue`** and **`/etc/issue.net`** on Enterprise Linux systems
(`manifests/init.pp:90-107`). It writes each file as a root-owned `0644` file
and, by default, points `/etc/issue.net` at `/etc/issue` so the two stay in
sync.

The banner content comes from one of three sources, in priority order
(`init.pp:63-79`): an explicit `$content` string, an explicit file `$source`
pointer, or — if neither is given — a named `$profile` resolved through
`simp_banners::fetch()` (provided by the `simp/simp_banners` dependency). The
module ships its own legacy banner text files under `files/issue/` (`default`,
`lite`, `us_doc`, `us_doc_lite`, `us_dod`, `us_noaa`) but the manifest no longer
reads them directly — see the Gotchas.

### Business logic

The module is a single public class; there are no defines and no other classes.

- **`issue` (`manifests/init.pp:42-108`)** — Public entry class (not
  `assert_private()`'d; consumers `include issue`). It calls
  `simplib::assert_metadata($module_name)` first (`init.pp:49`). Parameters
  (`init.pp:42-48`):
  - `$profile` (`String`, default `'default'`) — selects a named banner when
    neither `$content` nor `$source` is set.
  - `$content` (`Optional[String]`, default `undef`) — literal banner text /
    `File` `content` value; highest priority.
  - `$source` (`Optional[Pattern[/^puppet:/, /^file:/, /^http:/]]`, default
    `undef`) — a `File` `source` pointer; used only when `$content` is unset.
  - `$net_link` (`Boolean`, default `true`) — when true, `/etc/issue.net` is
    sourced from `file:///etc/issue` (`init.pp:81-84`).
  - `$net_content` (`Optional[String]`, default `undef`) — content for
    `/etc/issue.net` when `$net_link` is false.

  Control flow and resources:
  - **Legacy profile mapping** (`init.pp:52-59`): `$_valid_profiles` maps the
    six historical profile names (`default`, `lite`, `us_doc`, `us_doc_lite`,
    `us_dod`, `us_noaa`) to their current `simp_banners` names (e.g.
    `default` → `simp`, `us_dod` → `us/department_of_defense`).
  - **Content selection** (`init.pp:63-79`): if `$content` is set, use it (and
    clear `$_source`); elsif `$source` is set, use it (and clear `$_content`);
    else resolve the profile — if `$profile` is a legacy key it is translated
    via `$_valid_profiles`, otherwise `$profile` is passed straight through —
    and fetch the text with `simp_banners::fetch(...)` (`init.pp:72-78`).
  - **`$net_source` selector** (`init.pp:81-84`): `file:///etc/issue` when
    `$net_link`, else `undef`.
  - **Validation** (`init.pp:86-88`): if `$net_link` is false **and**
    `$net_content` is unset, the catalog `fail()`s with "If \"$net_link\" is
    false, \"$net_content\" needs to be provided."
  - `file { '/etc/issue' }` (`init.pp:90-97`) — `0644` root:root, with
    `source => $_source` and `content => $_content`.
  - `file { '/etc/issue.net' }` (`init.pp:99-107`) — `0644` root:root,
    `content => $net_content`, `source => $net_source`,
    `require => File['/etc/issue']`.

### Gotchas / non-obvious details

- **`$content` silently wins over `$source`.** The `@param source` docstring
  says "Cannot be set with $content" (`init.pp:29-31`), but the manifest does
  **not** enforce that — if both are given, `$content` is used and `$source` is
  discarded with no error (`init.pp:63-66`). The only hard validation is the
  `net_link`/`net_content` pair (`init.pp:86-88`).
- **The banner text now comes from `simp_banners`, not this module's own
  `files/`.** `simp_banners::fetch()` is what actually supplies the default
  content (`init.pp:73,76`); the local `files/issue/*` files are legacy leftovers
  that the manifest never references. The unit spec asserts the fetched default
  contains `ATTENTION` (`spec/classes/issue_spec.rb:12-15`), which the local
  `files/issue/default` also happens to contain — but the value comes from the
  dependency at catalog time.
- **`$profile` is not an enum.** It is a plain `String` (`init.pp:43`); unknown
  values are passed verbatim to `simp_banners::fetch()` (`init.pp:76`), so a
  typo surfaces as a `simp_banners` lookup failure, not a Puppet type error.
- **`/etc/issue.net` depends on `/etc/issue`** via `require`
  (`init.pp:106`); the two files are always managed together.
- **Docstring typos left as-is:** "Atmospehric" (`init.pp:20`,
  `REFERENCE.md:47`) and the README's `/ets/issue.net` (`README.md:18`). Cosmetic
  only.

## The `simp_options` / `simplib::lookup` seam

**This module has no `simp_options` / `simplib::lookup` seam.** Unlike most SIMP
modules, `manifests/init.pp` never calls `simplib::lookup('simp_options::*',
...)` and reads no `simp_options::*` toggles. The only `simplib` call is
`simplib::assert_metadata($module_name)` (`init.pp:49`), which validates the OS
against `metadata.json` rather than routing a feature flag. Behaviour is driven
entirely by the class parameters above (and by module-data Hiera if any were
added — there is none today; see Repository layout).

## Dependencies

Module dependencies (from `metadata.json`):

- `simp/simp_banners` `>= 0.1.0 < 2.0.0` — provides `simp_banners::fetch()`, the
  function that supplies the actual banner text (`init.pp:73,76`).
- `simp/simplib` `>= 4.9.0 < 6.0.0` — provides `simplib::assert_metadata`
  (`init.pp:49`).
- `puppetlabs/stdlib` `>= 8.0.0 < 10.0.0` — provides `keys()` (`init.pp:72`).

No optional dependencies are declared (`metadata.json` has no
`simp.optional_dependencies`).

Fixture-only checkouts (from `.fixtures.yml`, cloned for test compilation):
`stdlib`, `simplib`, `simp_banners` — the three runtime deps above, each pulled
from the `simp/` GitHub forks; plus a symlink of this module as `issue`.

Runtime requirement (from `metadata.json` `requirements`): `openvox
>= 8.0.0 < 9.0.0`.

Supported OS matrix (from `metadata.json`): CentOS 9/10; RedHat 8/9/10;
OracleLinux 8/9/10; Rocky 8/9/10; AlmaLinux 8/9/10.

## Repository layout

- `manifests/init.pp` — the sole manifest; the `issue` class (all logic).
- `files/issue/{default,lite,us_doc,us_doc_lite,us_dod,us_noaa}` — legacy banner
  text files. **Orphaned:** the manifest no longer reads them (content now comes
  from `simp_banners::fetch()`); kept for reference/history.
- `metadata.json` — deps, OS matrix, OpenVox requirement.
- `REFERENCE.md` — generated Puppet Strings reference for the `issue` class.
- `README.md` — user-facing overview.
- `spec/classes/issue_spec.rb` — rspec-puppet unit tests (default/profile/
  content/source/net_link permutations, including the `fail()` path).
- `spec/spec_helper.rb`, `spec/spec_helper_acceptance.rb` — test harness
  (puppetsync-managed).
- `spec/acceptance/suites/default/00_default_spec.rb` — beaker acceptance suite:
  applies `class { 'issue': }` and checks apply + idempotence. Nodesets under
  `spec/acceptance/nodesets/` (almalinux/centos/oel/rhel/rocky 8-10).
- No `data/` or `hiera.yaml` — this module ships **no module data**; all
  defaults live in the class signature.
- No `types/`, `lib/`, or `templates/` — no custom data types, Ruby
  types/providers/functions/facts, or ERB/EPP templates. Every custom function
  it uses (`simp_banners::fetch`, `simplib::assert_metadata`, `keys`) comes from
  the dependencies above.
- **Acceptance runs in CI:** `.github/workflows/pr_tests.yml` has an
  `acceptance` job (matrix `almalinux9`, `almalinux10`) whose final step runs
  `bundle exec rake beaker:suites[default,<node>]` under
  `BEAKER_HYPERVISOR=vagrant_libvirt`.

## Common commands

```sh
# Install dependencies
bundle install

# Run all unit tests
bundle exec rake spec

# Run the single class spec
bundle exec rspec spec/classes/issue_spec.rb

# Run specs in parallel (as CI does)
bundle exec rake parallel_spec

# Puppet lint
bundle exec rake lint

# Ruby lint
bundle exec rake rubocop

# Regenerate REFERENCE.md from puppet-strings docstrings
puppet strings generate --format markdown --out REFERENCE.md

# Run the default beaker acceptance suite
bundle exec rake beaker:suites[default]
```

Relevant gem pins (from `Gemfile`): `puppetlabs_spec_helper ~> 8.0.0`,
`simp-rake-helpers ~> 5.24.0`, `simp-rspec-puppet-facts ~> 4.0.0`,
`simp-beaker-helpers ~> 2.0.0`. Rubocop is pinned to `~> 1.88.0`. The Gemfile
loads **both** the `openvox` and `puppet` gems during the migration, defaulting
the tested range to `>= 8 < 9` (`Gemfile:22-32`).

## Conventions

- Preserve the `@summary` / `@param` puppet-strings docstrings on the class —
  they drive `REFERENCE.md`. Regenerate `REFERENCE.md` after changing docs or
  parameters.
- Keep the legacy-profile compatibility map (`$_valid_profiles`,
  `init.pp:52-59`) in sync with `simp_banners` names if you touch it — it exists
  purely for backward compatibility with the old local profile names.
- Prefer delegating banner content to `simp_banners::fetch()` rather than
  re-adding reads of the orphaned `files/issue/*` copies.
- `Gemfile`, `spec/spec_helper.rb`, `spec/spec_helper_acceptance.rb`, and
  `.github/workflows/pr_tests.yml` carry a **puppetsync** notice — they are
  baseline-managed and the next sync overwrites local edits. Push changes to
  those files upstream to the baseline, not here.
- Match the existing 2-space Puppet indentation and aligned-arrow parameter
  style used in `manifests/init.pp`.
