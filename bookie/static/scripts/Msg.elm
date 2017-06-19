module Msg exposing (..)

import Http
import Json.Decode


type Msg
    = ApiRequest
    | ApiResponse (Result Http.Error Json.Decode.Value)
