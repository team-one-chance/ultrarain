// Environmental instant kills bypass combat iFrames.
other.pHP = 0;
global.demo_took_damage = true;
instance_destroy(other);
