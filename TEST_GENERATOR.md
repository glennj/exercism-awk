# Building a test generator in AWK

In late June 2026, @IsaacG added the Python3 + Jinja2 test generator scheme to the AWK track, following a successful deployment to the Bash and Jq tracks.

I (@glennj) thought it would be fun to build one in AWK.

## Some design decisions

This thing has to parse the canonical_data.json file.
So we need a JSON parser.

The [`gawkextlib`][gawkextlib] has a [`json`][gawk-json]  module, which can read a JSON string into an awk array.

## Building gawk-json

```sh
for f in gawkextlib-1.0.4.tar.gz  do
    curl --output "$f" -L https://sourceforge.net/projects/gawkextlib/files/"$f"/download
done

tar zxf gawkextlib-1.0.4.tar.gz
cd gawkextlib-1.0.4/
autoreconf -i
autoupdate
./configure --prefix=$HOME/.local
make
make check
make install
cd ..

tar zxf gawk-json-2.1.0.tar.gz
cd gawk-json-2.1.0/
sudo apt install rapidjson-dev
autoreconf -i
autoupdate
./configure --prefix=$HOME/.local
make
make check
make install
```

And then using it: in the local copy of the exercism/awk repo
```sh
export AWKPATH=$PWD/lib
export AWKLIBPATH=$HOME/.local/lib/gawk
gawk '
    @include "arrays"
    @load "json"
    NR == FNR {json_string = json_string $0 "\n"}
    END {
        print json_string
        print "==="
        json::from_json(json_string, data)
        arrays::pprint(data)
    }
' $XDG_CACHE_HOME/exercism/configlet/problem-specifications/exercises/two-fer/canonical-data.json
```

outputs:
```none
{
  "exercise": "two-fer",
  "cases": [
    {
      "uuid": "1cf3e15a-a3d7-4a87-aeb3-ba1b43bc8dce",
      "description": "no name given",
      "property": "twoFer",
      "input": {
        "name": null
      },
      "expected": "One for you, one for me."
    },
    {
      "uuid": "b4c6dbb8-b4fb-42c2-bafd-10785abe7709",
      "description": "a name given",
      "property": "twoFer",
      "input": {
        "name": "Alice"
      },
      "expected": "One for Alice, one for me."
    },
    {
      "uuid": "3549048d-1a6e-4653-9a79-b0bda163e8d5",
      "description": "another name given",
      "property": "twoFer",
      "input": {
        "name": "Bob"
      },
      "expected": "One for Bob, one for me."
    }
  ]
}

===
[cases]    = <an array of length 3>
  [1] = <an array of length 5>
    [input]       = <an array of length 1>
      [name] = <unassigned>
    [property]    = twoFer
    [uuid]        = 1cf3e15a-a3d7-4a87-aeb3-ba1b43bc8dce
    [expected]    = One for you, one for me.
    [description] = no name given
  [2] = <an array of length 5>
    [input]       = <an array of length 1>
      [name] = Alice
    [property]    = twoFer
    [uuid]        = b4c6dbb8-b4fb-42c2-bafd-10785abe7709
    [expected]    = One for Alice, one for me.
    [description] = a name given
  [3] = <an array of length 5>
    [input]       = <an array of length 1>
      [name] = Bob
    [property]    = twoFer
    [uuid]        = 3549048d-1a6e-4653-9a79-b0bda163e8d5
    [expected]    = One for Bob, one for me.
    [description] = another name given
[exercise] = two-fer
```

The `arrays` module is one [I developed for my AWK exercises][glennj-arrays-awk].

## A test generator

So the key thing I've found is that, while gawk has `@include "some_file"`, that module name must be a literal double-quoted string.
You cannot provide a variable name there.

That means that we can put a `generator.awk` module in the exercise `.meta` dir, that dir **must** already be in the AWKPATH environment variable before running the awk script.

And that means we need a shell wrapper to set the environment and then launch gawk.

We have

* `./bin/test-generator` -- shell script, which invokes
* `./bin/test-generator.awk` -- awk script, which includes
* `./exercises/practice/${slug}/.meta/generator.awk`

---

## Conclusion

While it is possible to write a test generator with AWK, it's a bad idea:

* it requires all maintainers to build the gawk-json module
* it requires maintainers to set their AWKLIBPATH environment variable correctly
* the tests are created by building up strings: it's inelegant.
* it requires a shell wrapper script.

My prototype can be found [in git][prototype-commit].

Contrarily, the Python system:

* uses batteries-included python modules
* no user-specific settings are required
* uses a template to write the tests
  * while code-and-data templates can be hard to read, it's better than what I wrote with AWK
* uses one standalone script.
* it's already done and merged.

It was an interesting experiment, but it won't progress beyond that.

[gawkextlib]: https://gawkextlib.sourceforge.net/
[gawk-json]: https://gawkextlib.sourceforge.net/json/json.3am.html
[glennj-arrays-awk]: https://github.com/glennj/exercism.io/blob/main/awk/lib/arrays.awk
[prototype-commit]: https://github.com/exercism/awk/compare/main...glennj:exercism-awk:awk-test-generator?expand=1
