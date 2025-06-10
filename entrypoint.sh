#!/bin/sh -l

version=${1:-4.9.0}
schema_file=tei_all_$version.rng
files=${2:-tei/*.xml}

tmp=/tmp/dracor
validation_log=$tmp/validation.log
files_log=$tmp/validation-files.log
# error_log=$tmp/validation-errors.log


exists() {
    [ -e "$1" ]
}

mkdir -p $tmp

echo "## Validation against TEI $version" >> $GITHUB_STEP_SUMMARY

if exists $files; then
  # echo "### Files" >> $GITHUB_STEP_SUMMARY
  # for f in $files; do
  #   echo "* $f" >> $GITHUB_STEP_SUMMARY
  # done
  echo >> $GITHUB_STEP_SUMMARY
else
  echo "No files found ($files)" >> $GITHUB_STEP_SUMMARY
  echo >> $GITHUB_STEP_SUMMARY
  exit
fi

jing /$schema_file $files > $validation_log
jing_exit_code=$?
cat $validation_log

cat $validation_log | sed  -E 's/(\.xml):[0-9]+:[0-9]+: .+$/\1/i' | sort \
  | uniq > $files_log

if [ $jing_exit_code = 0 ]; then
  echo "All files are valid." >> $GITHUB_STEP_SUMMARY
  echo >> $GITHUB_STEP_SUMMARY
  exit
else
  echo "### Invalid files" >> $GITHUB_STEP_SUMMARY
  for f in $(cat $files_log | sed -E "s|^$PWD/||"); do
    echo "* $f" >> $GITHUB_STEP_SUMMARY
  done
fi

echo "### Errors" >> $GITHUB_STEP_SUMMARY
echo >> $GITHUB_STEP_SUMMARY
echo '```' >> $GITHUB_STEP_SUMMARY
cat $validation_log | sed -E "s|^$PWD/||" >> $GITHUB_STEP_SUMMARY
echo '```' >> $GITHUB_STEP_SUMMARY
echo >> $GITHUB_STEP_SUMMARY

if [ $INPUT_FAIL = "yes" ]; then
  exit $jing_exit_code
fi
