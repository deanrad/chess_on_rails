require File.dirname(__FILE__) + '/../spec_helper'

describe SetsHelper do
  include SetsHelper

  it 'should enumerate sets' do
    available_sets.should include('default')
  end
end
