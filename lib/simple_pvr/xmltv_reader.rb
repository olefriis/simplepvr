require 'nokogiri'

module SimplePvr
  class XmltvReader
    def initialize(dao, mapping_to_channels)
      @dao, @mapping_to_channels = dao, mapping_to_channels
    end
    
    def read(input)
      @dao.clear_programmes
      doc = Nokogiri::XML.parse(input)

      doc.xpath('/tv/programme').each do |programme|
        process_programme(programme)
      end
    end
    
    private
    def process_programme(programme)
      channel_id = programme[:channel]
      channel = @mapping_to_channels[channel_id.to_s]

      add_programme(channel, programme) if channel
    end
    
    def add_programme(channel, programme)
      title_node = programme.xpath('./title')
      subtitle_node = programme.xpath('./sub-title')
      description_node = programme.xpath('./desc')
      
      title = title_node.text
      subtitle = subtitle_node ? subtitle_node.text : ''
      description = description_node ? description_node.text : ''
      start_time = Time.parse(programme[:start])
      stop_time = Time.parse(programme[:stop])

      @dao.add_programme(channel, title, subtitle, description, start_time, stop_time - start_time)
    end
  end
end