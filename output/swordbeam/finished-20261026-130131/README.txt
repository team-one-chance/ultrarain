Completed sword beam Aura layer. Original Beam artwork preserved pixel-for-pixel, with additional canvas room for trailing energy. The aura uses generated flame artwork in the original black #000000, red #EE1C24, and yellow #FFF200 palette. It grows with the beam and flows through a seven-frame cyclic phase. All three colors are visible outside the core in every looping frame (displayed frames 10-16).

Runtime sprite: sprites/sSowrdBeam/sSowrdBeam.yy. Same 16 frame IDs, layers, keyframes, and 30fps playback. oSwordBeam still loops from image_index=9. No gameplay scripts changed.

Canvas increased from 35x65 to 47x73. Old pixels are padded by (10,4); custom origin becomes (45,69), and manual collision bounds are shifted by (10,4). The original beam pixels and collision area retain their exact world positions at any image scale or facing.

Backups: before.zip contains the complete previous sprite, including the attempted Aura layer. staged/ contains the delivered sprite files. Full source and built-in image_gen prompt are in the parent swordbeam folder.

Previews: growth-and-loop.gif shows startup followed by several loop cycles; loop.gif repeats only the final seven frames. contact.png shows selected composite frames above their Aura layers. visible-aura-colors.json records color counts outside the beam core.

Validation: all 48 saved composite/layer PNGs match staged output in every visible pixel (fully transparent RGB is ignored); all original core pixels preserved; all seven live loop frames contain all three aura colors outside the core; sprite frame/timing references verified; world-space collision bounds checked at positive and negative scales; GIF previews decoded successfully. GameMaker runtime was not launched.
