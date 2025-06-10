#!/bin/sh -l

exists() {
    [ -e "$1" ]
}

# default versions
TEI_VERSION="4.9.0"
DRACOR_VERSION="1.0.0-rc.1"

schema=${1:-all}

echo "::debug::input schema: $INPUT_SCHEMA"
echo "::debug::input version: $INPUT_VERSION"

if [ $schema = "all" ]; then
  version=${2:-$TEI_VERSION}
  schema_title="TEI-All $version"
  schema_file=/tei_all_$version.rng
  url="https://tei-c.org/Vault/P5/$version/xml/tei/custom/schema/relaxng/tei_all.rng"
elif [ $schema = "dracor" ]; then
  version=${2:-$DRACOR_VERSION}
  schema_title="DraCor schema $version"
  schema_file=/dracor_$version.rng
  url="https://github.com/dracor-org/dracor-schema/releases/download/v$version/dracor-schema-v$version.rng"
else
  echo "::error::Unsupported schema '$schema'"
  exit
fi

if [ ! -f $schema_file ]; then
  [ "$VERBOSE" = "yes" ] && echo "Downloading $schema_file $url"
  curl -Lsfo $schema_file $url
  if [ $? > 0 ]; then
    echo "::error::Failed to fetch schema $url"
    exit
  fi
else
  [ "$VERBOSE" = "yes" ] && echo "Schema $schema_file exists"
fi

files=${3:-tei/*.xml}

tmp=/tmp/dracor
validation_log=$tmp/validation.log
files_log=$tmp/validation-files.log

if [ -z "$GITHUB_STEP_SUMMARY" ]; then
  # if we are not on GitHub write summary to our own temporary file
  summary=$tmp/summary.md
else
  summary=$GITHUB_STEP_SUMMARY
fi

mkdir -p $tmp

echo "## Validation against $schema_title" >> $summary

if exists $files; then
  echo >> $summary
else
  echo "No files found ($files)" >> $summary
  echo >> $summary
  exit
fi

jing $schema_file $files > $validation_log
jing_exit_code=$?

cat $validation_log | sed  -E 's/(\.xml):[0-9]+:[0-9]+: .+$/\1/i' | sort \
  | uniq > $files_log

if [ $jing_exit_code = 0 ]; then
  echo "All files are valid." >> $summary
  echo >> $summary
  exit
else
  echo "### Invalid files\n" >> $summary
  for f in $(cat $files_log | sed -E "s|^$PWD/||"); do
    echo "* $f" >> $summary
  done
fi

echo "\n### Errors" >> $summary
echo >> $summary
echo '```' >> $summary
cat $validation_log | sed -E "s|^$PWD/||" >> $summary
echo '```' >> $summary
echo >> $summary

# output validation results to console
if [ ! "$VERBOSE" = "yes" ]; then
  cat $validation_log
elif [ -z "$GITHUB_STEP_SUMMARY" ]; then
  # if we are not on GitHub dump the summary
  cat $summary
fi

if [ "$INPUT_FATAL" = "yes" ]; then
  exit $jing_exit_code
fi
