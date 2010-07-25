require File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'spec_helper.rb'))


describe Megaleech::GoogleReader do
  before do
    @sid = 'some_sid'
    @user = 'some_user'
    @password = 'some_pass'
  end

  it 'should login to Google and get a session id when sid is requested' do
    sid = mock_google_reader_login(@user, @password)

    reader = Megaleech::GoogleReader.new(@user, @password)
    reader.sid.should == sid
  end

  it 'should re-raise errors' do
    fake_http = mock(Net::HTTP)
    fake_http.should_receive(:use_ssl=)
    fake_response = mock('response', :body=>'Error=foo')
    fake_http.should_receive(:post).and_return(fake_response)
    Net::HTTP.stub(:new => fake_http)

    lambda { Megaleech::GoogleReader.new(@user, @password).sid }.should raise_error('foo')
  end

  describe 'starred' do

    before do
      @sample_starred_response = fixture('sample_starred.xml')
    end

    it 'should be able to retrieve starred items' do
      mock_google_reader_starred(@sid, @sample_starred_response)
      reader = Megaleech::GoogleReader.new(@user, @password)
      reader.stub!(:sid => @sid)
      starred = reader.starred
      starred.length.should == 2
      starred.collect { |entry| entry.title }.should ==
        ['Cops - 21x35 - Coast to Coast', 'Miami Social - 1x01 - Liar Liar (Indi)']
    end


    it 'should recall with continuation until it gets the number of entries specified' do
      fake_http = mock(Net::HTTP)
      fake_response = mock('response', :body=> @sample_starred_response)
      fake_http.should_receive(:get).with(
        "/reader/atom/user/-/state/com.google/starred",
        {"Cookie"=>"Name=SID;SID=#{@sid};Domain=.google.com;Path=/;Expires=160000000000"}
      ).and_return(fake_response)
      fake_http.should_receive(:get).with(
        "/reader/atom/user/-/state/com.google/starred?c=CKy72pDxzZsC",
        {"Cookie"=>"Name=SID;SID=#{@sid};Domain=.google.com;Path=/;Expires=160000000000"}
      ).at_least(4).times.and_return(fake_response)
      Net::HTTP.stub(:new => fake_http)

      reader = Megaleech::GoogleReader.new(@user, @password)
      reader.stub!(:sid => @sid)
      results = reader.starred(10)
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
      reader.stub!(:sid => @sid)
      results = reader.starred(10)
      results.length.should == 6
    end
  end
end