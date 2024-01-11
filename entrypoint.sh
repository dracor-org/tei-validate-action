#!/bin/sh -l

version=${1:-4.7.0}
schema_file=tei_all_$version.rng

echo "Validating against TEI $version ($schema_file)..."

jing /$schema_file $2
