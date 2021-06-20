extends Node

# Constants

const ARCHIVE_BUILT = 4
const WILD_ENERGY = 4

# Enums

enum {ARCHIVE, PICK, BUILD, RESEARCH}
enum {ACTIVE_GIZMO, ARCHIVED_GIZMO, RESEARCH_GIZMO, REVEALED_GIZMO}
# Energy/gizmo color type codes
enum {RED, YELLOW, BLUE, BLACK}
# Variables

# Used when giving free actions/disabling actions from passive gizmos
var action_code = {
	ARCHIVE: 'archive',
	PICK: 'pick',
	BUILD: 'build',
	RESEARCH: 'research'
}
