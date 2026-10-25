extends Node3D

@export var energy_amount: float = 100.0
@export_group("interaction")
@export var prompt_text: String = "battery (press E)"

# هذه الدالة تستدعى عندما ينظر اللاعب للبطارية ويضغط E
func interact(player: Node3D) -> void:
	if player.has_method("add_battery_energy"):
		player.add_battery_energy(energy_amount)
		queue_free() # إخفاء البطارية من المتاهة
