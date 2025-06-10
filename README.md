# tei-validate-action

This GitHub action validates TEI files specified by the `tei-files` input
against the TEI_all schema.

## Inputs

### `tei-version`

The TEI version to validate against. Default `"4.9.0"`.

Supported versions are `4.0.0`, `4.1.0`, `4.2.0`, `4.2.1`, `4.2.2`, `4.3.0`,
`4.4.0`, `4.5.0`, `4.6.0`, `4.7.0`, `4.8.0` and `4.9.0`.

### `tei-files`

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
    name: Validate TEI documents against TEI_all schema
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Validate against older schema
        uses: dracor-org/tei-validate-action@v1.2.0
        with:
          tei-version: "4.2.2"
          fatal: "no"
      - name: Validate against current schema
        uses: dracor-org/tei-validate-action@v1.2.0
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
  '4.2.2' \
  'tei/lessing-*.xml'
```

To output a markdown report you can set the `$VERBOSE` environment variable:

```sh
docker run --rm -it -e VERBOSE=yes -v $PWD/tei:/tei dracor/tei-validate-action
```
