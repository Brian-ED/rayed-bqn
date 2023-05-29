# Sequences of functions
There are sets of functions i decided not to export such as `window.Open` and  `window.Close`, because they are useless if you use window._openAs.
They also don't behave well if ran in the wrong order, and you only want to run them in a special sequence.

This pattern was also used in `draw._withCanvas_`