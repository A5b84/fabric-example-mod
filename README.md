# A5b84/fabric-example-mod

This repository contains:
- A custom fork of [FabricMC/fabric-example-mod]
- A mirror of [FabricMC/fabric-example-mod] where history is maintained as a single linear branch instead of parallel branches for each game version.
  See the [mirror](https://github.com/A5b84/fabric-example-mod/tree/mirror) branch.
- The script that updates the mirror. Usage:
  ```ps1
  .\scripts\Update-Mirror.ps1
  git push origin mirror
  ```

[FabricMC/fabric-example-mod]: https://github.com/FabricMC/fabric-example-mod
