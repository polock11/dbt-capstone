# airstats

dbt project that builds cleaned airport and runway tables in Snowflake from the raw `airports`, `airport_comments`, and `runways` tables.

Layers: `bronze` (ephemeral renames) → `sliver` (tables and one incremental model) → `snapshots` (SCD2 history of the silver airports and runways).

## Running the project

```bash
dbt build      # run models, tests, and snapshots in DAG order
dbt run        # models only
dbt test       # data tests only
dbt snapshot   # snapshots only
```

Commands run from this directory (`airstat/`). Connection settings are in `profiles.yml`.

## Documentation

dbt builds a documentation site from the YAML files in `models/` and `snapshots/` (descriptions and column docs), the SQL itself, and the Snowflake catalog.

### Generate the docs

```bash
dbt docs generate
```

This does two things:

- Compiles the project into `target/manifest.json`, `target/index.html`, and related files. Descriptions and tests are read from the YAML at this step.
- Queries Snowflake for table and column metadata and writes `target/catalog.json`. This needs a working connection, the same one `dbt run` uses.

Run it again whenever you change a description, add a column, or rebuild models, so the site reflects the current state.

### Serve the docs

```bash
dbt docs serve
```

This starts a local web server (default port 8080) and opens the site in your browser. Use `dbt docs serve --port 8081` if 8080 is taken, or `--no-browser` to skip opening the browser. Stop the server with Ctrl+C.

The site has these sections:

- **Models and snapshots**: each with its description, columns, and tests.
- **Sources**: the three raw tables in the `raw` schema.
- **Lineage graph**: the DAG from sources through bronze and silver to snapshots.

### Where to edit documentation

| What | Where |
| --- | --- |
| Model and column descriptions, column tests | `models/schema.yml` |
| Source and source column descriptions | `models/sources.yml` |
| Snapshot descriptions and column docs | `snapshots/scd_silver_*.yml` |

Descriptions use plain Markdown. Use `{{ doc('name') }}` to reuse a block from a `.md` file if a description is needed in several places.

## Resources

- [dbt docs](https://docs.getdbt.com/docs/introduction)
- [dbt Discourse](https://discourse.getdbt.com/)
- [dbt Community Slack](https://community.getdbt.com/)
- [dbt blog](https://blog.getdbt.com/)
