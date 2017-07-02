module Bookmark exposing (Bookmark, empty, decoder)

import Json.Decode as JsonD


type alias Bookmark =
    { id : Int
    , title : String
    , url : String
    , description : Maybe String
    }


empty : Bookmark
empty =
    Bookmark -1 "" "" Nothing


decoder : JsonD.Decoder Bookmark
decoder =
    JsonD.map4
        Bookmark
        (JsonD.field "id" JsonD.int)
        (JsonD.field "title" JsonD.string)
        (JsonD.field "url" JsonD.string)
        (JsonD.field "description" (JsonD.nullable JsonD.string))
