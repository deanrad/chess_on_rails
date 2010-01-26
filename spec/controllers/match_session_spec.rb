require 'spec/spec_helper'

describe MatchSession do

  controller_name :matches

  it 'should have a reference to match_session in any controller action' do
    @controller.instance_eval{ match_session }.should_not be_nil
  end
end
