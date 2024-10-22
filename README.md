# Take-home challenge

## Questions

1. is exception/exit from the script good enough to handle File.read errors?
1. is exception/exit from the script good enough to handle JSON.parse errors?
1. example_output.txt contains sometimes tabs, sometimes spaces at the beginning of lines. Should I just output spaces
   (or tabs) only or adhere exactly to the format given?
1. does output file only contain active users (the ones who received a top-up)?
1. what kind of other errors shpould the script take into acoount (e.g. data missing in fields? mismatched types). What
   should be the actual handling: is an exception okay or should there be a relevant error message?

## Assumptions

* users.json and companies.json are in the same directory as challenge.rb

## How to run

* script: `./challenge.rb` or `ruby challenge.rb`
* tests: `ruby challenge_test.rb`
