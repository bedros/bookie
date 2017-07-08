module Bookmark exposing (Bookmark, empty, decoder, encoder)

import Json.Decode as JsonD
import Json.Encode as JsonE
import Maybe exposing (withDefault)


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


encoder : Bookmark -> JsonE.Value
encoder bookmark =
    JsonE.object
        [ ( "id_", JsonE.int bookmark.id )
        , ( "title", JsonE.string bookmark.title )
        , ( "url", JsonE.string bookmark.url )
        , ( "description", JsonE.string (withDefault "" bookmark.description) )
        ]
