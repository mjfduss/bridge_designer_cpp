require 'test/unit'
require 'WPBDC'

class WPBDCTest < Test::Unit::TestCase

  YEAR = WPBDC::CONTEST_YEAR
  N_VARIANTS = 10
  TEST_DATA_PATH = '../../../../bridgedesigner'

  # 428	1052804100	42A	196560.3239129398
  HEAD_FMT = "i i s f".split(' ')
  # 1	190x190x9	Tube	CS	4.25	449.28209310650266	1232.3796209685247	0.36456468888491744	OK	0.0	1547.55	0.0	OK
  TABLE_FMT = "i s s s f f f f s f f f s".split(' ')

  def test_analysis_text_table_generation
    Dir.glob("test/eg/#{YEAR}/*.bdc").each do |ifn|
      bridge = open(ifn, "rb") { |f| f.read }
      WPBDC.endecrypt(bridge)
      ofn = ifn.sub('.bdc', '.txt').sub("/#{YEAR}", "/#{YEAR}/log")
      open(ofn, "w") { |f| f.write(WPBDC.analysis_log(bridge)) }
    end
    # Diff the member data tables with respect to the judge's versions
    Dir.glob("test/eg/#{YEAR}/log/*.txt").each do |judge_fn|
      bd_fn = judge_fn.sub(%r|^.*test/|, "#{TEST_DATA_PATH}/")
      pairs = IO.readlines(judge_fn).zip(IO.readlines(bd_fn))
      pairs.each_with_index do |pair, i|
        # TODO Should actually compare on slenderness failures
        next if pair.any? {|p| p =~ /Slenderness/ }
        line = i + 1
        (line == 1 ? HEAD_FMT : TABLE_FMT).zip(*pair.map(&:split)).each_with_index do |triple, j|
          col = j + 1
          fmt, a, b = triple
          case fmt
          when 's'
            assert(a == b, "#{bd_fn}: line #{line}, string col #{col}-#{pair.inspect}")
          when 'i'
            assert(Integer(a) == Integer(b), "#{bd_fn}: line #{line}, int col #{col}-#{pair.inspect}")
          when 'f'
            assert((Float(a) - Float(b)).abs < 0.01, "#{bd_fn}: line #{line}, float col #{col}-#{pair.inspect}")
          else
            assert(false, "line #{line} col #{col}: unknown format")
          end
        end
      end
    end
  end

  def test_similarity
    seed = 53535353
    Dir.glob("test/eg/#{YEAR}/*.bdc").each do |fn|
      bridge = open(fn, "rb") { |f| f.read }
      WPBDC.endecrypt(bridge)
      bridge_result = WPBDC.analyze(bridge)
      assert(bridge_result[:version], "#{fn}: version missing")
      assert(bridge_result[:scenario], "#{fn}: scenario missing")
      assert(bridge_result[:scenario_number], "#{fn}: scenario_number missing")
      assert(bridge_result[:test_status], "#{fn}: test_status missing")
      assert(bridge_result[:status], "#{fn}: status missing")
      assert(bridge_result[:error], "#{fn}: error missing")
      assert(bridge_result[:score], "#{fn}: score missing")
      assert(bridge_result[:hash], "#{fn}: hash missing")
      (1 .. N_VARIANTS).each do |i|
        variant = WPBDC.variant(bridge, seed)
        seed = 0
        variant_result = WPBDC.analyze(variant)
        assert_equal(bridge_result[:version], variant_result[:version], "#{fn}: versions differ")
        assert_equal(bridge_result[:scenario], variant_result[:scenario], "#{fn}: scenarios differ")
        assert_equal(bridge_result[:scenario_number], variant_result[:scenario_number], "#{fn}: scenario numbers differ")
        assert_equal(bridge_result[:test_status], variant_result[:test_status], "#{fn}: test statuses differ")
        assert_equal(bridge_result[:status], variant_result[:status], "#{fn}: statuses differ")
        assert_equal(bridge_result[:error], variant_result[:error], "#{fn}: errors differ")
        assert_equal(bridge_result[:score], variant_result[:score], "#{fn}: scores differ")
        assert_equal(bridge_result[:hash], variant_result[:hash], "#{fn}: hashes differ")
      end
    end
  end

  def test_pass_fail
    Dir.glob("test/eg/#{YEAR}/*.bdc").each do |fn|
      good_bridge = fn.index('failed').nil?
      bridge = open(fn, "rb") { |f| f.read }
      WPBDC.endecrypt(bridge)
      result = WPBDC.analyze(bridge)
      if result[:status] == WPBDC::BRIDGE_MALFORMED
        puts result.inspect
      end
      assert_includes([WPBDC::BRIDGE_OK, WPBDC::BRIDGE_FAILEDTEST, WPBDC::BRIDGE_WRONGVERSION, WPBDC::BRIDGE_MALFORMED], result[:status], "bad status")
      assert(result[:status] != WPBDC::BRIDGE_OK || good_bridge, "#{fn}: failed bridge returned ok")
      assert(result[:status] != WPBDC::BRIDGE_FAILEDTEST || !good_bridge, "#{fn}: good bridge returned failed")
      assert_not_equal(result[:status], WPBDC::BRIDGE_WRONGVERSION, "#{fn}: bad report of wrong version")
      assert_not_equal(result[:status], WPBDC::BRIDGE_MALFORMED, "#{  fn}: bad report of malformed bridge")
    end
  end

  def test_compare
    seed = 42424242
    Dir.glob("test/eg/#{YEAR}/*.bdc").each do |fn|
      bridge = open(fn, "rb") { |f| f.read }
      WPBDC.endecrypt(bridge)
      (1 .. N_VARIANTS).each do |i|
        variant = WPBDC.variant(bridge, seed)
        seed = 0
        assert_equal(WPBDC.are_same(bridge, variant), true, "#{fn}: variants fail are_same")
      end
    end
  end
end
