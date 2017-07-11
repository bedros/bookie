module Bookmark
    exposing
        ( Bookmark
        , empty
        , decoder
        , decodeId
        , decodeTitle
        , decodeUrl
        , decodeDescription
        , encoder
        )

import Constants
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
    Bookmark Constants.default_id "" "" Nothing


decoder : JsonD.Decoder Bookmark
decoder =
    JsonD.map4
        Bookmark
        decodeId
        decodeTitle
        decodeUrl
        decodeDescription


decodeId : JsonD.Decoder Int
decodeId =
    JsonD.field "id" JsonD.int


decodeTitle : JsonD.Decoder String
decodeTitle =
    JsonD.field "title" JsonD.string


decodeUrl : JsonD.Decoder String
decodeUrl =
    JsonD.field "url" JsonD.string


decodeDescription : JsonD.Decoder (Maybe String)
decodeDescription =
    JsonD.field "description" (JsonD.nullable JsonD.string)


encoder : Bookmark -> JsonE.Value
encoder bookmark =
    JsonE.object
        [ ( "id_", JsonE.int bookmark.id )
        , ( "title", JsonE.string bookmark.title )
        , ( "url", JsonE.string bookmark.url )
        , ( "description", JsonE.string (withDefault "" bookmark.description) )
        ]
