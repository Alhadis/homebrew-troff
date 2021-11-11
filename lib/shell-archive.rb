# Class(es) for interacting with shar(1) bundles.
module ShellArchive
	include FileUtils

	# Strategy for downloading and unpacking a shell-archive.
	#
	# @api public
	class Downloader < NoUnzipCurlDownloadStrategy
		attr_accessor :mtime
		def stage
			# Unpack bundle by executing it like a shell-script
			chmod 0755, cached_location
			output = IO.popen ["sh", cached_location, :err => [:child, :out]], &:read
			raise unless $?.success?
			puts output if verbose?
			
			# Fix modification dates of unpacked files
			@mtime = File.stat(cached_location).mtime
			now    = Time.now
			files  = Dir["**/*"].reject { |x| File.stat(x).mtime - 1000 >= now }
			FileUtils.touch files, mtime: @mtime, nocreate: true
			yield if block_given?
		end
	end
end
