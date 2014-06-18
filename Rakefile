
VIZSHARE_MODULE_DIR = '../dev.communitydata.p/sites/all/modules/custom/vizshare'
VIZBUILDER_DIR = VIZSHARE_MODULE_DIR + '/vizbuilder'

task :build do
  sh 'grunt'
  sh 'grunt haml'
end


task :copy do
  puts "Copy vizbuilder files into Drupal module"
  # rm_r VIZBUILDER_DIR if File.exists?(VIZBUILDER_DIR)
  mv VIZBUILDER_DIR, VIZBUILDER_DIR + '_' + Time.now.strftime("%d-%m-%Y-%H-%M")
  cp_r 'dist', VIZSHARE_MODULE_DIR
  mv VIZSHARE_MODULE_DIR + '/dist', VIZSHARE_MODULE_DIR + '/vizbuilder'
  cp_r '.tmp/views', VIZSHARE_MODULE_DIR + '/vizbuilder'
end


task :dist => [:build, :copy] do
end

task :default => 'dist'
