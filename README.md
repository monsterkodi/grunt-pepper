# grunt-pepper

> puts pepper to my coffee

A little tool that parses my coffee-script files before they get translated to javascript.

It replaces log function calls with calls to an alternative log function that receives an
info object as its first argument. The info object contains the file-path, line-number,
class- and method-name of the place where the log occurred.

For example, in a file *./drink/some.coffee* ...
```coffee
class Hello

  sayHello: =>
    # ... it would replace the following log:
    log "hello", "world!"

    # ... with this one:
    _log {file: 'drink/some.coffee', line: 5, class: 'Hello', method: 'sayHello'},
          "hello", "world"

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

## Installation

```shell
npm install grunt-pepper --save-dev
```
## Gruntfile.coffee

```coffee
module.exports = (grunt) ->

  grunt.initConfig

    pepper:
      options:
        dryrun:   false      # if true, no files are written,
                             # just prints what would be done
        verbose:  false      # if true, the parse result is printed to stdout
        quiet:    false      # if true, almost no information is printed
        outdir:   '.pepper'  # directory where the parse results are written to
        type:     '.coffee'  # suffix of the parse result files
        template: '::'       # replaces ::file.json:key:: with value of
                             # property key from object in file.json
                             # set to false to disable templating
        log:      'log'      # original log function that gets replaced
        infoLog:  '_log'     # replacement log function that has info object
                             # as additional first argument
    task:
      files:
        'spiced': [ file(s) ] # will parse all file(s) and write the result
                              # to file '.pepper/spiced.coffee'

  grunt.loadNpmTasks 'grunt-pepper'
```

Have a look at the [Gruntfile](https://github.com/monsterkodi/knix/blob/master/Gruntfile.coffee) of my other [pet project](https://github.com/monsterkodi/knix) if you need another example.
