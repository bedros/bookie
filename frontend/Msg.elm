module Msg exposing (..)

import Api
import Editor.Main as Editor
import Browser.Main as Browser
import Search.Main as Search


type Msg
    = ApiRequest
    | ApiResponse Api.Msg
    | BrowserMsg Browser.Msg
    | EditorMsg Editor.Msg
    | CreateBookmark
    | SearchMsg Search.Msg
    | ShowInfoDialog Bool
