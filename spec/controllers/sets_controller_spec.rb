require File.dirname(__FILE__) + '/../spec_helper'

describe SetsController do 

  controller_name 'sets'

  it 'should let you change set' do
    request.env['HTTP_REFERER'] = 'match'
    get :change, :set => 'foo'
    session[:set].should == 'foo'
    response.should be_redirect
  end

end
