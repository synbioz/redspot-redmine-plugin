# Rakefile

desc "Build the Redspot"
task :build do
  Dir.chdir(File.expand_path("../../../redspot_vuejs", __FILE__))
  sh 'npm install && npm run build'
  puts "Now built, enjoy"
end

desc "Watch & Expose the Redspot at localhost:8080"
task :dev do
  Dir.chdir(File.expand_path("../../../redspot_vuejs", __FILE__))
  sh 'npm run dev'
end