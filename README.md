# PBIT Deserializer GitHub Action

This GitHub Action deserializes Power BI Template (`.pbit`) files in a pull request by unpacking their contents, renaming and converting files to JSON format, and reformatting JSON files for readability. It is useful for reviewing changes to Power BI templates in a human-readable format, allowing for easier code review and collaboration.

## Features

- Unpacks `.pbit` files in a pull request.
- Converts certain files from UTF-16LE to UTF-8 format.
- Adds the `.json` extension to the converted files.
- Unpacks the `DataMashup` file and renames it.
- Removes binary files from the unpacked directory.
- Reformats JSON files for better readability.

## Usage

To use the PBIT Deserializer GitHub Action in your GitHub repository, you need to create a new workflow file (e.g., `.github/workflows/deserialize-pbit.yml`) with the following content:

```yaml
name: Deserialize PBIT

on:
  pull_request:
    paths:
      - '**/*.pbit'

jobs:
  deserialize:
    runs-on: ubuntu-latest
    steps:
      - name: checkout
        uses: actions/checkout@v3
        with:
          fetch-depth: 0  # OR "2" -> To retrieve the preceding commit.
      - name: Deserialize PBIT files
        run: ${GITHUB_WORKSPACE}/action.sh
        shell: bash
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          PR_NUMBER: ${{ github.event.number }}
      - uses: stefanzweifel/git-auto-commit-action@v4
        with:
          commit_message: Deserialize Power BI files
```
Make sure to include the bash script in the `run` section or place it in a separate file and call it from the workflow.
## Requirements
This action requires the following tools to be installed on the runner:

- `7z`: A file archiver with a high compression ratio. Used for unpacking .pbit files.
- `jq`: A lightweight and flexible command-line JSON processor. Used for reformatting JSON files.

## Contributing
If you'd like to contribute to the development of the PBIT Deserializer GitHub Action, please feel free to submit a pull request, report issues, or suggest new features.

## License
This GitHub Action is released under the MIT License. See the LICENSE file for details.

## Disclaimer
This action is provided "as-is" with no guarantees. Please use it at your own risk. Always review the changes to your `.pbit` files carefully before merging them.
