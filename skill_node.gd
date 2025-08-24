extends Control
class_name SkillNode

@export var isUnlocked : bool = false;
@export var unlockedStyle: StyleBoxFlat
@export var requiresAll: bool = true;
@export var dependencies: Array[SkillNode]

var isParentUnlocked = false;
var dependents: Array[SkillNode] = []
var button: Button

var texts = ["☠️", "🔫", "🖤", "🙏", "💴", "🪙", "💥"]

func _ready() -> void:
	visible = false;
	var subNodes = get_children().filter(isSkillNode) as Array[SkillNode]
	for dependency in dependencies:
		dependency.dependents.append(self)
	for subNode in subNodes:
		subNode.dependencies.append(self)
		dependents.append(subNode)
	button = $MarginContainer/Button
	button.text = texts[randi_range(0, len(texts) - 1)]
	updateState()

func updateState() -> void:
	if isUnlocked:
		button.add_theme_stylebox_override("normal", unlockedStyle)
		button.add_theme_stylebox_override("hover", unlockedStyle)
		button.add_theme_stylebox_override("pressed", unlockedStyle)
		button.add_theme_stylebox_override("disabled", unlockedStyle)
		button.disabled = true
		visible = true;
		isParentUnlocked = true;
		for subNode in dependents:
			subNode.isParentUnlocked = true
			subNode.visible = subNode.shouldBeVisible()
			subNode.updateState()
	else: 
		button.disabled = !shouldBeUnlockable()
	queue_redraw()

func isSkillNode(node: Node) -> bool:
	return node is SkillNode
	
func centerPosition(node: Node) -> Vector2:
	return Vector2(node.global_position.x - global_position.x + node.size.x/2, node.global_position.y - global_position.y + node.size.y/2)

func _draw() -> void:
	var isVisible = shouldBeVisible();
	if isVisible:
		updateDependencies()
		var visibleDependents = dependents.filter(func(d: SkillNode): return d.visible) as Array[SkillNode]
		for subNode in visibleDependents:
			var color = Color.AQUAMARINE if subNode.isUnlocked else Color.GHOST_WHITE if subNode.shouldBeUnlockable() else Color.DIM_GRAY
			draw_line(Vector2(20,20), centerPosition(subNode), color, 4, false)

func shouldBeVisible() -> bool:
	return dependencies.any(isNodeUnlocked) or isParentUnlocked
	
func shouldBeUnlockable() -> bool:
	if requiresAll:
		return dependencies.all(isNodeUnlocked) and isParentUnlocked
	return dependencies.any(isNodeUnlocked) or isParentUnlocked
	
func isNodeUnlocked(node: SkillNode) -> bool:
	return node.isUnlocked
	
func updateDependents() -> void:
	for dep in dependents:
		dep.queue_redraw()
		
func updateDependencies() -> void:
	for dep in dependencies:
		dep.queue_redraw()

func _on_skill_unlock() -> void:
	isUnlocked = true
	updateState()
	pass
