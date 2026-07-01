function front_matter() {
    return ""
}

function test_case(i, case,   t) {
    t = "@test " shell_quote(case["description"]) " {\n"
    t = t "  " (i == 1 ? "# " : "") "[[ $BATS_RUN_SKIPPED == \"true\" ]] || skip\n"
    t = t "  run gawk -f " solution_file " <<< " shell_quote(case["input"]["name"]) "\n"
    t = t "  assert_success\n"
    t = t "  assert_output " shell_quote(case["expected"]) "\n"
    t = t "}"
    return t
}

function end_matter() {
    return ""
}
