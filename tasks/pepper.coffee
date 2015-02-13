#
# grunt-pepper
# https://github.com/monsterkodi/grunt-pepper
#
ansi     = require 'ansi'
cursor   = ansi process.stdout
fs       = require 'fs'

'use strict';

parseFile = (grunt, options, f) ->

    s = grunt.file.read f
    lines = s.split '\n'
    newlines = []

    if not options.quiet
      cursor.red()   if     options.dryrun
      cursor.green() if not options.dryrun
      cursor.write('       ' + f + ' ')

    for li in [0...lines.length]
        line = lines[li]

        regexp = new RegExp('(^[^#]*\\s)(' + options.log + ')(\\s.*$)')
        if m = line.match(regexp)
            lines[li] = line.replace regexp, "$1" + options.fileLog + " '"+f+"', "+(li+1)+", $3"
            if not options.quiet
                cursor.blue().write('.')

        if options.template
            regexp = new RegExp('(^[^#]*)(' + options.template + ')(.+)(' + options.template + ')(.*$)')
            if m = line.match(regexp)
                [jsonFile, key] = m[3].split ':'
                json = fs.readFileSync jsonFile,
                          encoding: 'utf8'
                jsonObj = JSON.parse(json)
                if jsonObj?[key]?
                    lines[li] = line.replace regexp, "$1"+jsonObj[key]+"$5"
                    if not options.quiet
                        cursor.blue().write(':')

    if not options.quiet
        cursor.write('\n').reset()
    lines.join('\n')

module.exports = (grunt) ->

  grunt.registerMultiTask 'pepper', 'puts pepper to my coffe', () ->

    options = @options
              dryrun:   false         # if true, no files are written, just prints what whould be done
              verbose:  false         # if true, the parse result is printed to stdout
              quiet:    false         # if true, almost no information is printed
              outdir:   '.pepper'     # directory where the parse results are written to
              type:     '.coffee'     # suffix of the parse result files
              template: '::'          # replaces ::file.json:key:: with property key of object in file.json. set to false to disable templating
              log:      'log'         # original log function that gets replaced
              fileLog:  '_log'        # replaced log function that gets peppered with two additional (file-path and line-number) arguments

    for file in @files

        cursor.yellow().bold()
              .write(file.dest).write('\n')
              .reset()

        files = (f for f in file.src when grunt.file.exists(f))
        peppered = ( parseFile(grunt, options, f) for f in files ).join('\n')

        if options.verbose
            cursor.reset()
            cursor.write(peppered).write('\n')

        if not options.dryrun
            target = options.outdir + '/' + file.dest + options.type
            grunt.file.write target, peppered

    if options.dryrun
      cursor.red().write('\n !!!!!!!!!!!! this was a dry run !!!!!!!!!!!!\n')
