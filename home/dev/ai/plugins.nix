# Skill/plugin sources (pinned with npins) and skill selections. Not a module:
# `import ./plugins.nix { inherit lib; }`.
{ lib }:
with lib;
let
  sources = import ../../../npins;

  mattPocock = sources.claude-plugin-mattpocock-skills;

  # name -> dir for each child of `root` holding a SKILL.md.
  skillsIn =
    root:
    mapAttrs' (name: _: nameValuePair name (root + "/${name}")) (
      filterAttrs (name: type: type == "directory" && builtins.pathExists (root + "/${name}/SKILL.md")) (
        builtins.readDir root
      )
    );

  caveman = sources.claude-plugin-caveman;
  karpathy = sources.claude-plugin-karpathy-skills;

  # Stable categories, as in the upstream manifest.
  mattPocockSkills = foldl' (acc: category: acc // skillsIn "${mattPocock}/skills/${category}") { } [
    "engineering"
    "productivity"
  ];

  # ./skills/<name>/SKILL.md; must be git-tracked for the flake to see it.
  ownSkills = optionalAttrs (builtins.pathExists ./skills) (skillsIn ./skills);
in
{
  inherit
    caveman
    karpathy
    mattPocock
    mattPocockSkills
    ownSkills
    ;

  official = sources.claude-plugins-official;

  # For ~/.agents/skills. Drops Caveman Cloud ops and cavecrew (needs agent
  # definitions a skill-only install lacks).
  sharedSkills =
    removeAttrs (skillsIn "${caveman}/skills" // skillsIn "${karpathy}/skills" // mattPocockSkills) [
      "cavecrew"
      "caveman-discover"
      "caveman-evidence-review"
      "caveman-learn"
      "caveman-manage"
      "caveman-optimize"
      "caveman-setup"
      "caveman-stats"
      "grill-me"
    ]
    // ownSkills;
}
