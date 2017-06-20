module Msg exposing (..)

import Http
import Json.Decode
import Models exposing (Bookmark)


type Msg
    = ApiRequest
    | ApiResponse (Result Http.Error Json.Decode.Value)
    | SelectBookmark Bookmark
