module Msg exposing (..)

import Api
import Editor.Main as Editor
import Browser.Main as Browser


type Msg
    = ApiRequest
    | ApiResponse Api.Msg
    | BrowserMsg Browser.Msg
    | EditorMsg Editor.Msg
    | CreateBookmark
