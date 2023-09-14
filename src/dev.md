# Developer notes

### Regex color.bqn

When adding colors in colors.bqn, to make rows even and reading easier, reformat with the regex's:

- Find `"(?<=[0-9]{2})‿"` Replace `" ‿"` (one space)
- Find `"(?<=[0-9]{1})‿"` Replace `"  ‿"` (two spaces)

This is so `0‿255‿0‿255` reformats as `0  ‿255‿0  ‿255`

### Sequences of functions
There are sets of functions i decided not to export such as `window.Open` and  `window.Close`, because they are useless if you use window._openAs.
They also don't behave well if ran in the wrong order, and you only want to run them in a special sequence.
This pattern was also used in `draw._withCanvas_`