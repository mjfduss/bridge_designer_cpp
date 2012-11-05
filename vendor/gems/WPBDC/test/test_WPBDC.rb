require 'test/unit'
require 'WPBDC'

class WPBDCTest < Test::Unit::TestCase

  YEAR = 2012

  def test_pass_fail
    for fn in Dir.glob("test/eg/#{YEAR}/*.bdc")
      good_bridge = fn.index('failed').nil?
      bridge = open(fn, "rb") { |f| f.read }
      WPBDC.endecrypt(bridge)
      result = WPBDC.analyze(bridge)
      assert_includes([WPBDC::BRIDGE_OK, WPBDC::BRIDGE_FAILEDTEST, WPBDC::BRIDGE_WRONGVERSION, WPBDC::BRIDGE_MALFORMED ], result[:status], "bad status")
      assert(result[:status] != WPBDC::BRIDGE_OK || good_bridge, "#{fn}: failed bridge returned ok")
      assert(result[:status] != WPBDC::BRIDGE_FAILEDTEST || !good_bridge, "#{fn}: good bridge returned failed")
      assert_not_equal(result[:status], WPBDC::BRIDGE_WRONGVERSION, "#{fn}: bad report of wrong version")
      assert_not_equal(result[:status], WPBDC::BRIDGE_MALFORMED, "#{fn}: bad report of malformed bridge")
    end
  end

  def test_comparisons
    seed = 42424242
    n_variants = 100
    for fn in Dir.glob("test/eg/#{YEAR}/*.bdc")
        bridge = open(fn, "rb") { |f| f.read }
        WPBDC.endecrypt(bridge)
        for i in 1 .. n_variants
          variant = WPBDC.variant(bridge, seed)
          seed = 0
          assert_equal(WPBDC.are_same(bridge, variant), true, "#{fn}: similar variant reported not same")
        end
    end
  end
end
