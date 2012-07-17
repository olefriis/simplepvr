#encoding: UTF-8
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
  
  it 'reads programme information' do
    data = @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programs.xmltv'))
    
    data.programmes['www.ontv.dk/tv/1'].length.should == 5
    noddy = data.programmes['www.ontv.dk/tv/1'][0]
    noddy.title.should == 'Noddy'
    noddy.subtitle.should == 'Bare vær dig selv, Noddy.'
    noddy.description.should == "Tegnefilm.\nHer kommer Noddy - så kom ud og leg! Den lille dreng af træ har altid travlt med at køre sine venner rundt i Legebyen - og du kan altid høre, når han er på vej!"
    noddy.start_time.should == Time.new(2012, 7, 17, 6, 0, 0, "+02:00")
    noddy.duration.should == 10.minutes
  end
end