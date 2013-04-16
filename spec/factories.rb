require "tables_helper"

module FactoryHelpers
  def self.read_bridge(key, good = true)
    path= 'vendor/gems/WPBDC/test/eg/2012'
    unless defined? @@eg_good
      entries = Dir.entries(path).reject { |name| name.start_with?('.') }
      @@eg_good   = entries.reject { |name| name.include? 'failed' }
      @@eg_failed = entries.select { |name| name.include? 'failed' }
    end
    file_name = if good
                  @@eg_good[key % @@eg_good.length]
                else
                  @@eg_failed[key % @@eg_failed.length]
                end
    f = File.open "#{path}/#{file_name}", 'rb'
    if f
      bridge = f.read
      WPBDC.endecrypt(bridge);
      { :bridge => bridge, :analysis => WPBDC.analyze(bridge) }
    end
  end

  def self.next_local_contest_code
    @@code ||= 'AAAA'
    @@code.next!
  end
end

FactoryGirl.define do

  sequence :team_name do |n|
    "Beat Navy #{n}"
  end

  sequence :email do |n|
    "team-#{n}@anywhere.com"
  end

  sequence :team_category do |n|
     ['u', 'n'][n % 2]
  end

  sequence :first_name do |n|
    "Jane#{n}"
  end

  sequence :last_name do |n|
    "Doe#{n}"
  end

  sequence :state do |n|
    TablesHelper.keyed_code_from_pairs(n, TablesHelper::STATE_PAIRS)
  end

  sequence :good_bridge do |n|
    FactoryHelpers.read_bridge(n, true)
  end

  sequence :bad_bridge do |n|
    FactoryHelpers.read_bridge(n, false)
  end

  sequence :phone_number do |n|
    sprintf '(555)555-%04d', n
  end

  factory :local_contest do
    code { FactoryHelpers.next_local_contest_code }
    sequence(:description) {|n| "Local contest #{n}"}
    poc_first_name 'John'
    poc_middle_initial 'Q'
    poc_last_name 'Public'
    poc_position 'Bridge Contest Director'
    organization 'West Virgina'
    city 'Arlington'
    state 'VA'
    zip '123451234'
    phone '1231231234'
    link 'ressler@usma.edu'
  end

  factory :member do
    first_name { generate :first_name }
    middle_initial ''
    last_name { generate :last_name }
    age { 13 + rand(6) }
    grade { age - 6 }
    phone { generate :phone_number }
    sequence(:street) { |n| "#{n} Main Street"}
    city 'Goodtown'
    state { generate :state }
    zip { sprintf "%05d", rand(100000) }
    school { "PS #{1 + rand(1000)}" }
    school_city 'Near Goodtown'
    sex ''
    hispanic ''
    race ''
    category { generate :team_category }
    school_state { state }
    res_state { state }
    team

    trait :non_captain do
      rank 1
    end

    factory :non_captain_member, :traits => [:non_captain]
  end

  factory :team do

    name { generate :team_name }
    password 'foobarbaz'
    password_confirmation { password }
    email { generate :email }
    category 'e'

    ignore do
      member_count 1
    end

    after(:create) do |team, e|
      FactoryGirl.create_list(:member, e.member_count, :team => team)
    end

    trait :ineligible do
      category 'i'
    end

    trait :semifinal do
      category '2'
    end

    trait :completed do
      completion_status :complete_with_fresh_password
    end
  end

  factory :design do
    ignore do
      bridge_data { generate :good_bridge }
    end
    bridge { bridge_data[:bridge] }
    score { bridge_data[:analysis][:score] }
    sequence(:sequence) { |n| n }
    scenario { bridge_data[:analysis][:scenario] }
    hash_string { bridge_data[:analysis][:hash] }
    team

    trait :bad do
      ignore do
        bridge_data { generate :bad_bridge }
      end
    end

    factory :bad_design, :traits => [:bad]
  end

end
