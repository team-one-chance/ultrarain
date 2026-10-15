if (!instance_exists(other)) exit;
if (other.grinder_dying) exit;

wire_contact_effect(other, true);

other.pHP = 0;
global.demo_took_damage = true;
instance_destroy(other);