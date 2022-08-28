# tei-validate-action

This GitHub action validates TEI files specified by the `tei-files` input
against the TEI_all schema.

## Inputs

## `tei-version`

The TEI version to validate against. Default `"4.4.0"`.

Supported versions are `4.0.0`, `4.1.0`, `4.2.0`, `4.2.1`, `4.2.2`, `4.3.0` and
`4.4.0`.

## `tei-files`

Path or pattern pointing to TEI files to validate. Default `"tei/*.xml"`

## Example usage

```yaml
jobs:
  validate_tei:
    runs-on: ubuntu-latest
    name: Validate TEI documents against TEI_all schema
    steps:
      - name: Checkout
        uses: actions/checkout@v3
      - name: Validate
        uses: dracor-org/tei-validate-action@v1.0.0
        with:
          tei-version: '4.2.2'


```
## Testing locally

With docker installed this action can also be run locally. Make sure to provide
both the TEI version and a file pattern as input arguments:

```sh
docker build -t tei-validate-action .
docker run --rm -it -v /path/to/local/tei/directory:/tei tei-validate-action '4.4.0' 'tei/*.xml'
```
