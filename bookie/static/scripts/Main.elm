module Main exposing (..)

import Models exposing (..)
import Msg exposing (..)
import Html exposing (Html, div, program)
import Api
import Debug exposing (log)
import Json.Decode as JsonD
import Result
import View


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
        SelectBookmark bookmark ->
            ( { model | selectedBookmark = Just bookmark }, Cmd.none )

        ApiRequest ->
            ( model, Api.getBookmarks )

        ApiResponse response ->
            case Api.update (ApiResponse response) of
                Api.ApiData data ->
                    let
                        bookmarks =
                                case (JsonD.decodeValue (JsonD.list bookmarkDecoder) data.data) of
                                    Ok bookmarks ->
                                        bookmarks

                                    Err error ->
                                        let
                                            _ =
                                                log "Error decoding list of bookmarks" error
                                        in
                                            []

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
                        ( model , Cmd.none )

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
        [ View.bookmarkTableView model.bookmarks
        , View.bookmarkEditorView model.selectedBookmark
        ]
