# Timetree

Timetree is a command line utility that prints a tree-like breakdown of time spent on activities based on a simple, human readable time logging language stored in plain text files.

## Installation

    $ gem install time_tree

## Time Log Format

Each day's log should start with a date in YYYY/MM/DD format. Any text following is ignored as comments. Following this are lines starting with a time in 24 hour format - HHMI, followed by an activity which must contain no spaces, any text following is ignored and considered as comments. Activities may have nested subcategories to any level separated by forward slashes - these will be printed as a hierarchy by timetree. Use a dash (-) for the activity to be ignored and not reported on - this means a day's log must always end with a time followed by a dash to denote when the previous line's activity finished.

Blank lines are ignored and lines starting with # are ignored as comments.

Here's an example:

    2013/04/21 A splendid day!
    
    0930 admin some comments
    0945 development/project1 some more comments
    1005 -
    1030 developemnt/project2
    1115 -
    
    # Did some work in the evening!
    2230 bugfixing/project3  # Use a hash after a time line if you want but not needed
    2315 -


A day's log can't span across more than one file, but a file may contain multiple day's logs. This gives flexibility, all time may be stored in one big file or there may be multiple files, one for each day or week for example. Multiple files may be stored in a nested folder hierarchy - time tree will recursively search for files, ignoring those starting with . (dot).

## Usage

    $ timetree [options] [path]

### Options

Reports on the given date or period. Weeks are deemed to start on Monday.

  * *--all*, *-a* - include all dates recorded
  * *--today*, *-t* - this is the assumed default
  * *--yesterday*, *-y*
  * *--week [weeks-previous]*, *-w* - the current week so far. To report on previous weeks use the optional *weeks-previous* argument, 0 (the assumed default) would mean the current week, 1 would mean last week, 2 would mean the week previous to that and so on.
  * *--month [months-previous]*, *-m* - the current calendar month so far. The optional *months-revious* argument works in a similar way to *--week weeks-previous*
  * *--date YYYY/MM/DD*, *-d*
  * *--between YYYY/MM/DD:YYYY/MM/DD*, *-b* - reports on the given inclusive range of dates
  * *--filter search-string[,search-string]*, *-f* - only reports on activities matching *search-string*

If given no path, Timetree will look in the users's home directory for a file or directory called *Time*, *time* or *.time*.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
