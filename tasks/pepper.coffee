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

    if not options.quiet
        cursor.hex('#444444')
        cursor.write('       ' + f + ' ').reset()

    info = { file: f }

    for li in [0...lines.length]
        info.line = li+1
        line = lines[li]

        if options.tag
            regexp = /(^\s*class\s+)(\w+)(\s?.*$)/
            if m = line.match(regexp)
                info.class = m[2]
                if not options.quiet
                    cursor.green()
                    cursor.write('\n        '+info.class+' ')

            if m = line.match(/(\@)?(\w+)\s*\:\s*(\([^)]*\))?\s*[=-]\>/)
                info.args = ( a.trim() for a in m[3].slice(1,-1).split(',') ) if m[3]
                info.method = m[2]
                info.type = m[1] or '.'
                if options.verbose
                    cursor.hex(info.type == '@' and '#333333' or '#777777')
                    cursor.write('\n             '+info.type+' '+info.method+' '+info.args)

        if options.log
            regexp = new RegExp('(^[^#]*\\s)(' + options.log + ')(\\s.*$)')
            if m = line.match(regexp)

                if options.infoLog
                    lines[li] = line.replace regexp, "$1" + options.infoLog + " " + JSON.stringify(info) + ", $3"
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
              infoLog:  '_log'        # replacement log function that gets peppered with one additional argument
                                      #       object with keys: file, line, method, type, args
              tag:      '_tag'

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
