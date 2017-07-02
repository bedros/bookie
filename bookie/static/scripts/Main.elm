module Main exposing (..)

import Bookmark exposing (Bookmark)
import Browser
import Dict
import Html exposing (Html, div, program)
import Msg exposing (..)
import Api
import Debug exposing (log)
import Json.Decode as JsonD
import Result


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Model =
    { bookmarks : Dict.Dict Int Bookmark
    , browser : Browser.Model
--    , editor : Editor.Model
    }


init : ( Model, Cmd Msg )
init =
    ( Model (Dict.empty) Browser.init {-Editor.init-}
    , Api.getBookmarks
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BrowserMsg bMsg ->
            let
                ( browser, browserMsg, subCmd ) =
                    Browser.update bMsg model.browser
            in
                { model | browser = browser } ! [ subCmd ]

--        EditorMsg eMsg ->
--            let
--                ( editor, subCmd ) =
--                    Editor.update model.browser eMsg
--            in
--                { model | editor = editor } ! [ subCmd ]

        ApiRequest ->
            ( model, Api.getBookmarks )

        ApiResponse response ->
            case Api.update (ApiResponse response) of
                Api.ApiData data ->
                    let
                        bookmarks =
                            case (JsonD.decodeValue (JsonD.list Bookmark.decoder) data.data) of
                                Ok bookmarks ->
                                    bookmarksToDict bookmarks

                                Err error ->
                                    let
                                        _ =
                                            log "Error decoding list of bookmarks" error
                                    in
                                        bookmarksToDict []

                        _ =
                            log "Data.data" data.data

                        _ =
                            log "Bookmarks" bookmarks
                    in
                        ( { model | bookmarks = bookmarks }, Cmd.none )

                Api.ApiError data ->
                    let
                        _ =
                            log "ApiError" data
                    in
                        ( model, Cmd.none )

                Api.ResponseError error ->
                    let
                        _ =
                            log "ResponseError" error
                    in
                        ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ Browser.view model.browser model.bookmarks |> Html.map Msg.BrowserMsg
--        , Editor.view model.editor
        ]


bookmarksToDict: List Bookmark -> Dict.Dict Int Bookmark
bookmarksToDict bookmarks =
    listIntoDict Dict.empty bookmarks


listIntoDict : Dict.Dict Int Bookmark -> List Bookmark -> Dict.Dict Int Bookmark
listIntoDict dict bookmarks =
    case bookmarks of
        bookmark::rest ->
            listIntoDict (insertBookmark dict bookmark) rest

        [] ->
            dict


insertBookmark : Dict.Dict Int Bookmark -> Bookmark -> Dict.Dict Int Bookmark
insertBookmark bookmarks bookmark =
    Dict.insert bookmark.id bookmark bookmarks
