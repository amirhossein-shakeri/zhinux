.PHONY: help init update

help:
	@echo "Zhinux Platform Management"
	@echo ""
	@echo "Commands:"
	@echo "  make init    - Initialize all submodules"
	@echo "  make update  - Update all submodules to latest"
	@echo "  make docs    - Open documentation"

init:
	git submodule update --init --recursive

update:
	git submodule update --remote --recursive

docs:
	@echo "Documentation available in zhinux-docs/"
	@echo "- Guides: zhinux-docs/guides/"
	@echo "- Standards: zhinux-docs/standards/"

