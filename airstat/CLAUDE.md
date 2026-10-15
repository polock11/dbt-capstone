# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository layout

The git repo root is one level up (`dbt-capstone/`), which also holds `pyproject.toml` and `uv.lock` for the Python toolchain (dbt-core/dbt-snowflake 1.11, sqlfluff). The dbt project lives in `airstat/`; run all dbt commands from there.

## Commands

Setup: run `uv sync` from the repo root (Python 3.13). The virtualenv is `../.venv`; activate it or prefix commands with `uv run`.

Run from `airstat/`:

- `dbt run`: build all models
- `dbt test`: run data tests (defined in `models/schema.yml`)
- `dbt snapshot`: run the SCD2 snapshots
- `dbt build`: run, test, and snapshot in DAG order
- Single model: `dbt run --select silver_airports` (add `+` for downstream, e.g. `silver_airports+`)
- Single test: `dbt test --select unique_silver_airports_airport_ident`, or all tests on a model with `dbt test --select silver_runways`
- Rebuild the incremental model from scratch: `dbt run --select silver_airport_comments --full-refresh`

Only the `dev` target exists (profile `airstats`, Snowflake, database `AIRSTATS`, warehouse `COMPUTE_WH`, role `TRANSFORM`). `profiles.yml` is in the project directory and is committed to git; it contains a private key and passphrase, so don't print or copy its contents.

Linting: sqlfluff is installed (`sqlfluff-templater-dbt` is in the dependencies), but no `.sqlfluff` config is committed.

## Architecture

Data flows through three layers, plus snapshots. Schema routing is set by `macros/generate_schema_name.sql`, which uses custom schema names verbatim (`bronze`, `sliver`, `snapshots`) rather than prefixing them with the target schema. As a result, the `dev` target's `schema: DEV` is never used for model output.

- **Sources** (`models/sources.yml`): three raw tables in the `raw` schema (`raw_airports`, `raw_airport_comments`, `raw_runways`).
- **Bronze** (`models/bronze/src_*.sql`): renames raw columns to the silver naming scheme (e.g. `ident` to `airport_ident`, `id` to `comment_id`, `date` to `comment_timestamp`). These are `ephemeral`, so they compile into downstream models as CTEs and create no relations. The `view` default in `dbt_project.yml` is overridden per file.
- **Silver** (`models/sliver/`): the directory is spelled `sliver`, but the models are named `silver_*` and the schema is `sliver`. Keep the spelling consistent with the existing code.
  - `silver_airports` and `silver_runways` are tables. They add `silver_created_at` and default null `member_nickname` / `runway_surface` to `'__UNKNOWN__'`.
  - `silver_airport_comments` is incremental, keyed on `comment_id`. It drops rows with null bodies and, on incremental runs, only loads `comment_id > max(comment_id)`.
- **Snapshots** (`snapshots/scd_silver_*.yml`): YAML-defined `check`-strategy snapshots over the silver tables, keyed on `airport_ident` and `runway_id`, written to the `snapshots` schema. Each snapshot lists its tracked columns in `check_cols`, so update that list when silver columns change.

## Data quality notes

- `silver_airport_comments.airport_ident` has no `relationships` test. About 1,367 comment rows reference airports that aren't in `silver_airports`, so the test fails. It was removed deliberately. Don't re-add it until the source gap is resolved. `silver_runways.airport_ident` keeps its `relationships` test, which passes.
- `airport_type` and `continent` are constrained with `accepted_values` tests. Update those lists in `models/schema.yml` if the source adds values.
