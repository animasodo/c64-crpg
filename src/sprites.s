
    .export _door_sprite, _lizard_sprite_0, _lizard_sprite_0_walking, _lizard_sprite_1, _lizard_sprite_1_walking

.SEGMENT "RODATA"

_door_sprite:
    .incbin "../data/door_sprite.inc"
_lizard_sprite_0:
    .incbin "../data/lizard_sprite_0.inc"
_lizard_sprite_0_walking:
    .incbin "../data/lizard_sprite_0_walking.inc"
_lizard_sprite_1:
    .incbin "../data/lizard_sprite_1.inc"
_lizard_sprite_1_walking:
    .incbin "../data/lizard_sprite_1_walking.inc"