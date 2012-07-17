require "rexml/document"

module SimplePvr
  class XmltvReader
    def initialize(dao, mapping_to_channels)
      @dao, @mapping_to_channels = dao, mapping_to_channels
    end
    
    def read(input)
      @dao.clear_programmes
      doc = REXML::Document.new input

      doc.elements.each('tv/programme') do |programme|
        process_programme(programme)
      end
    end
    
    private
    def process_programme(programme)
      channel_id = programme.attributes['channel']
      channel = @mapping_to_channels[channel_id]

      add_programme(channel, programme) if channel
    end
    
    def add_programme(channel, programme)
      title = programme.elements['title'].text
      subtitle = programme.elements['sub-title'] ? programme.elements['sub-title'].text : ''
      description = programme.elements['desc'] ? programme.elements['desc'].text : ''
      start_time = Time.parse(programme.attributes['start'])
      stop_time = Time.parse(programme.attributes['stop'])

      @dao.add_programme(channel, title, subtitle, description, start_time, stop_time - start_time)
    end
  end
end