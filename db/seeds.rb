# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
require 'factories'

dean =   FactoryGirl.create(:player, id: 314, name: 'Dean')
paul =   FactoryGirl.create(:player, id: 271, name: 'Paul')
miles =  FactoryGirl.create(:player, id: 111, name: 'Miles')

FactoryGirl.create(:match) # proves default factories work

FactoryGirl.create(:match) do |m|
  white = dean
  black = paul
end

