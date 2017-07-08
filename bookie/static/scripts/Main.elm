module Main exposing (..)

import Bookmark exposing (Bookmark, encoder)
import Editor
import Browser
import Dict
import Html exposing (Html, div, program, button, text)
import Html.Attributes exposing (id)
import Html.Events exposing (onClick)
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
    , editor : Editor.Model
    }


init : ( Model, Cmd Msg )
init =
    ( Model (Dict.empty) Browser.init Editor.init
    , Api.getBookmarks ApiResponse
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



------------
-- Update --
------------


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        BrowserMsg bMsg ->
            let
                ( browser, browserMsg, subCmd ) =
                    Browser.update bMsg model.browser

                maybeBookmark =
                    case browserMsg of
                        Browser.BrowserSelection maybeBookmark ->
                            maybeBookmark

                editor =
                    model.editor
            in
                { model
                    | browser = browser
                    , editor = { editor | bookmark = maybeBookmark }
                }
                    ! [ subCmd ]

        CreateBookmark ->
            let
                ( editor, editorMsg, subCmd ) =
                    Editor.update Editor.CreateBookmark model.editor
            in
                { model | editor = editor } ! [ subCmd ]

        EditorMsg eMsg ->
            let
                ( editor, editorMsg, subCmd ) =
                    Editor.update eMsg model.editor
            in
                case editorMsg of
                    Editor.EditorSave bookmark ->
                        let
                            ( browser, browserMsg, subCmd ) =
                                Browser.update Browser.DeselectBookmark model.browser
                        in
                            { model
                                | browser = browser
                                , editor = editor
                                , bookmarks = updateBookmarks bookmark model.bookmarks
                            }
                                ! [ subCmd, Api.putBookmark ApiResponse (Bookmark.encoder bookmark) ]

                    Editor.EditorSaveNew bookmark ->
                        let
                            ( browser, browserMsg, subCmd ) =
                                Browser.update Browser.DeselectBookmark model.browser
                        in
                            { model
                                | browser = browser
                                , editor = editor
                                , bookmarks = updateBookmarks bookmark model.bookmarks
                            }
                                ! [ subCmd, Api.postBookmark ApiResponse (Bookmark.encoder bookmark) ]

                    Editor.EditorDiscardChanges ->
                        let
                            ( browser, browserMsg, subCmd ) =
                                Browser.update Browser.DeselectBookmark model.browser
                        in
                            { model
                                | editor = editor
                                , browser = browser
                            }
                                ! [ subCmd ]

                    Editor.EditorDeleteBookmark bookmark ->
                        let
                            ( browser, browserMsg, subCmd ) =
                                Browser.update Browser.DeselectBookmark model.browser
                        in
                            { model
                                | browser = browser
                                , editor = editor
                                , bookmarks = removeBookmark bookmark model.bookmarks
                            }
                                ! [ subCmd, Api.deleteBookmark ApiResponse (Bookmark.encoder bookmark) ]

                    _ ->
                        { model | editor = editor } ! [ subCmd ]

        ApiRequest ->
            ( model, Api.getBookmarks ApiResponse )

        ApiResponse response ->
            let
                ( apiMsg, subCmd ) =
                    Api.update response
            in
                case apiMsg of
                    Api.ApiConfirmation data ->
                        let
                            _ =
                                log "API confirmation" data
                        in
                            model ! [ Cmd.none ]

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
                        in
                            { model | bookmarks = bookmarks } ! [ subCmd ]

                    Api.ApiError error ->
                        let
                            _ =
                                log "ApiError" error
                        in
                            ( model, Cmd.none )

                    Api.ApiNetworkError errorString ->
                        let
                            _ =
                                log "ResponseError" errorString
                        in
                            ( model, Cmd.none )



----------
-- View --
----------


view : Model -> Html Msg
view model =
    div []
        [ menubar
        , Browser.view model.browser model.bookmarks |> Html.map Msg.BrowserMsg
        , Editor.view model.editor |> Html.map Msg.EditorMsg
        ]


menubar : Html Msg
menubar =
    div
        [ id "menu-bar" ]
        [ button [ onClick CreateBookmark ] [ text "new bookmark" ] ]



-----------
-- Utils --
-----------


removeBookmark : Bookmark -> Dict.Dict Int Bookmark -> Dict.Dict Int Bookmark
removeBookmark bookmark bookmarks =
    Dict.remove bookmark.id bookmarks


updateBookmarks : Bookmark -> Dict.Dict Int Bookmark -> Dict.Dict Int Bookmark
updateBookmarks bookmark bookmarks =
    Dict.insert bookmark.id bookmark bookmarks


bookmarksToDict : List Bookmark -> Dict.Dict Int Bookmark
bookmarksToDict bookmarks =
    listIntoDict Dict.empty bookmarks


listIntoDict : Dict.Dict Int Bookmark -> List Bookmark -> Dict.Dict Int Bookmark
listIntoDict dict bookmarks =
    case bookmarks of
        bookmark :: rest ->
            listIntoDict (insertBookmark dict bookmark) rest

        [] ->
            dict


insertBookmark : Dict.Dict Int Bookmark -> Bookmark -> Dict.Dict Int Bookmark
insertBookmark bookmarks bookmark =
    Dict.insert bookmark.id bookmark bookmarks
