require 'simple_pvr/xmltv_reader'

describe SimplePvr::XmltvReader do
  before do
    @xmltv_reader = SimplePvr::XmltvReader.new
  end
  
  it 'reads the channel information' do
    data = @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programs.xmltv'))
    
    data.channels.length.should == 2
    data.channels[0].id.should == 'www.ontv.dk/tv/1'
    data.channels[0].name.should == 'DR1 DK'
    data.channels[0].icon_url.should == 'http://ontv.dk/imgs/epg/logos/dr1_big.png'
  end
end