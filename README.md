# grunt-pepper

> puts pepper to my coffe

A little tool that parses my coffescript files before they get translated to javascript.

It replaces log calls to include the file-path as well as the line-number as additional arguments.

For example, in a file at *./drink/some.coffee* it would ...
```coffee
# ... replace following log:

log "hello", "world!"

# ... with this one:

_log 'drink/file.coffee', 3, "hello", "world"

```

It can also replace special markers with values from a json file:

```coffee
# ... the following:

@version = '::package.json:version::'

# ... gets replaced by:

@version = '1.2.3'
```

I am pretty new to the coffee-script and grunt world,
so please use at your own risk!

## Getting Started

install the grunt plugin:

```shell
npm install grunt-pepper --save-dev
```

Gruntfile.coffee example:

```coffee
grunt.initConfig

    pepper:
        options:
            dryrun:   false      # if true, no files are written, just prints what would be done
            verbose:  false      # if true, the parse result is printed to stdout
            quiet:    false      # if true, almost no information is printed
            outdir:   '.pepper'  # directory where the parse results are written to
            type:     '.coffee'  # suffix of the parse result files
            template: '::'       # replaces ::file.json:key:: with property key of object in file.json. set to false to disable templating
            log:      'log'      # original log function that gets replaced
            fileLog:  '_log'     # replaced log function that gets peppered with two additional (file-path and line-number) arguments

    task:
        files:
            'spiced': [ file(s) ] # will parse all file(s) and write the result to file '.pepper/spiced.coffee'

    grunt.loadNpmTasks 'grunt-pepper'
```
