#!/bin/sh -l

exists() {
    [ -e "$1" ]
}

version=${1:-4.9.0}
schema_file=tei_all_$version.rng
files=${2:-tei/*.xml}

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

echo "## Validation against TEI $version" >> $summary

if exists $files; then
  echo >> $summary
else
  echo "No files found ($files)" >> $summary
  echo >> $summary
  exit
fi

jing /$schema_file $files > $validation_log
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
