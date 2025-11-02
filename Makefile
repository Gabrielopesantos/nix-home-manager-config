.PHONY: update
update:
	NIXPKGS_ALLOW_UNFREE=1 home-manager switch --impure --flake .#gabriel

.PHONY: clean
clean:
	nix-collect-garbage -d

