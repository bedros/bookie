module Main exposing (..)

import Api
import Bookmark exposing (Bookmark, encoder)
import Browser.Main as Browser
import Constants
import Debug exposing (log)
import Dict
import Editor.Main as Editor
import Html exposing (a, Html, div, program, button, text)
import Html.Attributes exposing (href)
import Html.CssHelpers
import Html.Events exposing (onClick, onMouseEnter, onMouseLeave)
import Json.Decode as JsonD
import Msg exposing (..)
import Result
import Search.Main as Search
import Style exposing (CssIds, CssClasses)
import Maybe exposing (withDefault)


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
    , showInfoDialog : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( Model (Dict.empty) (Dict.empty) Browser.init Editor.init Search.init False
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
        ApiRequest ->
            ( model, Api.getBookmarks ApiResponse )

        ApiResponse response ->
            let
                ( apiMsg, subCmd ) =
                    Api.update response
            in
                case apiMsg of
                    Api.ApiBookmarkConfirmation data ->
                        case data.type_ of
                            "bookmarks insert confirmation" ->
                                let
                                    id =
                                        case JsonD.decodeValue Bookmark.decodeId data.data of
                                            Ok id_ ->
                                                id_

                                            Err error ->
                                                let
                                                    _ =
                                                        log "Error decoding id of new bookmark" error
                                                in
                                                    Dict.keys model.bookmarks
                                                        |> List.maximum
                                                        |> withDefault (Constants.default_id - 1)
                                                        |> (+) 1

                                    bookmarks =
                                        setNewBookmarkId id model.bookmarks
                                in
                                    { model
                                        | bookmarks = bookmarks
                                        , displayedBookmarks = bookmarks
                                    }
                                        ! [ Cmd.none ]

                            _ ->
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

        BrowserMsg bMsg ->
            let
                ( browser, browserMsg, subCmd ) =
                    Browser.update bMsg model.browser
            in
                case browserMsg of
                    Browser.BrowserSelection maybeBookmark ->
                        let
                            editor =
                                model.editor
                        in
                            { model
                                | browser = browser
                                , editor = { editor | bookmark = maybeBookmark }
                            }
                                ! [ subCmd ]

                    Browser.NoOp ->
                        { model | browser = browser } ! [ subCmd ]

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

                            updatedBookmarks =
                                updateBookmarks bookmark model.bookmarks
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

                            updatedBookmarks =
                                updateBookmarks bookmark model.bookmarks
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

                            updatedBookmarks =
                                removeBookmark bookmark model.bookmarks
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

        ShowInfoDialog state ->
            { model | showInfoDialog = state } ! []



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


setNewBookmarkId : Int -> Dict.Dict Int Bookmark -> Dict.Dict Int Bookmark
setNewBookmarkId id bookmarks =
    let
        bookmark =
            withDefault (Bookmark.empty) (Dict.get Constants.default_id bookmarks)

        bookmarkUpdated =
            { bookmark | id = id }
    in
        Dict.insert id bookmarkUpdated bookmarks
            |> Dict.remove Constants.default_id



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
        , footer
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
        , button
            [ onMouseEnter (ShowInfoDialog True)
            , onMouseLeave (ShowInfoDialog False)
            , class [ Style.InfoDialogButton ]
            ]
            [ text "?"
            ]
        , infoDialog model.showInfoDialog
        , div
            [ class [ Style.Brand ] ]
            [ div
                [ class [ Style.BrandTitle ] ]
                [ text "bookie" ]
            , text " | "
            , div
                [ class [ Style.BrandTagline ] ]
                [ text "fast. simple. bookmarks." ]
            ]
        , Search.view model.search |> Html.map Msg.SearchMsg
        ]


infoDialog : Bool -> Html Msg
infoDialog display =
    let
        style =
            [ Style.InfoDialog ]

        styles =
            case display of
                False ->
                    Style.Hidden :: style

                True ->
                    style
    in
        div
            [ class styles ]
            [ div
                [ class [ Style.InfoDialogHelp ] ]
                [ div
                    [ class [ Style.InfoDialogHelpTitle ] ]
                    [ text "Help" ]
                , text
                    ("The interface is fairly intuitive, but the only thing "
                        ++ "that might not be obvious is that you need to DOUBLE CLICK "
                        ++ "the delete button for it to work."
                    )
                ]
            , div
                [ class [ Style.InfoDialogOther ] ]
                [ text
                    ("bookie is a simple and efficient bookmark manager. Its "
                        ++ "primary goals are speed and simplicity."
                    )
                , text
                    ("It's still in the early stages of development (it's a toy project really -- "
                        ++ "to 'git gud' with Elm, Python and full stack development in general). "
                        ++ "The code can be found at github (link at the bottom). If you have any suggestions "
                        ++ "or have found a bug, please create an issue with a detailed description."
                    )
                ]
            ]


footer : Html Msg
footer =
    div
        [ class [ Style.Footer ] ]
        [ div [] [ text "work in progress" ]
        , div [] [ text "|" ]
        , a
            [ href "https://github.com/francium/bookie" ]
            [ text "see on github" ]
        ]
