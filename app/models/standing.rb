# A non-standard model for standings implemented over Redis.
#
# Use Redis ordered (z) sets to store <score, sequence> pairs that can be looked up
# by score, sequence number, or rank in pairwise lexicographic order. Given
# a pair, the rank can be retrieved, which is the standing we need.
#
# Use Redis (h) hashes to map team id to sequence of current best team design.
#
# A z-h pair is used for each category, currently Eligible, Ineligible, and Semifinal.
# The category is obtained from a team object.
#
module Standing

  # Insert the given design in the standings and return 
  # standings for national contest.
  def self.insert(team, design)
    # Category is:
    #   e - eligible for prizes
    #   i - ineligible for prizes
    #   2 - semifinal
    scores_key = to_scores_key(team)
    teams_key = to_teams_key(team)

    score = design.score
    tid = team.id
    seq = to_val(design.sequence)

    old_seq = REDIS.hget(teams_key, tid)
    REDIS.pipelined do
      REDIS.zadd(scores_key, score, seq)
      REDIS.hset(teams_key, tid, seq)
      REDIS.zrem(scores_key, old_seq) unless old_seq.nil?
    end unless old_seq == seq
    (rank, len) = REDIS.pipelined do
      REDIS.zrank(scores_key, seq)
      REDIS.hlen(teams_key)
    end
    return rank && len && [1 + rank, len]
  end

  # Delete the standing for the given team.
  def self.delete(team)
    scores_key = to_scores_key(team)
    teams_key = to_teams_key(team)
    seq = REDIS.hget(teams_key, team.id)
    if seq
      REDIS.pipelined do
        REDIS.hdel(teams_key, team.id)
        REDIS.zrem(scores_key, seq)
      end
    end
  end

  # Interpolate the standing a design with given score would have if it were inserted.
  def self.interpolated_standing(team, score)
    scores_key = to_scores_key(team)
    # Find the first element with a score bigger than the one given.
    bigger = REDIS.zrangebyscore(scores_key, "(#{score}", "+inf", :limit => [0, 1])
    # If none found, return one more than the number of scores.
    # Otherwise we'll supplant the one found.
    if bigger.empty?
      rank = REDIS.zcard(scores_key) + 1
      return [rank, rank]
    end
    (rank, len) = REDIS.pipelined do
      REDIS.zrank(scores_key, bigger[0])
      REDIS.zcard(scores_key)
    end
    return [1 + rank, 1 + len]
  end

  # Re-insert team's best design if the standings database is missing it.
  # This will fix up standings if REDIS is down when a new best bridge is posted.
  def self.missing_standing(team)
    best_design = team.best_design
    return Standing.insert(team, best_design) if best_design
    [nil, REDIS.hlen(to_teams_key(team))]
  end

  # Return the current standing of the given team.
  def self.standing(team)
    scores_key = to_scores_key(team)
    teams_key = to_teams_key(team)
    seq = REDIS.hget(teams_key, team.id)
    return missing_standing(team) unless seq
    (rank, len) = REDIS.pipelined do
      REDIS.zrank(scores_key, seq)
      REDIS.hlen(teams_key)
    end
    return [1 + rank, len]
  end

  # Return the current standing of the given team.
  def self.rank(team)
    scores_key = to_scores_key(team)
    teams_key = to_teams_key(team)
    seq = REDIS.hget(teams_key, team.id)
    return seq && 1 + REDIS.zrank(scores_key, seq)
  end

  # Stub for testing.
  def self.team_count(category)
    return REDIS.hlen("t:#{category}:*")
  end

  # Stub for testing.
  def self.score_count(category)
    return REDIS.zcard("s:#{category}:*")
  end

  # Return the number of teams in the same category as the given team.
  def self.max_standing(team)
    REDIS.hlen(to_teams_key(team))
  end

  private

  def self.to_scores_key(team)
    "s:#{team.category}:*"
  end

  def self.to_teams_key(team)
    "t:#{team.category}:*"
  end

  # Convert a sequence number to a string where lexicographic
  # order is the same as numerical sorted order.
  def self.to_val(seq)
    #"%08d" % seq
    #(seq >> 24).chr + ((seq >> 16) & 0xff).chr + ((seq >> 8) & 0xff).chr + (seq & 0xff).chr 
    [seq].pack('U')
  end
end