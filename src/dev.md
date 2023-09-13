# Developer notes

### Regex color.bqn
When adding colors in colors.bqn, to make rows even and reading easier, reformat with the regex's:
- Find `"(?<=[0-9]{2})‿"` Replace `" ‿"` (one space)
- Find `"(?<=[0-9]{1})‿"` Replace `"  ‿"` (two spaces)

This is so `0‿255‿0‿255` reformats as `0  ‿255‿0  ‿255` 