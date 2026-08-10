# Which homeConfigurations output to build. See flake.nix for the full list.
HOST ?= gabriel

.PHONY: update
update:
	home-manager switch --impure --flake .#$(HOST)

.PHONY: headless
headless:
	home-manager switch --impure --flake .#$(HOST) --override-option gui.enable false

.PHONY: clean
clean:
	nix-collect-garbage -d
