# tei-validate-action

This GitHub action validates TEI files specified by the `files` input
against various schemas.

## Inputs

### `schema`

The schema to validate. Supported values are:

- `"all"`: The TEI-All schema (default)
- `"dracor"`: The [DraCor schema](https://github.com/dracor-org/dracor-schema)

### `version`

The schema version to validate against. The defaults are `"4.9.0"` for TEI-All
and `"1.0.0-rc.1"` for the DraCor schema.

### `files`

Path or pattern pointing to TEI files to validate. Default `"tei/*.xml"`

### `fatal`

Exit with an error code when validation fails. Default `"yes"`.

If you want to prevent the action from failing even if there are invalid files
set this to `"no"`. This can be useful if you want to run the validation for
informational purposes only without possibly blocking pull requests from being
merged.

## Example usage

```yaml
jobs:
  validate_tei:
    runs-on: ubuntu-latest
    name: Validate TEI documents against TEI-All schema
    steps:
      - name: Checkout
        uses: actions/checkout@v4
      - name: Validate against current TEI-All schema
        uses: dracor-org/tei-validate-action@v2.0.0-beta.1
      - name: Validate against older TEI-All schema
        uses: dracor-org/tei-validate-action@v2.0.0-beta.1
        with:
          version: "4.2.2"
          fatal: "no"
      - name: Validate against current DraCor schema
        uses: dracor-org/tei-validate-action@v2.0.0-beta.1
        with:
          schema: dracor
```

## Testing locally

With docker installed this action can also be run locally. You need to mount
your local TEI files to the `/tei` directory in the docker container:

```sh
docker pull dracor/tei-validate-action:latest
docker run --rm -it -v /path/to/local/tei/dir:/tei dracor/tei-validate-action
```

This validates each XML file in the `/tei` directory against the latest
supported TEI version.

To validate against a different TEI version and/or to validate only specific
files you can pass the version number and a file pattern as input arguments:

```sh
docker run --rm -it -v /path/to/local/tei/dir:/tei \
  dracor/tei-validate-action \
  all \
  '4.2.2' \
  'tei/lessing-*.xml'
```

To output a markdown report you can set the `$VERBOSE` environment variable:

```sh
docker run --rm -it -e VERBOSE=yes -v $PWD/tei:/tei dracor/tei-validate-action
```
