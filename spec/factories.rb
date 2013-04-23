FactoryGirl.define do
  factory :player do |p|
    p.active true
    p.name { Faker::Name.first_name }
  end
  
  factory :match do
    players { [FactoryGirl.create(:player), FactoryGirl.create(:player)] }
  end
  
  factory :gameplay do
  end
end
