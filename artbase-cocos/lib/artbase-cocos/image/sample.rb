module Pixelart

  class Image

###
#   add common
#     pixel(ate) steps/offsets (for re/down/sampling)
DOwNSAMPLING_STEPS = {
  '24x24' => {
    '269x269' => Image.calc_sample_steps( 269, 24 ),  # width (269px), new_width (24px)
    '512x512' => Image.calc_sample_steps( 512, 24 ),  # width (512px), new_width (24px)
  },
  '32x32' => {
    '320x320' => Image.calc_sample_steps( 320, 32 ),
    '512x512' => Image.calc_sample_steps( 512, 32 ),
  },
  '35x35' => {
    '512x512' => Image.calc_sample_steps( 512, 35 ),
  },
  '60x60' => {
    '512x512' => Image.calc_sample_steps( 512, 60 ),
  },
  '80x80' => {
    '512x512' => Image.calc_sample_steps( 512, 80 ),
  },
}

  end  # class Image
end   # module Pixelart


