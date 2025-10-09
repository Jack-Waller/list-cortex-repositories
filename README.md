# list-cortex-repositories

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
Run the script from any directory once it is installed:

```bash
list-cortex-repositories
```

If you prefer not to install it, run the script directly from the repository root:

```bash
./list-cortex-repositories
```

By default the script:
- filters services by the owner tag `mighty-llamas-squad`
- queries `https://api.getcortexapp.com/api/v1/catalog`
- writes the results to `cortex_repos.csv` in the current directory
- prints the repository names to standard output

Optional flags adjust the behaviour:
- `-o <owner-tag>` changes the owner tag used for filtering
- `-f <file>` changes the output file path
- `-u <base-url>` changes the Cortex base uniform resource locator
- `-q` suppresses the repository list on standard output while still writing the file
- `-h` shows the help text

To gather data for several teams, run the script once per owner tag and write each result to a different file.

## Output
The comma separated values file contains the columns `entity name`, `repo name`, and `repo link`. Each row represents a unique Git repository discovered in the Cortex Catalogue for the supplied owner tag. The final line printed by the script confirms how many rows were written so you can quickly confirm the call succeeded.

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
