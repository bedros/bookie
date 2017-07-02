module Msg exposing (..)

import Api
import Editor
import Browser


type Msg
    = ApiRequest
    | ApiResponse Api.Msg
    | BrowserMsg Browser.Msg
    | EditorMsg Editor.Msg
