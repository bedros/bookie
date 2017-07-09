module Main exposing (..)

import Api
import Bookmark exposing (Bookmark, encoder)
import Browser.Main as Browser
import Debug exposing (log)
import Dict
import Editor.Main as Editor
import Html exposing (Html, div, program, button, text)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Json.Decode as JsonD
import Msg exposing (..)
import Result
import Search.Main as Search
import Style exposing (CssIds, CssClasses)


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
    , displayedBookmarks : Dict.Dict Int Bookmark
    , browser : Browser.Model
    , editor : Editor.Model
    , search : Search.Model
    }


init : ( Model, Cmd Msg )
init =
    ( Model (Dict.empty) (Dict.empty) Browser.init Editor.init Search.init
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
        SearchMsg sMsg ->
            let
                ( search, searchMsg, subCmd ) =
                    Search.update sMsg model.search model.bookmarks
            in
                case searchMsg of
                    Search.SearchResult results ->
                        { model
                            | search = search
                            , displayedBookmarks = bookmarksToDict results
                        }
                            ! [ subCmd ]
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

                            updatedBookmarks = updateBookmarks bookmark model.bookmarks
                        in
                            { model
                                | browser = browser
                                , editor = editor
                                , bookmarks = updatedBookmarks
                                , displayedBookmarks = updatedBookmarks
                            }
                                ! [ subCmd, Api.putBookmark ApiResponse (Bookmark.encoder bookmark) ]

                    Editor.EditorSaveNew bookmark ->
                        let
                            ( browser, browserMsg, subCmd ) =
                                Browser.update Browser.DeselectBookmark model.browser

                            updatedBookmarks = updateBookmarks bookmark model.bookmarks
                        in
                            { model
                                | browser = browser
                                , editor = editor
                                , bookmarks = updatedBookmarks
                                , displayedBookmarks = updatedBookmarks
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

                            updatedBookmarks = removeBookmark bookmark model.bookmarks
                        in
                            { model
                                | browser = browser
                                , editor = editor
                                , bookmarks = updatedBookmarks
                                , displayedBookmarks = updatedBookmarks
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
                            { model
                                | bookmarks = bookmarks
                                , displayedBookmarks = bookmarks
                            }
                                ! [ subCmd ]

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



----------
-- View --
----------


{ id, class, classList } =
    Html.CssHelpers.withNamespace "bookie"


view : Model -> Html Msg
view model =
    div [ id Style.App ]
        [ menu model
        , Browser.view model.browser model.displayedBookmarks |> Html.map Msg.BrowserMsg
        , Editor.view model.editor |> Html.map Msg.EditorMsg
        ]


menu : Model -> Html Msg
menu model =
    div
        [ class [ Style.Menu ] ]
        [ button
            [ onClick CreateBookmark
            , class [ Style.NewBookmarkButton ]
            ]
            [ text "new bookmark"
            ]
        , Search.view model.search |> Html.map Msg.SearchMsg
        ]
