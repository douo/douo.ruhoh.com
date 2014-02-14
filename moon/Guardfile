# Guardfile. More info at https://github.com/guard/guard#readme
# required gems: guard, guard-haml, guard-sass, guard-coffeescript

# variable to switch themes:
theme = "moon"

puts ""
puts "===> guard will watch the theme stored in "+theme+" <==="
puts ""

guard 'haml', :input => theme+'/abstractions/layouts-haml', :output => theme+'/layouts', :all_on_start => true do
  watch(/^.+(\.html\.haml)/)
end
