@tool
extends EditorPlugin

var toolbar_button: Button

## Estructura de carpetas a generar, relativa a res://
const FOLDER_STRUCTURE: Array[String] = [
	"assets",
	"assets/models",
	"assets/textures",
	"assets/audio",
	"assets/fonts",
	"scripts",
	"components",
	"scenes",
	"scenes/levels",
	"scenes/ui",
	"src",
	"src/autoload",
	"src/resources",
	"vfx",
	"vfx/materials",
	"vfx/particles",
]


func _enter_tree() -> void:
	toolbar_button = Button.new()
	toolbar_button.text = "Generar Estructura"
	toolbar_button.tooltip_text = "Genera la estructura de carpetas estándar del proyecto"
	toolbar_button.pressed.connect(_on_generate_pressed)
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, toolbar_button)


func _exit_tree() -> void:
	if toolbar_button:
		remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, toolbar_button)
		toolbar_button.queue_free()
		toolbar_button = null


func _on_generate_pressed() -> void:
	var created := 0
	var skipped := 0
	var failed := 0

	for path in FOLDER_STRUCTURE:
		var full_path := "res://%s" % path
		if DirAccess.dir_exists_absolute(full_path):
			skipped += 1
			continue

		var err := DirAccess.make_dir_recursive_absolute(full_path)
		if err == OK:
			created += 1
		else:
			failed += 1
			push_error("No se pudo crear la carpeta: %s (error %d)" % [full_path, err])

	EditorInterface.get_resource_filesystem().scan()

	var msg := "Carpetas creadas: %d\nYa existían: %d" % [created, skipped]
	if failed > 0:
		msg += "\nFallidas: %d (revisa la consola de salida)" % failed

	print("[Folder Structure Generator] %s" % msg.replace("\n", " | "))
	_show_result_dialog(msg)


func _show_result_dialog(msg: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = "Generador de Estructura"
	dialog.dialog_text = msg
	EditorInterface.get_base_control().add_child(dialog)
	dialog.popup_centered()
	dialog.confirmed.connect(dialog.queue_free)
	dialog.canceled.connect(dialog.queue_free)
