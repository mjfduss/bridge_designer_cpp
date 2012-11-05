module StandingsHelper

  SEQ_SCORE = "*seq*"

  # Add or replace a score for the given design sequence number.
  # Return the current rank of the score.
  def set(score, seq)
    val = "%08d" % seq
    REDIS.zadd(SEQ, score, val)
    return REDIS.zrank(SEQ, team)
  end

  # Return the rank that the given score would have if it were entered
  # with a sequence number later than all others currently there.
  def query(score)
    item = REDIS.zrangebyscore(All, score.to_s, "+inf", :limit => [0, 1])
  end

  # Delete the standing of the given team.
  def delete(team)
    REDIS.zrem(ALL, team)
  end

  def to_key(score, sequence)
    return (score * 10e6 + sequence).to_s
  end
end