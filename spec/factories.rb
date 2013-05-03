F = FactoryGirl

F.define do
  factory :player do
    name { Faker::Name.first_name }
    active true
  end
  
  factory :match do
    white { F.create(:player) }
    black { F.create(:player) }
  end
  
end
