#!/usr/bin/env bats
load bats-extra

# generated on 2026-07-01 00:16:50

@test 'no name given' {
  # [[ $BATS_RUN_SKIPPED == "true" ]] || skip
  run gawk -f two-fer.awk <<< ""
  assert_success
  assert_output 'One for you, one for me.'
}

@test 'a name given' {
  [[ $BATS_RUN_SKIPPED == "true" ]] || skip
  run gawk -f two-fer.awk <<< 'Alice'
  assert_success
  assert_output 'One for Alice, one for me.'
}

@test 'another name given' {
  [[ $BATS_RUN_SKIPPED == "true" ]] || skip
  run gawk -f two-fer.awk <<< 'Bob'
  assert_success
  assert_output 'One for Bob, one for me.'
}
