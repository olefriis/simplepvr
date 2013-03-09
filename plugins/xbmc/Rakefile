directory 'output'

desc 'Package XBMC plug-in'
task :package => 'output' do
  zip_file_name = 'output/plugin.video.simplepvr.zip'
  File.delete zip_file_name if File.exists? zip_file_name
  `zip -r #{zip_file_name} plugin.video.simplepvr`
end

task :default => ['package']