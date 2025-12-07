# list-cortex-repositories

[![CI](https://github.com/Jack-Waller/list-cortex-repositories/actions/workflows/ci.yml/badge.svg)](https://github.com/Jack-Waller/list-cortex-repositories/actions/workflows/ci.yml)

`list-cortex-repositories` is a Bash script that queries the Cortex Catalogue and lists every unique Git repository owned by a chosen team. The results are written to a comma separated values file so the data can be shared or analysed easily.

## Requirements
- Bash (tested with version 5)
- `curl`
- `jq`
- `shellcheck` (for linting)
- `bats` (for tests)
- Network access to the Cortex Catalogue application programming interface endpoint used by your organisation

Ensure these commands are installed and available on your command line interface before running the script.

## Authentication
The script requires a Cortex application programming interface token with permission to read Catalogue entities. Set the token in the `CORTEX_API_TOKEN` environment variable. If the variable is not set, the script prompts you to paste the token; the prompt hides the input so the token does not appear in your terminal history. The token is only used for the outbound Cortex requests and is not written to disk.

## Installation
The repository includes a Makefile that copies the script into `/usr/local/bin` so it is available on your command line interface path. Run:

```bash
make setup
```

The command marks the script as executable and copies it to `/usr/local/bin/list-cortex-repositories`. The copy step uses `sudo`, so supply your password when prompted. To remove the installed script later, run:

```bash
make uninstall
```

## Usage
Run the script from any directory once it is installed. Supply the owner tag with the `-o` option:

```bash
list-cortex-repositories -o example-owner-tag
```

You can also set the `CORTEX_OWNER_TAG` environment variable and call the script without the `-o` option:

```bash
CORTEX_OWNER_TAG=example-owner-tag list-cortex-repositories
```

If you prefer not to install it, run the script directly from the repository root:

```bash
./list-cortex-repositories
```

With the required owner tag in place, the script:
- queries `https://api.getcortexapp.com/api/v1/catalog`
- writes the results to `cortex_repos.csv` in the current directory
- prints the repository names to standard output

Optional flags adjust the behaviour:
- `-o <owner-tag>` sets or overrides the owner tag used for filtering (required unless `CORTEX_OWNER_TAG` is set)
- `-c <service-classes>` filters by service classes (comma-separated list); if not provided, all repositories are returned
- `-t <component-types>` filters by component types (comma-separated list) when any value is present in the entity `groups` array
- `-f <file>` changes the output file path
- `-u <base-url>` changes the Cortex base uniform resource locator
- `-q` suppresses the repository list on standard output while still writing the file
- `-h` shows the help text

To gather data for several teams, run the script once per owner tag and write each result to a different file.

## Output
The comma separated values file contains one row per unique Git repository discovered in the Cortex Catalogue for the supplied owner tag. Columns are:

| Column             | Example value                                  | Description                                                   |
|--------------------|------------------------------------------------|---------------------------------------------------------------|
| repo name          | `example-org/example-service`                  | Git repository identifier                                     |
| repo link          | `https://github.com/example-org/example-service`| Normalised repository link                                    |
| entity name        | `example-service`                              | Cortex entity name                                            |
| entity description | `Service that handles bookings`                | Cortex entity description                                     |
| component type     | `tooling;platform`                             | Semicolon-separated list from the entity `groups` array       |
| service class      | `business-class`                               | Value of the `service-class` metadata key, if present         |

The final line printed by the script confirms how many rows were written so you can quickly confirm the call succeeded.

## Troubleshooting
- If the script reports `Error: required command ... not found`, install the missing command and retry.
- If the script reports an authentication error, confirm that your token is valid and has Catalogue read permissions.
- If the output file is empty, confirm that the owner tag exists in Cortex and that its entities have Git repository metadata set.

## Testing

The repository includes automated tests built with [shellcheck](https://www.shellcheck.net/) and [bats](https://bats-core.readthedocs.io/). To run them locally:

```bash
make test
```

The `make test` target lints the script with shellcheck and exercises the bats suite using stubbed Cortex responses, so no real Cortex API token is required.
