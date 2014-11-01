require 'tables_helper'
require 'standing'

module FactoryHelpers

  PATH = 'vendor/gems/WPBDC/test/eg/2014'

  def self.read_bdc_file(entry)
    f = File.open "#{PATH}/#{entry}", 'rb'
    bridge = f.read
    WPBDC.endecrypt(bridge);
    { :bridge => bridge, :analysis => WPBDC.analyze(bridge) }
  end

  def self.initialize
    return if defined? @@designs
    entries = Dir.entries(PATH).select { |name| name.end_with?('.bdc') }
    @@designs = entries.map { |entry| read_bdc_file(entry) }
    @@designs.sort! { |a, b| b[:analysis][:score] <=> a[:analysis][:score] }
    @@good_designs = @@designs.select { |d| d[:analysis][:status] == WPBDC::BRIDGE_OK }
    @@bad_designs  = @@designs.select { |d| d[:analysis][:status] != WPBDC::BRIDGE_OK }
  end

  def self.read_design(key, good = true)
    initialize
    return good.nil? ? @@designs[key % @@designs.length] :
           good ? @@good_designs[key % @@good_designs.length] :
              @@bad_designs[key % @@bad_designs.length]
  end

  def self.read_similar_design(i)
    # Two similar designs (same scenario).  First is cheaper.
    @@similar_designs ||= %w{similar-01.bdcx similar-02.bdcx}.map { |entry| read_bdc_file(entry) }
    @@similar_designs[i]
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
    %w{e i}[n % 2]
  end

  sequence :status do |n|
    %w{a r - 2}[n % 4]
  end

  sequence :member_category do |n|
     %w(u n)[n % 2]
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

  sequence :good_design do |n|
    FactoryHelpers.read_design(n, true)
  end

  sequence :bad_design do |n|
    FactoryHelpers.read_design(n, false)
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
    sex '-'
    hispanic '-'
    race '-'
    category { generate :member_category }
    school_state { state }
    res_state { state }
    rank 0
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
#    email { generate :email }
    email 'gene.ressler@gmail.com'
    category { generate :team_category }
    status { generate :status }
    reg_completed { Time.now }

    ignore do
      member_count 1
    end

    after(:create) do |team, e|
      (0..e.member_count - 1).each {|rank| FactoryGirl.create(:member, :team => team, :rank => rank) }
    end

    trait :ineligible do
      category 'i'
    end

    trait :semifinal do
      status '2'
    end

    trait :completed do
      completion_status :complete_with_fresh_password
    end
  end

  factory :design do
    ignore do
      the_design { generate :good_design }
    end
    bridge { the_design[:bridge] }
    score { the_design[:analysis][:score] }
    sequence(:sequence) { |n| n }
    scenario { the_design[:analysis][:scenario] }
    hash_string { the_design[:analysis][:hash] }
    team

    after(:create) do |design, e|
      Standing.insert(e.team, design) if e.the_design[:analysis][:status] == WPBDC::BRIDGE_OK
    end

    trait :bad do
      ignore do
        the_design { generate :bad_bridge }
      end
    end

    trait :cheap do
      ignore do
        the_design { FactoryHelpers.read_similar_design(0) }
      end
    end

    trait :expensive do
      ignore do
        the_design { FactoryHelpers.read_similar_design(1) }
      end
    end

    factory :bad_design, :traits => [:bad]
    factory :cheap_design, :traits => [:cheap]
    factory :expensive_design, :traits => [:expensive]
  end

end
