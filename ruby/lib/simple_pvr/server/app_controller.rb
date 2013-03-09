module SimplePvr
  module Server
    class AppController < BaseController
      get '/app/*' do |path|
        send_file File.join(settings.public_folder, path)
      end

      get '/*' do
        send_file File.join(settings.public_folder, 'index.html')
      end
    end
  end
end