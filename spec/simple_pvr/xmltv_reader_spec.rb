#encoding: UTF-8
require 'simple_pvr/xmltv_reader'

describe SimplePvr::XmltvReader do
  MockProgramme = Struct.new(:title, :subtitle, :description, :start_time, :duration)

  class MockDao
    attr :programmes

    def clear_programmes
      @programmes = {}
    end
    
    def add_programme(channel, *arguments)
      @programmes[channel] ||= []
      @programmes[channel] << MockProgramme.new(*arguments)
    end
  end
  
  before do
    @dao = MockDao.new
    @xmltv_reader = SimplePvr::XmltvReader.new(@dao, {'www.ontv.dk/tv/1' => 'DR 1'})
  end
  
  it 'populates programme information through the DAO' do
    @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programs.xmltv'))
    
    @dao.programmes['DR 1'].length.should == 5
    noddy = @dao.programmes['DR 1'][0]
    noddy.title.should == 'Noddy'
    noddy.subtitle.should == 'Bare vær dig selv, Noddy.'
    noddy.description.should == "Tegnefilm.\nHer kommer Noddy - så kom ud og leg! Den lille dreng af træ har altid travlt med at køre sine venner rundt i Legebyen - og du kan altid høre, når han er på vej!"
    noddy.start_time.should == Time.new(2012, 7, 17, 6, 0, 0, "+02:00")
    noddy.duration.should == 10.minutes
  end
  
  it 'ignores programmes for channels with no mapping' do
    @xmltv_reader.read(File.new(File.dirname(__FILE__) + '/../resources/programs.xmltv'))

    # There are two channels in the XMLTV file, but only one with a mapping
    @dao.programmes.length.should == 1
  end
end