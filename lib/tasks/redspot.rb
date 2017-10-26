# Rakefile
desc "Build the Redspot"
task :redspot_build do
  Dir.chdir(File.expand_path("../../../redspot_vuejs", __FILE__))
  sh 'npm install && npm run build'
  puts "Now built, enjoy"
end
