.PHONY: update
update:
	home-manager switch --impure --flake .#gabriel

.PHONY: clean
clean:
	nix-collect-garbage -d

