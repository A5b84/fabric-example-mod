# A5b84/fabric-example-mod

This repository contains the following branches:

- `mirror`: A mirror of [FabricMC/fabric-example-mod] where history is maintained as a single linear branch instead of parallel branches for each game version.
- `main`: The script that updates the mirror in this branch.
- `custom`: A custom fork of [FabricMC/fabric-example-mod].

## Updating the mirror

Run:

```ps1
Update-Mirror.ps1
git push origin mirror
```

Alternatively, run the `update-mirror` workflow using GitHub Actions from [here](https://github.com/A5b84/fabric-example-mod/actions/workflows/update-mirror.yml).

[FabricMC/fabric-example-mod]: https://github.com/FabricMC/fabric-example-mod
