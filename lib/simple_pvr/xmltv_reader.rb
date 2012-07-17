require "rexml/document"

module SimplePvr
  XmltvResult = Struct.new(:channels)
  XmltvChannel = Struct.new(:id, :name, :icon_url)

  class XmltvReader
    def read(input)
      
      doc = REXML::Document.new input
      
      XmltvResult.new(read_channels(doc))
    end
    
    private
    def read_channels(doc)
      result = []
      doc.elements.each("tv/channel") do |channel|
        result << XmltvChannel.new(channel.attributes['id'], channel.elements['display-name'].text, channel.elements['icon'].attributes['src'])
      end
      result
    end
  end
end