Web Parser for lontar.cs.ui.ac.id
===============

For easy viewing bachelor thesis list (aka. Skripsi in Bahasa Indonesia).

## Why I Am Doing This?

Because..

- lontar doesn't show full list of skripsi. Instead it use pagination.
- It has search, but i can't categorize skripsi by year.
- It doesn't have API

So i make a web parser. It parse the web page and convert it into human readable and filterable output.

## Result Table / Output

We have 4 output formats. Choose that suit for you:

- Markdown. This format is suitable for human viewing and very readable. I have sort it and categorize in by year.
- TSV. This is actually a CSV-like format, but use tab (`\t`) as separator. This is done due to some title which use comma. The benefit is instant search (when viewed from Github Desktop Web).
- JSON. If you want your own data, just grab this format.

## Updating and Installation

For some reason in the future, i might forget to update the output. To update, simply:

1. Install Ruby
1. Clone this repositories, and `cd` into it.

    git clone https://github.com/mufid/lontarcs-parser   # Do you know you can omit .git in Github remote?
    cd lontarcs-parser

1. Install the dependencies

    bundle install

1. Run the ruby script

    ruby lontar-cs-sc.rb

1. See the result in `out.*` files.

