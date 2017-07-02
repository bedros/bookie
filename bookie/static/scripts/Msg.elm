module Msg exposing (..)

import Editor
import Http
import Json.Decode
import Browser


type Msg
    = ApiRequest
    | ApiResponse (Result Http.Error Json.Decode.Value)
    | BrowserMsg Browser.Msg
    | EditorMsg Editor.Msg
