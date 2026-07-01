#!/usr/bin/env -S gawk -f
#
# Usage: gawk -f bin/test-generator.awk -v slug=exercise-slug

@load "json"            # found in AWKLIBPATH
@include "assert"       # found in system AWKPATH
@include "readfile"     # found in system AWKPATH
@include "shellquote"   # found in system AWKPATH
@include "arrays"       # found in ./lib
@include "generator"    # found in ./exercises/practice/$slug/.meta

function file_exists(filename,    status, tmp) {
    status = getline tmp < filename
    close(filename)
    assert(status >= 0, "Cannot open " filename)
}

function header(  h) {
    h = "#!/usr/bin/env bats\n"
    h = h "load bats-extra\n"
    h = h "\n"
    h = h "# generated on " strftime("%F %T")
    return h
}

BEGIN {
    assert(slug != "", "Usage: " ARGV[0] " -v slug=exercise-slug")

    # read the canonical data
    cache_dir = ENVIRON["XDG_CACHE_HOME"] ? ENVIRON["XDG_CACHE_HOME"] : (ENVIRON["HOME"] "/.cache")
    canonical_data_file = cache_dir "/exercism/configlet/problem-specifications/exercises/" slug "/canonical-data.json"
    file_exists(canonical_data_file)

    canonical_data_json = readfile(canonical_data_file)
    json::from_json(canonical_data_json, canonical_data)
    #arrays::pprint(canonical_data)

    # read exercise config
    exercise_dir = "./exercises/practice/" slug
    config_file = exercise_dir "/.meta/config.json"
    config = readfile(config_file)
    json::from_json(config, config_json)
    solution_file = config_json["files"]["solution"][1]
    test_file = exercise_dir "/" config_json["files"]["test"][1]

    # generate the test suite
    print header() > test_file
    f = front_matter()
    if (f) print f >> test_file

    for (i = 1; i <= length(canonical_data["cases"]); i++) {
        print "" >> test_file
        print test_case(i, canonical_data["cases"][i]) >> test_file
    }

    e = end_matter()
    if (e) print e >> test_file
    close(test_file)

    exit
}
