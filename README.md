# Take-home challenge

## How to run

* script: `./challenge.rb` or `ruby challenge.rb` (also `ruby challenge.overengineered.rb` to run the more stuctured
  version
* tests: `for f in *_test.rb ; do ruby $f ; done` (clunky, but left it be, as in real project there would be a better
  infrastructure to run all tests)

Note: tested with Ruby 3.3.5.

## Notes on Assessment Criteria

### Functionality

My script generates exactly the same output as in example_output.txt.

For the data in companies.json and users.json there is one gotcha: the order of users with the same last name (e.g.
Boberson) in the same company is not guaranteed (due to how Enumerable#group_by works in Ruby) - I made sure it works
with the example, but even changing Ruby version might mess this up. The assignment specifies to order users by their
last name, but to be sure that the output always matches the example, we would need to secondary-sort by user's
first_name or id.

### Error Handling

"There could be bad data" is not enough to make reasonable assumptions about error handling. I provided a clean script
(challenge.rb) that leaves error handling to exceptions assuming that engineer running it will be able to debug the
problem.

I also provided a proof-of-concept (challenge.overengineered.rb) of one way to go about error handling if the
requirement was to list all problems with input data. Note that there is a lot of code duplication and no tests provided
for CompaniesValidator and UsersValidator. But there are also many other ways (to clarify before commiting to one
implementation) to go about input validation. For example, we could decide to fix some of data problems (e.g. convert
"tokens": "47.0" to an integer instead of complaining it isn't one). As for the code duplication, in an established
project there would be a better DSL to implement validations (e.g. ActiveModel::Validations or dry-validations).

### Reusability

Reusability is only as good as how many times the code needs to be read/modified. For example, unneeded one-off script
"beautyfication" can be a waste of time if the script is only needed this once - so refactoring code duplication may be
pointless.

For production-ready code, reusability comes not only from clean code, but also from being well-tested and
well-documented.

### Style

I used `standardrb` gem to style-fix this code.

### Adherence to convention

There are Ruby conventions (which I always try to adhere to), but there are also project, team, product conventions that
may override Ruby defaults. And even for Ruby, conventions may be subjective among developers. Feel free to ask me
about anything that stands out to you in my code - I hope I can explain!

### Documentation

My philosopy is to best document my code by choosing good names and using clear idiomatic Ruby constructs (e.g. I may
avoid Enumerable#inject because for non-Ruby devs - or even junior devs - it may not be quite clear how it works).
The second line of documentation are good tests.
Only after that I resort to comments (unlike tests, comments will not tell you they were made obsolete by code changes).
But I believe in well documented interfaces.

### Communication

Ask me anything! :)

### Tests

I'm a strong believer in tests. Naturally, one-off scripts or proof-of-concepts don't need to be rigorously tested, but
as soon as a piece of code becomes part of production release, the tests are a must. To illustrate my approch to testing
(in the limited scope of this assignment) I included tests for the main components of my solution: InputParser and
OutputFormatter (in the overengineered version).

### Github

I usually work with atomic commits and then squash them once merging to main. In this case, I left all my commits
unsquashed if you're interested in my implementation process.

### Overengineering

No, I don't usually spend 10 hours on what should be implemented in 1 or 2. My first solution (`challenge.rb`) was ready
in ~2 hours after I received the assignment (I sent it to Bianca with my questions). However, given this is an interview
test and I'm expected to show off my skills as best as I can, I spent well over 2 hours to implement an overengineered
version of it, with error handling, tests, structure (`challenge.overengineered.rb`). That said, I had to stop
somewhere. In an actual production-ready project I would have existing patterns to follow, better tools to implement
tests (e.g. rspec), better tools to validate (rails validations) and type-cast (active_record; dry-types) data. I would
also know that improving on solution should be iterative: there is rarely a point to make the first iteration "perfect"
(if that's even possible), but when iterating one learns which parts of the code are changed often enough to justify
cleaner refactoring.
