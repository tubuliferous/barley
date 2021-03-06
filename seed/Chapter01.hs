-- This is a file of Haskell code. Don't worry about trying to understand all
-- the details of how it works, or the syntax for now. Just follow along and
-- try stuff. You can always get to the original, pristine version of this file
-- with the links at the left.

-- Frist thing to know is that these are comments. Everything after two dashes
-- and a space to the end of the line is a comment. In these tutorials you should
-- read the comments, because that is where we guide you through.

module Chapter01 where
-- The line above just declares the name of this module, which keeps all the
-- names of things defined here separate from things named in other files which
-- are their own modules. This module is named Step01.

import Text.Html
-- This line imports all the names defined in the Text.Html module locally so
-- that code in this file can use them. Text.Html defines functions that let us
-- build up HTML pages.

--
-- *** LOOK HERE ***
--
-- The code below defines a value called "page". It is what will be retuned when
-- the browser fetches Step01 as a web page.

page = thehtml <<
    [ header << (thetitle << "Step 1")
    , body <<
        [ h1 << "Your First Haskell Page"
        , paragraph << "Look, it worked!"
        , paragraph << "Now go play with the source."
        ]
    ]

--
-- *** TRY THIS ***
--
-- Try editing some string inside double quotes and save it. See what it does.
-- Try adding another paragraph. Just duplicate one of those lines and try it.
-- Add some other common block elements: Try h2 or pre.

-- You can define sections of your own, and add them the same way, such as:

footnote = paragraph << (small << "You are getting sleepy.")

