module Models exposing (..)

import Dict exposing (Dict)
import Bookmark exposing (Bookmark)


type Tags
    = Tags (Dict Int Tag)


type alias Tag =
    { id : Int
    , tag : String
    , bookmarks : Dict Int Bookmark
    }
