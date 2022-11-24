##
#  to run use
#     ruby -I ./lib -I ./test test/test_sample_steps.rb


require 'helper'



class TestSample < MiniTest::Test

def calc_step( width, new_width, i, center: true )
   base_step = width / new_width    ## pixels per pixel
   overflow  = width - (base_step * new_width)

   base  = i * base_step
   base += base_step / 2    if center

   err = (i*overflow + overflow/2.0) / new_width.to_f
   puts " [#{i}] #{base} + #{err}"

   base + err.floor
end



def test_24px
  #############
  # 512x512 (24x24)
  indexes_exp = 24.times.map { |i| calc_step( 512, 24, i ) }

  assert_equal indexes_exp, Pixelart::Image.calc_sample_steps( 512, 24 )

  ######################
  #  269x269  (24x24)
  #   assume 11px per pixel 11x24 = 264 + 5 = 269
  indexes_exp = 24.times.map { |i| calc_step( 269, 24, i ) }

  assert_equal indexes_exp, Pixelart::Image.calc_sample_steps( 269, 24 )
end

def test_32px
    ######################
    #  320x320  (32x32)
    #    assume 10px per pixel 10x32 = 320
    indexes_exp = 32.times.map { |i| calc_step( 320, 32, i ) }

    assert_equal indexes_exp, Pixelart::Image.calc_sample_steps( 320, 32 )
end

def test_35px
    #############
    #  512x512 (35x35)
    #     14px * 35 = 490px   plus add 22px overflow => 512px
    indexes_exp = 35.times.map { |i| calc_step( 512, 35, i ) }

    assert_equal indexes_exp, Pixelart::Image.calc_sample_steps( 512, 35 )
end

def test_60px
    ###########
    #   512x512 (60x60)
    #    assume 8px    60*8 = 480  + 32 = 512
    indexes_exp_center  = 60.times.map { |i| calc_step( 512, 60, i, center: true ) }
    indexes_exp         = 60.times.map { |i| calc_step( 512, 60, i, center: false ) }

    assert_equal indexes_exp_center, Pixelart::Image.calc_sample_steps( 512, 60, center: true )
    assert_equal indexes_exp,        Pixelart::Image.calc_sample_steps( 512, 60, center: false )
end

def test_80px
    ###########
    #   512x512 (80x80)
    #    assume 6px    80*6 = 480  + 32 = 512
    indexes_exp         = 80.times.map { |i| calc_step( 512, 80, i ) }

    assert_equal indexes_exp,        Pixelart::Image.calc_sample_steps( 512, 80 )
end
end # class TestSample

