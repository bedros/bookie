module Models exposing (..)

import Json.Decode as JsonD


type alias Model =
    { bookmarks : List Bookmark
    , selectedBookmark : Maybe Bookmark
    , data : String
    }


type Bookmarks
    = Bookmarks (List Bookmark)


type alias Bookmark =
    { id : Int
    , title : String
    , url : String
    , description : Maybe String

    --    , tags : Tags
    }


type Tags
    = Tags (List Tag)


type alias Tag =
    { id : Int
    , tag : String
    , bookmarks : Bookmarks
    }


bookmarkDecoder : JsonD.Decoder Bookmark
bookmarkDecoder =
    JsonD.map4
        Bookmark
        (JsonD.field "id" JsonD.int)
        (JsonD.field "title" JsonD.string)
        (JsonD.field "url" JsonD.string)
        (JsonD.field "description" (JsonD.nullable JsonD.string))
