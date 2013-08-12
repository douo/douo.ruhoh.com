require 'rack'
# require 'rack-livereload'
require 'ruhoh'
#require 'raven'

# use Rack::LiveReload

# run Ruhoh::Program.preview

# To preview your blog in "production" mode:
#use Raven::Rack

#raven:test[https://public:secret@app.getsentry.com/3825]

run Ruhoh::Program.preview(:env => 'development')