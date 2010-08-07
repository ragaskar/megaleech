require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb'))


describe Megaleech::GoogleReader do
  before do
    @auth = 'some_auth'
    @user = 'some_user'
    @password = 'some_pass'
  end

  describe 'starred' do

    before do
      @sample_starred_response = fixture('sample_starred.xml')
    end

    it 'should retrieve all starred items' do
      mock_google_reader_starred(@auth, @sample_starred_response)
      reader = Megaleech::GoogleReader.new(@user, @password)
      reader.stub!(:auth => @auth)
      starred = reader.starred
      starred.length.should == 102
      starred.collect { |entry| entry.title }.should include('Cops - 21x35 - Coast to Coast', 'Miami Social - 1x01 - Liar Liar (Indi)')
    end


    it 'should recall with continuation until it gets the number of entries specified' do
      fake_http = mock(Net::HTTP)
      fake_response = mock('response', :body=> @sample_starred_response)
      fake_http.should_receive(:get).with(
        "/reader/atom/user/-/state/com.google/starred",
         {"Authorization"=>"GoogleLogin auth=some_auth"}
      ).and_return(fake_response)
      fake_http.should_receive(:get).with(
        "/reader/atom/user/-/state/com.google/starred?c=CKy72pDxzZsC",
         {"Authorization"=>"GoogleLogin auth=some_auth"}
      ).at_least(4).times.and_return(fake_response)
      Net::HTTP.stub(:new => fake_http)

      reader = Megaleech::GoogleReader.new(@user, @password)
      reader.stub!(:auth => @auth)
      results = reader.starred(:limit => 10)
      #ha, limit is .. not really limited ;)
      results.length.should == 12
    end

    it 'should stop before count is reached if continuation is blank' do
      fake_http = mock(Net::HTTP)

      fake_response = mock('response', :body=> @sample_starred_response)
      fake_response_with_no_continuation =
        mock('response',
             :body=> fixture('sample_starred_no_continuation.xml')
        )
      fake_http.should_receive(:get).exactly(2).times.and_return(fake_response)
      fake_http.should_receive(:get).and_return(fake_response_with_no_continuation)
      Net::HTTP.stub(:new => fake_http)

      reader = Megaleech::GoogleReader.new(@user, @password)
      reader.stub!(:auth => @auth)
      results = reader.starred(:limit => 10)
      results.length.should == 6
    end

    it "if :newer_than is passed, it should only return items newer than the passed date" do
      fake_http = mock(Net::HTTP)
      fake_response = mock('response', :body=> @sample_starred_response)
      fake_http.stub!(:get).and_return(fake_response)
      Net::HTTP.stub(:new => fake_http)
      reader = Megaleech::GoogleReader.new(@user, @password)
      reader.stub!(:auth => @auth)
      results = reader.starred(:newer_than => Time.parse("2010-08-05T15:21:39Z"))
      results.collect(&:title).should == ["Cops - 21x35 - Coast to Coast"]
    end
  end
end