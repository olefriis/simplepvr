module SimplePvr
  module Model
    class Recording
      attr_accessor :channel, :show_name, :start_time, :duration, :programme, :conflicting

      def initialize(channel, show_name, start_time, duration, programme=nil)
        @channel = channel
        @show_name = show_name
        @start_time = start_time
        @duration = duration
        @programme = programme
      end

      def expired?
        expired_at(Time.now)
      end
      
      def expired_at(time)
        end_time < time
      end
      
      def conflicting?
        conflicting
      end

      def inspect
        "'#{@show_name}' from '#{@channel.name}' at '#{@start_time}' with duration #{@duration} and programme #{@programme}"
      end

      def ==(other)
        other != nil &&
        other.channel == @channel &&
        other.show_name == @show_name &&
        other.start_time == @start_time &&
        other.duration == @duration &&
        other.programme == @programme
      end
      
      private
      def end_time
        @start_time.advance(seconds: duration)
      end
    end
  end
end