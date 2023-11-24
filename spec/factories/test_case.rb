FactoryBot.define do
  factory :test_case do
    name { 'Test' }
    classname { 'spec.requests.some_spec' }
    file { './spec/requests/some_spec.rb' }
    time { 0.1 }
    test_run
  end
end
