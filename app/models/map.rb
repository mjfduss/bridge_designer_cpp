# Non-standard model for maps drawn from various other models.
module Map

  MEMBER_MAP_CACHE_NAME_PREFIX = 'member_map_'
  DEFAULT_MEMBER_MAP_VERSION = 'USA50'

  def self.members_from_cache(version = DEFAULT_MEMBER_MAP_VERSION, refresh = false)

    # Ignore case and make sure the version is a known one.
    version = Pippa.map_names.find {|name| name.downcase == version.downcase } || DEFAULT_MEMBER_MAP_VERSION
    cache_name = MEMBER_MAP_CACHE_NAME_PREFIX + version

    Rails.cache.fetch(cache_name, :force => refresh, :expires_in => 6.hours, :race_condition_ttl => 15) do
      members(version)
    end
  end

  # Title and legend parameters.
  FONT_HEIGHT = 10
  INTER_LINE_SPACE = 4
  LEGEND_TOP = 12
  LEGEND_LEFT = 20
  DOT_SIZES = [1, 5, 10, 50, 100]
  POINT_SIZE = 2
  LEGEND_MARGIN = 175
  MAX_DOT_SIDE = 14 * POINT_SIZE

  # Assumes version is a valid Pippa map name.
  def self.members(version)

    # Count participation in each zip code.
    counts = Hash.new(0)
    Member.where('zip IS NOT NULL').find_each {|member| counts[member.zip] += 1 }
    Parent.where('zip IS NOT NULL').find_each {|parent| counts[parent.zip] += 1 }

    # Draw dots on a map.
    map = Pippa::Map.new(version)
    map.point_size = POINT_SIZE

    # Add title and legend.
    gc = Magick::Draw.new
    gc.stroke('transparent')
    gc.fill('black')
    lx = LEGEND_LEFT
    ly = LEGEND_TOP
    gc.text(lx, ly, "West Point Bridge Design Contest Participants (#{Time.now.to_s(:nice)})")

    ly = LEGEND_TOP + MAX_DOT_SIDE / 2
    gc.text(lx, ly + FONT_HEIGHT / 2, 'Legend (# of participants)')
    lx = LEGEND_MARGIN
    DOT_SIZES.each do |size|
      map.add_dot(lx, ly, size)
      side = Math.sqrt(size).round * POINT_SIZE
      gc.text(lx + side / 2 + 5, ly + FONT_HEIGHT / 2, "- #{size}")
      lx += side + 50
    end
    gc.draw(map.image)

    counts.each {|zip, count| map.add_at_zip(zip, count) }
    map.to_png
  end
end