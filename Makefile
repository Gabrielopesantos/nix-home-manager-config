.PHONY: update
update:
	home-manager switch --impure --flake .#gabriel

.PHONY: headless
headless:
	home-manager switch --impure --flake .#gabriel --override-option gui.enable false

.PHONY: clean
clean:
	nix-collect-garbage -d

