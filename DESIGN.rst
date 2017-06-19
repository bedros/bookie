======
Bookie
======

-------------------------
Personal Bookmark manager
-------------------------

Features
--------
1. Add url, title, details and tags
    1.1. Auto retrieve title

2. View bookmarks
    2.1. Search by tag, title, url

    2.2. Sort by tag, title, url

-------------------------------------------------------------------------------

Icebox
------
1. Cache pages locally
2. Fuzzy search of page caches

-------------------------------------------------------------------------------

Details
-------

Features
========

1. Add url, title, details and tags
###################################

  - Data transfer object:
    ::

      {
        "title": string,
        "auto-retrieve-title": bool,
        "description": string,
        "tags": [string,],
        "cache": bool
      }

1.1. Auto retrieve title
########################

  - Server side using `curl`.

2. View bookmarks
#################

  - Retrieve arrays of length BOOKMARKS_PER_PAGE.
  - Upon a request for a next page of bookmarks, remove all bookmark nodes,
    display a loading icon, and then render next page of bookmarks once loading
    is request is complete.

  - Data transfer object:
    ::

      {
        [
          {
            "id",
            "title",
            "description",
            "tags"
          },
        ]
      }

2.1. Search by tag, title, url
##############################

  - Server side
  - Client side

2.2. Sort by tag, title, url
############################

  - Handle client side

-------------------------------------------------------------------------------

Appendix
--------

Symbols and Values
==================

+--------------------+-------+
| Symbol             | Value |
+====================+=======+
| BOOKMARKS_PER_PAGE | 100   |
+--------------------+-------+
