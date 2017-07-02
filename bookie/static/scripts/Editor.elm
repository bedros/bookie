module Editor exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (Bookmark)
import Maybe exposing (withDefault)


type alias Model =
    { bookmark : Maybe Bookmark
    , bookmarkEditing : Maybe Bookmark
    }


type Msg
    = CreateBookmark
    | EditBookmark Bookmark
    | SaveBookmark
    | DiscardChanges
    | EditTitle String
    | EditUrl String
    | EditDescription String


init : Model
init =
    Model Nothing Nothing


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        EditBookmark bookmark ->
            ( { model
                | bookmarkEditing =
                    Just
                        ( Bookmark bookmark.title
                        , bookmark.url
                        , bookmark.description
                        )
              }
            , Cmd.none
            )

        CreateBookmark ->
            ( { model | bookmarkEditing = Just (Bookmark "" "" "") }, Cmd.none )

        SaveBookmark ->
            ( { model | bookmark = model.bookmarkEditing }, Cmd.none )

        EditTitle title ->
            let
                bookmarkEditing =
                    model.bookmarkEditing

                bookmarkEditing =
                    { bookmarkEditing | title = title }
            in
                ( { model | bookmarkEditing = bookmarkEditing }, Cmd.none )

        EditUrl url ->
            let
                bookmarkEditing =
                    model.bookmarkEditing

                bookmarkEditing =
                    { bookmarkEditing | url = url }
            in
                ( { model | bookmarkEditing = bookmarkEditing }, Cmd.none )

        EditDescription description ->
            let
                bookmarkEditing =
                    model.bookmarkEditing

                bookmarkEditing =
                    { bookmarkEditing | description = description }
            in
                ( { model | bookmarkEditing = bookmarkEditing }, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    case model.selectedBookmark of
        Just bookmark ->
            viewEditorForm bookmark

        Nothing ->
            div [ id "editor" ] []


viewEditorForm : Bookmark -> Html Msg
viewEditorForm bookmark =
    div
        [ id "editor" ]
        [ input
            [ class "editor-form editor-form-title"
            , defaultValue bookmark.title
            ]
            []
        , input
            [ class "editor-form editor-form-url"
            , defaultValue bookmark.url
            ]
            []
        , input
            [ class "editor-form editor-form-description"
            , defaultValue (withDefault "" bookmark.description)
            ]
            []
        ]
