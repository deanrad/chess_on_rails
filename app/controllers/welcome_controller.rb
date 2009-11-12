class WelcomeController < ApplicationController
  def index; render :text => "Welcome to Chess On Rails at #{HOST}. Sign in at #{sign_in_url}"; end
end
