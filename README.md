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
*	[`awf`](http://doc.cat-v.org/henry_spencer/awf/):
	The Amazingly Workable Formatter, a partial `nroff(1)` clone written in Awk.
*	[`chem`](https://netlib.org/typesetting/):
	Historic version of `chem(1)`, a preprocessor for chemical diagrams.
*	[`deroff`](http://www.moria.de/~michael/deroff/):
	Enhanced version of the traditional `deroff(1)` utility used to remove Roff markup.
*	[`dformat`](https://github.com/sathlan/dformat):
	Awk-based preprocessor for data formats, taken from [CSTR #142](https://www.troff.org/papers.html).
*	[`dpic`](https://gitlab.com/aplevich/dpic):
	Reimplementation of `gpic(1)` targeting LaTeX and web-based formats.
*	[`heirloom-doctools`](http://n-t-roff.github.io/heirloom/doctools.html):
	Modernised `troff` geared toward high-quality typesetting.
*	[`man-db`](https://man-db.gitlab.io/man-db/):
	The implementation of `man(1)` widely used on Linux.
*	[`neatroff`](http://litcave.rudi.ir/):
	Modern reimplementation of Troff with Unicode and bidirectional text support.
*	[`pikchr`](https://pikchr.org/home):
	Web-friendly PIC interpreter optimised for SVG output.
*	[`sqlrpt`](https://github.com/jklowden/sqlrpt):
	Preprocessor for `tbl(1)` that generates tables from [SQLite](https://www.sqlite.org/lang.html) queries.
*	[`teqn`](https://github.com/mahdiElliot/teqn):
	Convert TeX equations to [Neateqn](https://github.com/aligrudi/neateqn) preprocessor markup.
