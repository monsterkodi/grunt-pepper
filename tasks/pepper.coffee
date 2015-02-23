#
# grunt-pepper
# https://github.com/monsterkodi/grunt-pepper
#
ansi     = require 'ansi'
cursor   = ansi process.stdout
fs       = require 'fs'
path     = require 'path'
_        = require 'lodash'

'use strict';

#__________________________________________________________________________________________________________ pepper file

pepperFile = (grunt, options, f) ->

    s = grunt.file.read f
    lines = s.split '\n'

    if not options.quiet
        cursor.hex('#444444')
        cursor.write('       ' + f + ' ').reset()

    info = { file: f }

    for li in [0...lines.length]
        info.line = li+1
        line = lines[li]

        if options.pepper

            regexp = /(^\s*class\s+)(\w+)(\s?.*$)/
            if m = line.match(regexp)
                info.class = m[2]
                if not options.quiet
                    cursor.green()
                    cursor.write('\n        '+info.class+' ')

            if m = line.match(/^\s{2,6}(\@)?(\w+)\s*\:\s*(\([^)]*\))?\s*[=-]\>/)
                info.args = ( a.trim() for a in m[3].slice(1,-1).split(',') ) if m[3]
                info.method = m[2]
                info.type = m[1] or '.'
                if options.verbose
                    cursor.hex(info.type == '@' and '#333333' or '#777777')
                    cursor.write('\n             '+info.type+' '+info.method+' '+info.args)

            if Array.isArray(options.pepper)
                map = _.zipObject options.pepper, options.pepper
            else
                map = options.pepper

            for key of map
                regexp = new RegExp('(^[^#]*\\s)(' + key + ')(\\s.*$)')
                if m = line.match(regexp)
                    lines[li] = line.replace regexp, "$1" + map[key] + " " + JSON.stringify(info) + ", $3"
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

#__________________________________________________________________________________________________________ grunt tasks

module.exports = (grunt) ->

    grunt.registerMultiTask 'pepper', 'puts pepper to my coffee', () ->

        options = @options
                  dryrun:   false         # if true, no files are written,
                  verbose:  false         # if true, the parse result is printed to stdout
                  quiet:    false         # if true, almost no information is printed
                  outdir:   '.pepper'     # directory where the parse results are written to
                  type:     '.coffee'     # suffix of the parse result files
                  template: '::'          # replaces ::file.json:key:: with value of
                                          #       property key from object in file.json
                                          # set to false to disable templating
                  pepper: ['console.log']
                          # names of functions that get peppered
                          #
                          # if specified as a map:
                          #       key: original function name that gets replaced
                          #       value: replacement function that gets called instead
                          #
                          # if specified as a list:
                          #       preserves the original function names
                          #
                          #  the replacement function receives one additional argument:
                          #       an object with keys: file, line, method, type, args

        for file in @files

            cursor.yellow().bold()
                  .write(file.dest).write('\n')
                  .reset()

            files = (f for f in file.src when grunt.file.exists(f))
            peppered = ( pepperFile(grunt, options, f) for f in files ).join('\n')

            if options.verbose
                cursor.reset()
                cursor.write(peppered).write('\n')

            if not options.dryrun
                target = options.outdir + '/' + file.dest + options.type
                grunt.file.write target, peppered

        if options.dryrun
            cursor.red().write('\n !!!!!!!!!!!! this was a dry run !!!!!!!!!!!!\n')
            
    #_____________________________________________________________________________________

    grunt.registerMultiTask 'salt', 'puts salt to my coffee', () ->

        options = @options
                  dryrun:   false         # if true, no files are written,
                  verbose:  false         # if true, more information is printed to stdout
                  quiet:    false         # if true, almost no information is printed
                  refresh:  false         # if true, all ascii headers will be regenerated
                                          # if false, only empty ascii headers are updated

        for file in @files
            for f in (f for f in file.src when grunt.file.exists(f))
                if file.dest == 'asciiHeader'
                    asciiHeader grunt, options, f

        if options.dryrun
            cursor.red().write('\n !!!!!!!!!!!! this was a dry run !!!!!!!!!!!!\n')

#__________________________________________________________________________________________________________ ascii header

asciiText = (s) ->
    cs = (chars[c.charCodeAt(0) - 97].split('\n') for c in s)
    zs = _.zip.apply(null, cs)
    js = _.map(zs, (j) -> j.join('  '))
    "\n"+js.join('\n')+"\n"

asciiHeader = (grunt, options, f) ->

    s = grunt.file.read f
    lines = s.split '\n'

    if _.startsWith(lines[0], '###')
        for li in [1...lines.length]
            if _.startsWith(lines[li], '###')
                if li == 1 or options.refresh
                    if not options.quiet
                        cursor.hex('#444444').write('creating ascii header for file ' + String(f)).write('\n')
                    base = path.basename f, path.extname(f)
                    ascii = asciiText base
                    if options.verbose
                        cursor.hex('#ff0000').write(ascii).write('\n')
                    salted = _.flatten([lines[0], ascii, lines.splice(li)]).join('\n')
                    if not options.dryrun
                        grunt.file.write f, salted
                        
#__________________________________________________________________________________________________________ ascii font

chars = [ \
"""
\ 0000000 
000   000
000000000
000   000
000   000
""","""
0000000  
000   000
0000000  
000   000
0000000  
""","""
\ 0000000
000     
000     
000     
 0000000
""","""
0000000  
000   000
000   000
000   000
0000000  
""","""
00000000
000     
0000000 
000     
00000000
""","""
00000000
000     
000000  
000     
000     
""","""
\ 0000000 
000      
000  0000
000   000
 0000000 
""","""
000   000
000   000
000000000
000   000
000   000
""","""
000
000
000
000
000
""","""
\      000
      000
      000
000   000
 0000000 
""","""
000   000
000  000 
0000000  
000  000 
000   000
""","""
000    
000    
000    
000    
0000000
""","""
00     00
000   000
000000000
000 0 000
000   000
""","""
000   000
0000  000
000 0 000
000  0000
000   000
""","""
\ 0000000 
000   000
000   000
000   000
 0000000 
""","""
00000000 
000   000
00000000 
000      
000      
""","""
\ 0000000
000   000
000 00 00
000 0000 
 00000 00
""","""
00000000 
000   000
0000000  
000   000
000   000
""","""
\ 0000000
000     
0000000 
     000
0000000 
""","""
000000000
   000   
   000   
   000   
   000   
""","""
000   000
000   000
000   000
000   000
 0000000 
""","""
000   000
000   000
 000 000 
   000   
    0    
""","""
000   000
000 0 000
000000000
000   000
00     00
""","""
000   000
 000 000 
  00000  
 000 000 
000   000
""","""
000   000
 000 000 
  00000  
   000   
   000   
""","""
0000000
   000 
  000  
 000   
0000000
"""
]
