module Editor exposing (..)

import Bookmark exposing (Bookmark)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Maybe exposing (withDefault)


type alias Model =
    { bookmark : Maybe Bookmark
    }


type Msg
    = CreateBookmark
    | EditBookmark Bookmark
    | SaveBookmark
    | DiscardChanges
    | EditTitle String
    | EditUrl String
    | EditDescription String


type EditorMsg
    = EditorDiscardChanges
    | EditorSave Bookmark
    | EditorSaveNew Bookmark
    | NoOp


init : Model
init =
    Model Nothing



------------
-- Update --
------------


update : Msg -> Model -> ( Model, EditorMsg, Cmd msg )
update msg model =
    case msg of
        CreateBookmark ->
            ( { model | bookmark = Just Bookmark.empty }
            , NoOp
            , Cmd.none
            )

        DiscardChanges ->
            ( { model | bookmark = Nothing }
            , EditorDiscardChanges
            , Cmd.none
            )

        EditBookmark bookmark ->
            ( { model
                | bookmark =
                    Just
                        (Bookmark
                            bookmark.id
                            bookmark.title
                            bookmark.url
                            bookmark.description
                        )
              }
            , NoOp
            , Cmd.none
            )

        SaveBookmark ->
            let
                newModel =
                    { model | bookmark = Nothing }

                bookmarkOut =
                    (withDefault (Bookmark.empty) model.bookmark)
            in
                case model.bookmark of
                    Just bookmark ->
                        case bookmark.id of
                            (-1) ->
                                ( newModel
                                , EditorSaveNew bookmarkOut
                                , Cmd.none
                                )

                            _ ->
                                ( { model | bookmark = Nothing }
                                , EditorSave bookmarkOut
                                , Cmd.none
                                )

                    Nothing ->
                        ( model, NoOp, Cmd.none )

        EditTitle title ->
            let
                bookmark =
                    withDefault (Bookmark.empty) model.bookmark

                bookmarkUpdated =
                    { bookmark | title = title }
            in
                ( { model | bookmark = Just bookmarkUpdated }
                , NoOp
                , Cmd.none
                )

        EditUrl url ->
            let
                bookmark =
                    withDefault (Bookmark.empty) model.bookmark

                bookmarkUpdated =
                    { bookmark | url = url }
            in
                ( { model | bookmark = Just bookmarkUpdated }
                , NoOp
                , Cmd.none
                )

        EditDescription description ->
            let
                bookmark =
                    withDefault (Bookmark.empty) model.bookmark

                bookmarkUpdated =
                    { bookmark | description = Just description }
            in
                ( { model | bookmark = Just bookmarkUpdated }
                , NoOp
                , Cmd.none
                )



----------
-- View --
----------


view : Model -> Html Msg
view model =
    case model.bookmark of
        Just bookmark ->
            viewEditorForm bookmark

        Nothing ->
            div [ id "editor" ] []


viewEditorForm : Bookmark -> Html Msg
viewEditorForm bookmark =
    div
        [ id "editor"
        , onSubmit SaveBookmark
        ]
        [ input
            [ class "editor-form editor-form-title"
            , onInput EditTitle
            , defaultValue bookmark.title
            ]
            []
        , input
            [ class "editor-form editor-form-url"
            , onInput EditUrl
            , defaultValue bookmark.url
            ]
            []
        , input
            [ class "editor-form editor-form-description"
            , onInput EditDescription
            , defaultValue (withDefault "" bookmark.description)
            ]
            []
        , button
            [ class "editor-form editor-form-discard"
            , onClick DiscardChanges
            ]
            [ text "cancel" ]
        , button
            [ class "editor-form editor-form-save"
            , onClick SaveBookmark
            ]
            [ text "save" ]
        ]
