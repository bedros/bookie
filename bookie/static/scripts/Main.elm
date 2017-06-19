module Main exposing (..)

import Models exposing (..)
import Msg exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
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


init : ( Model, Cmd Msg )
init =
    ( Model [] Nothing "", Api.getBookmarks )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ApiRequest ->
            ( model, Api.getBookmarks )

        ApiResponse response ->
            case Api.update (ApiResponse response) of
                Api.ApiData data ->
                    let
                        bookmarks = Result.withDefault
                            []
                            (JsonD.decodeValue (JsonD.list bookmarkDecoder) data.data)
                        _ = log "Bookmarks" bookmarks
                        _ = log "Data.data" data.data
                    in
                        ( { model | bookmarks = bookmarks, data = (toString data) }, Cmd.none )

                Api.ApiError data ->
                    ( { model | data = (toString data) }, Cmd.none )

                Api.ResponseError error ->
                    let
                        _ =
                            log "Error:" error
                    in
                        ( model, Cmd.none )

                _ ->
                    ( model, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ bookmarkTableView model.bookmarks
        ]


bookmarkTableView : List Bookmark -> Html Msg
bookmarkTableView  bookmarks =
    ul
        []
        ( bookmarkTableHeadersView
            :: (List.map bookmarkTableRowView bookmarks)
        )


bookmarkTableHeadersView : Html Msg
bookmarkTableHeadersView =
    li
        []
        [ bookmarkTableEntryView "entry-header entry-title" (text "Title")
        , bookmarkTableEntryView "entry-header entry-url" (text "Url")
        , bookmarkTableEntryView "entry-header entry-description" (text "Description")
        ]

bookmarkTableRowView : Bookmark -> Html Msg
bookmarkTableRowView bookmark =
    li
        []
        [ bookmarkTableEntryView "entry-title" (text bookmark.title)
        , bookmarkTableEntryView "entry-url" (text bookmark.url)
        , bookmarkTableEntryView "entry-description" (text bookmark.description)
        ]


bookmarkTableEntryView : String -> Html Msg -> Html Msg
bookmarkTableEntryView class_ view_ =
    div [class class_] [ view_ ]
