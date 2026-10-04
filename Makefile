.PHONY: update
update:
	home-manager switch --flake .#gabriel

.PHONY: headless
headless:
	home-manager switch --flake .#gabriel-headless

.PHONY: clean
clean:
	nix-collect-garbage -d
