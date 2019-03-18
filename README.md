Homebrew formulae for `troff(1)` and `man(1)`
=============================================

Whether you love man pages or the Troff typesetting system itself, you've come to the right place.

This is a “tap” for [Homebrew](https://brew.sh), the unofficial package manager for macOS.
We'll gauchely assume you know what we're talking about.
If not, see [`brew(1)`](https://docs.brew.sh/Manpage) or their [online documentation](https://brew.sh/) for more info on getting started.


Installing
----------

To grab hold of these formulae, run:

	brew tap alhadis/troff

Then install any of them at your leisure:

	brew install alhadis/troff/man-db
	brew install heirloom-doctools

**Note:** Some of these formulae are already available from Homebrew's core, but [require configuration](https://github.com/Homebrew/homebrew-core/issues/36981#issuecomment-464290531) before use.
This tap replaces them with DWIM equivalents, ones which require no `PATH`-fiddling after installation.
A complication of this is that `alhadis/troff/` must prefix the formula's name when installed.
Others can be installed normally (e.g., `heirloom-doctools` as illustrated above).


Available formulae
------------------
*	[`dformat`](https://github.com/sathlan/dformat)
	Awk-based preprocessor for data formats, taken from [CSTR #142](https://www.troff.org/papers.html).
*	[`man-db`](https://nongnu.org/man-db/):
	The implementation of `man(1)` widely used on Linux.
*	[`libpipeline`](http://libpipeline.nongnu.org/):
	C library for manipulating pipelines of subprocesses.
*	[`heirloom-doctools`](http://n-t-roff.github.io/heirloom/doctools.html):
	Modernised `troff` geared toward high-quality typesetting.
