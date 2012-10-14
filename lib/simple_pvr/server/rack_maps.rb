map('/')                        { run SimplePvr::Server::AppController                }
map('/api/channels')            { run SimplePvr::Server::ChannelsController           }
map('/api/programmes')          { run SimplePvr::Server::ProgrammesController         }
map('/api/schedules')           { run SimplePvr::Server::SchedulesController          }
map('/api/shows')               { run SimplePvr::Server::ShowsController              }
map('/api/status')              { run SimplePvr::Server::StatusController             }
map('/api/upcoming_recordings') { run SimplePvr::Server::UpcomingRecordingsController }
