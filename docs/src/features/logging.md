
 - Log-Message can be overwritten
   - this always occurs if the `overwrite_lastlog=true` kwarg is passed fo `@info`/`@warn`/etc
   - this never occurs if the `overwrite_lastlog=false` kwarg is passed fo `@info`/`@warn`/etc
   - otherwise, this occurs if it the log message is from the same source (e.g. it is in a loop)


 - Progress bars will be displayed
   - if the named argument `progress` is used it will be displayed as a progress bar
		- It should have a floating point value between 0 (0%) and 1 (100%) 
   - If *any* argument has a percentage string, eg `"51.3 %"`, it also will be displayed as a progress bar.
   - Progress bars use the same overwriting rules as above.
