
task :build do
  sh 'grunt haml'
end


task :dist do
  puts "Copy vizbuilder files into Drupal module"
  cp_r 'dist', '../dev.communitydata.p/sites/all/modules/custom/vizshare/vizbuilder'
end

task :default => 'dist'
