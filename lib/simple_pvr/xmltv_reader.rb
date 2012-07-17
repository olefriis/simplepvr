require "rexml/document"

module SimplePvr
  XmltvResult = Struct.new(:channels, :programmes)
  XmltvChannel = Struct.new(:id, :name, :icon_url)
  XmltvProgramme = Struct.new(:title, :subtitle, :description, :start_time, :duration)

  class XmltvReader
    def read(input)
      
      doc = REXML::Document.new input
      
      XmltvResult.new(read_channels(doc), read_programmes(doc))
    end
    
    private
    def read_channels(doc)
      result = []
      doc.elements.each('tv/channel') do |channel|
        result << XmltvChannel.new(channel.attributes['id'], channel.elements['display-name'].text, channel.elements['icon'].attributes['src'])
      end
      result
    end
    
    def read_programmes(doc)
      result = {}
      doc.elements.each('tv/programme') do |programme|
        channel_id = programme.attributes['channel']
        title = programme.elements['title'].text
        subtitle = programme.elements['sub-title'] ? programme.elements['sub-title'].text : ''
        description = programme.elements['desc'].text
        start_time = Time.parse(programme.attributes['start'])
        stop_time = Time.parse(programme.attributes['stop'])

        result[channel_id] ||= []
        result[channel_id] << XmltvProgramme.new(title, subtitle, description, start_time, stop_time - start_time)
      end
      result
    end
  end
end