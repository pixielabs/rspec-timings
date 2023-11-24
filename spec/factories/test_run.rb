FactoryBot.define do
  factory :test_run do
    name { 'rspec' }
    tests { 4 }
    skipped { 1 }
    failures { 1 }
    errored { 0 }
    time { 10.00000 }
    timestamp { Time.now }
    hostname { 'testrun' }
    branch { 'master' }
    commit { '00000' }
    project

    after(:create) do |test_run, evaluator|
      FactoryBot.create_list :test_case, 1, test_run: test_run
    end
  end
end
