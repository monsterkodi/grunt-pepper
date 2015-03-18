
module.exports = (grunt) ->

    grunt.initConfig
        pkg: grunt.file.readJSON 'package.json'

        salt:
            options:
                dryrun  : false 
                verbose : true
                refresh : false
            coffee:
                files:
                    'asciiHeader' : ['./tasks/*.coffee']
                    'asciiText'   : ['./tasks/*.coffee']
        open:
          npm:
            path: 'https://www.npmjs.com/package/grunt-pepper'
            app: 'Firefox'
            
        watch:
          scripts:
            files: ['tasks/*.coffee']
            tasks: ['build']
        
        shell:
            commit:
                command: 'git add . && git commit -m "some spice"'
            push:
                command: 'git push'
            publish:
                command: 'npm publish'
        
                
    grunt.loadNpmTasks 'grunt-contrib-watch'
    grunt.loadNpmTasks 'grunt-bumpup'
    grunt.loadNpmTasks 'grunt-pepper'
    grunt.loadNpmTasks 'grunt-shell'
    grunt.loadNpmTasks 'grunt-open'

    grunt.registerTask 'build',     [ 'salt' ]
    grunt.registerTask 'default',   [ 'build' ]
    grunt.registerTask 'push',      [ 'shell:commit', 'shell:push' ]
    grunt.registerTask 'publish',   [ 'bumpup', 'push', 'shell:publish', 'open:npm' ]
