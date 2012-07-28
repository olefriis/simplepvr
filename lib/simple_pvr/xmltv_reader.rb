require 'simple_pvr/model/programme'
require 'nokogiri'

module SimplePvr
  class XmltvReader
    def initialize(mapping_to_channels)
      @mapping_to_channels = mapping_to_channels
    end
    
    def read(input)
      Model::Programme.clear
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
      title_node, subtitle_node, description_node = nil
      programme.children.each do |child|
        case child.name.to_s
        when 'title'
          title_node = child
        when 'sub-title'
          subtitle_node = child
        when 'desc'
          description_node = child
        end
      end
      
      title = title_node.text
      subtitle = subtitle_node ? subtitle_node.text : ''
      description = description_node ? description_node.text : ''
      start_time = Time.parse(programme[:start])
      stop_time = Time.parse(programme[:stop])

      Model::Programme.add(channel, title, subtitle, description, start_time, stop_time - start_time)
    end
  end
end