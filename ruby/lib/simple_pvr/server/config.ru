SimplePvr::PvrInitializer.setup
SimplePvr::RecordingPlanner.read

# Due to a lazy initialization bug in ActiveSupport:
# http://stackoverflow.com/questions/5267700/undefined-method-encode-for-activesupportjsonmodule
{:a => :b}.to_json

eval SimplePvr::PvrInitializer.rack_maps_file
