class Schedule < ActiveRecord::Base

  attr_accessible :name, :active, :closed, :message
  attr_accessible :start_quals_prereg, :start_quals, :end_quals, :quals_tally_complete
  attr_accessible :start_semis_prereg, :start_semis, :end_semis

  validates :name, :uniqueness => true

  after_initialize :set_reasonable_field_values

  CACHE_NAME = 'wpbdc/schedule'

  # Makes sure the date/times are a time line.
  class ScheduleValidator < ActiveModel::Validator
    def validate(schedule)
      unless schedule.start_quals >= schedule.start_quals_prereg
        schedule.errors[:start_quals] << 'Qualifying round must start after early registration'
      end
      unless schedule.end_quals > schedule.start_quals
        schedule.errors[:start_quals] << 'Qualifying round must end later than it starts'
      end
      unless schedule.start_semis_prereg > schedule.end_quals
        schedule.errors[:start_quals] << 'Semifinal login check must start after qualifiers end'
      end
      unless schedule.start_semis >= schedule.start_semis_prereg
        schedule.errors[:start_quals] << 'Semifinals must start after login checks'
      end
      unless schedule.end_semis >= schedule.start_semis
        schedule.errors[:start_quals] << 'Semifinals must end later than they start'
      end
    end
  end

  validates_with ScheduleValidator

  STATE_CLOSED = 0
  STATE_INITIAL_FREE = 1
  STATE_QUALS_PREREG = 2
  STATE_QUALS = 3
  STATE_QUALS_CLOSED = 4
  STATE_INTERIM_FREE = 5
  STATE_SEMIS_PREREG = 6
  STATE_SEMIS = 7
  STATE_POST_FREE = 8
  STATES_CLOSED_FOR_LOGIN = [STATE_CLOSED, STATE_QUALS_CLOSED]

  DESCRIPTIONS = [
    'Team logins disabled with "closed" message displayed',
    'Open for free play, qualifying round not begun',
    'Early registration for qualifying round',
    'Qualifying round',
    'Tallying results of qualifying round',
    'Open for free play between qualifying round and semis',
    'Semifinal login checks while also open for free play',
    'Semifinals in progress while also open for free play',
    'Open for free play, contest year complete',
  ]

  def state(t = Time.now)
    return STATE_CLOSED if closed?
    return STATE_INITIAL_FREE if t < start_quals_prereg
    return STATE_QUALS_PREREG if t < start_quals
    return STATE_QUALS if t < end_quals
    return STATE_QUALS_CLOSED if t < start_semis_prereg && !quals_tally_complete?
    return STATE_INTERIM_FREE if t < start_semis_prereg
    return STATE_SEMIS_PREREG if t < start_semis
    return STATE_SEMIS if t < end_semis
    STATE_POST_FREE
  end

  def self.fetch_cache
    Rails.cache.fetch(Schedule::CACHE_NAME) do
      find_by_active(true) || Session.new(:closed => true, :message => "We're having a system problem.  Sorry.")
    end
  end

  def self.expire_cache
    Rails.cache.delete(Schedule::CACHE_NAME)
  end

  def formatted(visible = %w(start_quals_prereg start_quals end_quals quals_tally_complete start_semis_prereg start_semis end_semis closed))
    visible.map { |item| send("#{item}_formatted") }
  end

  def name_formatted
    [ 'Name', description ]
  end

  def active_formatted
    [ 'Active', active?.to_s(:word) ]
  end

  def closed_formatted
    [ 'Logins suspended', closed?.to_s(:word) ]
  end

  def message_formatted
    [ 'Message', message ]
  end

  def start_quals_prereg_formatted
    [ 'Start registration', start_quals_prereg ]
  end

  def start_quals_formatted
    [ 'Start qualifying', start_quals ]
  end

  def end_quals_formatted
    [ 'End qualifying', end_quals ]
  end

  def quals_tally_complete_formatted
    [ 'Tally complete', quals_tally_complete?.to_s(:word) ]
  end

  def start_semis_prereg_formatted
    [ 'Start semi logins', start_semis_prereg ]
  end

  def start_semis_formatted
    [ 'Start semis', start_semis ]
  end

  def end_semis_formatted
    [ 'End semis', end_semis ]
  end

  private

  def set_reasonable_field_values
    return unless new_record?
    # Use some reasonable dates based on 2013 schedule.
    time = Time.now
    year = time.month >= 6 ? time.year + 1 : time.year
    self.start_quals_prereg = Time.local(year, 1, 14, 13, 0)
    self.start_quals = Time.local(year, 1, 15, 13, 0)
    self.end_quals = Time.local(year, 3, 25, 13, 0)
    self.start_semis_prereg = Time.local(year, 4, 1, 13, 0)
    self.start_semis = Time.local(year, 4, 5, 13, 0)
    self.end_semis = Time.local(year, 4, 5, 15, 0)
  end

end
