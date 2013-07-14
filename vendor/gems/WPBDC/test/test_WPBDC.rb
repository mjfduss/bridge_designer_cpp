require 'test/unit'
require 'WPBDC'

class WPBDCTest < Test::Unit::TestCase

  YEAR = 2012
  N_VARIANTS = 10

  def test_similarity
    seed = 53535353
    Dir.glob("test/eg/#{YEAR}/*.bdc").each |fn| do
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
      assert_includes([WPBDC::BRIDGE_OK, WPBDC::BRIDGE_FAILEDTEST, WPBDC::BRIDGE_WRONGVERSION, WPBDC::BRIDGE_MALFORMED], result[:status], "bad status")
      assert(result[:status] != WPBDC::BRIDGE_OK || good_bridge, "#{fn}: failed bridge returned ok")
      assert(result[:status] != WPBDC::BRIDGE_FAILEDTEST || !good_bridge, "#{fn}: good bridge returned failed")
      assert_not_equal(result[:status], WPBDC::BRIDGE_WRONGVERSION, "#{fn}: bad report of wrong version")
      assert_not_equal(result[:status], WPBDC::BRIDGE_MALFORMED, "#{fn}: bad report of malformed bridge")
    end
  end

  def test_compare
    seed = 42424242
    Dir.glob("test/eg/#{YEAR}/*.bdc").each do |fn|
      bridge = open(fn, "rb") { |f| f.read }
      WPBDC.endecrypt(bridge)
      for i in 1 .. N_VARIANTS
        variant = WPBDC.variant(bridge, seed)
        seed = 0
        assert_equal(WPBDC.are_same(bridge, variant), true, "#{fn}: variants fail are_same")
      end
    end
  end
end
