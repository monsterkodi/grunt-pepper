###

00000000   00000000  00000000   00000000   00000000  00000000 
000   000  000       000   000  000   000  000       000   000
00000000   0000000   00000000   00000000   0000000   0000000  
000        000       000        000        000       000   000
000        00000000  000        000        00000000  000   000

### 
## https://github.com/monsterkodi/grunt-pepper

ansi     = require 'ansi'
cursor   = ansi process.stdout
fs       = require 'fs'
path     = require 'path'
_        = require 'lodash'

'use strict';

###
00000000  000  000      00000000
000       000  000      000     
000000    000  000      0000000 
000       000  000      000     
000       000  0000000  00000000
###

pepperFile = (grunt, options, f) ->

    s = grunt.file.read f
    lines = s.split '\n'

    if not options.quiet
        cursor.hex('#444444')
        cursor.write('       ' + f + ' ').reset()

    info = { file: f, class: path.basename f, '.coffee' }
    
    for li in [0...lines.length]
        info.line = li+1
        line = lines[li]

        if options.pepper or options.paprika
            
            regexp = /(^\s*class\s+)(\w+)(\s?.*$)/
            if m = line.match(regexp)
                info.class = m[2]
                if options.verbose
                    cursor.green()
                    cursor.write('\n        '+info.class+' ')

            if m = line.match(/^\s{0,6}(\@)?([\_\.\w]+)\s*[\:\=]\s*(\([^)]*\))?\s*[=-]\>/)
                info.args = ( a.trim() for a in m[3].slice(1,-1).split(',') ) if m[3]
                info.method = m[2]
                info.type = m[1] or '.'
                if options.debug
                    cursor.hex(info.type == '@' and '#333333' or '#777777')
                    cursor.write('\n             '+info.type+' '+info.method+' '+info.args)

            ###
            00000000   00000000  00000000   00000000   00000000  00000000 
            000   000  000       000   000  000   000  000       000   000
            00000000   0000000   00000000   00000000   0000000   0000000  
            000        000       000        000        000       000   000
            000        00000000  000        000        00000000  000   000
            ###

            if options.pepper
                if Array.isArray(options.pepper)
                    map = _.zipObject options.pepper, options.pepper
                else
                    map = options.pepper

                for key of map
                    regexp = new RegExp('(^[^#]*\\s)(' + key + ')(\\s.*$)')
                    if m = line.match(regexp)
                        if options.verbose
                            cursor.white().bold().write('\n').write(lines[li]).reset()                        
                        lines[li] = line.replace regexp, "$1" + map[key] + " " + JSON.stringify(info) + ", $3"
                        if options.debug
                            cursor.blue().write('\n').write(lines[li])
                        cursor.blue().write('.') if not options.quiet

            ###
            00000000    0000000   00000000   00000000   000  000   000   0000000 
            000   000  000   000  000   000  000   000  000  000  000   000   000
            00000000   000000000  00000000   0000000    000  0000000    000000000
            000        000   000  000        000   000  000  000  000   000   000
            000        000   000  000        000   000  000  000   000  000   000
            ###

            if options.paprika
                if Array.isArray(options.paprika)
                    map = _.zipObject options.paprika, options.paprika
                else
                    map = options.paprika

                for key of map
                    regexp = new RegExp('(^[^#]*\\s)(' + key + ')(\\s.*$)')
                    if m = line.match(regexp)
                        if options.verbose
                            cursor.white().bold().write('\n').write(lines[li]).reset()
                        lines[li] = line.replace regexp, "$1" + map[key] + " " + JSON.stringify(info) + ", $3"
                        arglist = (_.trim(a) for a in m[3].split(','))
                        argreg = new RegExp('^[^\\{\\[\\\'\\\"\\d]*$')
                        for i in [arglist.length-1..0]
                            arg = arglist[i]
                            if arg.match argreg
                                arglist.splice i, 0, '"' + options.paprikaPrefix + arg + options.paprikaPostfix + '"'
                        lines[li] = lines[li].replace(m[3], arglist.join(', '))

                        if options.verbose
                            cursor.magenta().write('\n').write(lines[li])
                        cursor.magenta().write('.') if not options.quiet

        ###
        000000000  00000000  00     00  00000000   000       0000000   000000000  00000000
           000     000       000   000  000   000  000      000   000     000     000     
           000     0000000   000000000  00000000   000      000000000     000     0000000 
           000     000       000 0 000  000        000      000   000     000     000     
           000     00000000  000   000  000        0000000  000   000     000     00000000
        ###

        if options.template
            regexp = new RegExp('(^[^#]*)(' + options.template + ')(.+)(' + options.template + ')(.*$)')
            if m = line.match(regexp)
                [jsonFile, key] = m[3].split ':'
                json = fs.readFileSync jsonFile,
                          encoding: 'utf8'
                jsonObj = JSON.parse(json)
                if jsonObj?[key]?
                    lines[li] = line.replace regexp, "$1"+jsonObj[key]+"$5"
                    cursor.blue().write(':') if not options.quiet

    if not options.quiet
        cursor.write('\n')
        cursor.reset()
    lines.join('\n')

###
 0000000   00000000   000   000  000   000  000000000
000        000   000  000   000  0000  000     000   
000  0000  0000000    000   000  000 0 000     000   
000   000  000   000  000   000  000  0000     000   
 0000000   000   000   0000000   000   000     000   
###

module.exports = (grunt) ->

    grunt.registerMultiTask 'pepper', 'puts pepper to my coffee', () ->

        options = @options
                  dryrun:   false         # if true, no files are written,
                  verbose:  false         # if true, the matches are printed to stdout
                  print:    false         # if true, the parse result is printed to stdout
                  quiet:    false         # if true, almost no information is printed
                  join:     true          # if true, source files are joined into one target file
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
                  paprika: ['dbg']
                          # names of functions that get paprikaed :-)
                          #
                          # same as pepper, but the original variable arguments get
                          #                 prefixed by their names. eg.:
                          #  
                          # dbg foo, bar
                          # 
                          # gets replaced by
                          #
                          # dbg {...pepper...}, 'foo:', foo, 'bar:', bar
                  paprikaPrefix:  ''
                  paprikaPostfix: ':'

        for file in @files

            cursor.green().write('>> ' )
            if not options.quiet
                cursor.yellow().bold()
                      .write(file.dest)
                      .write(' ')
                      .reset()
                  
            cursor.write('\n') if not options.quiet

            files = (f for f in file.src when grunt.file.exists(f))
            
            if options.join
                peppered = ( pepperFile(grunt, options, f) for f in files ).join('\n')

                # cursor.write('\n') if not options.quiet

                if options.print
                    cursor.reset()
                    cursor.write(peppered).write('\n')

                if not options.dryrun
                    target = options.outdir + '/' + file.dest + options.type
                    grunt.file.write target, peppered
            else
                for f in files
                    peppered = pepperFile(grunt, options, f)
                    # cursor.write('\n') if not options.quiet
                    if not options.dryrun
                        target = options.outdir + '/' + f
                        grunt.file.write target, peppered                    
                        
            if options.quiet
                cursor.reset().write(' ' + files.length + ' files peppered.\n')

        if options.dryrun
            cursor.red().write('\n !!!!!!!!!!!! this was a dry run !!!!!!!!!!!!\n')
            
    #_____________________________________________________________________________________

    grunt.registerMultiTask 'salt', 'puts salt to my coffee', () ->

        options = @options            #
                                      # 'asciiHeader' options:
                                      #
                  headerStart : "###" #   filename will be put between this ...
                  headerEnd   : "###" #   ... and this marker
                  refresh     : false #   if true: all ascii headers will be regenerated
                                      #   if false: only empty ascii headers are updated
                                      #
                                      # 'asciiText' options:
                                      #
                  textMarker  : "#!!" #   text following this one will be transformed
                  textPrefix  : "###" #   this is put before the replacing lines
                  textFill    : ""    #   each replacing line starts with these characters
                  textPostfix : "###" #   this is put after the replacing lines
                  dryrun      : false # if true: no files are written,
                  verbose     : false # if true: more information is printed to stdout
                  quiet       : false # if true: almost no information is printed
                  character   : null 

        for file in @files
            for f in (f for f in file.src when grunt.file.exists(f))
                if file.dest == 'asciiHeader'
                    asciiHeader grunt, options, f
                else if file.dest == 'asciiText'
                    asciiText grunt, options, f

        if options.dryrun
            cursor.red().write('\n !!!!!!!!!!!! this was a dry run !!!!!!!!!!!!\n')

    #_____________________________________________________________________________________
            
    ###
     0000000  000   000   0000000    0000000   00000000 
    000       000   000  000        000   000  000   000
    0000000   000   000  000  0000  000000000  0000000  
         000  000   000  000   000  000   000  000   000
    0000000    0000000    0000000   000   000  000   000
    ###
            
    grunt.registerMultiTask 'sugar', 'puts sugar to my coffee', () ->
        
        options = @options
                  dryrun:   false         # if true, no files are written,
                  template: '::'          # replaces ::file.json:key:: with value of
                                          #       property key from object in file.json
                
        for file in @files
            files = (f for f in file.src when grunt.file.exists(f))
            for f in files
                
                cursor.green()
                      .write(file.dest)
                      .write(' ')
                      .reset()

                s = grunt.file.read f
                lines = s.split '\n'
                found = false
                
                for li in [0...lines.length]
                    line = lines[li]

                    if options.template
                        regexp = new RegExp('(^[^#]*)(' + options.template + ')(.+)(' + options.template + ')(.*$)')
                        if m = line.match(regexp)
                            [jsonFile, key] = m[3].split ':'
                            json = fs.readFileSync jsonFile,
                                      encoding: 'utf8'
                            jsonObj = JSON.parse(json)
                            if jsonObj?[key]?
                                found = true
                                lines[li] = line.replace regexp, "$1"+jsonObj[key]+"$5"
                                
                if found
                    if options.dryrun
                        cursor.red().write('\n !!!!!!!!!!!! this was a dry run !!!!!!!!!!!!\n')
                    else
                        grunt.file.write file.dest, lines.join('\n')

###
 0000000   0000000   000      000000000
000       000   000  000         000   
0000000   000000000  000         000   
     000  000   000  000         000   
0000000   000   000  0000000     000   
###

asciiLines = (s, options) ->
        s = s.toLowerCase().trim()

        cs = []
        for c in s
            if chars[c]?
                cs.push chars[c]

        zs = _.zip.apply(null, cs)
        rs = _.map(zs, (j) -> j.join('  '))
        if options.character? and options.character.length == 1
            rs = _.map(rs, (l) -> l.replace(/0/g, options.character))
        rs
    
asciiJoin = (l) ->
    "\n"+l.join('\n')+"\n"

asciiHeader = (grunt, options, f) ->

    s = grunt.file.read f
    lines = s.split '\n'

    if _.startsWith(lines[0], options.headerStart)
        for li in [1...lines.length]
            if _.startsWith(lines[li], options.headerEnd)
                if li == 1 or options.refresh
                    if not options.quiet
                        cursor.hex('#444444').write('creating ascii header for file ' + String(f)).write('\n')
                    base = path.basename f, path.extname(f)
                    ascii = asciiJoin asciiLines base, options
                    if options.verbose
                        cursor.hex('#ff0000').write(ascii).write('\n')
                    salted = _.flatten([lines[0], ascii, lines.splice(li)]).join('\n')
                    if not options.dryrun
                        if s != salted
                            grunt.file.write f, salted
    
asciiText = (grunt, options, f) ->
    
    s = grunt.file.read f
    lines = s.split '\n'
    salted = []
    r = new RegExp('^(\\s*)(' + options.textMarker + ")", 'i')
    for li in [0...lines.length]
        if m = lines[li].match(r)
            if not options.quiet
                cursor.hex('#444444').write('creating ascii text in line ' + String(li) + ' in file ' + String(f)).write('\n')
            lns = asciiLines(lines[li].slice(m[1].length+options.textMarker.length), options)
            if options.verbose
                cursor.hex('#ff0000').write(asciiJoin lns).write('\n')
            salted.push m[1] + options.textPrefix if options.textPrefix?
            for l in lns
                salted.push m[1] + (options.textFill? and options.textFill or '') + l
            salted.push m[1] + options.textPostfix if options.textPostfix?
        else
            salted.push lines[li]
    if not options.dryrun
        new_s = salted.join('\n')
        if new_s != s
            grunt.file.write f, new_s
                        
###
00000000   0000000   000   000  000000000
000       000   000  0000  000     000   
000000    000   000  000 0 000     000   
000       000   000  000  0000     000   
000        0000000   000   000     000   
###

chars =
    '0': [
        " 000000 "
        "000  000"
        "00    00"
        "000  000"
        " 000000 "
    ]
    '1': [
        "   000"
        " 00000"
        "000000"
        "   000"
        "   000"
    ]
    '2': [
        "00000 "
        "   000"
        "  000 "
        " 000  "
        "000000"
    ]
    '3': [
        "000000 "
        "    000"
        "  0000 "
        "    000"
        "000000 "
    ]
    '4': [
        "000  000"
        "000  000"
        "00000000"
        "     000"
        "     000"
    ]
    '5': [
        "0000000 "
        "000     "
        "0000000 "
        "     000"
        "0000000 "
    ]
    '6': [
        "  000   "
        " 000    "
        "0000000 "
        "000  000"
        " 000000 "
    ]
    '7': [
        "0000000"
        "   000 "
        "  000  "
        " 000   "
        "000    "
    ]
    '8': [
        " 000000 "
        "000  000"
        "  0000  "
        "000  000"
        " 000000 "
    ]
    '9': [
        " 000000 "
        "000  000"
        " 000000 "
        "   000  "
        "  000   "
    ]
    '!': [
        "000"
        "000"
        "000"
        "   "
        "000"
    ]
    '?' : [
        "00000 "
        "   000"
        " 000  "
        "      "
        " 000  "
    ]
    '-': [
        "      "
        "      "
        "000000"
        "      "
        "      "
    ]
    '_': [
        "      "
        "      "
        "      "
        "      "
        "000000"
    ]
    '/': [
        "    000"
        "   000 "
        "  000  "
        " 000   "
        "000    "
    ]
    '#': [
        " 00  00 "
        "00000000"
        " 00  00 "
        "00000000"
        " 00  00 "
    ]
    '\\': [
        "000    "
        " 000   "
        "  000  "
        "   000 "
        "    000"
    ]
    ':': [
        "000"
        "000"
        "   "
        "000"
        "000"
    ]
    '.': [
        "   "
        "   "
        "   "
        "000"
        "000"
    ]
    ' ': [
        "    "
        "    "
        "    "
        "    "
        "    "
    ]
    'a': [
        " 0000000 "
        "000   000"
        "000000000"
        "000   000"
        "000   000"
    ]
    'b': [
        "0000000  "
        "000   000"
        "0000000  "
        "000   000"
        "0000000  "
    ]
    'c': [
        " 0000000"
        "000     "
        "000     "
        "000     "
        " 0000000"
    ]
    'd': [
        "0000000  "
        "000   000"
        "000   000"
        "000   000"
        "0000000  "
    ]
    'e': [
        "00000000"
        "000     "
        "0000000 "
        "000     "
        "00000000"
    ]
    'f': [
        "00000000"
        "000     "
        "000000  "
        "000     "
        "000     "
    ]
    'g': [
        " 0000000 "
        "000      "
        "000  0000"
        "000   000"
        " 0000000 "
    ]
    'h': [
        "000   000"
        "000   000"
        "000000000"
        "000   000"
        "000   000"
    ]
    'i': [
        "000"
        "000"
        "000"
        "000"
        "000"
    ]
    'j': [

        "      000"
        "      000"
        "      000"
        "000   000"
        " 0000000 "
    ]
    'k': [

        "000   000"
        "000  000 "
        "0000000  "
        "000  000 "
        "000   000"
    ]
    'l': [

        "000    "
        "000    "
        "000    "
        "000    "
        "0000000"
    ]
    'm': [

        "00     00"
        "000   000"
        "000000000"
        "000 0 000"
        "000   000"
    ]
    'n': [

        "000   000"
        "0000  000"
        "000 0 000"
        "000  0000"
        "000   000"
    ]
    'o': [

        " 0000000 "
        "000   000"
        "000   000"
        "000   000"
        " 0000000 "
    ]
    'p': [

        "00000000 "
        "000   000"
        "00000000 "
        "000      "
        "000      "
    ]
    'q': [

        " 0000000 "
        "000   000"
        "000 00 00"
        "000 0000 "
        " 00000 00"
    ]
    'r': [

        "00000000 "
        "000   000"
        "0000000  "
        "000   000"
        "000   000"
    ]
    's': [

        " 0000000"
        "000     "
        "0000000 "
        "     000"
        "0000000 "
    ]
    't': [

        "000000000"
        "   000   "
        "   000   "
        "   000   "
        "   000   "
    ]
    'u': [

        "000   000"
        "000   000"
        "000   000"
        "000   000"
        " 0000000 "
    ]
    'v': [

        "000   000"
        "000   000"
        " 000 000 "
        "   000   "
        "    0    "
    ]
    'w': [

        "000   000"
        "000 0 000"
        "000000000"
        "000   000"
        "00     00"
    ]
    'x': [

        "000   000"
        " 000 000 "
        "  00000  "
        " 000 000 "
        "000   000"
    ]
    'y': [

        "000   000"
        " 000 000 "
        "  00000  "
        "   000   "
        "   000   "
    ]
    'z': [

        "0000000"
        "   000 "
        "  000  "
        " 000   "
        "0000000"
    ]
