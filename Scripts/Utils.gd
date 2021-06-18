extends Node

# Constants

const ARCHIVE_BUILT = 4

# Enums

enum {FREE_ARCHIVE, FREE_PICK, FREE_BUILD, FREE_RESEARCH}
enum {ACTIVE_GIZMO, ARCHIVED_GIZMO, RESEARCH_GIZMO, REVEALED_GIZMO}

# Variables

var free_action_code = {
	FREE_ARCHIVE: 'archive',
	FREE_PICK: 'pick',
	FREE_BUILD: 'build',
	FREE_RESEARCH: 'research'
}
