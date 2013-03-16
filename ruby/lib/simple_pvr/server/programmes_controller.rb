module SimplePvr
  module Server
    class ProgrammesController < BaseController
      get '/title_search' do
        Model::Programme.titles_containing(params['query']).to_json
      end

      get '/search' do
        Model::Programme.with_title_containing(params['query']).map {|programme| programme_hash(programme) }.to_json
      end

      get '/:id' do |id|
        programme = Model::Programme.get(id)
        programme_hash(programme).to_json
      end

      post '/:id/record_on_any_channel' do |id|
        programme = Model::Programme.get(id.to_i)
        Model::Schedule.add_specification(title: programme.title)
        reload_schedules
        programme_hash(programme).to_json
      end

      post '/:id/record_on_this_channel' do |id|
        programme = Model::Programme.get(id.to_i)
        Model::Schedule.add_specification(title: programme.title, channel: programme.channel)
        reload_schedules
        programme_hash(programme).to_json
      end

      post '/:id/record_just_this_programme' do |id|
        programme = Model::Programme.get(id.to_i)
        Model::Schedule.add_specification(title: programme.title, channel: programme.channel, start_time: programme.start_time, end_time: programme.end_time)
        reload_schedules
        programme_hash(programme).to_json
      end

      post '/:id/exclude' do |id|
        programme = Model::Programme.get(id.to_i)
        Model::Schedule.create(type: :exception, title: programme.title, channel: programme.channel, start_time: programme.start_time, end_time: programme.end_time)
        reload_schedules
        programme_hash(programme).to_json
      end
    end
  end
end
